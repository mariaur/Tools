. $PSScriptRoot\sfapp.ps1

function TryAction($action) { try { & $action } catch { Write-Host "  -> $_" -ForegroundColor Yellow } }

if ($services)
{
    Write-Host
    Write-Host "INFO: Removing services ... "

    $services | % {
        
        $serviceName = $_.Split(':')[0]

        Write-Host " -> '$serviceName' ..."
        TryAction { Remove-ServiceFabricService -ServiceName "fabric:/$fabricAppName/$serviceName" -Force }
    }
}

Write-Host
Write-Host "INFO: Removing application ('fabric:/$fabricAppName') ..."
TryAction { Remove-ServiceFabricApplication -ApplicationName "fabric:/$fabricAppName" -Force }

Write-Host
Write-Host "INFO: Removing application type ('$fabricAppName') ..."
TryAction { Unregister-ServiceFabricApplicationType -ApplicationTypeName $fabricAppName -ApplicationTypeVersion 1.0 -Force }

Write-Host
Write-Host "INFO: Removing application package ('$fabricAppPkgName') ..."
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore $fabricAppPkgName -ImageStoreConnectionString $imageStore

