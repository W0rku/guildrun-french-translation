[CmdletBinding()]
param(
    [string] $SourcesRoot,
    [string] $PayloadRoot,
    [string] $AssetsToolsDll
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourcesRoot)) { $SourcesRoot = Join-Path $projectRoot 'sources' }
if ([string]::IsNullOrWhiteSpace($PayloadRoot)) { $PayloadRoot = Join-Path $projectRoot 'payload' }
if ([string]::IsNullOrWhiteSpace($AssetsToolsDll)) { $AssetsToolsDll = Join-Path $PSScriptRoot 'vendor\AssetsTools.NET.dll' }
$officialLocalesHash = 'D4A2D1D0DC9773DFA75E07778EE90EF9F13252DE96DF2E1D72F4A8476E3BBDC7'
$officialCatalogLegacyHash = 'DC16E4280C5FAD3526AEC223B3C41F9A46B519D3EED96E1364EB20DA6A6A5783'
$officialCatalogCurrentHash = '1E436E183F5CC451943F090AD2166B56D592EEBDB75C0D2AD210EEF7FDB26E85'
$officialCatalogV213Hash = '647051CA4D8AAF4ED9E2BB13674E690333C689D9743F88D0DFB4DE3097FA820C'
$baselineFrenchHash = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
$expectedFrenchLegacyHash = '7C8D467B719EEEE955C0226248EC90004277842B5017436607E7A01EAE388305'
$expectedFrenchV213Hash = '07995AA60F88CCAE1FDE1FA375819099906BC0EBCAA0B424358637D00AADDE73'
$expectedLocalesHash = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
$expectedCatalogLegacyHash = '44BC589D21336E54170B5F39702BFAE8E07B971AB573B1459BD09008D6D97232'
$expectedCatalogCurrentHash = '7B78213D5C73446074C59F223BAE05199D7C65ABB6F7CA77484AA7BE33657A71'
$expectedCatalogV213Hash = '1A6271C3E89DC351D3780BB3A84BD6CE793AA4DB9E75F98F5E377B5E9AED6203'
$frenchPathId = [long]996707670718014713

function Assert-Hash([string] $Path, [string] $Expected, [string] $Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "$Label introuvable : $Path" }
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
    if ($actual -ne $Expected) { throw "$Label inattendu : $actual" }
}

function Get-Crc32([byte[]] $Bytes) {
    [uint32] $crc = [uint32]::MaxValue
    $table = New-Object 'System.UInt32[]' 256
    for ($i = 0; $i -lt 256; $i++) {
        [uint32] $value = $i
        for ($bit = 0; $bit -lt 8; $bit++) {
            if (($value -band 1) -ne 0) { $value = [uint32]([uint32]0xEDB88320L -bxor ($value -shr 1)) }
            else { $value = [uint32]($value -shr 1) }
        }
        $table[$i] = $value
    }
    foreach ($byte in $Bytes) {
        $crc = [uint32]($table[($crc -bxor $byte) -band 0xFF] -bxor ($crc -shr 8))
    }
    [uint32]($crc -bxor [uint32]::MaxValue)
}

function Get-BundleInternalCrc([string] $Path) {
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundle = $manager.LoadBundleFile([IO.Path]::GetFullPath($Path), $true)
    $directory = $bundle.file.BlockAndDirInfo.DirectoryInfos[0]
    $bundle.file.DataReader.Position = $directory.Offset
    $data = $bundle.file.DataReader.ReadBytes([int]$directory.DecompressedSize)
    Get-Crc32 -Bytes $data
}

