# stop on error
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression.FileSystem

function global:Create-Zip(
    [Parameter(Mandatory=$true)]
    [string]$sourcePath, 
    [Parameter(Mandatory=$true)]
    [string]$zipFile, 

    # use force (overwrite zip file, if exists)
    [Alias("f")]
    [switch]$force = $false
    )
{
    if ($force)
    {
        if (Test-Path $zipFile)
        {
            Remove-Item $zipFile
        }
    }

    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcePath, $zipFile)
}

function global:Expand-Zip(
    [Parameter(Mandatory=$true)]
    [string]$zipFile, 
    [Parameter(Mandatory=$true)]
    [string]$targetPath , 

    # use force (overwrite zip file, if exists)
    [Alias("f")]
    [switch]$force = $false
    )
{
    if (Test-Path $targetPath -PathType Container)
    {
        if ($force)
        {
            Remove-Item $targetPath -Recurse
        }
        else
        {
            throw "Target directory '$targetPath' already exists. "
        }
    }

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $targetPath)
}
