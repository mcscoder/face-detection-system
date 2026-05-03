# Deployment Guide

## Status

Backend setup is documented in the backend README. Client setup is documented in the client README. Full target-host deployment still needs GPU smoke verification and release packaging.

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

## Client Setup

Use [`../client/README.md`](../client/README.md) for Flutter client setup, client tests, analysis, and current run status.

## GPU Smoke

GPU smoke command is pending.

## Remaining Deployment Steps

1. Provision the host machine
2. Install GPU driver and runtime dependencies
3. Complete backend setup
4. Complete client setup
5. Start the FastAPI server
6. Run GPU model smoke
7. Add client platform run support
8. Verify recognition and audit flow end to end

## Operational Notes

- Keep inference on the server
- Do not store probe images longer than required
- Keep admin and operator credentials separate
- Keep backup and restore procedures local and simple

## Web Camera Note

Flutter web camera access may require localhost or HTTPS local. If the web client is opened from a device over LAN IP, secure context setup should be planned before demo.

## Not Yet Available

- Admin seed command
- Backup/restore commands
- GPU model smoke command
- Client platform run command
- Docker files
- systemd units
- reverse proxy config
- CI/CD pipeline
- release artifacts

## References

- Product scope: [`../deep-research-report.md`](../deep-research-report.md)
