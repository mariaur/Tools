@echo off

setlocal

set XSLTCMD_MSXML=cscript /nologo %~dp0\xslt.js %*
set XSLTCMD_DOTNET=powershell -ExecutionPolicy Unrestricted %~dp0\xslt.ps1 %*

if {%XSLT_USE_MSXML%} NEQ {} (
    %XSLTCMD_MSXML%
) else (
    %XSLTCMD_DOTNET%
)

