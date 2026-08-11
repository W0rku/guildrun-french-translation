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
    $BaselineFrenchBundle = Join-Path $projectRoot 'sources\localization-string-tables-french(fr)_assets_all.v211.bundle'
}
if ([string]::IsNullOrWhiteSpace($CorrectedFrenchBundle)) {
    $CorrectedFrenchBundle = Join-Path $projectRoot 'payload\localization-string-tables-french(fr)_assets_all.bundle'
}
if ([string]::IsNullOrWhiteSpace($AssetsToolsDll)) {
    $AssetsToolsDll = Join-Path $PSScriptRoot 'vendor\AssetsTools.NET.dll'
}
$correctionsPath = Join-Path $projectRoot 'translations\corrections-v2.1.2.fr.json'

foreach ($required in @($EnglishBundle, $BaselineFrenchBundle, $CorrectedFrenchBundle, $AssetsToolsDll, $correctionsPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Fichier requis introuvable : $required" }
}
[void][Reflection.Assembly]::LoadFrom([IO.Path]::GetFullPath($AssetsToolsDll))

function Assert-Audit([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

function Get-StringTableEntries([string] $BundlePath, [string] $LocaleSuffix) {
    $result = @{}
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
        foreach ($entry in $base.Get('m_TableData').Get('Array').Children) {
            $hasSmart = $false
            foreach ($item in $entry.Get('m_Metadata').Get('m_Items').Get('Array').Children) {
                if ($smartRids.ContainsKey([long]$item.Get('rid').AsLong)) { $hasSmart = $true }
            }
            $key = "$tableName`:$($entry.Get('m_Id').AsULong)"
            if ($result.ContainsKey($key)) { throw "Cle dupliquee dans $BundlePath : $key" }
            $result[$key] = [pscustomobject]@{
                Table = $tableName
                Id = [string]$entry.Get('m_Id').AsULong
                Text = $entry.Get('m_Localized').AsString
                Smart = $hasSmart
            }
        }
    }
    $result
}

function Get-TokenSignature([string] $Text, [string] $Pattern, [int] $Group) {
    @(foreach ($match in [regex]::Matches($Text, $Pattern)) { $match.Groups[$Group].Value }) | Sort-Object
}

$english = Get-StringTableEntries $EnglishBundle '_en'
$baseline = Get-StringTableEntries $BaselineFrenchBundle '_fr'
$french = Get-StringTableEntries $CorrectedFrenchBundle '_fr'
$definition = Get-Content -Raw -Encoding UTF8 -LiteralPath $correctionsPath | ConvertFrom-Json
$declared = @{}
foreach ($correction in $definition.corrections) { $declared["$($correction.table):$($correction.id)"] = [string]$correction.text }

Assert-Audit ($english.Count -eq 3919) "Nombre de cles English inattendu : $($english.Count)."
Assert-Audit ($french.Count -eq 3919) "Nombre de cles French inattendu : $($french.Count)."
$missing = @($english.Keys | Where-Object { -not $french.ContainsKey($_) })
$extra = @($french.Keys | Where-Object { -not $english.ContainsKey($_) })
Assert-Audit ($missing.Count -eq 0 -and $extra.Count -eq 0) "Ecart de cles : $($missing.Count) manquante(s), $($extra.Count) supplementaire(s)."

$changed = @($french.Keys | Where-Object { -not $baseline.ContainsKey($_) -or $baseline[$_].Text -cne $french[$_].Text })
$removed = @($baseline.Keys | Where-Object { -not $french.ContainsKey($_) })
Assert-Audit ($removed.Count -eq 0) "Des cles French V2.1.1 ont ete supprimees : $($removed -join ', ')."
Assert-Audit ($changed.Count -eq 10) "Nombre de corrections effectives inattendu : $($changed.Count)."
Assert-Audit (@($changed | Where-Object { -not $declared.ContainsKey($_) }).Count -eq 0) 'Une modification French n est pas declaree.'
foreach ($key in $declared.Keys) {
    Assert-Audit ($french.ContainsKey($key)) "Correction absente : $key."
    Assert-Audit ($french[$key].Text -ceq $declared[$key]) "Texte corrige inattendu : $key."
}

$smartMismatch = @()
$placeholderMismatch = @()
$tagMismatch = @()
$placeholderWithoutSmart = @()
$invalidSelector = @()
foreach ($key in $english.Keys) {
    $en = $english[$key]
    $fr = $french[$key]
    if ($en.Smart -ne $fr.Smart) { $smartMismatch += $key }
    $enArgs = @(Get-TokenSignature $en.Text '\{(\d+)' 1)
    $frArgs = @(Get-TokenSignature $fr.Text '\{(\d+)' 1)
    if (($enArgs -join ',') -cne ($frArgs -join ',')) { $placeholderMismatch += $key }
    $enTags = @(Get-TokenSignature $en.Text '<([^>]+)>' 1)
    $frTags = @(Get-TokenSignature $fr.Text '<([^>]+)>' 1)
    if (($enTags -join ',') -cne ($frTags -join ',')) { $tagMismatch += $key }
    if ($fr.Text -match '\{\d+:[^}]+' -and -not $fr.Smart) { $placeholderWithoutSmart += $key }
    if ($fr.Text -match '\{\d+:pluriel\s*:') { $invalidSelector += $key }
}

Assert-Audit ($smartMismatch.Count -eq 0) "Metadonnees Smart String divergentes : $($smartMismatch -join ', ')."
Assert-Audit ($placeholderMismatch.Count -eq 0) "Arguments de format divergents : $($placeholderMismatch -join ', ')."
Assert-Audit ($tagMismatch.Count -eq 0) "Balises de gameplay divergentes : $($tagMismatch -join ', ')."
Assert-Audit ($placeholderWithoutSmart.Count -eq 0) "Formats dynamiques sans SmartFormatTag : $($placeholderWithoutSmart -join ', ')."
Assert-Audit ($invalidSelector.Count -eq 0) "Selecteur Smart String traduit par erreur : $($invalidSelector -join ', ')."

Write-Host 'Audit traduction V2.1.2 valide.'
Write-Host "English : $($english.Count) cles."
Write-Host "French : $($french.Count) cles, aucune manquante."
Write-Host "Corrections ciblees : $($changed.Count)."
Write-Host 'Smart Strings, arguments et balises : conformes aux tables English.'
