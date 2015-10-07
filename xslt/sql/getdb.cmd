@echo off

if {%1} == {/?} goto :USAGE
if {%1} == {-?} goto :USAGE

REM 
REM Default to localhost
REM
set SERVERNAME=localhost

set SCRIPTDIR=%~dp0

set SCHEMAONLY=
if {%1} == {-schemaonly} set SCHEMAONLY=1&shift

set DATABASENAME=%1

if {%DATABASENAME%} == {} goto :USAGE

if {%2} NEQ {} set SERVERNAME=%2

echo.
echo Getting data for database %DATABASENAME% on %SERVERNAME% ...

echo.
echo 1. Obtaining database schema -^> _database.xml ...
sqlcmd -i %SCRIPTDIR%\sqlcmd_xml.sql -S %SERVERNAME% -d %DATABASENAME% -v InputFile="%SCRIPTDIR%\database.sql" -o _database.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR
call %SCRIPTDIR%\sqlcmd_xml.cmd _database.xml _database.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR

if {%SCHEMAONLY%} == {1} goto :EXIT

echo.
echo 2. Generating table data SQL script -^> _gettabledata.sql ...
call %SCRIPTDIR%\..\xslt.cmd _database.xml %SCRIPTDIR%\tabledata.xslt _gettabledata.sql dataOnly
if %ERRORLEVEL% NEQ 0 goto :ERROR

echo.
echo 3. Retrieving all data as XML -^> _tabledata.xml ...
sqlcmd -i %SCRIPTDIR%\sqlcmd_xml.sql -S %SERVERNAME% -d %DATABASENAME% -v InputFile=_gettabledata.sql -o _tabledata.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR
call %SCRIPTDIR%\sqlcmd_xml.cmd _tabledata.xml _tabledata.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR

echo.
echo 4. Generating INSERT statements -^> _tabledata.sql ...
call %SCRIPTDIR%\..\xslt.cmd _tabledata.xml %SCRIPTDIR%\tableins.xslt _tabledata.sql tableSpecFile=%CD%\_database.xml
if %ERRORLEVEL% NEQ 0 goto :ERROR

:EXIT
echo.
echo -^> Success.

goto :EOF

:USAGE

echo.
echo USAGE: getdb.cmd [-schemaonly] ^<database^> [^<server^>]
echo.

goto :EOF

:ERROR

echo.
echo -^> Failed!
echo.

goto :EOF

