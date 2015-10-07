@echo off 

REM 
REM Load the "common" command shell configuration
REM
call "%~dp0\prompt.cmd"

REM
REM Load the Visual Studio command shell configuration
REM
call "%VS140COMNTOOLS%\VsDevCmd.bat"

set PATH=%PATH%;c:\tools\tfs
