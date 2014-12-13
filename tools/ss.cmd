@echo off
setlocal 

REM 
REM Temp file name
REM 
set TMPFILENAME=%TEMP%\$$$search_tmp$$$
set EDITOR_CMD=gvim.exe -q

REM 
REM Grep command variables - add more file exts here
REM
set GREP_CMD=findstr
set GREP_CMD_DEFAULT_FILEEXT=*.cpp *.h *.inl *.c *.def *.plt *.cxx *.hxx *.hpp *.cs *.cmd sources *.wxs *.wxi *.inc *.cmn *.mc *.asm *.sql *.config *.mk *.xml *.rc *.vbs *.idl *.man *.w *.scopet4
set GREP_CMD_DEFAULT_OPT=/s /i /n


REM
REM Internal variables
REM
SET NOOPT=0
SET NOEXT=0
SET UI=0

 
SET CMD_LINE_ARGS=



if {%1} == {} (
    goto USAGE
)


REM 
REM Parse command line arguments
REM 
:NextArg
if {%1} == {} (
    goto ArgsDone
)


if %1 == -noopt (
    SET NOOPT=1    
    goto ContinueArg
)

if %1 == -noext (
    SET NOEXT=1    
    goto ContinueArg
)

if %1 == -ui (
    SET UI=1    
    goto ContinueArg
)


REM 
REM Collect all the other arguments in CMD_LINE_ARGS
REM
SET CMD_LINE_ARGS=%CMD_LINE_ARGS% %1

:ContinueArg
shift /1
goto NextArg

:ArgsDone

REM 
REM Execute search 
REM
if %NOOPT% NEQ 1 (
    SET GREP_CMD=%GREP_CMD% %GREP_CMD_DEFAULT_OPT%
)

SET GREP_CMD=%GREP_CMD% %CMD_LINE_ARGS%

if %NOEXT% NEQ 1 (
    SET GREP_CMD=%GREP_CMD% %GREP_CMD_DEFAULT_FILEEXT%
)

echo. 
echo SS: Executing %GREP_CMD%
echo SS: Please wait...
echo.

if %UI% == 1 (
    %GREP_CMD% > %TMPFILENAME%
    start %EDITOR_CMD% %TMPFILENAME%
) else (
    %GREP_CMD%
)


goto END


:USAGE
echo. 
echo    ss: Search for pattern in source files
echo. 
echo    USAGE: ss [-noopt] [-noext] [-ui] ^<pattern^> [^<additional file extensions^>]
echo.
echo                -noopt - do not include default search options (%GREP_CMD_DEFAULT_OPT%)
echo                -noext - do not include default file extensions (%GREP_CMD_DEFAULT_FILEEXT%)
echo                -ui    - show results in editor (%EDITOR_CMD%)
echo. 
goto END


:END
endlocal


