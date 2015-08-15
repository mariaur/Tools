function global:Convert-FromBinHex([string]$value, [switch]$showValue = $false)
{
    $r = New-Object Byte[] ([Math]::Floor($value.Length / 2))

    for ($n = 0; $n -lt $r.Length; $n++) 
    {
        $r[$n] = [Convert]::ToByte($value.Substring($n * 2, 2), 16)

        if ($showValue)
        {
            [Console]::Write("{0}", [char]$r[$n])
        }
    }

    if (-not $showValue)
    {
        return $r
    }
    else
    {
        [Console]::WriteLine()
    }
}

