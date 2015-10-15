@echo off 

setlocal

set MSBUILD_COMMON_ARGS=/v:minimal /fl /flp:verbosity=normal

if {%INETROOT%} NEQ {} (
    REM CorExt
    if {"%1"} == {"-pp"} (
        %BUILD_MSBUILD_PROGRAM% /pp:out.xml %*
    ) else (
        build -cZP %*
    )
) else (
    REM VS/.NET Tools
    if {"%1"} == {"-pp"} (
        msbuild /pp:out.xml %*
    ) else (
        msbuild %MSBUILD_COMMON_ARGS% %*
    )
)
