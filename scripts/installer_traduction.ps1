[CmdletBinding()]
param(
    [string] $GameRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = 'Stop'
$v21Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'GuildrunV21.Common.ps1')

try {
    $result = Invoke-GuildrunV21Install -GameRoot $GameRoot -PayloadRoot (Join-Path $v21Root 'payload')
    if ($result.State -eq 'AlreadyInstalled') {
        Write-Host 'La traduction V2.1 etait deja installee. Le Locale fr a ete confirme.'
    }
    else {
        Write-Host 'Traduction francaise V2.1 installee. French est visible, le Locale fr est selectionne et English est intact.'
    }
    Write-Host "Sauvegarde locale exacte : $($result.BackupRoot)"
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
