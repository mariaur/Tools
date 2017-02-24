
param(
    # search pattern
    [Parameter(Mandatory=$true, 
        HelpMessage="Search pattern (regex or string literal)")]
    [Alias("p")]
    [string]$pattern, 

    # output file names only
    [Alias("fo")]
    [switch]$fileOnly = $false, 

    # output statistics only
    [Alias("so")]
    [switch]$statOnly = $false, 

    # quite mode (no info messages)
    [Alias("q")]
    [switch]$quiet = $false, 

    # open vim UX
    [switch]$ui = $false, 

    # case sensitive search
    [Alias("c")]
    [switch]$caseSensitive = $false, 

    # use regular expression (vs. simple text)
    [Alias("r")]
    [switch]$regex = $false, 

    # default files
    [Alias("f")]
    [string]$files = '*.cs *.*proj *.ps1 *.psm1 *.config *.cpp *.h *.props *.bond'
    )

# load the C# worker 
Add-Type -TypeDefinition ([IO.File]::ReadAllText("$PSScriptRoot\ssps.cs"))

if (-not $quiet)
{
    Write-Host
    Write-Host "INFO: Searching for '$pattern' in files '$files' (`$fo=$fileOnly,`$so=$statOnly,`$c=$caseSensitive,`$r=$regex). Please wait ..."
    Write-Host
}

$mc = 0

# obtain a list of file extensions
$fileList = -split $files

$fileMap = @{}

$worker = {
    [PsHelpers]::SearchFiles($fileList, $pattern, $fileOnly, $quiet, !$caseSensitive, $regex) | % {
        
        # update the stats
        $fileMap[$_.FileName] = 1
        $script:mc += 1;

        if ($statOnly)
        {
            return
        }

        # format and output the location
        if (-not $fileOnly)
        {
            $loc = "{0}:{1}: " -f $_.FileName, $_.LineNumber
        }
        else
        {
            $loc = $_.FileName
        }

        if ($ui)
        {
            Write-Output "$loc$($_.LineText)"
        }
        else
        {
            Write-Host -ForegroundColor White -NoNewLine $loc

            # output the line text
            if (-not $fileOnly)
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

if (-not $quiet)
{
    Write-Host
    Write-Host "INFO: $mc matches found in $($fileMap.Count) files ($ms ms). "
    Write-Host
}

