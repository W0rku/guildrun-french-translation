[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installerRoot = $PSScriptRoot
$v21Root = Split-Path -Parent $installerRoot
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$output = Join-Path $installerRoot 'Guildrun_Demo_FR_Installer_V2.1.4.exe'
$source = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.cs'
$updateSource = Join-Path $installerRoot 'InstallerUpdateService.cs'
$manifest = Join-Path $installerRoot 'GuildrunFrenchInstallerV21.manifest'
$common = Join-Path $v21Root 'scripts\GuildrunV21.Common.ps1'
$install = Join-Path $v21Root 'scripts\installer_traduction.ps1'
$restore = Join-Path $v21Root 'scripts\restaurer_sauvegarde.ps1'
$frenchCurrent = Join-Path $v21Root 'payload\localization-string-tables-french(fr)_assets_all.bundle'
$frenchV213 = Join-Path $v21Root 'payload\localization-string-tables-french(fr)_assets_all.v213.bundle'
$frenchLegacy = Join-Path $v21Root 'payload\localization-string-tables-french(fr)_assets_all.v212.bundle'
$locales = Join-Path $v21Root 'payload\localization-locales_assets_all.bundle'
$catalog24551494 = Join-Path $v21Root 'payload\catalog-24551494.bin'
$catalog24613101 = Join-Path $v21Root 'payload\catalog.bin'
$catalog24690909 = Join-Path $v21Root 'payload\catalog-24690909.bin'
$catalog24816645 = Join-Path $v21Root 'payload\catalog-24816645.bin'

foreach ($required in @($csc, $source, $updateSource, $manifest, $common, $install, $restore, $frenchCurrent, $frenchV213, $frenchLegacy, $locales, $catalog24551494, $catalog24613101, $catalog24690909, $catalog24816645)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Fichier requis introuvable : $required" }
}

. $common
$policy = Get-GuildrunV21Policy
function Get-BuildProfile([string] $SteamBuildId) {
    $matches = @($policy.Profiles | Where-Object { $_.SteamBuildId -eq $SteamBuildId })
    if ($matches.Count -ne 1) { throw "Profil Steam BuildID $SteamBuildId absent ou ambigu dans la politique V2.1." }
    return $matches[0]
}

$profile24551494 = Get-BuildProfile '24551494'
$profile24613101 = Get-BuildProfile '24613101'
$profile24690909 = Get-BuildProfile '24690909'
$profile24816645 = Get-BuildProfile '24816645'

$expectedNames = @(
    [pscustomobject]@{ Actual = $profile24551494.PayloadFrenchName; Expected = 'localization-string-tables-french(fr)_assets_all.v212.bundle'; Label = 'French BuildID 24551494' }
    [pscustomobject]@{ Actual = $profile24613101.PayloadFrenchName; Expected = 'localization-string-tables-french(fr)_assets_all.v212.bundle'; Label = 'French BuildID 24613101' }
    [pscustomobject]@{ Actual = $profile24690909.PayloadFrenchName; Expected = 'localization-string-tables-french(fr)_assets_all.v213.bundle'; Label = 'French BuildID 24690909' }
    [pscustomobject]@{ Actual = $profile24816645.PayloadFrenchName; Expected = 'localization-string-tables-french(fr)_assets_all.bundle'; Label = 'French BuildID 24816645' }
    [pscustomobject]@{ Actual = $profile24551494.PayloadCatalogName; Expected = 'catalog-24551494.bin'; Label = 'catalogue BuildID 24551494' }
    [pscustomobject]@{ Actual = $profile24613101.PayloadCatalogName; Expected = 'catalog.bin'; Label = 'catalogue BuildID 24613101' }
    [pscustomobject]@{ Actual = $profile24690909.PayloadCatalogName; Expected = 'catalog-24690909.bin'; Label = 'catalogue BuildID 24690909' }
    [pscustomobject]@{ Actual = $profile24816645.PayloadCatalogName; Expected = 'catalog-24816645.bin'; Label = 'catalogue BuildID 24816645' }
)
foreach ($entry in $expectedNames) {
    if ($entry.Actual -ne $entry.Expected) { throw "Nom de payload inattendu pour $($entry.Label) : $($entry.Actual)" }
}
if ($profile24551494.PatchedFrenchHash -ne $profile24613101.PatchedFrenchHash) {
    throw 'Les deux profils Guildrun 0.5.3 doivent partager exactement le payload French V2.1.2.'
}

$expected = @{
    $frenchLegacy = $profile24551494.PatchedFrenchHash
    $frenchV213 = $profile24690909.PatchedFrenchHash
    $frenchCurrent = $profile24816645.PatchedFrenchHash
    $locales = $policy.PatchedLocalesHash
    $catalog24551494 = $profile24551494.PatchedCatalogHash
    $catalog24613101 = $profile24613101.PatchedCatalogHash
    $catalog24690909 = $profile24690909.PatchedCatalogHash
    $catalog24816645 = $profile24816645.PatchedCatalogHash
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
    "/resource:$frenchCurrent,GuildrunFRV21.FrenchCurrent",
    "/resource:$frenchV213,GuildrunFRV21.FrenchV213",
    "/resource:$frenchLegacy,GuildrunFRV21.FrenchLegacy",
    "/resource:$locales,GuildrunFRV21.Locales",
    "/resource:$catalog24551494,GuildrunFRV21.Catalog24551494",
    "/resource:$catalog24613101,GuildrunFRV21.Catalog24613101",
    "/resource:$catalog24690909,GuildrunFRV21.Catalog24690909",
    "/resource:$catalog24816645,GuildrunFRV21.Catalog24816645",
    $source, $updateSource
)
& $csc $arguments
if ($LASTEXITCODE -ne 0) { throw "Compilation echouee avec le code $LASTEXITCODE." }
Write-Host "Installateur V2.1.4 multi-BuildID compile : $output"
Write-Host "SHA-256 : $((Get-FileHash -Algorithm SHA256 -LiteralPath $output).Hash)"
