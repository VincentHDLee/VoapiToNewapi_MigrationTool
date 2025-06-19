# VoAPI 到 NewAPI 迁移工具

本项目旨在帮助用户将现有的 VoAPI 实例数据平滑迁移到 NewAPI 实例，并最终在原有的 Docker Compose 环境中用 NewAPI 服务替换 VoAPI 服务，以实现最短的停机时间。

## 核心理念

迁移的核心理念是**“就地升级”**：

1.  在您现有的 `voapi` 服务器上进行操作。
2.  利用此工具将 `voapi` 数据库中的数据导出并导入（覆盖）到 `newapi` 的数据库。
3.  修改 `docker-compose.yml`，用 `newapi` 服务替换 `voapi` 服务，实现无缝切换。

## 迁移流程

### 阶段一：准备工作

**1. 备份！备份！备份！**

在进行任何操作之前，请务必完整备份您现有的 `voapi` 数据库和整个项目目录。

**2. 放置迁移工具**

将本迁移工具（即当前项目的全部内容）下载并解压到您 **`voapi` 项目的根目录**下。操作完成后，您的目录结构应如下所示：

```
/path/to/your/voapi/
├── docker-compose.yml  <-- 您现有的 voapi compose 文件
├── data/
├── logs/
├── ... (voapi 的其他目录)
│
└── VoapiToNewapi_Migration/  <-- 将本工具放在这里
    ├── migration_scripts/
    ├── config/
    ├── before-migration.compose.example.yml
    ├── after-migration.compose.example.yml
    └── ... (本工具的其他文件)
```

### 阶段二：配置

**1. 准备统一的 docker-compose.yml**

为了简化操作，我们将所有服务统一管理在您 `voapi` 项目根目录的 `docker-compose.yml` 文件中。

*   **备份现有 compose 文件**：
    `cp docker-compose.yml docker-compose.backup.yml`
*   **使用迁移前的模板**：
    *   打开本工具目录下的 `before-migration.compose.example.yml`。它是一个包含了 VoAPI 和 NewAPI（已注释）的完整范本。
    *   **复制**其内容，**覆盖**您现有的 `docker-compose.yml`。
    *   **重要**：将范本中的所有占位符密码（如 `YOUR_MYSQL_ROOT_PASSWORD`）替换为您自己的实际密码。
*   **启动数据库服务进行迁移**：
    *   在 `voapi` 项目根目录下，运行 `docker-compose up -d`。
    *   根据 `before-migration` 范本的设置，这将启动 `voapi` 的所有服务以及 `newapi` 的数据库服务，为数据迁移做好准备。

**2. 配置环境变量**

进入本工具的 `config` 目录，配置数据库连接信息。

*   **源数据库 (VoAPI)**:
    *   复制 `source.env.example` 为 `source.env`。
    *   编辑 `source.env`，填入您的 VoAPI 数据库连接信息，端口为您上一步映射的**主机端口** (`33066`)。

*   **目标数据库 (NewAPI)**:
    *   复制 `target.env.example` 为 `target.env`。
    *   编辑 `target.env`，填入您的 NewAPI 数据库连接信息，端口为您上一步映射的**主机端口** (`33067`)。

### 阶段三：执行迁移

在迁移工具的根目录下（即 `VoapiToNewapi_Migration/`），依次执行以下脚本：

**1. 导出 VoAPI 数据**
```bash
python migration_scripts/01_export_voapi_data.py
```

**2. 导入数据到 NewAPI**
```bash
python migration_scripts/02_transform_and_import_data.py
```

### 阶段四：服务切换

这是实现平滑过渡的关键一步。

**1. 切换 Compose 配置**

*   **参考 `after-migration.compose.example.yml`**：
    *   打开本工具目录下的这个示例文件。它展示了迁移完成后的最终服务状态，其中旧的 `voapi` 服务被注释掉，新的 `new-api` 和所有相关的子服务（备份、监控等）都被激活并正确配置。
    *   **复制**其内容，再次**覆盖**您现有的 `docker-compose.yml`。
    *   同样，请确保将所有占位符密码替换为您的实际密码。

**2. 启动完整服务**

*   在 `voapi` 项目根目录下，运行 `docker-compose up -d`。
*   这将关闭旧的 `voapi` 服务，并启动新的 `new-api` 及其全套生态系统服务。

### 阶段五：验证

现在，您的服务已经由 NewAPI 提供。访问您原来的域名或 IP 地址，您应该能看到 NewAPI 的界面，并且您原有的用户、数据都应该存在。

登录 `root` 用户（密码已被重置为 `123456`），并检查其他用户的账户信息和额度，以确保迁移成功。

## 相关文档

- **[FIELD_MAPPING.md](FIELD_MAPPING.md:1)**: 详细说明了两个数据库之间字段的映射关系。
- **[MIGRATION_PLAN.md](MIGRATION_PLAN.md:1)**: 概述了迁移的整体策略和步骤。
- **[MIGRATION_LOG.md](MIGRATION_LOG.md:1)**: 记录了项目期间进行的工作和决策。