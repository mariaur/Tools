$errorActionPreference = 'Stop'

# Connect to Visual Studio IDE
$dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject("VisualStudio.DTE")

function Get-LocalProcessList(
    [Parameter(Mandatory=$true)]
    [string]$procName
    )
{
    $dte.Debugger.LocalProcesses | ? Name | ? { (Split-Path $_.Name -Leaf) -eq $procName }
}

# attach/detach worker functon
function Debug-VisualStudioAttachOrDetachProcess(
    [Parameter(Mandatory=$true)]
    [string]$procName, 
    [switch]$detach
    )
{
    $p = Get-LocalProcessList $procName

    if ($p)
    {
        if ($detach)
        {
            $p.Detach()
        }
        else
        {
            $p.Attach()
        }
    }
    else
    {
        Write-Host "Process '$procName' not found" -ForegroundColor Yellow
        Write-Host "Hit [ENTER] to exit ..."
        Read-Host
    }
}

# Attach Visual Studio to running process(es)
function Debug-VisualStudioAttachProcess(
    [Parameter(Mandatory=$true)]
    [string]$procName
    )
{
    Debug-VisualStudioAttachOrDetachProcess $procName
}

# Detach Visual Studio from running process(es)
function Debug-VisualStudioDetachProcess(
    [Parameter(Mandatory=$true)]
    [string]$procName
    )
{
    Debug-VisualStudioAttachOrDetachProcess $procName -detach
}

