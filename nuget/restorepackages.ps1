param($outDir = "nupkg")

$configs = Get-ChildItem packages.config -ErrorAction SilentlyContinue -Recurse -File

$ErrorActionPreference = 'Stop'

# Pass arguments to the command line below via 
# environment variables
$pkgSource_PsNuGet = "http://ps-nuget/nuget/"
$pkgSource_MsNuGet = "https://ms-nuget.cloudapp.net/api/v2/"
$pkgSource_Azure = "\\wanuget04\NugetPackages\Official"

# Private feed
$pkgSource_Private = "\\kalindev\shared\NuGet"

$env:NUPKG_SOURCES = " -Source `"$pkgSource_PsNuGet`" -Source `"$pkgSource_MsNuGet`" -Source `"$pkgSource_Azure`""
$env:NUPKG_SOURCES += " -Source `"$pkgSource_Private`""
$env:NUPKG_OUTDIR=$outDir

$configs | % {
    $env:NUPKG_CONFIG = $_.FullName
    Write-Host " -> $env:NUPKG_CONFIG"
 
    nuget.exe --% restore %NUPKG_SOURCES% -ConfigFile "%NUPKG_CONFIG%" -OutputDirectory "%NUPKG_OUTDIR%"

    if ($LastExitCode -ne 0) {
        throw "Command (nuget.exe) failed with exit code $LastExitCode."
    }
}

