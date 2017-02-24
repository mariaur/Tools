. $PSScriptRoot\sfapp.ps1

function TryAction($action) { try { & $action } catch { Write-Host "  -> $_" -ForegroundColor Yellow } }

if ($services)
{
    Write-Host
    Write-Host "INFO: Removing services ... "

    $services | % {
        
        $serviceName = $_.Split(':')[0]

        Write-Host " -> '$serviceName' ..."
        TryAction { Remove-ServiceFabricService -ServiceName "fabric:/$fabricAppInstance/$serviceName" -Force }
    }
}

Write-Host
Write-Host "INFO: Removing application ('fabric:/$fabricAppInstance') ..."
TryAction { Remove-ServiceFabricApplication -ApplicationName "fabric:/$fabricAppInstance" -Force }

Write-Host
Write-Host "INFO: Removing application type ('$fabricAppType') ..."
TryAction { Unregister-ServiceFabricApplicationType -ApplicationTypeName $fabricAppType -ApplicationTypeVersion 1.0 -Force }

Write-Host
Write-Host "INFO: Removing application package ('$fabricAppPkgName') ..."
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore $fabricAppPkgName -ImageStoreConnectionString $imageStore

