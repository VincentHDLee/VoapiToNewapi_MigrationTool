# README for AI Agent

## Objective

Your primary objective is to automate the data migration from a VoAPI instance to a NewAPI instance and perform a service switch within a single, unified Docker Compose environment.

---

## Standard Operating Procedure (SOP)

Execute the following steps sequentially. Do not proceed to the next step until the previous one is confirmed successful.

### 1. Environment Scan & Analysis

1.  **Identify VoAPI Project Root**: This is the directory containing the `docker-compose.yml` to be modified. Assume this tool (`VoapiToNewapi_Migration`) is located in a subdirectory within it.
2.  **Define File Paths**:
    *   `TARGET_COMPOSE_PATH` = `../docker-compose.yml`
    *   `TARGET_COMPOSE_BACKUP_PATH` = `../docker-compose.backup.yml`
    *   `BEFORE_EXAMPLE_PATH` = `./before-migration.compose.example.yml`
    *   `AFTER_EXAMPLE_PATH` = `./after-migration.compose.example.yml`

### 2. Configuration

1.  **Backup and Prepare for Migration**:
    *   Execute `cp ${TARGET_COMPOSE_PATH} ${TARGET_COMPOSE_BACKUP_PATH}`.
    *   Read content from `BEFORE_EXAMPLE_PATH`.
    *   Overwrite file at `TARGET_COMPOSE_PATH` with this content.
    *   **CRITICAL**: Search file at `TARGET_COMPOSE_PATH` for all password placeholders (e.g., `YOUR_MYSQL_ROOT_PASSWORD`) and replace them with known or pre-configured credential values.
    *   From the parent directory (`../`), execute `docker-compose up -d`. This will start all necessary services for migration based on the `before` template.

2.  **Populate `.env` Files**:
    *   Parse `TARGET_COMPOSE_PATH` to extract environment variables for `mysql` and `mysql-newapi` services.
    *   Create and write to `./config/source.env`: `DB_HOST=127.0.0.1`, `DB_PORT=33066`, and the credentials for the `mysql` service.
    *   Create and write to `./config/target.env`: `DB_HOST=127.0.0.1`, `DB_PORT=33067`, and the credentials for the `mysql-newapi` service.

### 3. Execution

Execute the migration scripts in the root of this tool:

1.  `python migration_scripts/01_export_voapi_data.py`
2.  `python migration_scripts/02_transform_and_import_data.py`

Confirm both scripts complete without errors.

### 4. Service Switch

1.  **Stop All Services**: In the VoAPI Project Root (`../`), execute `docker-compose down`.

2.  **Switch Compose Configuration**:
    *   Read content from `AFTER_EXAMPLE_PATH`.
    *   Overwrite file at `TARGET_COMPOSE_PATH` with this content. This file contains the final state where all sub-services are correctly configured for the new `new-api` ecosystem.
    *   **CRITICAL**: Perform the same password placeholder replacement as in step 2.1.

3.  **Restart Environment**: In the VoAPI Project Root (`../`), execute `docker-compose up -d`.

### 5. Verification & Completion

1.  **Check Services**: In the VoAPI Project Root (`../`), execute `docker-compose ps`.
2.  **Confirm Status**:
    *   Verify the `new-api-app` container is `Up` or `running`.
    *   Verify the `voapi-app` container is stopped or gone.
3.  **Report Success**: If the above conditions are met, report task completion.

---
## Success Condition

The primary success indicator is the `new-api` service and its entire ecosystem running successfully within the original VoAPI Docker Compose environment, while the old `voapi` service is no longer active.
