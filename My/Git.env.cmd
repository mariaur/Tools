@echo Off
title Git CMD
doskey NP="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey GS=git status
doskey Pull=git pull --rebase --prune $*
doskey Push=git push $*
doskey CO=git checkout "$*"
doskey NB=git checkout -b "$*"
doskey X=exit
doskey Pie=cd "%~dp0\..\..\Ess.PIE"
doskey Portal=cd "%~dp0\..\..\Ess.InsightsPortal"
call "%~dp0\GitDiffSetup.cmd"
pushd .
rem start VS 2017 Prompt
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat" & popd
