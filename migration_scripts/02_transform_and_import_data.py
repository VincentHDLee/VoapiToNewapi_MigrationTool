import pandas as pd
from sqlalchemy import create_engine, text
import os
import logging
from dotenv import load_dotenv

# --- 配置信息 ---
# 日志配置
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 从 config/target.env 文件加载环境变量
load_dotenv(dotenv_path='config/target.env')

# 从环境变量中获取 NewAPI 数据库连接信息
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT')
DB_NAME = os.getenv('DB_NAME')

DB_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"

# CSV 文件所在目录
INPUT_DIR = 'exported_data'

def transform_users(df):
    """根据 FIELD_MAPPING.md 对 users DataFrame 进行转换。"""
    logging.info("正在转换 'users' 数据...")
    # 舍弃字段
    columns_to_drop = [
        'password', 'github_id', 'github_info', 'linuxdo_id_level', 
        'last_clock_in', 'register_ip', 'last_login_ip', 'created_at'
    ]
    df = df.drop(columns=[col for col in columns_to_drop if col in df.columns])

    # 字段重命名
    rename_map = {
        'aff_history_quota': 'aff_history',
        'linuxdo_id': 'linux_do_id'
    }
    df = df.rename(columns=rename_map)

    # 为 password 添加临时占位符
    df['password'] = 'PLEASE_RESET_PASSWORD'
    logging.info("'users' 数据转换完成。")
    return df

def transform_tokens(df):
    """根据 FIELD_MAPPING.md 对 tokens DataFrame 进行转换。"""
    logging.info("正在转换 'tokens' 数据...")
    # 目前不需要对 tokens 表进行特殊转换，但保留此函数以便未来扩展。
    logging.info("'tokens' 数据转换完成。")
    return df

def transform_logs(df, engine):
    """根据 FIELD_MAPPING.md 对 logs DataFrame 进行转换。"""
    logging.info("正在转换 'logs' 数据...")
    # 字段重命名
    df = df.rename(columns={'channel': 'channel_id'})
    
    # 舍弃字段
    if 'root_content' in df.columns:
        df = df.drop(columns=['root_content'])
        
    # 引用与融合：填充 channel_name 和 group
    # 为避免大数据量查询时的性能问题，这里先获取一个映射字典
    logging.info("正在创建 channel_id -> channel_name 的映射...")
    channels_map = pd.read_sql("SELECT id, name FROM channels", engine).set_index('id')['name'].to_dict()
    
    logging.info("正在创建 user_id -> group 的映射...")
    users_map = pd.read_sql("SELECT id, `group` FROM users", engine).set_index('id')['group'].to_dict()

    logging.info("正在填充 'channel_name' 和 'group'...")
    df['channel_name'] = df['channel_id'].map(channels_map)
    df['group'] = df['user_id'].map(users_map)

    # 处理 ip 字段长度问题
    df['ip'] = df['ip'].str[:191]

    logging.info("'logs' 数据转换完成。")
    return df

# 安全的系统配置项白名单
# 经过测试，About, Notice, Footer, HomePageContent, SiteName 等配置项在新版中存在显示问题，故放弃迁移。
SAFE_OPTIONS = [
    'Logo', 'ModelRatio', 'GroupRatio', 'TopUpLink', 'ChatLink', 'QuotaPerUnit', 'DisplayInCurrency'
]

def transform_and_import_options(connection):
    """选择性地导入系统配置 (options)，只更新白名单内的安全配置。"""
    file_path = os.path.join(INPUT_DIR, 'options.csv')
    if not os.path.exists(file_path):
        logging.warning(f"文件 {file_path} 不存在，跳过 options 导入。")
        return

    logging.info("--- 开始选择性导入 options ---")
    df = pd.read_csv(file_path)
    
    # 筛选出在白名单内的配置
    safe_df = df[df['key'].isin(SAFE_OPTIONS)]
    
    if safe_df.empty:
        logging.info("在 options.csv 中没有找到需要迁移的安全配置项。")
        return

    try:
        with connection.cursor() as cursor:
            for index, row in safe_df.iterrows():
                key = row['key']
                value = row['value']
                # 使用 INSERT ... ON DUPLICATE KEY UPDATE 实现插入或更新
                sql = "INSERT INTO `options` (`key`, `value`) VALUES (%s, %s) ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)"
                cursor.execute(sql, (key, value))
                logging.info(f"已更新配置: {key}")
        connection.commit()
        logging.info(f"成功更新 {len(safe_df)} 条安全配置项。")
    except Exception as e:
        logging.error(f"更新 options 时发生错误: {e}")
        connection.rollback()


