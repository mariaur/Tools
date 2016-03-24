@echo Off
title WDGit CMD
doskey np="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey gs=git status
doskey pull=git pull
doskey push=git push
doskey cdcp=pushd C:\Git\WD.Services.CloudProtection
doskey Validate=call C:\Git\Tools\WDGit\validate.cmd
doskey deploy=powershell "C:\Git\WD.Services.CloudProtection\Scripts\Redeploy-CloudProtectionToDevCluster.ps1" $*
doskey PushApp=call C:\Git\Tools\WDGit\PushAppPPE.cmd
rem start VS 2015.1 Prompt
"%VS140COMNTOOLS%\VsDevCmd.bat" amd64
