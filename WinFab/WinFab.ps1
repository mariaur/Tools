$errorActionPreference = 'Stop'

if (-not $env:PSAPP_SERVICE_NAMES)
{
    Write-Host
    Write-Host "PSAPP_SERVICE_NAMES variable not defined. "
    Write-Host "Please set this variable with services to deploy. For example - "
    Write-Host
    Write-Host " -> set PSAPP_SERVICE_NAMES=SampleStoreService,FileMetadataService"
    Write-Host

    throw "PSAPP_SERVICE_NAMES not defined"
}

if (-not $env:PSAPP_PACKAGE_ROOT)
{
    Write-Host
    Write-Host "PSAPP_PACKAGE_ROOT variable not defined. "
    Write-Host "Please set this variable to PSApp package root. For example - "
    Write-Host
    Write-Host " -> set PSAPP_PACKAGE_ROOT=D:\tfs\PS2\public\WinFab Prototype\WDApp\PackageRoot"
    Write-Host

    throw "PSAPP_PACKAGE_ROOT not defined"
}

if (-not $imageStore)
{
    # default image store
    $imageStore = "file:$env:SystemDrive\SfDevCluster\Data\ImageStore"
}

if (-not $ClusterConnection)
{
    # connect to local dev cluster
    Connect-ServiceFabricCluster | Out-Null
}

$services = @($env:PSAPP_SERVICE_NAMES.Split(',').Trim())

Write-Host
Write-Host "INFO: Connected to local dev fabric. "


