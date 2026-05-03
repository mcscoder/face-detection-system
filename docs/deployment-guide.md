# Deployment Guide

## Status

Backend setup is documented in the backend README. Client setup is documented in the client README. Android release APK build passes. Manual target-phone enrollment smoke, database and GPU smoke verification, and full end-to-end hardware audit still need verification.

## Intended Deployment Model

- Single local machine
- NVIDIA GPU 8GB available on the server machine
- PostgreSQL and app server run on the same host
- Clients connect over LAN or localhost

## Prerequisites

- Python runtime for FastAPI backend
- PostgreSQL with `pgvector`
- NVIDIA driver and CUDA-compatible runtime
- Local storage volume for enrollment and audit artifacts
- Flutter SDK for mobile and web clients

## Expected Runtime Layout

| Service | Location |
|---|---|
| API server | same host as database |
| Recognition engine | same host, GPU enabled |
| Database | local PostgreSQL instance |
| File storage | local disk or mounted volume |
| Mobile client | Android/iOS device on LAN |
| Web client | browser on localhost or HTTPS local |

## Backend Setup

Use [`../backend/README.md`](../backend/README.md) for backend setup, database setup, backend tests, and backend run commands.

Create the first admin after schema setup from `backend/`:

```bash
FACE_ADMIN_PASSWORD='YOUR_ADMIN_PASSWORD' uv run python -m app.cli.create_admin
```

There is no default admin password.

## Client Setup

Use [`../client/README.md`](../client/README.md) for Flutter client setup, client tests, analysis, and current run status.

The Flutter app reads the backend URL from `client/env/mobile.json`.

## Database Smoke

Run from `backend/` on a host with `FACE_TEST_DATABASE_URL` set:

```bash
FACE_TEST_DATABASE_URL='postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection' uv run pytest tests/integration/test_database_paths.py -vv
```

The test skips unless `FACE_TEST_DATABASE_URL` is set.

## GPU Smoke

Run on the NVIDIA host from `backend/`:

```bash
FACE_RUN_GPU_SMOKE=1 uv run pytest -m gpu -vv
```

Run the server with model preload:

```bash
FACE_PRELOAD_MODEL=true uv run uvicorn app.main:create_app --factory
```

Then check:

```text
http://127.0.0.1:8000/v1/server/info
```

Expected fields include `version`, `model.model_pack`, `model.providers`, `model.loaded`, and `model.warning`. Authenticated admin/operator/enrollment requests include `active_template_count`; anonymous requests get `null`, and the count excludes templates for deleted people.

## Backup And Restore

Run from the deployment host:

```bash
pg_dump "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" -Fc -f face_detection.backup
```

Creates a compressed PostgreSQL backup.

```bash
tar -czf face_detection_storage.tar.gz local-storage
```

Creates a storage archive for enrollment and retained probe files.

Restore database:

```bash
pg_restore --clean --if-exists -d "postgresql://postgres:YOUR_PASSWORD@localhost:5432/face_detection" face_detection.backup
```

Restore storage:

```bash
tar -xzf face_detection_storage.tar.gz
```

## Mobile LAN Demo Path

1. Start PostgreSQL.
2. Apply `backend/app/db/schema.sql`.
3. Create the admin user with `FACE_ADMIN_PASSWORD='YOUR_ADMIN_PASSWORD' uv run python -m app.cli.create_admin`.
4. Start backend with `uv run uvicorn app.main:create_app --factory --host 0.0.0.0`.
5. Confirm `http://SERVER_LAN_IP:8000/v1/server/health`.
6. Run the Android client with `flutter run`.
7. Login, enroll samples, identify a probe image, and check `/v1/events`.

Flutter web localhost smoke after web platform files exist:

```bash
flutter run -d chrome
```

## Remaining Deployment Steps

1. Provision the host machine
2. Install GPU driver and runtime dependencies
3. Complete backend setup
4. Complete client setup
5. Start the FastAPI server
6. Run database smoke
7. Run GPU model smoke
8. Verify enrollment on the target phone
9. Add Flutter web platform run folder
10. Verify recognition and audit flow end to end on target hardware

## Operational Notes

- Keep inference on the server
- Do not store probe images longer than required
- Keep admin and operator credentials separate
- Keep backup and restore procedures local and simple

## Web Camera Note

Flutter web camera access may require localhost or HTTPS local. If the web client is opened from a device over LAN IP, secure context setup should be planned before demo.

## Not Yet Available

- Manual target-phone enrollment smoke
- Flutter web platform run folder
- Docker files
- systemd units
- reverse proxy config
- CI/CD pipeline

## References

- Product scope: [`../deep-research-report.md`](../deep-research-report.md)
