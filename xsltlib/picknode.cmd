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
copy /y %~dp0\picknode.xslt %PICKNODE_XSLT% 2>nul 1>nul
if %ERRORLEVEL% NEQ 0 goto :ERROR

rep -noundo -find:{{{XPATH}}} -replace:%2 -find:{{{THISPATH}}} -replace:%~dp0 %PICKNODE_XSLT% 1>nul
if %ERRORLEVEL% NEQ 0 goto :ERROR

echo. 
echo Info: Transforming to picknode.xml ...
call %~dp0\xslt.cmd %1 %PICKNODE_XSLT% picknode.xml
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

