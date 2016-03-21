@echo Off
title WDGit CMD
doskey np="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey gs=git status
doskey pull=git pull
doskey push=git push
doskey cp=pushd C:\Git\WD.Services.CloudProtection
doskey prepush=call C:\Git\Tools\git\validate.cmd
doskey deploy=powershell "C:\Git\WD.Services.CloudProtection\Scripts\Redeploy-CloudProtectionToDevCluster.ps1" $*
rem start VS 2015.1 Prompt
"%VS140COMNTOOLS%\VsDevCmd.bat" amd64
