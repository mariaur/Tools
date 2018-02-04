. $PSScriptRoot\sfapp.ps1

if (-not $env:SF_APP_PACKAGE_ROOT)
{
    Write-Host
    Write-Host "ERROR: SF_APP_PACKAGE_ROOT variable not defined. " -ForegroundColor Red
    Write-Host
    Write-Host "Please set this variable to App package root. For example - " -ForegroundColor White
    Write-Host
    Write-Host " -> set SF_APP_PACKAGE_ROOT=D:\tfs\PS2\public\WinFab Prototype\WDApp\PackageRoot"
    Write-Host

    throw "SF_APP_PACKAGE_ROOT not defined"
}

$packagePath = $env:SF_APP_PACKAGE_ROOT

Write-Host
Write-Host "INFO: Copying application package ('$fabricAppPkgName') ..."
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $packagePath -ImageStoreConnectionString $imageStore -ApplicationPackagePathInImageStore $fabricAppPkgName -Verbose -Debug -ErrorAction Stop

Write-Host
Write-Host "INFO: Registering application type ..."
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $fabricAppPkgName

Write-Host
Write-Host "INFO: Creating application instance ('fabric:/$fabricAppInstance') ..."
New-ServiceFabricApplication -ApplicationName "fabric:/$fabricAppInstance" -ApplicationTypeName $fabricAppType -ApplicationTypeVersion 1.0

if ($services)
{
    Write-Host
    Write-Host "INFO: Creating services ..."

    # stateful service parameters
    $statefulSvcParams = " -Stateful -HasPersistedState -PartitionSchemeUniformInt64 -PartitionCount 1 -LowKey 0 -HighKey 0 -TargetReplicaSetSize 1 -MinReplicaSetSize 1"

    # stateless service parameters
    $statelessSvcSingletonParams = " -Stateless -PartitionSchemeSingleton -InstanceCount 1"
    $statelessSvcPartitionedParams = " -Stateless -PartitionSchemeUniformInt64 -PartitionCount 1 -LowKey 0 -HighKey 0 -InstanceCount 1"

    $services | % {

        $serviceName = $_.Split(':')[0]

        # Check for stateful service
        $statefulSvc = ($_.Split(':')[1] -eq 's')

        $addsvc = "New-ServiceFabricService -ApplicationName 'fabric:/$fabricAppInstance' -ServiceName 'fabric:/$fabricAppInstance/$serviceName' -ServiceTypeName '$($serviceName)Type'"

        if ($statefulSvc)
        {
            $addsvc += $statefulSvcParams
        }
        else
        {
            # Check for partitioned stateless service
            $partitioned = ($_.Split(':')[1] -eq 'p')

            if ($partitioned)
            {
                $addsvc += $statelessSvcPartitionedParams
            }
            else
            {
                $addsvc += $statelessSvcSingletonParams
            }
        }

        Write-Host " -> '$serviceName' ..."
        iex $addsvc
    }
}

