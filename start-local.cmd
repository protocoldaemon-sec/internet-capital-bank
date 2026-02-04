@echo off
echo ========================================
echo Starting Agentic Reserve System (ARS)
echo Local Development Environment
echo ========================================
echo.

REM Create logs directory
if not exist logs mkdir logs

REM Check Node.js
echo Checking Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js found
echo.

REM Check Redis (optional for Windows)
echo Checking Redis...
redis-cli ping >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Redis is not running
    echo Some features may not work without Redis
    echo Install Redis: https://github.com/microsoftarchive/redis/releases
    echo.
) else (
    echo [OK] Redis is running
    echo.
)

REM Install backend dependencies
echo Checking backend dependencies...
cd backend
if not exist node_modules (
    echo Installing backend dependencies...
    call npm install
)
echo [OK] Backend dependencies ready
cd ..
echo.

REM Install frontend dependencies
echo Checking frontend dependencies...
cd frontend
if not exist node_modules (
    echo Installing frontend dependencies...
    call npm install
)
echo [OK] Frontend dependencies ready
cd ..
echo.

echo ========================================
echo Starting Services...
echo ========================================
echo.

REM Start backend
echo Starting Backend API (Port 3000)...
cd backend
start "ARS Backend" cmd /k "npm run dev"
cd ..
echo [OK] Backend started
echo.

REM Wait for backend
echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul
echo.

REM Start frontend
echo Starting Frontend (Port 5173)...
cd frontend
start "ARS Frontend" cmd /k "npm run dev"
cd ..
echo [OK] Frontend started
echo.

echo ========================================
echo ARS is running!
echo ========================================
echo.
echo Services:
echo   - Backend API:  http://localhost:3000
echo   - Frontend:     http://localhost:5173
echo   - Redis:        localhost:6379
echo.
echo API Endpoints:
echo   - GET  /ili/current
echo   - GET  /icr/current
echo   - GET  /reserve/state
echo   - GET  /proposals
echo   - GET  /revenue/current
echo.
echo Press any key to open frontend in browser...
pause >nul

start http://localhost:5173

echo.
echo Services are running in separate windows.
echo Close those windows to stop the services.
echo.
pause
