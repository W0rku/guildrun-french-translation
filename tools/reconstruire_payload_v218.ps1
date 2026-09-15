[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'reconstruire_payload_v21.ps1')
$sourceNew = Join-Path $SourcesRoot 'catalog-25323618.bin.official'
Assert-Hash $sourceNew '4F9FEF5C06A28D8809CBD420A87E584F83EA958498FCFAE40B3DC1883A78110A' 'Catalogue officiel BuildID 25323618'
$frenchNew = Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.v218.bundle'
New-CorrectedFrenchBundle $frenchPayload $frenchNew (Join-Path $projectRoot 'translations\corrections-v2.1.8.fr.json') '2.1.8' 1
Assert-Hash $frenchNew 'E900D7AAC8ED1E7BCEF558D67718CFF6CB00C83B49D41918DB11D0A7257B8B85' 'French V2.1.8'
New-PatchedCatalog $sourceNew (Join-Path $PayloadRoot 'catalog-25323618.bin') 'B6FE63A51A9C317AA06734B23DED044DC0D34FDA3517357609CB8DFA3715719A' '25323618' $frenchNew
Write-Host 'Payload V2.1.8 reconstruit et verifie.'
