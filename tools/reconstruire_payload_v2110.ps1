[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'reconstruire_payload_v218.ps1')
$frenchNew = Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.v2110.bundle'
New-CorrectedFrenchBundle (Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.v218.bundle') $frenchNew (Join-Path $projectRoot 'translations\corrections-v2.1.10.fr.json') '2.1.10' 2
Assert-Hash $frenchNew 'D8E23CC8C4C1FB925056C1014D9317EDC9FF2E003FDCF20CB95FBECE93BBF885' 'French V2.1.10'
New-PatchedCatalog $sourceNew (Join-Path $PayloadRoot 'catalog-25323618.bin') 'F8FD7F62131E2A23EAB04B1C29053ABDBD5FF8587ED991D0FF90102FC842CCF5' '25751498' $frenchNew
Write-Host 'Payload V2.1.10 reconstruit et verifie.'
