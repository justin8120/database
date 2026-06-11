@echo off
echo ==================================================
echo Starting Servers...
echo ==================================================

echo [1/2] Starting Backend Server (FastAPI)...
start "Backend (FastAPI)" cmd /k "cd backend && uvicorn main:app --reload"

echo [2/2] Starting Frontend Server (Vite/Vue)...
start "Frontend (Vite/Vue)" cmd /k "npm run dev"

echo.
echo Both servers have been launched in separate windows!
echo You can close this window now.
pause
