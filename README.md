# VoAPI 到 NewAPI 迁移工具

## **重要：法律声明**
在使用本工具前，请务必阅读 [**LICENSE**](LICENSE) 和 [**DISCLAIMER.md**](DISCLAIMER.md) 文件。一旦您使用本工具，即代表您同意其中的全部条款。**数据无价，请谨慎操作并务必备份**。

---

## 核心理念

迁移的核心理念是**“就地升级”**：在一个统一的 `docker-compose.yml` 文件内，通过注释和修改，完成从 VoAPI 到 NewAPI 的数据迁移和生态系统切换，以实现最短停机时间。

## 迁移流程

### 阶段一：准备工作

**1. 备份！备份！备份！**

在进行任何操作之前，请务必完整备份您现有的 `voapi` 数据库和整个项目目录。

**2. 放置迁移工具**

将本迁移工具下载并解压到您 **`voapi` 项目的根目录**下。

### 阶段二：配置

**1. 准备统一的 docker-compose.yml**

*   **备份现有 compose 文件**：
    `cp docker-compose.yml docker-compose.backup.yml`
*   **使用迁移前的模板**：
    *   打开本工具目录下的 `before-migration.compose.example.yml`。它是一个包含了 VoAPI 和 NewAPI（已注释）的完整范本。
    *   **复制**其内容，**覆盖**您现有的 `docker-compose.yml`。
    *   **重要**：将范本中的所有占位符密码（如 `YOUR_MYSQL_ROOT_PASSWORD`）替换为您自己的实际密码。
*   **启动数据库服务进行迁移**：
    *   在 `voapi` 项目根目录下，运行 `docker-compose up -d`。
    *   这将启动 `voapi` 的所有服务以及 `newapi` 的数据库服务，为数据迁移做好准备。

**2. 配置环境变量**

进入本工具的 `config` 目录，配置数据库连接信息。

*   **源数据库 (VoAPI)**:
    *   复制 `source.env.example` 为 `source.env`。
    *   编辑 `source.env`，填入 VoAPI 数据库连接信息 (主机端口: `33066`)。
*   **目标数据库 (NewAPI)**:
    *   复制 `target.env.example` 为 `target.env`。
    *   编辑 `target.env`，填入 NewAPI 数据库连接信息 (主机端口: `33067`)。

### 阶段三：执行迁移

在迁移工具的根目录下 (`VoapiToNewapi_Migration/`)，依次执行以下脚本：

```bash
# 1. 导出 VoAPI 数据
python migration_scripts/01_export_voapi_data.py

# 2. 导入数据到 NewAPI
python migration_scripts/02_transform_and_import_data.py
```

### 阶段四：服务切换

**1. 切换 Compose 配置**

*   **参考 `after-migration.compose.example.yml`**：
    *   打开本工具目录下的这个示例文件。它展示了迁移完成后的最终服务状态，其中 `new-api` 及其全套生态系统服务被激活。
    *   **复制**其内容，再次**覆盖**您现有的 `docker-compose.yml`。
    *   同样，请确保将所有占位符密码替换为您的实际密码。

**2. 启动完整服务**

*   在 `voapi` 项目根目录下，运行 `docker-compose up -d`。
*   这将关闭旧的 `voapi` 服务，并启动新的 `new-api` 及其全套生态系统服务。

### 阶段五：验证

现在，您的服务已经由 NewAPI 提供。访问您原来的域名或 IP 地址，并使用 `root` 用户（密码已被重置为 `123456`）登录，检查数据是否完整。

---

## 应急恢复计划

如果迁移后 NewAPI 出现严重问题，您可以快速恢复到迁移前的状态。

1.  **停止当前服务**：在 `voapi` 项目根目录运行 `docker-compose down`。
2.  **使用恢复模板**：
    *   打开本工具目录下的 `recovery.compose.example.yml`。
    *   复制其内容，**覆盖** `docker-compose.yml`。
    *   将占位符密码替换为您的实际密码。
3.  **重启旧服务**：运行 `docker-compose up -d`。

这将重新启动 VoAPI 的全套服务，让您的业务恢复到迁移前的状态。

## 相关文档

- **[FIELD_MAPPING.md](FIELD_MAPPING.md:1)**: 字段映射关系。
- **[MIGRATION_PLAN.md](MIGRATION_PLAN.md:1)**: 迁移策略。
- **[MIGRATION_LOG.md](MIGRATION_LOG.md:1)**: 项目日志。