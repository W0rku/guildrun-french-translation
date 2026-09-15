[CmdletBinding()]
param([string] $EnglishBundle)
$projectRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'auditer_traduction_v212.ps1') -EnglishBundle $EnglishBundle -BaselineFrenchBundle (Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.bundle') -CorrectedFrenchBundle (Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.v218.bundle') -CorrectionsFile (Join-Path $projectRoot 'translations\corrections-v2.1.8.fr.json') -ExpectedVersion '2.1.8' -ExpectedCorrections 1 -ExpectedEntries 3923
