param([string]$_, [string]$nodeDomainType = "MT")

# Source the init script
. $PSScriptRoot\sfinit.ps1

# Cluster manifest placeholder
$nodeDomainTypePlaceholder = '$$$NodeDomainType$$$'

# Get the node type (specialized) cluster manifest file name
$clusterManifestForNodeDomainType = Join-Path ([IO.Path]::GetTempPath()) (Split-Path $clusterManifest -Leaf)

Write-Host
Write-Host "INFO: Creating cluster manifest for node domain type '$nodeDomainType' ('$clusterManifest' -> '$clusterManifestForNodeDomainType') ..."

(Get-Content -Raw $clusterManifest).Replace($nodeDomainTypePlaceholder, $nodeDomainType) | Set-Content $clusterManifestForNodeDomainType -Force

# Check the cluster manifest
Write-Host
Write-Host "INFO: Checking cluster manifest ('$clusterManifestForNodeDomainType') ..."
Test-ServiceFabricClusterManifest -ClusterManifestPath "$clusterManifestForNodeDomainType"

Write-Host
Write-Host "INFO: Creating cluster node configuration ..."
New-ServiceFabricNodeConfiguration -RunFabricHostServiceAsManual -ClusterManifestPath $clusterManifestForNodeDomainType `
    -FabricDataRoot $fabricDataRoot -FabricLogRoot $fabricLogRoot -Verbose 

# Start the Service Fabric host
Write-Host
Write-Host "INFO: Starting service fabric host ..."

$fabricHost = "$env:ProgramFiles\Microsoft Service Fabric\bin\FabricHost.exe"
$arguments = '-c -activateHidden'
Start-Process $fabricHost $arguments

