param([string]$_, [string]$nodeType = "SingleNodeType")

# Source the init script
. $PSScriptRoot\sfinit.ps1

# Cluster manifest placeholder
$nodeTypePlaceholder = '$$$SingleNodeType$$$'

# Get the node type (specialized) cluster manifest file name
$clusterManifestForNodeType = Join-Path ([IO.Path]::GetTempPath()) (Split-Path $clusterManifest -Leaf)

Write-Host
Write-Host "INFO: Creating cluster manifest for node type '$nodeType' ('$clusterManifest' -> '$clusterManifestForNodeType') ..."

(Get-Content -Raw $clusterManifest).Replace($nodeTypePlaceholder, $nodeType) | Set-Content $clusterManifestForNodeType -Force

# Check the cluster manifest
Write-Host
Write-Host "INFO: Checking cluster manifest ('$clusterManifestForNodeType') ..."
Test-ServiceFabricClusterManifest -ClusterManifestPath "$clusterManifestForNodeType"

Write-Host
Write-Host "INFO: Creating cluster node configuration ..."
New-ServiceFabricNodeConfiguration -RunFabricHostServiceAsManual -ClusterManifestPath $clusterManifestForNodeType `
    -FabricDataRoot $fabricDataRoot -FabricLogRoot $fabricLogRoot -Verbose 

# Start the Service Fabric host
Write-Host
Write-Host "INFO: Starting service fabric host ..."

$fabricHost = "$env:ProgramFiles\Microsoft Service Fabric\bin\FabricHost.exe"
$arguments = '-c -activateHidden'
Start-Process $fabricHost $arguments

