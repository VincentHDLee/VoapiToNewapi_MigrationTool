# README for AI Agent

## **LEGAL NOTICE**
Before execution, you must acknowledge the terms in [**LICENSE**](LICENSE) and [**DISCLAIMER.md**](DISCLAIMER.md). The user is responsible for all risks.

---

## Objective

Your primary objective is to automate the data migration from a VoAPI instance to a NewAPI instance and perform a full ecosystem service switch within a single, unified Docker Compose environment.

---

## Standard Operating Procedure (SOP)

### 1. Environment Scan & Analysis

1.  **Define File Paths**:
    *   `TARGET_COMPOSE_PATH` = `../docker-compose.yml`
    *   `TARGET_COMPOSE_BACKUP_PATH` = `../docker-compose.backup.yml`
    *   `BEFORE_EXAMPLE_PATH` = `./before-migration.compose.example.yml`
    *   `AFTER_EXAMPLE_PATH` = `./after-migration.compose.example.yml`
    *   `RECOVERY_EXAMPLE_PATH` = `./recovery.compose.example.yml`

### 2. Configuration

1.  **Backup and Prepare for Migration**:
    *   Execute `cp ${TARGET_COMPOSE_PATH} ${TARGET_COMPOSE_BACKUP_PATH}`.
    *   Read content from `BEFORE_EXAMPLE_PATH`.
    *   Overwrite file at `TARGET_COMPOSE_PATH` with this content.
    *   **CRITICAL**: Search `TARGET_COMPOSE_PATH` for all password placeholders (e.g., `YOUR_MYSQL_ROOT_PASSWORD`) and replace with known or pre-configured credential values.
    *   **CRITICAL**: Ensure all external ports defined in `TARGET_COMPOSE_PATH` are free on the host machine.
    *   From the parent directory (`../`), execute `docker-compose up -d`.

2.  **Populate `.env` Files**:
    *   Parse `TARGET_COMPOSE_PATH` to extract credentials for `mysql` and `mysql-newapi`.
    *   Write to `./config/source.env`: `DB_HOST=127.0.0.1`, `DB_PORT=33066`, and credentials for `mysql`.
    *   Write to `./config/target.env`: `DB_HOST=127.0.0.1`, `DB_PORT=33067`, and credentials for `mysql-newapi`.

### 3. Execution

Execute migration scripts:
1.  `python migration_scripts/01_export_voapi_data.py`
2.  `python migration_scripts/02_transform_and_import_data.py`
Confirm both scripts complete without errors. If an error occurs, analyze the error. The database schema should initialize automatically. If tables are missing, it indicates a problem with the volume mount in `docker-compose.yml`.

### 4. Service Switch

1.  **Stop All Services**: In the parent directory (`../`), execute `docker-compose down`.
2.  **Switch Compose Configuration**:
    *   Read content from `AFTER_EXAMPLE_PATH`.
    *   Overwrite file at `TARGET_COMPOSE_PATH` with this content.
    *   **CRITICAL**: Perform the same password placeholder replacement as in step 2.1.
3.  **Restart Environment**: In the parent directory (`../`), execute `docker-compose up -d`.

### 5. Verification & Completion

1.  **Check Services**: In the parent directory (`../`), execute `docker-compose ps`.
2.  **Confirm Status**: Verify `new-api-app` is `Up` and `voapi-app` is gone.
3.  **Report Success**: If status is confirmed, the task is complete. If not, proceed to **Recovery Plan**.

---

## Recovery Plan (Execute only on failure)

1.  **Stop Services**: In the parent directory (`../`), execute `docker-compose down`.
2.  **Restore Compose**: Read content from `RECOVERY_EXAMPLE_PATH` and overwrite `TARGET_COMPOSE_PATH`.
3.  **CRITICAL**: Perform password placeholder replacement.
4.  **Restart Old Services**: In the parent directory (`../`), execute `docker-compose up -d`.
5.  **Report Failure and Recovery**: Report that the migration failed but the system has been restored to its original state.
