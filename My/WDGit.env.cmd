@echo Off
title WDGit CMD
doskey NP="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey GS=git status
doskey Pull=git pull
doskey Push=git push
doskey cdcp=pushd "%~dp0\..\..\WD.Services.CloudProtection"
doskey StashPull=call "%~dp0\StashPull.cmd"
doskey Validate=call "%~dp0\Validate.cmd"
rem start VS 2015.2 Prompt
"%VS140COMNTOOLS%\VsDevCmd.bat" amd64
call '%~dp0\GitDiffSetup.cmd'