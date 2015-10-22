@echo off

setlocal

set SF_CMD=%1

if {"%SF_CMD%"} == {"start"} (
    call %~dp0\cmd\startsf.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"stop"} (
    call %~dp0\cmd\stopsf.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"check"} (
    call %~dp0\cmd\checksf.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"addapp"} (
    call %~dp0\cmd\addsfapp.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"delapp"} (
    call %~dp0\cmd\delsfapp.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"startxp"} (
    call %~dp0\cmd\startsfxperf.cmd %*
    goto :EOF
)
if {"%SF_CMD%"} == {"stopxp"} (
    call %~dp0\cmd\stopsfxperf.cmd %*
    goto :EOF
)

call %~dp0\cmd\sfinit.cmd

echo Commands - 
echo. 
echo    start   - start service fabric (host) with the specified cluster manifest
echo    stop    - stop service fabric
echo    check   - check service fabric connection
echo    addapp  - add (specified) application (and services) to service fabric cluster
echo    delapp  - delete (specified) application (and services) from service fabric cluster
echo    startxp - start xperf session (sf) for service fabric (Microsoft-ServiceFabric) provider 
echo    stopxp  - stop xperf session (sf)
echo. 

goto :EOF

