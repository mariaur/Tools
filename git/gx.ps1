$ErrorActionPreference = 'Stop'

# Get a list of all Git repositories
$gitdirs = (Get-ChildItem -Directory | ? { Test-Path "$_\.git" -PathType Container })

$args = $args | ? {$_} | % {"`"$_`""}
if ($args)
{
    $cmd = '& ' + ($args -join ' ')
}

# Invoke the command in each repo
$gitdirs | % {

    $dir = $pwd
    cd $_; Write-Host "`n-> [ $_ ]" -ForegroundColor Yellow

    try
    {
        if ($cmd)
        {
            iex $cmd
        }
    }
    finally
    {
        cd $dir
    }
}

