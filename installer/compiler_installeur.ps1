[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installerRoot = $PSScriptRoot
$v21Root = Split-Path -Parent $installerRoot
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$output = Join-Path $installerRoot 'Guildrun_Demo_FR_Installer_V2.1.exe'
$source = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.cs'
$manifest = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.manifest'
$common = Join-Path $v21Root 'scripts\GuildrunV21.Common.ps1'
$install = Join-Path $v21Root 'scripts\installer_traduction.ps1'
$restore = Join-Path $v21Root 'scripts\restaurer_sauvegarde.ps1'
$french = Join-Path $v21Root 'payload\localization-string-tables-french(fr)_assets_all.bundle'
$locales = Join-Path $v21Root 'payload\localization-locales_assets_all.bundle'
$catalog = Join-Path $v21Root 'payload\catalog.bin'

foreach ($required in @($csc, $source, $manifest, $common, $install, $restore, $french, $locales, $catalog)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Fichier requis introuvable : $required" }
}
$expected = @{
    $french = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
    $locales = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
    $catalog = '57A6EA642CE9DE2D89EB8F57FE083C66030834A8519806087D2EFE722A1231CC'
}
foreach ($entry in $expected.GetEnumerator()) {
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $entry.Key).Hash -ne $entry.Value) { throw "Charge utile V2.1 invalide : $($entry.Key)" }
}

$arguments = @(
    '/nologo', '/target:winexe', '/platform:anycpu', '/optimize+',
    "/out:$output", "/win32manifest:$manifest",
    '/reference:System.dll', '/reference:System.Core.dll', '/reference:System.Drawing.dll', '/reference:System.Windows.Forms.dll',
    "/resource:$common,GuildrunFRV21.Common",
    "/resource:$install,GuildrunFRV21.Install",
    "/resource:$restore,GuildrunFRV21.Restore",
    "/resource:$french,GuildrunFRV21.French",
    "/resource:$locales,GuildrunFRV21.Locales",
    "/resource:$catalog,GuildrunFRV21.Catalog",
    $source
)
& $csc $arguments
if ($LASTEXITCODE -ne 0) { throw "Compilation echouee avec le code $LASTEXITCODE." }
Write-Host "Installateur V2.1 compile : $output"
Write-Host "SHA-256 : $((Get-FileHash -Algorithm SHA256 -LiteralPath $output).Hash)"
