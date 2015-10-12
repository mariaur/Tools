@echo off 

REM 
REM Load the "common" command shell configuration
REM
call "%~dp0\prompt.cmd"

REM
REM Load the Visual Studio command shell configuration
REM
set VSTOOLSCMD=""

if DEFINED VS140COMNTOOLS (
    set VSTOOLSCMD="%VS140COMNTOOLS%\VsDevCmd.bat"
) else (
    if DEFINED VS120COMNTOOLS (
        set VSTOOLSCMD="%VS120COMNTOOLS%\VsDevCmd.bat"
    )
)

if {%VSTOOLSCMD%} == {""} (
    echo.
    echo ERROR: Visual Studio Tools not found!
    goto :EOF
)

call %VSTOOLSCMD% amd64

set PATH=%PATH%;c:\tools\tfs
