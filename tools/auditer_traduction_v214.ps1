[CmdletBinding()]
param(
    [string] $EnglishBundle,
    [string] $BaselineFrenchBundle,
    [string] $CorrectedFrenchBundle,
    [string] $AssetsToolsDll
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($EnglishBundle)) {
    $EnglishBundle = Join-Path (Split-Path -Parent $projectRoot) 'Guildrun_Data\StreamingAssets\aa\StandaloneWindows64\localization-string-tables-english(en)_assets_all.bundle'
}
if ([string]::IsNullOrWhiteSpace($BaselineFrenchBundle)) {
    $BaselineFrenchBundle = Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.v213.bundle'
}
if ([string]::IsNullOrWhiteSpace($CorrectedFrenchBundle)) {
    $CorrectedFrenchBundle = Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.bundle'
}
if ([string]::IsNullOrWhiteSpace($AssetsToolsDll)) {
    $AssetsToolsDll = Join-Path $PSScriptRoot 'vendor\AssetsTools.NET.dll'
}

& (Join-Path $PSScriptRoot 'auditer_traduction_v212.ps1') `
    -EnglishBundle $EnglishBundle `
    -BaselineFrenchBundle $BaselineFrenchBundle `
    -CorrectedFrenchBundle $CorrectedFrenchBundle `
    -AssetsToolsDll $AssetsToolsDll `
    -CorrectionsFile (Join-Path $projectRoot 'translations\corrections-v2.1.4.fr.json') `
    -ExpectedVersion '2.1.4' `
    -ExpectedCorrections 7
