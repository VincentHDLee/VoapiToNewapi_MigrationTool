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

**3. 准备 NewAPI 环境**

您需要有一个正在运行的 NewAPI 实例，因为我们将要把数据迁移到它的数据库中。您可以选择：
*   **已有 NewAPI 实例**：如果您已经有一个正在运行的 NewAPI，请确保您可以访问其 `docker-compose.yml` 文件和数据库。
*   **全新部署 NewAPI**：如果您没有，请先按照 NewAPI 的官方文档部署一个新的实例。数据卷的位置在下一步中尤为重要。

### 阶段二：配置

**1. 暴露数据库端口**

为了让迁移脚本能够连接到两个数据库，您需要分别修改 `voapi` 和 `newapi` 的 `docker-compose.yml` 文件，将它们的数据库端口映射到主机。

*   **对于 VoAPI**:
    *   请参考本工具目录下的 `before-migration.compose.example.yml` 文件。它展示了如何在您的 `voapi` 的 `docker-compose.yml` 中为 `mysql` 服务添加 `ports` 映射 (`"33066:3306"`)。

*   **对于 NewAPI**:
    *   在您的 `newapi` 的 `docker-compose.yml` 中，为 `mysql` 服务进行类似修改，但使用**不同**的主机端口 (`"33067:3306"`) 以避免冲突。

*   修改完成后，分别在两个项目目录中运行 `docker-compose up -d` 来应用更改。

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

这是实现平滑过渡的关键一步。您需要再次修改 **`voapi` 的 `docker-compose.yml`** 文件。

**我们强烈建议您参考本工具目录下的 `after-migration.compose.example.yml` 文件。**

它完整地展示了如何：
1.  安全地注释掉旧的 `voapi` 服务。
2.  添加并配置新的 `new-api` 服务。
3.  更新 `nginx` 等依赖 `voapi` 的服务，使其转向 `new-api`。

请将 `after-migration.compose.example.yml` 的内容作为最终参考，来修改您自己的 `docker-compose.yml`。修改完成后，运行 `docker-compose up -d` 启动新服务。

### 阶段五：验证

现在，您的服务已经由 NewAPI 提供。访问您原来的域名或 IP 地址，您应该能看到 NewAPI 的界面，并且您原有的用户、数据都应该存在。

登录 `root` 用户（密码已被重置为 `123456`），并检查其他用户的账户信息和额度，以确保迁移成功。

## 相关文档

- **[FIELD_MAPPING.md](FIELD_MAPPING.md:1)**: 详细说明了两个数据库之间字段的映射关系。
- **[MIGRATION_PLAN.md](MIGRATION_PLAN.md:1)**: 概述了迁移的整体策略和步骤。
- **[MIGRATION_LOG.md](MIGRATION_LOG.md:1)**: 记录了项目期间进行的工作和决策。