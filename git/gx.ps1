param($cmd)
$ErrorActionPreference = 'Stop'

# Get a list of all Git repositories
$gitdirs = (Get-ChildItem -Directory | ? { Test-Path "$_\.git" -PathType Container })

$isEmptyCmd = ($cmd -eq '="')

# Invoke the command in each repo
$gitdirs | % {

    $dir = $pwd
    cd $_; Write-Host "`n-> [ $_ ]" -ForegroundColor Yellow

    try
    {
        if (-not $isEmptyCmd)
        {
            iex $cmd
        }
    }
    finally
    {
        cd $dir
    }
}

