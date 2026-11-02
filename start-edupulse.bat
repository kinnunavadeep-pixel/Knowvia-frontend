@echo off
title EduPulse App Launcher
echo ========================================================
echo               EduPulse 1-Click Launcher
echo ========================================================
echo.

echo [1/3] Ensuring Local MySQL84 Service is running...
sc start MySQL84 >nul 2>&1
echo       MySQL84 service checked.
echo.

echo [2/3] Starting Spring Boot Backend (Port 8081)...
set "BACKEND_DIR=C:\Users\mkmk3\OneDrive\Documents\Edupulse123\Edupulse"
if not exist "%BACKEND_DIR%\pom.xml" set "BACKEND_DIR=%~dp0Edupulse123\Edupulse"
start "EduPulse Backend" cmd /k "cd /d ""%BACKEND_DIR%"" && .\mvnw.cmd spring-boot:run"
echo       Backend launcher window opened (from %BACKEND_DIR%).
echo.

echo [3/3] Starting Vite Frontend (Port 5174)...
start "EduPulse Frontend" cmd /k "cd /d ""%~dp0"" && npm run dev"
echo       Frontend launcher window opened.
echo.

echo ========================================================
echo  All services are booting!
echo  Frontend will be live at: http://localhost:5174
echo  Backend will be live at:  http://localhost:8081
echo ========================================================
timeout /t 5 >nul
start http://localhost:5174
pause
