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
sudo apt install -y curl postgresql-common
```

Installs `curl` for the `uv` installer and `postgresql-common` for the PostgreSQL APT script. `-y` answers yes to the install prompt.

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
FACE_MODEL_PACK=buffalo_m
```

`YOUR_PASSWORD` must match the PostgreSQL password from step 2.
The app reads `.env`.

## 5. Install Dependencies

```bash
uv sync --extra test
```

Installs dependencies into `.venv`. `--extra test` includes the optional test dependencies from `pyproject.toml`.

## 6. Apply Database Schema

```bash
psql "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" -f app/db/schema.sql
```

Applies the schema SQL file to the app database. `-f` reads SQL from a file.

```bash
psql "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" -c "\dt"
```

Lists database tables. `-c` runs one command and exits.

## 7. Run Tests

```bash
uv run --extra test pytest -vv
```

Runs tests in the `uv` environment. `--extra test` includes test dependencies and `-vv` increases pytest output detail.

## 8. Start Server

```bash
uv run uvicorn app.main:create_app --factory --reload
```

Starts the FastAPI server. `--factory` treats `create_app` as an app factory and `--reload` restarts the server after Python file changes.

## 9. Check Server

Open:

```text
http://127.0.0.1:8000/v1/server/health
```

Expected:

```json
{"status":"ok","service":"face-detection-system","version":"0.1.0"}
```

## Current Gaps

- First admin creation command is pending.
- Real InsightFace/GPU smoke test is pending.

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
| `uv sync --extra` | https://docs.astral.sh/uv/concepts/projects/sync/ |
| `uv run` | https://docs.astral.sh/uv/concepts/projects/run/ |
| pytest `-vv` | https://docs.pytest.org/en/stable/reference/reference.html#command-line-flags |
| Uvicorn `--factory` and `--reload` | https://www.uvicorn.org/settings/ |
| Environment variables | [`app/core/config.py`](app/core/config.py) |
| Database schema | [`app/db/schema.sql`](app/db/schema.sql) |
| Health response | [`app/api/routes/server.py`](app/api/routes/server.py) |
