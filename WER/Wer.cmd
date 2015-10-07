@echo off

setlocal

set DUMP_FOLDER=C:\LocalDumps

if NOT EXIST %DUMP_FOLDER% (
    md %DUMP_FOLDER%
)

@reg import %~dp0\wer.reg
