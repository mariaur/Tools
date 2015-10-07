@echo off

setlocal

set SCRIPTCMD=call %~dp0\xslt.cmd

if NOT EXIST "%1" (
    goto :USAGE
)

echo.
echo Info: Generating summary...
%SCRIPTCMD% %1 %~dp0\docsummary.xslt docsummary.txt inputFileName="%CD%\%1" %DOCSUMMARY_PARAMS%
if %errorlevel% NEQ 0 goto :ERROR

echo.
echo Done.

goto :EOF

:USAGE

echo.
echo Usage: docsummary ^<xml file^>

goto :EOF

:ERROR

echo.
echo Failed!
goto :EOF


