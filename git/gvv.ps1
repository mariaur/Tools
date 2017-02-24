$errorActionPreference = 'Stop'

# Load WPF
Add-Type -AssemblyName 'PresentationFramework'

# Prepare the UX
[xml]$xaml = Get-Content -Raw $PSScriptRoot\gvv.xaml

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Expose (publish) the PS variables
$xaml.SelectNodes("//*[@Name]") | % {
    Set-Variable -Name "WPF_$($_.Name)" -Value $window.FindName($_.Name)
}

function Get-CommitId($c)
{
    $id = $c.Commit

# check for a branch spec (coming with the commit)
    $index = $id.IndexOf(' ')

    if ($index -ne -1)
    {
        $id = $id.Substring(0, $index)
    }

    $id
}

function Show-Selection
{
    $sb = New-Object 'Text.StringBuilder'

    $ids = @()

    $WPF_ListView.SelectedItems | sort Version -desc | % {
        $id = Get-CommitId $_; $ids += $id
            
        # append the next commit
        [string[]]$c = iex "git show $id ."
        
        $c | % { [void]$sb.AppendLine($_) }
        [void]$sb.AppendLine()
    }

    $content = $sb.ToString()
    
    if ($content)
    {
        $title = $ids -join ','
        $content | gvim -R -c "set title titlestring=$title" -
    }
}

function Invoke-Viewer
{
    $viewer = {
        param($c1)

        $id1 = Get-CommitId $c1

        # invoke the viewer for this commit (id)
        Start-Process -NoNewWindow "gv.cmd" "$id1"
    }

    $sel = @() + ($WPF_ListView.SelectedItems | sort Version -desc)
    $count = $sel.Length

    switch ($count)
    {
        1 {
            & $viewer $sel[0]
        }

        default {
            if ($count -gt 1)
            {
                Show-Selection
            }
        }
    }
}

function Copy-Selection
{
    # copy to clipboard (as csv)
    $WPF_ListView.SelectedItems | sort Version -desc | `
        ConvertTo-Csv -NoTypeInformation | clip
}

$WPF_ListView.Add_SelectionChanged(
{
    $count = $WPF_ListView.SelectedItems.Count

    $menu = $WPF_ContextMenu.Items

    # View (single item)
    $menu[0].IsEnabled = ($count -eq 1)
})


# Attach window load handler
$window.Add_Loaded({

    # set the focus to the first item in the listview
    $item = $WPF_ListView.ItemContainerGenerator.ContainerFromIndex(0)

    if ($item)
    {
        $item.Focus()

        $menu = $WPF_ContextMenu.Items

        # View
        $menu[0].Add_Click({ Invoke-Viewer })

        # Show
        $menu[1].Add_Click({ Show-Selection })

        # Copy
        $menu[2].Add_Click({ Copy-Selection })
    }
})

# Attach copy handler
$WPF_ListView.Add_KeyUp(
{ 
    param($s, $e) 

    $keys = [Windows.Input.Key]

    $keyboard = [Windows.Input.Keyboard]

    if ($keyboard::IsKeyDown($keys::LeftCtrl) -and 
        ($e.Key -eq $keys::C -or $e.Key -eq $keys::Insert)) 
    { 
        Copy-Selection
    }
})

# Attach double click handler to the listview
$WPF_ListView.Add_MouseDoubleClick({ Invoke-Viewer })

# Attach click handler to the view button ("invisible")
$WPF_View.Add_Click({ Invoke-Viewer })

# Csv delimiter
$dm = "`b"

# Pull the git history
$hdr = "Commit$($dm)Description$($dm)User$($dm)Time$($dm)Version`n"

$a = "."
if ($args) { $a = $args }
$cmd = "git log --pretty=`"format:%h%d$($dm)%s$($dm)%ce$($dm)%cr$($dm)%ci`" $a"

$git = iex $cmd

if ($LastExitCode -ne 0 )
{
    throw "git.exe command failed!"
}

$csv = $hdr + ($git -join "`n")

# Populate the list view
$csv | ConvertFrom-Csv -Delimiter $dm | % {
    $c = $_

    $timeStamp = ([datetime]$c.Version).ToUniversalTime()

    $c.Version = "{0:yyyy}.{0:MMdd}.{0:HHmm}.{0:ss}" -f $timeStamp

    $WPF_ListView.AddChild($c)
}

# Kiff off the UX
[void]$window.ShowDialog()


