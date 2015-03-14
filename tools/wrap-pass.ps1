param(
    [Switch]
    $u
)

$errorActionPreference = 'Stop'

function Get-Clipboard
{
    [System.Windows.Forms.Clipboard]::GetText();
}

function Set-Clipboard($text)
{
    [System.Windows.Forms.Clipboard]::SetText($text);
}

Add-Type -AssemblyName System.Windows.Forms 

# load the helpers
. .\ss-util.ps1

Write-Host
Write-Host 'Simple password wrap/unwrap tool; use -u option to unwrap (default is wrap)'
Write-Host 'Note: The result of the operation will be stored in clipboard!'
Write-Host

$input = Get-Clipboard

if ($input)
{
    if (($c = (Read-Host "Use clipboard (y/n/q)?")) -ne "y")
    {
        if ($c -eq "q")
        {
            exit 0
        }

        $input = $null;
    }

    Write-Host
}

if (-not $input)
{
    $input = Read-Host "Input $(if ($u) {'Cipher'} else {'Secret'})"

    Write-Host
}


# type/re-type the password
$p1 = Decrypt-SecureString(Read-Host "Password" -AsSecureString)
$p2 = Decrypt-SecureString(Read-Host "Re-type Password" -AsSecureString)

if ($p1 -ne $p2)
{
    Write-Host 
    Write-Host "Error: Passwords do not match"

    exit 1
}

$k = Get-KeyForPassword $p1

Write-Host

if ($u)
{
    $r = (ConvertTo-SecureString $input -key $k | Decrypt-SecureString)
}
else
{
    $r = (ConvertTo-SecureString $input -AsPlainText -Force | ConvertFrom-SecureString -key $k)
}

Set-Clipboard $r

Write-Host Result stored in clipboard. 

