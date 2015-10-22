# Source the init script
. $PSScriptRoot\sfinit.ps1

if (-not $env:SF_APP_SERVICE_NAMES)
{
    Write-Host
    Write-Host "WARNING: SF_APP_SERVICE_NAMES variable not defined. " -ForegroundColor Yellow
    Write-Host
    Write-Host "Please set this variable with services to deploy. For example - " -ForegroundColor White
    Write-Host
    Write-Host " -> set SF_APP_SERVICE_NAMES=SampleStoreService,FileMetadataService"
    Write-Host
}

if (-not $ClusterConnection)
{
    # connect to local dev cluster
    Connect-ServiceFabricCluster | Out-Null
}

$services = @()

if ($env:PSAPP_SERVICE_NAMES)
{
    $services = @($env:PSAPP_SERVICE_NAMES.Split(',').Trim())
}

Write-Host
Write-Host "INFO: Connected to local dev fabric. " -ForegroundColor White

