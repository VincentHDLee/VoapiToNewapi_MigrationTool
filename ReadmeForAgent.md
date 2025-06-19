# README for AI Agent

## Objective

Your primary objective is to automate the data migration from a VoAPI instance to a NewAPI instance and perform a service switch within the existing Docker Compose environment.

---

## Standard Operating Procedure (SOP)

Execute the following steps sequentially. Do not proceed to the next step until the previous one is confirmed successful.

### 1. Environment Scan & Analysis

1.  **Identify Project Roots**: Scan the parent directory to identify two key project roots:
    *   The **VoAPI Project Root**: The directory containing the primary `docker-compose.yml` for the VoAPI service.
    *   The **NewAPI Project Root**: The directory containing the `docker-compose.yml` for the NewAPI service.

2.  **Locate this Tool**: Confirm this tool (`VoapiToNewapi_Migration`) is located within the VoAPI Project Root.

3.  **Analyze Compose Files**:
    *   Read the `docker-compose.yml` from the **VoAPI Project Root**.
    *   Read the `docker-compose.yml` from the **NewAPI Project Root**.
    *   Identify the `mysql` (or `mariadb`) service in both files.

### 2. Configuration

1.  **Expose Database Ports**:
    *   **VoAPI**: Modify its `docker-compose.yml`. In the `mysql` service definition, add/update the `ports` section to `["33066:3306"]`.
    *   **NewAPI**: Modify its `docker-compose.yml`. In the `mysql` service definition, add/update the `ports` section to `["33067:3306"]`.
    *   Execute `docker-compose up -d` in both project roots to apply the changes.

2.  **Create `.env` Files**:
    *   In this tool's `config/` directory, create `source.env` by copying `config/source.env.example`.
    *   In this tool's `config/` directory, create `target.env` by copying `config/target.env.example`.

3.  **Populate `.env` Files**:
    *   Read the `environment` section of the `mysql` service from **VoAPI's** `docker-compose.yml` to get the user, password, and database name.
    *   Write these values into `config/source.env`. Set `DB_HOST` to `127.0.0.1` and `DB_PORT` to `33066`.
    *   Read the `environment` section of the `mysql` service from **NewAPI's** `docker-compose.yml`.
    *   Write these values into `config/target.env`. Set `DB_HOST` to `127.0.0.1` and `DB_PORT` to `33067`.

### 3. Execution

Execute the migration scripts in the root of this tool:

1.  `python migration_scripts/01_export_voapi_data.py`
2.  `python migration_scripts/02_transform_and_import_data.py`

Confirm both scripts complete without errors.

### 4. Service Switch

1.  **Stop VoAPI Environment**: In the VoAPI Project Root, execute `docker-compose down`.

2.  **Modify VoAPI `docker-compose.yml`**:
    *   Read the `docker-compose.yml` from the VoAPI Project Root.
    *   Read the `after-migration.compose.example.yml` from this tool's directory.
    *   Apply the logic from the example file:
        *   Comment out the `voapi` service block.
        *   Insert the `new-api` service block from the example.
        *   Update the `nginx` service's `depends_on` to point to `new-api`.
        *   Add `new-api-data` to the `volumes` list.
        *   Replace password placeholders in the new `new-api` service block with the actual passwords found in step 2.3.

3.  **Restart Environment**: In the VoAPI Project Root, execute `docker-compose up -d`.

### 5. Verification & Completion

1.  **Check Services**: In the VoAPI Project Root, execute `docker-compose ps`.
2.  **Confirm Status**:
    *   Verify the `new-api-app` container is `Up` or `running`.
    *   Verify the `voapi-app` container is stopped or gone.
3.  **Report Success**: If the above conditions are met, report task completion.

---
## Success Condition

The primary success indicator is the `new-api` service running successfully within the original VoAPI Docker Compose environment, serving traffic, while the old `voapi` service is no longer active.