if (-not (Test-Path -LiteralPath $PayloadRoot)) { New-Item -ItemType Directory -Path $PayloadRoot | Out-Null }
$sourceLocales = Join-Path $SourcesRoot 'localization-locales_assets_all.bundle.official'
$sourceCatalogLegacy = Join-Path $SourcesRoot 'catalog.bin.official'
$sourceCatalogCurrent = Join-Path $SourcesRoot 'catalog-24613101.bin.official'
$sourceCatalogV213 = Join-Path $SourcesRoot 'catalog-24690909.bin.official'
$sourceFrench = Join-Path $SourcesRoot 'localization-string-tables-french(fr)_assets_all.v211.bundle'
$correctionsLegacyPath = Join-Path $projectRoot 'translations\corrections-v2.1.2.fr.json'
$correctionsV213Path = Join-Path $projectRoot 'translations\corrections-v2.1.3.fr.json'
$legacyFrenchPayload = Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.v212.bundle'
$frenchPayload = Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.bundle'
$localesOutput = Join-Path $PayloadRoot 'localization-locales_assets_all.bundle'
$catalogOutputLegacy = Join-Path $PayloadRoot 'catalog-24551494.bin'
$catalogOutputCurrent = Join-Path $PayloadRoot 'catalog.bin'
$catalogOutputV213 = Join-Path $PayloadRoot 'catalog-24690909.bin'

Assert-Hash $sourceLocales $officialLocalesHash 'Bundle Locales officiel'
Assert-Hash $sourceCatalogLegacy $officialCatalogLegacyHash 'Catalog officiel BuildID 24551494'
Assert-Hash $sourceCatalogCurrent $officialCatalogCurrentHash 'Catalog officiel BuildID 24613101'
Assert-Hash $sourceCatalogV213 $officialCatalogV213Hash 'Catalog officiel BuildID 24690909'
Assert-Hash $sourceFrench $baselineFrenchHash 'Bundle French traduit V2.1.1 de reference'
Assert-Hash $AssetsToolsDll '8D3CF02A877B0FA0363C7AA5AEDE18B8C1023519632F5E7EAC19AD084C743B34' 'AssetsTools.NET 3.0.5'
[void][Reflection.Assembly]::LoadFrom([IO.Path]::GetFullPath($AssetsToolsDll))

function New-CorrectedFrenchBundle(
    [string] $Source,
    [string] $Output,
    [string] $CorrectionsFile,
    [string] $ExpectedVersion,
    [int] $ExpectedCount
) {
    if (-not (Test-Path -LiteralPath $CorrectionsFile -PathType Leaf)) {
        throw "Fichier de corrections introuvable : $CorrectionsFile"
    }
    $definition = Get-Content -Raw -Encoding UTF8 -LiteralPath $CorrectionsFile | ConvertFrom-Json
    if ($definition.version -ne $ExpectedVersion -or @($definition.corrections).Count -ne $ExpectedCount) {
        throw "Le manifeste de corrections V$ExpectedVersion est inattendu."
    }

    $requested = @{}
    foreach ($correction in $definition.corrections) {
        $key = "$($correction.table):$($correction.id)"
        if ($requested.ContainsKey($key)) { throw "Correction dupliquee : $key" }
        $requested[$key] = $correction
    }

    $temporaryBundle = $Output + '.uncompressed.tmp'
    try {
        $manager = New-Object AssetsTools.NET.Extra.AssetsManager
        $bundleInstance = $manager.LoadBundleFile([IO.Path]::GetFullPath($Source), $true)
        $assetsInstance = $manager.LoadAssetsFileFromBundle($bundleInstance, 0, $false)
        $applied = 0

        foreach ($info in $assetsInstance.file.GetAssetsOfType(114)) {
            $base = $manager.GetBaseField($assetsInstance, $info)
            $assetName = $base.Get('m_Name').AsString
            if (-not $assetName.EndsWith('_fr', [StringComparison]::Ordinal)) { continue }
            $tableName = $assetName.Substring(0, $assetName.Length - 3)
            $entries = $base.Get('m_TableData').Get('Array')
            $changed = $false

            foreach ($entry in $entries.Children) {
                $key = "$tableName`:$($entry.Get('m_Id').AsULong)"
                if (-not $requested.ContainsKey($key)) { continue }
                $correction = $requested[$key]
                if ([bool]$correction.add) { throw "La cle a ajouter existe deja : $key" }
                $entry.Get('m_Localized').AsString = [string]$correction.text
                $requested.Remove($key)
                $applied++
                $changed = $true
            }

            $additions = @($requested.GetEnumerator() | Where-Object {
                $_.Value.table -eq $tableName -and [bool]$_.Value.add
            })
            foreach ($addition in $additions) {
                $templateId = [uint64][string]$addition.Value.smartTemplateId
                $template = $entries.Children | Where-Object { $_.Get('m_Id').AsULong -eq $templateId } | Select-Object -First 1
                if ($null -eq $template) { throw "Modele Smart String introuvable pour $($addition.Key)." }
                $newEntry = $template.Clone()
                $newEntry.Get('m_Id').AsULong = [uint64][string]$addition.Value.id
                $newEntry.Get('m_Localized').AsString = [string]$addition.Value.text
                $entries.Children.Add($newEntry)
                $entries.AsArray.size = $entries.Children.Count
                $requested.Remove([string]$addition.Key)
                $applied++
                $changed = $true
            }

            if ($changed) { $info.SetNewData($base) }
        }
        if ($requested.Count -ne 0 -or $applied -ne $ExpectedCount) {
            throw "Corrections French incompletes : $applied appliquee(s), $($requested.Count) restante(s)."
        }

        $bundleInstance.file.BlockAndDirInfo.DirectoryInfos[0].SetNewData($assetsInstance.file)
        $writer = New-Object AssetsTools.NET.AssetsFileWriter($temporaryBundle)
        $bundleInstance.file.Write($writer)
        $writer.Close()

        $stream = [IO.File]::OpenRead($temporaryBundle)
        $reader = New-Object AssetsTools.NET.AssetsFileReader($stream)
        $uncompressed = New-Object AssetsTools.NET.AssetBundleFile
        $uncompressed.Read($reader)
        $packedWriter = New-Object AssetsTools.NET.AssetsFileWriter($Output)
        $uncompressed.Pack($packedWriter, [AssetsTools.NET.AssetBundleCompressionType]::LZ4)
        $packedWriter.Close()
        $uncompressed.Close()
        $reader.Close()
        $stream.Close()
    }
    finally {
        if (Test-Path -LiteralPath $temporaryBundle) { Remove-Item -LiteralPath $temporaryBundle -Force }
    }
}

