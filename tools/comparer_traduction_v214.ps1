[CmdletBinding()]
param(
    [string] $EnglishBundle,
    [string] $FrenchBundle,
    [string] $AssetsToolsDll,
    [string] $SearchPattern
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($EnglishBundle)) {
    $EnglishBundle = Join-Path (Split-Path -Parent $projectRoot) 'Guildrun_Data\StreamingAssets\aa\StandaloneWindows64\localization-string-tables-english(en)_assets_all.bundle'
}
if ([string]::IsNullOrWhiteSpace($FrenchBundle)) {
    $FrenchBundle = Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.bundle'
}
if ([string]::IsNullOrWhiteSpace($AssetsToolsDll)) {
    $AssetsToolsDll = Join-Path $PSScriptRoot 'vendor\AssetsTools.NET.dll'
}
foreach ($required in @($EnglishBundle, $FrenchBundle, $AssetsToolsDll)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Fichier requis introuvable : $required" }
}
[void][Reflection.Assembly]::LoadFrom([IO.Path]::GetFullPath($AssetsToolsDll))

function Get-Entries([string] $BundlePath, [string] $LocaleSuffix) {
    $result = New-Object System.Collections.Generic.List[object]
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundle = $manager.LoadBundleFile([IO.Path]::GetFullPath($BundlePath), $true)
    $assets = $manager.LoadAssetsFileFromBundle($bundle, 0, $false)
    foreach ($info in $assets.file.GetAssetsOfType(114)) {
        $base = $manager.GetBaseField($assets, $info)
        $assetName = $base.Get('m_Name').AsString
        if (-not $assetName.EndsWith($LocaleSuffix, [StringComparison]::Ordinal)) { continue }
        $tableName = $assetName.Substring(0, $assetName.Length - $LocaleSuffix.Length)
        $smartRids = @{}
        foreach ($reference in $base.Get('references').AsManagedReferencesRegistry.references) {
            if ($reference.data.TypeName -eq 'SmartFormatTag') { $smartRids[[long]$reference.rid] = $true }
        }
        $index = 0
        foreach ($entry in $base.Get('m_TableData').Get('Array').Children) {
            $smart = $false
            foreach ($item in $entry.Get('m_Metadata').Get('m_Items').Get('Array').Children) {
                if ($smartRids.ContainsKey([long]$item.Get('rid').AsLong)) { $smart = $true }
            }
            $result.Add([pscustomobject]@{
                Key = "$tableName`:$($entry.Get('m_Id').AsULong)"
                Table = $tableName
                Index = $index
                Id = [string]$entry.Get('m_Id').AsULong
                Text = $entry.Get('m_Localized').AsString
                Smart = $smart
            })
            $index++
        }
    }
    $result
}

function Get-Signature([string] $Text, [string] $Pattern, [int] $Group) {
    @(foreach ($match in [regex]::Matches($Text, $Pattern)) { $match.Groups[$Group].Value }) | Sort-Object
}

$english = @(Get-Entries $EnglishBundle '_en')
$french = @(Get-Entries $FrenchBundle '_fr')
$englishMap = @{}; foreach ($entry in $english) { $englishMap[$entry.Key] = $entry }
$frenchMap = @{}; foreach ($entry in $french) { $frenchMap[$entry.Key] = $entry }
$missing = @($english | Where-Object { -not $frenchMap.ContainsKey($_.Key) })
$extra = @($french | Where-Object { -not $englishMap.ContainsKey($_.Key) })
$mismatches = @()
foreach ($en in $english) {
    if (-not $frenchMap.ContainsKey($en.Key)) { continue }
    $fr = $frenchMap[$en.Key]
    $enArgs = @(Get-Signature $en.Text '\{(\d+)' 1)
    $frArgs = @(Get-Signature $fr.Text '\{(\d+)' 1)
    $enTags = @(Get-Signature $en.Text '<([^>]+)>' 1)
    $frTags = @(Get-Signature $fr.Text '<([^>]+)>' 1)
    if ($en.Smart -ne $fr.Smart -or ($enArgs -join ',') -cne ($frArgs -join ',') -or ($enTags -join ',') -cne ($frTags -join ',')) {
        $mismatches += [pscustomobject]@{
            Key = $en.Key
            Smart = "$($en.Smart)/$($fr.Smart)"
            EnglishArgs = $enArgs -join ','
            FrenchArgs = $frArgs -join ','
            EnglishTags = $enTags -join ','
            FrenchTags = $frTags -join ','
            English = $en.Text
            French = $fr.Text
        }
    }
}

Write-Host "English=$($english.Count) French=$($french.Count) Missing=$($missing.Count) Extra=$($extra.Count) StructuralMismatches=$($mismatches.Count)"
foreach ($item in $mismatches) {
    Write-Host "`nKEY $($item.Key)"
    Write-Host "ARGS EN=[$($item.EnglishArgs)] FR=[$($item.FrenchArgs)] SMART=$($item.Smart)"
    Write-Host "TAGS EN=[$($item.EnglishTags)] FR=[$($item.FrenchTags)]"
    Write-Host "EN: $($item.English)"
    Write-Host "FR: $($item.French)"
}

if (-not [string]::IsNullOrWhiteSpace($SearchPattern)) {
    Write-Host "`nSEARCH $SearchPattern"
    $matches = @($english | Where-Object { $_.Text -match $SearchPattern })
    foreach ($match in $matches) {
        $fr = $frenchMap[$match.Key]
        Write-Host "`nKEY $($match.Key) INDEX=$($match.Index)"
        Write-Host "EN: $($match.Text)"
        if ($null -ne $fr) { Write-Host "FR: $($fr.Text)" }
    }
}
