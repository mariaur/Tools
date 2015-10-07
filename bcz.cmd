@echo off 

setlocal

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
        msbuild %*
    )
)
