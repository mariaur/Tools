function Base64Decode 
{
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias("i")]
        [string]$InputFile, 
        [Parameter(Mandatory = $true)]
        [Alias("o")]
        [string]$OutputFile
    )

    $c = [System.IO.File]::ReadAllText($InputFile);

    [System.IO.File]::WriteAllBytes($OutputFile, [System.Convert]::FromBase64String($c));
}

function Base64Encode
{
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias("i")]
        [string]$InputFile, 
        [Parameter(Mandatory = $true)]
        [Alias("o")]
        [string]$OutputFile
    )

    $c = [System.IO.File]::ReadAllBytes($InputFile);

    [System.IO.File]::WriteAllText($OutputFile, [System.Convert]::ToBase64String($c));
}