def update_root_password(connection):
    """
    Update the password for the 'root' user.
    The hash is pre-calculated for the password '123456'.
    """
    # Pre-calculated bcrypt hash for '123456'
    hashed_password = '$2a$10$9FboeVHlcqmW7rZ83kBVEumDsXpvZMxCXg1wyB5sPLW8pVmscaSyi'
    
    try:
        with connection.cursor() as cursor:
            # Update the password for the user with username 'root'
            sql = "UPDATE `users` SET `password` = %s WHERE `username` = 'root'"
            cursor.execute(sql, (hashed_password,))
        connection.commit()
        print("Successfully updated root's password.")
    except Exception as e:
        print(f"An error occurred while updating root's password: {e}")
        connection.rollback()

def import_data(engine):
    """读取、转换并覆盖导入所有数据。"""
    
    # 待处理的表，顺序很重要，先父表后子表
    tables_to_process = [
        ('users', transform_users),
        ('tokens', transform_tokens),
        ('top_ups', None),
        ('quota_data', None),
        ('channels', None),
        ('abilities', None),
        ('logs', transform_logs),
        ('redemptions', None),
    ]

    with engine.begin() as connection:  # 使用事务确保原子性
        # 反向清空表，以处理外键约束
        logging.info("--- 开始清空目标数据库表 ---")
        for table_name, _ in reversed(tables_to_process):
            logging.info(f"正在清空表: {table_name}")
            connection.execute(text(f"TRUNCATE TABLE `{table_name}`"))
        logging.info("--- 目标数据库表已清空 ---")

        # 按顺序导入数据
        for table_name, transform_func in tables_to_process:
            file_name = f"{table_name}.csv"
            file_path = os.path.join(INPUT_DIR, file_name)

            if not os.path.exists(file_path):
                logging.warning(f"文件 {file_path} 不存在，跳过。")
                continue
            
            logging.info(f"--- 开始处理 {table_name} ---")
            df = pd.read_csv(file_path)
            
            if df.empty:
                logging.info(f"文件 {file_name} 为空，无需导入。")
                continue

            # 执行数据转换
            if transform_func:
                if table_name == 'logs':
                    # 对于 'logs' 的转换，我们需要一个新的数据库连接来查询 channels & users
                    # 因为我们不能在同一个连接的事务中，既执行 TRUNCATE 又执行 SELECT
                    with create_engine(DB_URL).connect() as new_connection:
                        df = transform_func(df, new_connection)
                else:
                    df = transform_func(df)

            # 导入数据
            logging.info(f"正在将数据导入到 '{table_name}' 表...")
            df.to_sql(table_name, con=connection, if_exists='append', index=False)
            logging.info(f"成功导入 {len(df)} 条记录到 '{table_name}'。")
            logging.info(f"--- 完成处理 {table_name} ---")

        # 选择性地导入系统配置
        transform_and_import_options(connection.connection)

        # After all data is imported, update the root password
        logging.info("--- 开始更新 root 用户密码 ---")
        # Since we are in a transaction, we need to use the raw connection
        update_root_password(connection.connection)
        logging.info("--- 完成更新 root 用户密码 ---")


def main():
    """主函数：创建数据库引擎并启动导入流程。"""
    logging.info("开始数据转换和导入流程...")
    try:
        engine = create_engine(DB_URL)
        import_data(engine)
        logging.info("数据转换和导入流程全部成功完成！")
    except Exception as e:
        logging.error(f"处理过程中发生严重错误: {e}")

if __name__ == '__main__':
    main()