$errorActionPreference = 'Stop'

# Setup directories
$clusterDir = "$env:SystemDrive\SfDevCluster"
$fabricLogRoot = "$clusterDir\Log"
$fabricDataRoot = "$clusterDir\Data"

# default image store
$imageStore = "file:$fabricDataRoot\ImageStore"


# Cluster manifest
if (-not $env:SF_CLUSTER_MANIFEST)
{
    # Default to "one-node" cluster manifest
    $env:SF_CLUSTER_MANIFEST = Resolve-Path "$PSScriptRoot\..\xml\ClusterManifest.OneNode.xml"
}

$clusterManifest = $env:SF_CLUSTER_MANIFEST


# Service fabric app name
if (-not $env:SF_APP_NAME)
{
    $env:SF_APP_NAME = 'PSApp'
}

$fabricAppName = $env:SF_APP_NAME

# Derive the app package name (based on the app name)
$fabricAppPkgName = $fabricAppName + 'Pkg'

Write-Host
Write-Host "Environment variables - " -ForegroundColor White
Write-Host
Write-Host " -> SF_CLUSTER_MANIFEST     - $env:SF_CLUSTER_MANIFEST"
Write-Host " -> SF_APP_NAME             - $env:SF_APP_NAME"
Write-Host " -> SF_APP_PACKAGE_ROOT     - $env:SF_APP_PACKAGE_ROOT"
Write-Host " -> SF_APP_SERVICE_NAMES    - $env:SF_APP_SERVICE_NAMES"
Write-Host

