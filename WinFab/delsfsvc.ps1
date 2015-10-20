. $PSScriptRoot\WinFab.ps1

function TryAction($action) { try { & $action } catch { Write-Host " -> $_" -ForegroundColor Yellow } }

Write-Host
Write-Host "INFO: Removing services ... "

$services | % {
    Write-Host " -> ($_) ..."
    TryAction { Remove-ServiceFabricService -ServiceName "fabric:/PSApp/$($_)" -Force }
}

Write-Host
Write-Host "INFO: Removing application ..."
TryAction { Remove-ServiceFabricApplication -ApplicationName 'fabric:/PSApp' -Force }

Write-Host
Write-Host "INFO: Removing application type ..."
TryAction { Unregister-ServiceFabricApplicationType -ApplicationTypeName PSApp -ApplicationTypeVersion 1.0 -Force }

Write-Host
Write-Host "INFO: Removing application package ..."
Remove-ServiceFabricApplicationPackage -ApplicationPackagePathInImageStore 'PSAppPkg' -ImageStoreConnectionString $imageStore

