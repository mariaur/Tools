param(
    [Parameter(Mandatory=$true)]
    [string[]]$pkgs
    )

$errorActionPreference = 'Stop'

Write-Host

$pkgs | % {
    $pkg = $_

    cd $pkg

    Write-Host " >>> BUILDING [ $_ ] <<< " -fore Yellow
    iex "msbuild /v:minimal /fl /flp:verbosity=normal /m /p:BuildRelease=true"
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error "Building '$_' failed. "
    }

    Write-Host " >>> PUSHING [ $_ ] <<< "  -fore Yellow
    iex "$($env:RepoRoot)\.init\nuget\nugetpush.cmd"
    if ($LASTEXITCODE -ne 0)
    {
        Write-Error "Pushing '$_' failed. "
    }

    cd ..
}

Write-Host
Write-Host "Done. " -fore Green

