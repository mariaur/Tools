# 
# This script takes care of a bug in SQLCMD whereby
# XML column output is broken into multiple lines 
# regardless of :XML ON option. It combines multiple
# lines of text into a single line (XML)
#

param ($xmlInputFile, $xmlOutputFile)

if (-not $xmlInputFile -or -not $xmlOutputFile)
{
    Write-Host
    Write-Host "Usage: sqlcmd_xml.ps1 <xml input> <xml output>"
    Write-Host
    exit;
}

trap [Exception]
{
    Write-Host
    Write-Host " sqlcmd_xml.ps1 (error) -> " + $_.Exception;
    Write-Host
    exit 1;
}

Write-Host 
Write-Host "Loading input file -> $xmlInputFile ...";
$lines = [System.IO.File]::ReadAllLines($xmlInputFile);

Write-Host 
Write-Host $lines.Length "lines loaded. ";

Write-Host 
Write-Host "Saving output file -> $xmlOutputFile ...";
$output = New-Object System.IO.StreamWriter $xmlOutputFile, $false

for ([int]$n = 0; $n -lt $lines.Length; $n++)
{                         
    $output.Write($lines[$n]);
}

$output.Close()

Write-Host 
Write-Host "Done.";
Write-Host 

