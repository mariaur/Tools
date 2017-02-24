# 
# Cosmos StructuredStream (api) module
#
param ([string]$src, [switch]$verbose)

# stop on error
$errorActionPreference = 'Stop'

#
# Load .NET structured stream stack
#
function Load-Assemblies
{
    $asm = @(
        'SSApi.dll', 
        'ScopeRuntime.exe', 
        'SSLibExt.dll', 
        'VcClient.dll', 
        'Newtonsoft.Json.dll', 
        'Microsoft.Scope.Interfaces.dll', 
        'Microsoft.Cosmos.FrontEnd.Contract.dll', 
        'Microsoft.Analytics.Common.dll', 
        'Microsoft.Analytics.Interfaces.dll', 
        'Microsoft.Analytics.Types.dll'
        )

    $asm | % {
        $path = Join-Path $PSScriptRoot $_
        [Reflection.Assembly]::Load([IO.File]::ReadAllBytes($path))
    }
}

<#
.SYNOPSIS
    Read structured stream metadata

.DESCRIPTION
    Read structured stream metadata, returning 
    metadata object, exposing various properties

.NOTES
    Author: Kalin Toshev
    Date:   Dec 28, 2016
#>
function Read-StructuredStreamMetadata(
    [string]$src 
    )
{
    if (-not $src)
    {
        $src = $global:src
    }

    Write-Progress -id 1 -Activity "Retrieving Cosmos stream metadata ($src) ..."
    [Microsoft.PS.Cosmos.StructuredStreamReader]::GetStreamMetadata($src)
}

<#
.SYNOPSIS
    Read structured stream data

.DESCRIPTION
    Read structured stream data, returning 
    data rows from the stream (as objects).

.NOTES
    Author: Kalin Toshev
    Date:   Dec 28, 2016
#>
function Read-StructuredStreamData(
    [string]$src, 
    [Microsoft.PS.Cosmos.StructuredStreamReader+Options]$sso
    )
{
    if ($script:__sse)
    {
        $script:__sse.Dispose()

        $script:__sse = $null
    }

    if (-not $src)
    {
        $src = $global:src
    }

    if (-not $sso)
    {
        $sso = $global:sso
    }

    Write-Progress -id 1 -Activity "Opening Cosmos stream ($src) ..."
    $reader = New-Object Microsoft.PS.Cosmos.StructuredStreamReader $src

    $md = $reader.Metadata
    if (-not $md)
    {
        Write-Error "Failed to retrieve metadata for stream '$src'. Make sure that the stream exists. "
    }

    # obtain the initial stream info
    $smd = $md.Statistics

    $partitionCount = $smd['PartitionCount']
    $rowCount = $smd['RowCount']
    $dataSize = $smd['DataSize']

    $script:__sse = $reader.GetDataEnumerator($sso)

    $rowNumber = 0

    $writeProgress = { 
        Write-Progress -id 1 -Activity "Reading Cosmos stream ($src), $dataSize bytes ..." -Status "$partitionCount/$rowCount/$rowNumber" 
    }

    # write initial progress
    & $writeProgress

    $clock = [Diagnostics.Stopwatch]::StartNew()

    try
    {
        $sse = $script:__sse

        while ($sse.MoveNext())
        {
            $row = $sse.Current

            $rowNumber += 1

            if ($rowNumber -eq 1)
            {
                $partitionCount = $row.GetDataUnitCount()
                $rowCount = $row.GetDataRowCount()

                # update progress
                & $writeProgress
            }

            Write-Output $row

            # update progress (every 1 sec)
            if ($clock.ElapsedMilliseconds -gt 1000)
            {
                & $writeProgress

                $clock.Restart()
            }
        }
    }
    finally
    {
        $script:__sse.Dispose()

        $script:__sse = $null
    }
    
}

<#
.SYNOPSIS
    Write structured stream data rows

