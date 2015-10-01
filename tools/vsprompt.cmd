@echo off 

REM 
REM Load the "common" command shell configuration
REM
call "%~dp0\prompt.cmd"

REM
REM Load the Visual Studio command shell configuration
REM
call "%VS140COMNTOOLS%\VsDevCmd.bat"

doskey root=pushd d:\tfs
set PATH=%PATH%;c:\tools\tfs
