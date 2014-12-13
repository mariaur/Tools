@echo off

setlocal

set SCRIPT_DIR=%~dp0
set ENCODE=0

if "%1" == "-d" (
    shift & goto :CONTINUE
)

if "%1" == "-e" (
    set ENCODE=1
    shift & goto :CONTINUE
)

goto :USAGE

:CONTINUE

if "%1" == "" goto :USAGE
if "%2" == "" goto :USAGE

set PS_CMD=. %SCRIPT_DIR%\b64.ps1; Write-Host PS: Working... `n

if %ENCODE% == 1 (
    set PS_CMD=%PS_CMD%;Base64Encode '%1' '%2'
) else (
    set PS_CMD=%PS_CMD%;Base64Decode '%1' '%2'
)

set PS_CMD=powershell -command "%PS_CMD%"

echo.
echo INFO: Invoking %PS_CMD% ...
echo.
%PS_CMD%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Failed!
) else (
    echo.
    echo Done. 
)

goto :EOF

:USAGE

echo.
echo USAGE: b64 [-d^|-e] ^<input_file^> ^<output_file^>
echo.

goto :EOF


