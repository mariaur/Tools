@echo Off
title Git CMD
doskey NP="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey GS=git status
doskey Pull=git pull --rebase
doskey Push=git push $*
doskey co=git checkout "$*"
doskey nb=git checkout -b "$*"
doskey ..=cd ..
rem start VS 2015.2 Prompt
"%VS140COMNTOOLS%\VsDevCmd.bat" amd64
call '%~dp0\GitDiffSetup.cmd'