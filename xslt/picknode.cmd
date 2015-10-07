@echo off

setlocal

if NOT EXIST "%1" (
    goto :USAGE
)

if {%2} == {} (
    goto :USAGE
)

set PICKNODE_XSLT=%TEMP%\picknode.xslt

echo. 
echo Info: Customizing transformation...
powershell -ExecutionPolicy Unrestricted -Command "(Get-Content -Raw %~dp0\picknode.xslt).Replace('{{{XPATH}}}', '%2').Replace('{{{THISPATH}}}', '%~dp0') | Out-File %PICKNODE_XSLT% -Force"
if %ERRORLEVEL% NEQ 0 goto :ERROR

echo. 
echo Info: Transforming to pickednodes.xml ...
call %~dp0\xslt.cmd %1 %PICKNODE_XSLT% pickednodes.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR

echo.
echo Done.

goto :EOF

:ERROR

echo.
echo Failed!

goto :EOF

:USAGE

echo.
echo Usage: picknode.cmd ^<xmlfile^> ^<xpath^>

goto :EOF

