function Add-WindowsDefenderExclusionsPolicy
{
    $ErrorActionPreference="Stop"

    #Default Exclusion Entries
    $excludes = @{
        Paths=@{
            NuGetPackageCache = "G:\PkgCache"
        }
        Processes=@{
        }
    }

    foreach($entry in $excludes.GetEnumerator())
    {
        $path = Join-Path "HKLM:SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" $entry.Key

        #Create entry if not exist
        if(!(Test-Path -Path $path)){
            New-Item -Path $path -Force | Out-Null
        }

        #Set exclusion item
        foreach($item in $entry.Value.GetEnumerator())
        {
            Set-ItemProperty -Path $path -Name $item.Value -Value 0 -Force
        }
    }
        
    #Apply Policy
    gpupdate | Out-Null
}

Add-WindowsDefenderExclusionsPolicy
