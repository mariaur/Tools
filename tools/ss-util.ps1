function Decrypt-SecureString(
    [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
    [System.Security.SecureString]
    $secureString
    )
{
    $marshal = [System.Runtime.InteropServices.Marshal];
    
    $ptr = $marshal::SecureStringToBSTR($secureString);

    $r = $marshal::PtrToStringBSTR($ptr)
    
    $marshal::ZeroFreeBSTR( $ptr )

    return $r;
} 

function Get-KeyForPassword($password)
{
    $hashAlg = (New-Object System.Security.Cryptography.SHA256Managed);

    return $hashAlg.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($password));
}
