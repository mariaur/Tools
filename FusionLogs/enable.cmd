@echo off

setlocal

if NOT exist C:\FusionLogs (
    mkdir C:\FusionLogs
)

@reg import %~dp0\enablelog.reg
