<#
.SYNOPSIS
    Command line interface to StructuredStream API (SSApi) module

.DESCRIPTION
    Command line interface (high level) to StructuredStream API 
    (SSApi) module 'dumping' data or schema information as TSV 
    or JSON output


.PARAMETER src
    StructuredStream source - VC (https URL) or local file

.PARAMETER out
    Name of output file; if not specified, default is [stdout]
    
.PARAMETER top
    Dump only top N records (rows)

.PARAMETER columns
    Column filter - limit the output to only selected columns
    

.PARAMETER metadata
    Dump metadata information (default is data)

.PARAMETER dataOnly
    Dump metadata data only (statistics) information; used when
    -metadata flag is specified as well

.PARAMETER schemaOnly
    Dump metadata schema only information; used when -metadata
    flag is specified as well


.PARAMETER keyValue
    SortKey value (filter) for data

.PARAMETER keyType
    SortKey value type (if not 'string')

.NOTES
    Author: Kalin Toshev
    Date:   Jan 02, 2017
#>
param(
    # source (stream) and output (file)
    [Parameter(Mandatory=$true)]
    [Alias("i")]
    [string]$src, 
    [Alias("o")]
    [string]$out, 

    # pick just top N records
    [long]$top, 
    # column 'filter'
    [Alias("c")]
    [string[]]$columns, 

    # metadata parameters
    [Alias("md")]
    [switch]$metadata, 
    [Alias("do")]
    [switch]$dataOnly, 
    [Alias("so")]
    [switch]$schemaOnly, 

    # sortkey parameters
    [Alias("kv")]
    [string]$keyValue, 
    [Alias("kt")]
    [string]$keyType
    )

# stop on error
$errorActionPreference = 'Stop'

# import the SSApi module, passing the (input) source
Import-Module $PSScriptRoot\SSApi.psm1 -ArgumentList @($src)

if (-not $out)
{
    # default to stdout
    $out = '-'
}

# setup (default) output
$global:ssf = $out

# parameters (passed down)
$p = @{}

# invoke the command
if ($metadata)
{
    if ($dataOnly)
    {
        $p['dataOnly'] = $true
    }
    if ($schemaOnly)
    {
        $p['schemaOnly'] = $true
    }

    $md = infoss @p

    if (-not $dataOnly)
    {
        $schema = $md.Schema

        if ($schemaOnly)
        {
            $schema = $md
        }

        # 'escape' <> with () for better JSON output    
        $schema.GetEnumerator() | % {
            $scopeType = $_.ScopeType

            $scopeType = $scopeType.Replace('<', '(').Replace('>', ')')

            $_.ScopeType = $scopeType            
        }
    }

    $md = $md | ConvertTo-Json

    if ($out -ne '-')
    {
        $md | Out-File -Encoding UTF8 $out
    }
    else
    {
        $md
    }
}
else
{
    $sso = $global:sso

    if ($keyValue)
    {
        $md = infoss -dataOnly

        # obtain the key name
        $keyName = $null

        if ($md.SortKey)
        {
            # note: using only first component of the sortkey
            $keyName = $md.SortKey[0].Name
        }

        if (-not $keyName)
        {
            Write-Error "SortKey not found for '$src'. "
        }

        $v = $keyValue

        if ($keyType)
        {
            # perform the 'type cast'
            $v = iex "[$keyType]'$v'"
        }

        # 'push' the sort key
        $sso.SortKey = @{$keyName=$v}
    }

    if ($columns)
    {
        # push the column filter
        $sso.ColumnFilter = $columns
    }

    if ($top)
    {
        $p['top'] = $top
    }

    expss @p
}

