. $PSScriptRoot\sfapp.ps1

function TryAction($action) { try { & $action } catch { Write-Host " -> $_" -ForegroundColor Yellow } }

if ($services)
{
    Write-Host
    Write-Host "INFO: Removing services ... "

    $services | % {
        Write-Host " -> ($_) ..."
        TryAction { Remove-ServiceFabricService -ServiceName "fabric:/$fabricAppName/$($_)" -Force }
    }
}

Write-Host
Write-Host "INFO: Removing application ..."
TryAction { Remove-ServiceFabricApplication -ApplicationName "fabric:/$fabricAppName" -Force }

Write-Host
Write-Host "INFO: Removing application type ..."
TryAction { Unregister-ServiceFabricApplicationType -ApplicationTypeName $fabricAppName -ApplicationTypeVersion 1.0 -Force }

Write-Host
Write-Host "INFO: Removing application package ..."
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore $fabricAppPkgName -ImageStoreConnectionString $imageStore

