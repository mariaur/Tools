@echo off
setlocal

set args=%*
set args=%args:"=\"%
@powershell %~dp0\gx.ps1 '%args%'
