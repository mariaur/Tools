@echo Off
title WDGit CMD
doskey NP="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
doskey GS=git status
doskey Pull=git pull
doskey Push=git push
doskey cdcp=pushd C:\Git\WD.Services.CloudProtection
doskey StashPull=call "%~dp0\StashPull.cmd"
doskey Validate=call "%~dp0\Validate.cmd"
doskey StartSF=powershell "C:\Git\WD.Services.CloudProtection\Scripts\Restart-ServiceFabricDevCluster.ps1 $*"
doskey DeployCP=powershell "C:\Git\WD.Services.CloudProtection\Scripts\Redeploy-CloudProtectionToDevCluster.ps1 CloudEngine $*"
rem start VS 2015.2 Prompt
"%VS140COMNTOOLS%\VsDevCmd.bat" amd64
call '%~dp0\GitDiffSetup.cmd'