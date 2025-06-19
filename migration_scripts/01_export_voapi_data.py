import pymysql
import pandas as pd
import os
from dotenv import load_dotenv

# --- 配置信息 ---
# 从 config/source.env 文件加载环境变量
load_dotenv(dotenv_path='config/source.env')

# 从环境变量中获取数据库连接信息
VOAPI_DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'port': int(os.getenv('DB_PORT')),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME'),
    'charset': 'utf8mb4'
}

# 需要导出的表
TABLES_TO_EXPORT = [
    'users',
    'tokens',
    'logs',
    'quota_data',
    'top_ups',
    'channels',
    'abilities',
    'options',
    'redemptions'
]

# 导出数据存放目录
OUTPUT_DIR = 'exported_data'

def export_table_to_csv(table_name, connection):
    """从指定的数据库表中查询所有数据并保存为 CSV 文件。"""
    try:
        print(f"正在导出表: {table_name}...")
        # 使用 pandas 直接从 SQL 查询读取数据到 DataFrame
        query = f"SELECT * FROM {table_name};"
        df = pd.read_sql(query, connection)

        # 创建输出文件路径
        output_file = os.path.join(OUTPUT_DIR, f"{table_name}.csv")
        
        # 将 DataFrame 保存为 CSV
        df.to_csv(output_file, index=False)
        
        print(f"成功导出 {len(df)} 条记录到 {output_file}")
        
    except Exception as e:
        print(f"导出表 {table_name} 时发生错误: {e}")

def main():
    """主函数，连接数据库并导出所有指定的表。"""
    # 确保输出目录存在
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        print(f"已创建目录: {OUTPUT_DIR}")

    connection = None
    try:
        # 建立数据库连接
        connection = pymysql.connect(**VOAPI_DB_CONFIG)
        print("成功连接到 VoAPI 数据库。")

        # 遍历并导出所有表
        for table in TABLES_TO_EXPORT:
            export_table_to_csv(table, connection)

    except pymysql.MySQLError as e:
        print(f"数据库连接失败: {e}")
    finally:
        # 关闭连接
        if connection:
            connection.close()
            print("数据库连接已关闭。")

if __name__ == '__main__':
    main()