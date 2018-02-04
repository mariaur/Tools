@powershell -ExecutionPolicy Bypass -NoExit -Command "Import-Module %~dp0\ssapi.psm1 -ArgumentList @('%1', $true)"
