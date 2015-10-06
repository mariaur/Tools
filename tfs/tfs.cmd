@echo off

setlocal

REM
REM Pick up the command
REM

set TFS_CMD=%1
shift

set TFS_ARGS=

:NEXT_ARG

if {"%1"} NEQ {""} (
    if {"%1"} == {"-n"} (
        set TFS_PREVIEW=/preview
    ) else (
        set TFS_ARGS=%TFS_ARGS% %1
    )
    shift
    goto :NEXT_ARG
)

REM 
REM Dispatch the commands
REM

set TFS_CMD_USAGE=1

if "%TFS_CMD%" == "online" (
    call :TFS_ONLINE
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "clean" (
    call :TFS_CLEAN
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "diff" (
    call :TFS_DIFF
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "list" (
    call :TFS_LIST
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "view" (
    call :TFS_VIEW
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "uu" (
    call :TFS_UU
    set TFS_CMD_USAGE=
)
if "%TFS_CMD%" == "ss" (
    call :TFS_SS
    set TFS_CMD_USAGE=
)

if "%TFS_CMD_USAGE%" == "1" (
    call :TFS_USAGE
)


goto :EOF

:TFS_USAGE
echo.
echo Usage: tfs ^<command^> [tfs options]
echo.           
echo.   commands - 
echo.       online - reconcile ("online") local changes with TFS
echo.       clean  - clean ("scorch") local workspace directory
echo.       diff   - diff ("review") pending changes
echo.       list   - changeset history (list)
echo.       view   - view (one) changeset
echo.       uu     - undo redundant changes
echo.       ss     - status of the current directory (tree)
echo.           
echo.   options - 
echo.       [-n] - preview (simulate) command
echo.
goto :EOF


:TFS_ONLINE
tfpt online . %TFS_ARGS% /r %TFS_PREVIEW% /noprompt /exclude:.git /adds /deletes /diff
goto :EOF

:TFS_CLEAN
tfpt scorch . %TFS_ARGS% /r %TFS_PREVIEW% /noprompt /exclude:.git /deletes /diff
goto :EOF

:TFS_DIFF
tfpt review . %TFS_ARGS%  /r
goto :EOF

:TFS_LIST

if {"%TFS_ARGS%"} == {""} (
    tf hist . /r /noprompt /stopafter:30
) else (
    call :TFS_LIST_ARGS
)

goto :EOF

:TFS_LIST_ARGS
if {"%TFS_ARGS:stopafter=%"} NEQ {"%TFS_ARGS%"} (
    tf hist . %TFS_ARGS% /r /noprompt
) else (
    tf hist . %TFS_ARGS% /r /noprompt /stopafter:30
)

goto :EOF

:TFS_VIEW
tf changeset %TFS_ARGS%
goto :EOF

:TFS_UU
tfpt uu . /r /noprompt
goto :EOF

:TFS_SS
tf status . /r
goto :EOF