.DESCRIPTION
    Write structured stream data rows as TSV 
    (tab separated values). It takes input from
    'Read-StructuredStreamData'. 'ScopeTsv' should
    be set as a Formatting option for consistency. 

.NOTES
    Author: Kalin Toshev
    Date:   Dec 28, 2016
#>
function Write-StructuredStreamTsvFile(
    [string]$fileName, 
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Microsoft.PS.Cosmos.StructuredStreamReader+DataRow]$dataRow, 
    [switch]$NoHeader
    )
{
    begin
    {
        # close previous stream, if any
        if ($script:__fsOut)
        {
            $script:__fsOut.Close()
        }

        if (-not $fileName)
        {
            $fileName = $global:ssf
        }
        
        if ($fileName -ne '-')
        {
            $fsOut = New-Object IO.StreamWriter $fileName
        }
        else
        {
            $fsOut = $null
        }
        
        $writeHeader = (-not $NoHeader)

        # save reference to the opened stream
        $script:__fsOut = $fsOut
    }
    process
    {
        if ($writeHeader)
        {
            $schema = $dataRow.GetSchema()

            $sc = $schema.Columns | % { "$($_.Name):$($_.Type)" }
            
            $header = [string]::Join("`t", $sc)

            if ($fsOut)
            {
                $fsOut.WriteLine($header)
            }
            else
            {
                Write-Output $header
            }

            $writeHeader = $false
        }

        $line = $dataRow.ToString()

        if ($fsOut)
        {
            $fsOut.WriteLine($line)
        }
        else
        {
            Write-Output $line
        }
    }
    end
    {
        if ($fsOut)
        {
            $fsOut.Close()
        }

        # clear the reference
        $script:__fsOut = $null
    }
}

<#
.SYNOPSIS
    Export StructuredStream to TSV

.DESCRIPTION
    Export StructuredStream to TSV ('porcelain') command, combining 
    'Read-StructuredStreamData' and 'Write-StructuredStreamTsvFile'
    with current source ($src), target ($ssf) and options ($sso). 

.NOTES
    Author: Kalin Toshev
    Date:   Dec 28, 2016
#>
function expss([long]$top)
{
    if ($top)
    {
        Read-StructuredStreamData | select -First $top | Write-StructuredStreamTsvFile
    }
    else 
    {
        Read-StructuredStreamData | Write-StructuredStreamTsvFile
    }
}

<#
.SYNOPSIS
    Obtain compact StructuredStream metadata

.DESCRIPTION
    Obtain compact StructuredStream metadata ('porcelain') command, 
    with current source ($src), target ($ssf) and options ($sso). 

.NOTES
    Author: Kalin Toshev
    Date:   Dec 29, 2016
