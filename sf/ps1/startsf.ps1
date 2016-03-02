# Source the init script
. $PSScriptRoot\sfinit.ps1

# Check the cluster manifest
Write-Host
Write-Host "INFO: Checking cluster manifest ($clusterManifest) ..."
Test-ServiceFabricClusterManifest -ClusterManifestPath $clusterManifest | Out-Null

Write-Host
Write-Host "INFO: Creating cluster node configuration ..."
New-ServiceFabricNodeConfiguration -RunFabricHostServiceAsManual -ClusterManifestPath $clusterManifest `
    -FabricDataRoot $fabricDataRoot -FabricLogRoot $fabricLogRoot -Verbose 

# Start the Service Fabric host
Write-Host
Write-Host "INFO: Starting service fabric host ..."

$fabricHost = "$env:ProgramFiles\Microsoft Service Fabric\bin\FabricHost.exe"
$arguments = '-c -activateHidden'
Start-Process $fabricHost $arguments

