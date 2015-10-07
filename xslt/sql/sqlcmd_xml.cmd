@echo off

REM 
REM Wrapper to invoke sqlcmd_xml.ps1
REM
powershell -ExecutionPolicy Unrestricted %~dp0\sqlcmd_xml.ps1 %*

