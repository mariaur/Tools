$ErrorActionPreference = 'Stop'

# Common NuGet package sources
$global:pkgSources = [ordered]@{
    # NuGet official feed
    Nuget = "https://www.nuget.org/api/v2/";

    # Protection Services (PS) NuGet feed
    PsNuget = "http://ps-nuget/nuget/";

    # Microsoft feed
    MsNuget = "https://ms-nuget.cloudapp.net/api/v2/";

    # Azure official feed
    Azure_Official = "http://wanuget/official/nuget";

    # Azure toolset feed
    Azure_ToolSet = "http://wanuget/toolset/nuget";
}

$global:NuGetExe = (Join-Path $PSScriptRoot .\nuget.exe)
$global:NuGetCfg = (Join-Path $PSScriptRoot .\NuGetPS.Config)


<#
    Retrieves a list of NuGet packages from various feeds
#>
function global:List-NuGetPackages(
    [Parameter(Mandatory=$true)]
    [string]$packageName, 

    # all versions
    [switch]$a = $false, 

    # verbose
    [switch]$v = $false, 

    # optional package source
    [string]$packageSource
    )
{
    Write-Host
    Write-Host "INFO: Retrieving packages for '$packageName'. Please wait..."  -ForegroundColor White

    if ($packageSource)
    {
        $pkgSources = @{ "<UserInput>" = $packageSource }
    }

    $pkgSources.GetEnumerator() | % {

        $pkgName = $_.Key; $pkgUrl = $_.Value

        Write-Host
        Write-Host "-> $pkgName [ $pkgUrl ] ..." -ForegroundColor Yellow

        $NuGetCmd = "$NuGetExe list $packageName -ConfigFile $NuGetCfg -Source $pkgUrl -Pre "

        if ($a)
        {
            $NuGetCmd += " -AllVersions"
        }
        if ($v)
        {
            $NuGetCmd += " -Verbosity detailed"
        }

        iex $NuGetCmd
    }
}

<#
    Gets (copy locally) a single NuGet package
#>
function global:Get-NuGetPackage(
    [Parameter(Mandatory=$true)]
    [string]$packageName, 

    # optional package source
    [string]$packageVersion, 

    # optional package source
    [string]$packageSource
    )
{
    Write-Host
    Write-Host "INFO: Retrieving package '$packageName $packageVersion' to 'nupkg'. Please wait..." -ForegroundColor White
    Write-Host

    if ($packageSource)
    {
        $pkgSources = "-Source $packageSource "
    }

    # append the default package sources
    $pkgSources += ($global:pkgSources.Values | % { "-Source $_" } ) -join ' '

    # compose and execute the NuGet command
    $NuGetCmd = "$NuGetExe install $packageName -Version $packageVersion -ConfigFile $NuGetCfg $pkgSources -OutputDirectory nupkg -Pre"
    iex $NuGetCmd
}

<#
    Restores NuGet packages, based on packages.config 
    in directory tree (solution)
#>
function global:Restore-NuGetPackages(
    # optional package source
    [string]$packageSource
    )
{
    Write-Host
    Write-Host "INFO: Restoring packages to 'nupkg'. Please wait..." -ForegroundColor White

    if ($packageSource)
    {
        $pkgSources = "-Source $packageSource "
    }

    # append the default package sources
    $pkgSources += ($global:pkgSources.Values | % { "-Source $_" } ) -join ' '

    # enumerate packages.config
    $pkgConfigFiles = Get-ChildItem packages.config -ErrorAction SilentlyContinue -Recurse -File

    # capture output directory
    $pkgOutDir = Join-Path $PWD nupkg

    if ($pkgConfigFiles.Length -eq 0)
    {
        Write-Host
        Write-Host "Package configurations (packages.config) not found (no action taken). " -ForegroundColor Yellow
    }
    else
    {
        $pkgConfigFiles | % {

            $pkgConfigFile = $_.FullName

            $pkgDir = [IO.Path]::GetDirectoryName($pkgConfigFile); Set-Location $pkgDir

            Write-Host
            Write-Host "-> $pkgConfigFile" -ForegroundColor Yellow

            $NuGetCmd = "$NuGetExe restore -ConfigFile $NuGetCfg $pkgSources -PackagesDirectory `"$pkgOutDir`""
            iex $NuGetCmd
        }
    }
}

