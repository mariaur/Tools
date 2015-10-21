. $PSScriptRoot\delsfsvc.ps1

$packagePath = $env:PSAPP_PACKAGE_ROOT

Write-Host
Write-Host "INFO: Copying application package ..."
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $packagePath -ImageStoreConnectionString $imageStore -ApplicationPackagePathInImageStore 'PSAppPkg' -Verbose -Debug -ErrorAction Stop

Write-Host
Write-Host "INFO: Registering application type ..."
Register-ServiceFabricApplicationType -ApplicationPathInImageStore 'PSAppPkg'

Write-Host
Write-Host "INFO: Creating application instance ..."
New-ServiceFabricApplication -ApplicationName 'fabric:/PSApp' -ApplicationTypeName PSApp -ApplicationTypeVersion 1.0

Write-Host
Write-Host "INFO: Creating services ..."

$statefulSvcs = @('RelationshipService', 'FileMetadataService', 'ExplodeQueueService')

$statefulSvcParams = " -Stateful -HasPersistedState -PartitionSchemeUniformInt64 -PartitionCount 2 -LowKey 0 -HighKey 1 -TargetReplicaSetSize 3 -MinReplicaSetSize 2"
$statelessSvcParams = " -Stateless -PartitionSchemeSingleton -InstanceCount 1"

$services | % {

    $addsvc = "New-ServiceFabricService -ApplicationName 'fabric:/PSApp' -ServiceName 'fabric:/PSApp/$_' -ServiceTypeName '$($_)Type'"

    if ($statefulSvcs -contains $_)
    {
        $addsvc += $statefulSvcParams
    }
    else
    {
        $addsvc += $statelessSvcParams
    }

    iex $addsvc
}

