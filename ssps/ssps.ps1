
param(
    # search pattern
    [Parameter(Mandatory=$true, HelpMessage="Search pattern or string")]
    [string]$p, 

    # output file names only
    [switch]$fo = $false, 

    # open vim UX
    [switch]$ui = $false, 

    # case sensitive search
    [switch]$c = $false, 

    # use regular expression (vs. simple text)
    [switch]$r = $false, 

    # default extensions
    [string]$e = '*.cs *.*proj'
    )

# load the C# worker 
Add-Type -TypeDefinition ([IO.File]::ReadAllText("$PSScriptRoot\ssps.cs"))

Write-Host
Write-Host "INFO: Searching for '$p' in files '$e' (`$fo=$fo,`$c=$c,`$r=$r). Please wait ..."
Write-Host

$mc = 0

# obtain a list of file extensions
$fileExt = -split $e

$fileMap = @{}

$worker = {
    [PsHelpers]::SearchFiles($fileExt, $p, $fo, !$c, $r) | % {
        # format and output the location
        if (-not $fo)
        {
            $loc = "{0}:{1}: " -f $_.FileName, $_.LineNumber
        }
        else
        {
            $loc = $_.FileName
        }

        $fileMap[$_.FileName] = 1

        $script:mc += 1;

        if ($ui)
        {
            Write-Output "$loc$($_.LineText)"
        }
        else
        {
            Write-Host -ForegroundColor White -NoNewLine $loc

            # output the line text
            if (-not $fo)
            {
                Write-Host $_.LineText
            }
            else
            {
                Write-Host
            }
        }
    }
}


if ($ui)
{
    $vimFile = "$env:TEMP\`$`$`$search_tmp`$`$`$"

    $ms = (Measure-Command { & $worker | Out-File $vimFile -Encoding UTF8 }).TotalMilliseconds

    # launch vim UX
    $env:VIMQFFILE=$vimFile
    gvim.exe --% -q "%VIMQFFILE%"
}
else
{
    $ms = (Measure-Command $worker).TotalMilliseconds
}

Write-Host
Write-Host "INFO: $mc match(es) found in $($fileMap.Count) files ($ms ms). "
Write-Host