New-CorrectedFrenchBundle $sourceFrench $legacyFrenchPayload $correctionsLegacyPath '2.1.2' 10
Assert-Hash $legacyFrenchPayload $expectedFrenchLegacyHash 'Bundle French traduit V2.1.2 reconstruit'
New-CorrectedFrenchBundle $legacyFrenchPayload $frenchPayload $correctionsV213Path '2.1.3' 11
Assert-Hash $frenchPayload $expectedFrenchV213Hash 'Bundle French traduit V2.1.3 reconstruit'

$temporaryBundle = $localesOutput + '.uncompressed.tmp'
try {
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundleInstance = $manager.LoadBundleFile([IO.Path]::GetFullPath($sourceLocales), $true)
    $assetsInstance = $manager.LoadAssetsFileFromBundle($bundleInstance, 0, $false)
    $info = $assetsInstance.file.GetAssetInfo($frenchPathId)
    if ($null -eq $info) { throw 'Locale French PathID 996707670718014713 introuvable.' }
    $base = $manager.GetBaseField($assetsInstance, $info)
    if ($base.Get('m_Name').AsString -ne 'French (fr)' -or $base.Get('m_Identifier').Get('m_Code').AsString -ne 'fr') {
        throw 'Le PathID cible ne correspond pas a French (fr).'
    }

    $items = $base.Get('m_Metadata').Get('m_Items').Get('Array')
    $registry = $base.Get('references').AsManagedReferencesRegistry
    [long] $commentRid = 0
    foreach ($item in $items.Children) {
        $rid = $item.Get('rid').AsLong
        foreach ($reference in $registry.references) {
            if ($reference.rid -eq $rid -and $reference.data.TypeName -eq 'Comment' -and
                $reference.data.Get('m_CommentText').AsString -eq 'EDITOR') {
                $commentRid = $rid
            }
        }
    }
    if ($commentRid -eq 0) { throw 'La metadonnee Comment=EDITOR de French est introuvable.' }
    for ($index = $items.Children.Count - 1; $index -ge 0; $index--) {
        if ($items.Children[$index].Get('rid').AsLong -eq $commentRid) { $items.Children.RemoveAt($index) }
    }
    for ($index = $registry.references.Count - 1; $index -ge 0; $index--) {
        if ($registry.references[$index].rid -eq $commentRid) { $registry.references.RemoveAt($index) }
    }

    $info.SetNewData($base)
    $bundleInstance.file.BlockAndDirInfo.DirectoryInfos[0].SetNewData($assetsInstance.file)
    $writer = New-Object AssetsTools.NET.AssetsFileWriter($temporaryBundle)
    $bundleInstance.file.Write($writer)
    $writer.Close()

    $stream = [IO.File]::OpenRead($temporaryBundle)
    $reader = New-Object AssetsTools.NET.AssetsFileReader($stream)
    $uncompressed = New-Object AssetsTools.NET.AssetBundleFile
    $uncompressed.Read($reader)
    $packedWriter = New-Object AssetsTools.NET.AssetsFileWriter($localesOutput)
    $uncompressed.Pack($packedWriter, [AssetsTools.NET.AssetBundleCompressionType]::LZ4)
    $packedWriter.Close()
    $uncompressed.Close()
    $reader.Close()
    $stream.Close()
}
finally {
    if (Test-Path -LiteralPath $temporaryBundle) { Remove-Item -LiteralPath $temporaryBundle -Force }
}
Assert-Hash $localesOutput $expectedLocalesHash 'Bundle Locales V2.1 reconstruit'

