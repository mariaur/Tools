param($cmd)
$ErrorActionPreference = 'Stop'

# Get a list of all Git repositories
$gitdirs = (Get-ChildItem -Directory | ? { Test-Path "$_\.git" -PathType Container })

# Invoke the command in each repo
$gitdirs | % {

    $dir = $pwd
    cd $_; Write-Host "`n-> [ $_ ]" -ForegroundColor Yellow

    try
    {
        # Note: handle empty input
        if ($cmd -ne '="')
        {
            iex $cmd
        }
    }
    finally
    {
        cd $dir
    }
}

