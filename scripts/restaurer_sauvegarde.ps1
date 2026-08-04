[CmdletBinding()]
param(
    [string] $GameRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = 'Stop'
$v21Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'GuildrunV21.Common.ps1')

try {
    $result = Invoke-GuildrunV21Restore -GameRoot $GameRoot -PayloadRoot (Join-Path $v21Root 'payload')
    Write-Host 'Les trois fichiers et la preference Unity precedente ont ete restaures exactement et verifies.'
    Write-Host "Sauvegarde conservee : $($result.BackupRoot)"
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
