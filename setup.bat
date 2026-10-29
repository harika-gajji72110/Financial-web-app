@echo off
REM ============================================================
REM  FinVault - one-step local setup ^& launch (Windows)
REM  Double-click this file, or run:  setup.bat
REM ============================================================
setlocal
cd /d "%~dp0"

echo.
echo   ============================================
echo     FinVault  -  local setup
echo   ============================================
echo.

REM --- 1. Locate Python ---------------------------------------
set "PY="
where py >nul 2>&1 && set "PY=py -3"
if not defined PY (
  where python >nul 2>&1 && set "PY=python"
)
if not defined PY (
  echo ERROR: Python 3.10+ is required but was not found.
  echo Install it from https://www.python.org/downloads/ and re-run this file.
  echo IMPORTANT: tick "Add Python to PATH" during installation.
  pause
  exit /b 1
)

set "VENV_PY=%~dp0.venv\Scripts\python.exe"
set "DEPS_OK=%~dp0.venv\.deps-ok"

REM --- 2. Create / reuse virtual environment ------------------
if not exist "%VENV_PY%" (
  echo   Creating virtual environment ^(.venv^) ...
  %PY% -m venv .venv
  if errorlevel 1 (
    echo ERROR: could not create the virtual environment.
    pause
    exit /b 1
  )
)

REM --- 3. Install dependencies (skipped once installed) -------
if exist "%DEPS_OK%" (
  echo   Dependencies already installed - skipping ^(delete the .venv folder to refresh^).
) else (
  echo   Installing dependencies ^(first run may take a minute^) ...
  call "%VENV_PY%" -m pip install --upgrade pip >nul
  call "%VENV_PY%" -m pip install -r requirements.txt
  if errorlevel 1 (
    echo ERROR: dependency installation failed. See messages above.
    pause
    exit /b 1
  )
  >"%DEPS_OK%" echo ok
)

REM --- 4. Verify the app loads (catches a broken/incomplete env early) ---
echo   Verifying installation ...
pushd "%~dp0app"
call "%VENV_PY%" -c "import app.main" 2>nul
if errorlevel 1 (
  echo   Environment looks incomplete - reinstalling dependencies ...
  call "%VENV_PY%" -m pip install -r "%~dp0requirements.txt"
  call "%VENV_PY%" -c "import app.main"
  if errorlevel 1 (
    echo ERROR: FinVault failed to load. See the messages above.
    popd
    pause
    exit /b 1
  )
)

REM --- 5. Launch (auto-opens http://localhost:8000) -----------
REM The importable "app" package lives in the "app" subfolder, so we launch
REM from there while pointing at the venv Python by absolute path.
echo.
echo   Setup complete. Starting FinVault ...
echo   Open http://localhost:8000 if your browser does not open automatically.
echo   Close this window or press Ctrl+C to stop.
echo.
call "%VENV_PY%" -m app.main
popd

pause
