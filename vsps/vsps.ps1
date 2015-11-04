$errorActionPreference = 'Stop'

# Connect to Visual Studio IDE
$dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject("VisualStudio.DTE")

# Attach Visual Studio to running process(es)
function Debug-VisualStudioAttachProcess(
    [Parameter(Mandatory=$true)]
    [string]$procName
    )
{
    $p = $dte.Debugger.LocalProcesses | ? { (Split-Path $_.Name -Leaf) -eq $procName }

    if ($p)
    {
        $p.Attach()
    }
    else
    {
        Write-Error "Process '$procName' not found. "
    }
}

# Detach Visual Studio from running process(es)
function Debug-VisualStudioDetachProcess(
    [Parameter(Mandatory=$true)]
    [string]$procName
    )
{
    $p = $dte.Debugger.LocalProcesses | ? { (Split-Path $_.Name -Leaf) -eq $procName }

    if ($p)
    {
        $p.Detach()
    }
    else
    {
        Write-Error "Process '$procName' not found. "
    }
}

