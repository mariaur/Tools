param($a)

$isRedir = [System.Console]::IsOutputRedirected

if ($isRedir)
{
    $format = 'format:%h%d %s [%ce] (%ar)'
}
else
{
    $format = 'format:%C(auto)%h%Creset%C(auto)%d%Creset %s %C(cyan)[%ce]%Creset %Cgreen(%ar)%Creset'
    $graph = '--graph'
}

$cmd = 'git log --pretty="' + $format + '" ' + $graph + ' ' + $a

if (-not $a)
{
    $cmd +=  ' .'
}

iex $cmd