#>
function infoss(
    [switch]$dataOnly, 
    [switch]$schemaOnly
    )
{
    # retrieve metadata
    $md = Read-StructuredStreamMetadata

    # create schema object
    $c = $md.Schema.ScopeSchema.Columns

    # Scope type map
    $scopeTypes = @{
        [bool]='bool';
        [sbyte]='sbyte';
        [byte]='byte';
        [int16]='short';
        [uint16]='ushort';
        [int]='int';
        [uint32]='uint';
        [long]='long';
        [uint64]='ulong';
        [float]='float';
        [double]='double';
        [string]='string';

        [guid]='Guid';
        [DateTime]='DateTime';
        [byte[]]='byte[]';
    }

    $getScopeTypeName = {
        param($type)

        # check for 'container' type
        if ($type.IsGenericType)
        {
            $gtype = $type.GetGenericTypeDefinition()
            $gargs = $type.GetGenericArguments()

            if ($gtype -eq [Nullable`1])
            {
                $v = & $getScopeTypeName $gargs[0]
                "$($v)?"
            }
            elseif ($gtype -eq [Microsoft.SCOPE.Types.ScopeMap`2])
            {
                $k = & $getScopeTypeName $gargs[0]
                $v = & $getScopeTypeName $gargs[1]
                "MAP<$k,$v>"
            }
            elseif ($gtype -eq [Microsoft.SCOPE.Types.ScopeArray`1])
            {
                $v = & $getScopeTypeName $gargs[0]
                "ARRAY<$v>"
            }
            else 
            {
                # fallback to the full (type) name
                $type.FullName
            }
        }
        else
        {
            $name = $scopeTypes[$type]

            if (-not $name)
            {
                # fallback to the full (type) name
                $type.FullName
            }
            else
            {
                $name
            }
        }
    }

    $schema = 0..$($c.Count - 1) | % {
        
        $scopeType = & $getScopeTypeName $c[$_].ColumnCLRType

        $props = [ordered]@{
            Index=$_;
            Name=$c[$_].Name;
            TypeAlias=$c[$_].Type.ToString();
            ScopeType=$scopeType;
        }

        New-Object psobject -prop $props
    }

    # create data object, based on statistics
    $smd = $md.Statistics
    $sm = $md.Schema
    
    # min, max, avg per-partition metrics
    $mmar = $md.DataUnitDescriptors | select -exp RowCount | measure -Min -Max -Average
    $mmad = $md.DataUnitDescriptors | select -exp DataLength | measure -Min -Max -Average

    $props = [ordered]@{
        DataSize=$smd['DataSize'];
        DataBlockCount=$smd['DataBlockCount'];

        RowCount=$smd['RowCount'];
        MinRowSize=$smd['MinRowSize'];
        MaxRowSize=$smd['MaxRowSize'];

        PartitionCount=$smd['PartitionCount'];
        PartitionKey=$sm.PartitionKey;
        PartitionType=$sm.PartitionType.ToString();
        SortKey=$sm.SortKey;

        MinPartitionRowCount=$mmar.Minimum;
        MaxPartitionRowCount=$mmar.Maximum;
        AvgPartitionRowCount=$mmar.Average;

        MinPartitionDataSize=$mmad.Minimum;
        MaxPartitionDataSize=$mmad.Maximum;
        AvgPartitionDataSize=$mmad.Average;
    }

    $data = New-Object psobject -prop $props

    # return the requested info object
    if ($schemaOnly)
    {
        $schema
    }
    elseif ($dataOnly)
    {
        $data
    }
    else
    {
        New-Object psobject -prop ([ordered]@{Data=$data;Schema=$schema})
    }
}

<#
.SYNOPSIS
    Invoke help screen

.DESCRIPTION
    Invoke help screen

.NOTES
    Author: Kalin Toshev
    Date:   Dec 28, 2016
#>
function helpss
{
    # capture and output (exported) commands
    $s = gcm -Module ssapi | ? { $expfunc -contains $_.Name } | ft -a | Out-String
    Write-Host $s -fore White

    # capture and output source and target 
    Write-Host "`$src -> $($global:src)" -fore White
    Write-Host
    Write-Host "`$ssf -> $($global:ssf)" -fore White
    Write-Host

    # capture and output options
    Write-Host '$sso -> ' -fore White
    $s = $global:sso | ft -a | Out-String
    Write-Host $s -fore White
}

#
# Module entry point
#

# load .NET modules
Load-Assemblies

# create 'global level' options
$global:sso = [Microsoft.PS.Cosmos.StructuredStreamReader+Options]::GetDefault()

# create global source
if (-not $src)
{
   $src ='*** StructuredStream source variable ($src) not set ***'
}
$global:src = $src

# create global file name
$global:ssf = 'datass.tsv'


# exported functions
$expfunc = @(
    'helpss','expss', 'infoss', 
    'Read-StructuredStreamMetadata', 'Read-StructuredStreamData', 
    'Write-StructuredStreamTsvFile'
)

$expfunc | % {
    Export-ModuleMember -Function $_
}

# check for verbose run
if ($verbose)
{
    Write-Host
    Write-Host 'Tip: type ''helpss'' to list commands and options' -fore Green

    # display help
    helpss
}

