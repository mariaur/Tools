# Source the init script
. $PSScriptRoot\sfinit.ps1

# Stop FabricHost
Write-Host
Write-Host "INFO: Stopping Fabric Host ..."
Stop-Service FabricHostSvc -WarningAction SilentlyContinue
Stop-Process -Name FabricHost -ErrorAction SilentlyContinue

Write-Host
Write-Host "INFO: Removing cluster configuration ..."
Remove-ServiceFabricNodeConfiguration -Force 

Write-Host
Write-Host "INFO: Stopping ETW sessions ..."
logman stop FabricAppInfoTraces >$null
logman stop FabricCounters >$null
logman stop FabricLeaseLayerTraces >$null
logman stop FabricQueryTraces >$null
logman stop FabricTraces >$null

Write-Host
Write-Host "INFO: Cleaning up log ($fabricLogRoot) and data ($fabricDataRoot) folders ..."
Remove-Item $fabricLogRoot -Recurse -Force
Remove-Item $fabricDataRoot -Recurse -Force

