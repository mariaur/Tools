param ($xmlFile, $xslFile, $outputFile)

if (-not $xmlFile -or -not $xslFile -or -not $outputFile)
{
    Write-Host
    Write-Host "Usage: xslt.ps1 <xml> <xslt> <output> [p1=v1 [p2=v2 [...]]]"
    Write-Host
    exit;
}

trap [Exception]
{
    Write-Host
    Write-Host " xslt.ps1 (error) -> " + $_.Exception;
    exit 1;
}

Write-Host 

$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
Write-Host "(.NET) Loading xslt -> $xslFile ...";

$xmlResolver = New-Object System.Xml.XmlUrlResolver;
$xslt.Load($xslFile, [System.Xml.Xsl.XsltSettings]::TrustedXslt, $xmlResolver);

$xsltArgs = New-Object  System.Xml.Xsl.XsltArgumentList;

# Pick additional parameters for the XSLT, if any
for ([int]$n = 0; $n -lt $args.Length; $n++)
{                         
    [String]$arg = $args[$n];
    [int]$sep = $arg.IndexOf('=');
    
    if ($sep -ne -1)
    {
        $xsltArgs.AddParam($arg.Substring(0, $sep), "", $arg.Substring($sep+1));
    }
    else
    {
        $xsltArgs.AddParam($arg, "", "1");
    }
}

Write-Host "(.NET) Transforming $xmlFile -> $outputFile ...";
$output = New-Object System.IO.FileStream ($outputFile, [System.IO.FileMode]::Create)
$xslt.Transform($xmlFile, $xsltArgs, $output);
$output.Close()

