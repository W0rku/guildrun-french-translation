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
$officialCatalogHash = 'DC16E4280C5FAD3526AEC223B3C41F9A46B519D3EED96E1364EB20DA6A6A5783'
$translatedFrenchHash = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
$expectedLocalesHash = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
$expectedCatalogHash = '57A6EA642CE9DE2D89EB8F57FE083C66030834A8519806087D2EFE722A1231CC'
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
$sourceCatalog = Join-Path $SourcesRoot 'catalog.bin.official'
$frenchPayload = Join-Path $PayloadRoot 'localization-string-tables-french(fr)_assets_all.bundle'
$localesOutput = Join-Path $PayloadRoot 'localization-locales_assets_all.bundle'
$catalogOutput = Join-Path $PayloadRoot 'catalog.bin'

Assert-Hash $sourceLocales $officialLocalesHash 'Bundle Locales officiel'
Assert-Hash $sourceCatalog $officialCatalogHash 'Catalog officiel'
Assert-Hash $frenchPayload $translatedFrenchHash 'Bundle French traduit V2'
Assert-Hash $AssetsToolsDll '8D3CF02A877B0FA0363C7AA5AEDE18B8C1023519632F5E7EAC19AD084C743B34' 'AssetsTools.NET 3.0.5'
[void][Reflection.Assembly]::LoadFrom([IO.Path]::GetFullPath($AssetsToolsDll))

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

$catalog = [IO.File]::ReadAllBytes([IO.Path]::GetFullPath($sourceCatalog))
$changes = @(
    [pscustomobject]@{ Offset = 4723; Expected = [byte[]](0x66,0xD4,0x57,0xE3); Replacement = [BitConverter]::GetBytes((Get-BundleInternalCrc $localesOutput)); Label = 'Locales' },
    [pscustomobject]@{ Offset = 6143; Expected = [byte[]](0xF9,0x6D,0x07,0xD8); Replacement = [BitConverter]::GetBytes((Get-BundleInternalCrc $frenchPayload)); Label = 'French' }
)
foreach ($change in $changes) {
    for ($index = 0; $index -lt 4; $index++) {
        if ($catalog[$change.Offset + $index] -ne $change.Expected[$index]) {
            throw "Octets source inattendus dans catalog.bin pour $($change.Label)."
        }
        $catalog[$change.Offset + $index] = $change.Replacement[$index]
    }
}
[IO.File]::WriteAllBytes([IO.Path]::GetFullPath($catalogOutput), $catalog)
Assert-Hash $catalogOutput $expectedCatalogHash 'Catalog V2.1 reconstruit'

Write-Host 'Payload V2.1 reconstruit et verifie.'
Write-Host 'French PathID 996707670718014713 : Comment=EDITOR supprime.'
Write-Host 'catalog.bin : octets 4723-4726 (Locales) et 6143-6146 (French) uniquement.'
