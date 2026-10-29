# FinVault — Standalone Personal Finance App

A fully local, single-user finance manager: portfolio tracking, expenses, an
encrypted password vault, and reports. FastAPI + SQLite + Jinja2/HTMX. No cloud,
no Node.js, no build step. All data lives on your machine.

## Quick start (one step)

The only prerequisite is **Python 3.10+** ([download](https://www.python.org/downloads/) —
on Windows tick *“Add Python to PATH”* during install).

Extract the zip, then:

- **Windows:** double-click **`setup.bat`**
- **macOS / Linux:** run **`./setup.sh`** (first time: `chmod +x setup.sh`)

The script creates a virtual environment, installs dependencies, and launches the
app — your browser opens at <http://localhost:8000>. First run shows a setup wizard
to create your account and master password. Run the same file again any time to start it.

### Manual run (if you prefer)

```bash
python -m venv .venv
# Windows:  .venv\Scripts\activate     macOS/Linux:  source .venv/bin/activate
pip install -r requirements.txt
python -m app.main
```

### Dev mode (hot reload)

```bash
python -m uvicorn app.main:create_app --factory --reload --host 127.0.0.1 --port 8000
```

## Sharing the project

Zip the project folder, but **exclude `.venv/`** (each teammate's script recreates it).
The app stores user data outside the project, so no personal data ships in the zip.

## Where your data lives

`%LOCALAPPDATA%\FinVault2\` (Windows) or `~/.finvault2/` (macOS/Linux) —
`finvault.db`, `storage/`, `backups/`, `logs/`.

## Features
- **Dashboard** — net worth, allocation chart, health score, upcoming SIPs
- **Assets** — CRUD across 8 asset types, P&L computed in paise-precise integers
- **Expenses** — per-month tracking, category breakdown, household members, income
- **Vault** — AES-256-CBC encrypted credentials, PBKDF2 key from master password,
  password generator, reveal/copy, audit log
- **Reports** — portfolio summary, financial health, CSV/JSON export
- **Background jobs** — SIP reminders, notification cleanup, daily auto-backup (APScheduler)

## Notes / deviations from the design docs
- Synchronous SQLAlchemy (instead of async/aiosqlite) — simpler and robust for a
  single-user local app.
- Plain SQLite (SQLCipher was optional in the spec).
- Cookie-based in-memory session (so server-rendered pages authenticate on normal
  navigation); still localhost-only with inactivity auto-lock.
- Tables created via `Base.metadata.create_all` + seed on first run (no Alembic).
- Export is CSV/JSON (skips WeasyPrint/python-pptx native deps).
```
