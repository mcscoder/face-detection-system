# Setup

Setup guide for this service.

Target system: Ubuntu 22.04 with PostgreSQL 14.

Canonical database setup path: `psql` with `app/db/schema.sql`.

## 1. Install System Packages

```bash
sudo apt update
```

Refreshes Ubuntu package indexes.

```bash
sudo apt install -y build-essential curl postgresql-common
```

Installs native build tools, `curl` for the `uv` installer, and `postgresql-common` for the PostgreSQL APT script. `-y` answers yes to the install prompt.

```bash
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

Adds the official PostgreSQL APT repository.

```bash
sudo apt update
```

Refreshes Ubuntu package indexes after adding the PostgreSQL APT repository.

```bash
sudo apt install -y postgresql-14 postgresql-contrib postgresql-14-pgvector
```

Installs PostgreSQL 14, PostgreSQL contributed extensions for `pgcrypto`, and `pgvector`. `-y` answers yes to the install prompt.

```bash
sudo systemctl enable --now postgresql
```

Enables PostgreSQL on boot and starts it now. `--now` starts the service during the enable command.

## 2. Create Database

```bash
sudo -u postgres psql
```

Opens `psql` as operating-system user `postgres`. In `sudo`, `-u postgres` selects that user.

Run inside `psql`:

```sql
ALTER USER postgres WITH PASSWORD 'YOUR_PASSWORD';
```

Sets the PostgreSQL password for database user `postgres`.

```sql
CREATE DATABASE face_detection;
```

Creates the app database.

```sql
\q
```

Exits `psql`.

## 3. Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Downloads and runs the official `uv` installer. `-L` follows redirects, `-s` runs silently, `-S` shows errors, and `-f` fails on HTTP errors.

Open a new terminal.

```bash
uv --version
```

Checks that `uv` works.

## 4. Configure `.env`

```dotenv
FACE_DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection
FACE_STORAGE_ROOT=./local-storage
FACE_JWT_SECRET=change-this-local-secret
FACE_MODEL_PACK=buffalo_l
FACE_MODEL_PROVIDER=cpu
FACE_PRELOAD_MODEL=false
```

`YOUR_PASSWORD` must match the PostgreSQL password from step 2.
The app reads `.env`.

## 5. Install Dependencies

```bash
uv sync
```

Installs dependencies into `.venv` using uv-managed Python.

## 6. Apply Database Schema

```bash
psql "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" -f app/db/schema.sql
```

Applies the schema SQL file to the app database. `-f` reads SQL from a file.

```bash
psql "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" -c "\dt"
```

Lists database tables. `-c` runs one command and exits.

## 7. Create First Admin

Run from `backend/`:

```bash
FACE_ADMIN_PASSWORD='YOUR_ADMIN_PASSWORD' uv run python -m app.cli.create_admin
```

Creates or updates the local admin user named `admin`. `FACE_ADMIN_PASSWORD` supplies the password; there is no default password.

```bash
FACE_ADMIN_USERNAME='admin' FACE_ADMIN_DISPLAY_NAME='Local Admin' FACE_ADMIN_PASSWORD='YOUR_ADMIN_PASSWORD' uv run python -m app.cli.create_admin
```

Creates or updates the admin user with explicit username and display name.

## 8. Run Tests

```bash
uv run pytest -vv
```

Runs tests in the `uv` environment. `-vv` increases pytest output detail. Database and GPU smoke tests skip unless their env vars are set.

Optional database smoke on a configured PostgreSQL database:

```bash
FACE_TEST_DATABASE_URL='postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection' uv run pytest tests/integration/test_database_paths.py -vv
```

Exercises repository/database paths. `FACE_TEST_DATABASE_URL` must be set for the test to run.

Optional GPU smoke on the NVIDIA host:

```bash
FACE_RUN_GPU_SMOKE=1 uv run pytest -m gpu -vv
```

Loads the configured InsightFace model and checks provider reporting. `FACE_RUN_GPU_SMOKE=1` must be set. `-m gpu` selects GPU-marked tests, and `-vv` increases pytest output detail.

## 9. Start Server

```bash
uv run uvicorn app.main:create_app --factory --reload
```

Starts the FastAPI server. `--factory` treats `create_app` as an app factory and `--reload` restarts the server after Python file changes.

To preload the model during startup:

```bash
FACE_PRELOAD_MODEL=true uv run uvicorn app.main:create_app --factory
```

Starts the server and loads the model before serving requests. `--factory` treats `create_app` as an app factory.

## 10. Check Server

Open:

```text
http://127.0.0.1:8000/v1/server/health
```

Expected:

```json
{"status":"ok","service":"face-detection-system","version":"0.1.0"}
```

## Current Gaps

- Real InsightFace/GPU smoke still needs target-host run.

## References

| Area | Reference |
|---|---|
| PostgreSQL Ubuntu APT repository | https://www.postgresql.org/download/linux/ubuntu/ |
| PostgreSQL `psql` shell | https://www.postgresql.org/docs/14/app-psql.html |
| PostgreSQL password command | https://www.postgresql.org/docs/14/sql-alteruser.html |
| PostgreSQL database command | https://www.postgresql.org/docs/14/sql-createdatabase.html |
| PostgreSQL extension command | https://www.postgresql.org/docs/14/sql-createextension.html |
| PostgreSQL `pgcrypto` | https://www.postgresql.org/docs/14/pgcrypto.html |
| `pgvector` | https://github.com/pgvector/pgvector |
| `systemctl enable --now` | https://manpages.ubuntu.com/manpages/jammy/en/man1/systemctl.1.html |
| `uv` install | https://docs.astral.sh/uv/getting-started/installation/ |
| `uv sync` | https://docs.astral.sh/uv/concepts/projects/sync/ |
| `uv run` | https://docs.astral.sh/uv/concepts/projects/run/ |
| pytest `-vv` | https://docs.pytest.org/en/stable/reference/reference.html#command-line-flags |
| Uvicorn `--factory` and `--reload` | https://www.uvicorn.org/settings/ |
| Environment variables | [`app/core/config.py`](app/core/config.py) |
| Database schema | [`app/db/schema.sql`](app/db/schema.sql) |
| Health response | [`app/api/routes/server.py`](app/api/routes/server.py) |
