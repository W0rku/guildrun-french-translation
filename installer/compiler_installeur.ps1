[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installerRoot = $PSScriptRoot
$v21Root = Split-Path -Parent $installerRoot
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$output = Join-Path $installerRoot 'Guildrun_Demo_FR_Installer_V2.1.2.exe'
$source = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.cs'
$updateSource = Join-Path $installerRoot 'InstallerUpdateService.cs'
$manifest = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.manifest'
$common = Join-Path $v21Root 'scripts\GuildrunV21.Common.ps1'
$install = Join-Path $v21Root 'scripts\installer_traduction.ps1'
$restore = Join-Path $v21Root 'scripts\restaurer_sauvegarde.ps1'
$french = Join-Path $v21Root 'payload\localization-string-tables-french(fr)_assets_all.bundle'
$locales = Join-Path $v21Root 'payload\localization-locales_assets_all.bundle'
$catalogCurrent = Join-Path $v21Root 'payload\catalog.bin'
$catalogLegacy = Join-Path $v21Root 'payload\catalog-24551494.bin'

foreach ($required in @($csc, $source, $updateSource, $manifest, $common, $install, $restore, $french, $locales, $catalogCurrent, $catalogLegacy)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Fichier requis introuvable : $required" }
}
$expected = @{
    $french = '7C8D467B719EEEE955C0226248EC90004277842B5017436607E7A01EAE388305'
    $locales = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
    $catalogCurrent = '7B78213D5C73446074C59F223BAE05199D7C65ABB6F7CA77484AA7BE33657A71'
    $catalogLegacy = '44BC589D21336E54170B5F39702BFAE8E07B971AB573B1459BD09008D6D97232'
}
foreach ($entry in $expected.GetEnumerator()) {
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $entry.Key).Hash -ne $entry.Value) { throw "Charge utile V2.1 invalide : $($entry.Key)" }
}

$arguments = @(
    '/nologo', '/target:winexe', '/platform:anycpu', '/optimize+', '/codepage:65001',
    "/out:$output", "/win32manifest:$manifest",
    '/reference:System.dll', '/reference:System.Core.dll', '/reference:System.Drawing.dll', '/reference:System.Windows.Forms.dll', '/reference:System.Web.Extensions.dll',
    "/resource:$common,GuildrunFRV21.Common",
    "/resource:$install,GuildrunFRV21.Install",
    "/resource:$restore,GuildrunFRV21.Restore",
    "/resource:$french,GuildrunFRV21.French",
    "/resource:$locales,GuildrunFRV21.Locales",
    "/resource:$catalogCurrent,GuildrunFRV21.CatalogCurrent",
    "/resource:$catalogLegacy,GuildrunFRV21.CatalogLegacy",
    $source, $updateSource
)
& $csc $arguments
if ($LASTEXITCODE -ne 0) { throw "Compilation echouee avec le code $LASTEXITCODE." }
Write-Host "Installateur V2.1.2 multi-BuildID compile : $output"
Write-Host "SHA-256 : $((Get-FileHash -Algorithm SHA256 -LiteralPath $output).Hash)"