function New-PatchedCatalog(
    [string] $Source,
    [string] $Output,
    [string] $ExpectedHash,
    [string] $BuildId,
    [string] $FrenchBundle
) {
    $catalog = [IO.File]::ReadAllBytes([IO.Path]::GetFullPath($Source))
    $changes = @(
        [pscustomobject]@{ Offset = 4723; Expected = [byte[]](0x66,0xD4,0x57,0xE3); Replacement = [BitConverter]::GetBytes((Get-BundleInternalCrc $localesOutput)); Label = 'Locales' },
        [pscustomobject]@{ Offset = 6143; Expected = [byte[]](0xF9,0x6D,0x07,0xD8); Replacement = [BitConverter]::GetBytes((Get-BundleInternalCrc $FrenchBundle)); Label = 'French' }
    )
    foreach ($change in $changes) {
        for ($index = 0; $index -lt 4; $index++) {
            if ($catalog[$change.Offset + $index] -ne $change.Expected[$index]) {
                throw "Octets source inattendus dans catalog.bin BuildID $BuildId pour $($change.Label)."
            }
            $catalog[$change.Offset + $index] = $change.Replacement[$index]
        }
    }
    [IO.File]::WriteAllBytes([IO.Path]::GetFullPath($Output), $catalog)
    Assert-Hash $Output $ExpectedHash "Catalog V2.1 BuildID $BuildId reconstruit"
}

New-PatchedCatalog $sourceCatalogLegacy $catalogOutputLegacy $expectedCatalogLegacyHash '24551494' $legacyFrenchPayload
New-PatchedCatalog $sourceCatalogCurrent $catalogOutputCurrent $expectedCatalogCurrentHash '24613101' $legacyFrenchPayload
New-PatchedCatalog $sourceCatalogV213 $catalogOutputV213 $expectedCatalogV213Hash '24690909' $frenchPayload

Write-Host 'Payload V2.1.3 reconstruit et verifie.'
Write-Host 'French V2.1.2 conserve pour les deux profils Guildrun 0.5.3.'
Write-Host 'French V2.1.3 : 11 textes adaptes a Guildrun 0.5.4.'
Write-Host 'French PathID 996707670718014713 : Comment=EDITOR supprime.'
Write-Host 'Catalogues 24551494, 24613101 et 24690909 : octets 4723-4726 (Locales) et 6143-6146 (French) uniquement.'
