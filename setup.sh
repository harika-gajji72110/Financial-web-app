#!/usr/bin/env bash
# ============================================================
# FinVault — one-step local setup & launch (macOS / Linux / WSL / Git Bash)
# Usage: ./setup.sh   (or: bash setup.sh)
# ============================================================
set -e
cd "$(dirname "$0")"

echo ""
echo "  ============================================"
echo "    FinVault  -  local setup"
echo "  ============================================"
echo ""

# --- 1. Locate Python 3.10+ ---------------------------------
PY=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then
    ver=$("$cand" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || echo "0.0")
    major=${ver%.*}; minor=${ver#*.}
    if [ "$major" = "3" ] && [ "$minor" -ge 10 ] 2>/dev/null; then PY="$cand"; break; fi
  fi
done
if [ -z "$PY" ]; then
  echo "ERROR: Python 3.10+ is required but was not found."
  echo "Install it from https://www.python.org/downloads/ and re-run this script."
  exit 1
fi
echo "  Using $("$PY" --version)"

# --- 2. Create / reuse virtual environment ------------------
if [ ! -d ".venv" ]; then
  echo "  Creating virtual environment (.venv) ..."
  "$PY" -m venv .venv
fi
# shellcheck disable=SC1091
if [ -f ".venv/bin/activate" ]; then
  . .venv/bin/activate            # macOS / Linux
else
  . .venv/Scripts/activate        # Git Bash on Windows
fi

# --- 3. Install dependencies --------------------------------
echo "  Installing dependencies (first run may take a minute) ..."
python -m pip install --upgrade pip >/dev/null
python -m pip install -r requirements.txt

# --- 4. Launch (auto-opens http://localhost:8000) -----------
echo ""
echo "  Setup complete. Starting FinVault ..."
echo "  Open http://localhost:8000 if your browser does not open automatically."
echo "  Press Ctrl+C to stop."
echo ""
# The importable "app" package lives in the "app" subfolder.
cd app
python -m app.main
