$ErrorActionPreference = 'Stop'

function Get-GuildrunV21Policy {
    [CmdletBinding()]
    param()

    $profiles = @(
        [pscustomobject]@{
            Name = 'Steam-24551494'
            SteamBuildId = '24551494'
            GameVersion = '0.5.3'
            GameBuild = 748
            OriginalEnglishHash = '8D9798819E3A2DDEE313E0BCB426030B540B7FD3195AA7BB8B24559983606629'
            OriginalCatalogHash = 'DC16E4280C5FAD3526AEC223B3C41F9A46B519D3EED96E1364EB20DA6A6A5783'
            PreviousPatchedFrenchHash = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
            PreviousPatchedCatalogHash = '57A6EA642CE9DE2D89EB8F57FE083C66030834A8519806087D2EFE722A1231CC'
            PatchedFrenchHash = '7C8D467B719EEEE955C0226248EC90004277842B5017436607E7A01EAE388305'
            PatchedCatalogHash = '44BC589D21336E54170B5F39702BFAE8E07B971AB573B1459BD09008D6D97232'
            PayloadFrenchName = 'localization-string-tables-french(fr)_assets_all.v212.bundle'
            PayloadCatalogName = 'catalog-24551494.bin'
            BackupDirectoryName = 'sauvegarde-locale'
        },
        [pscustomobject]@{
            Name = 'Steam-24613101'
            SteamBuildId = '24613101'
            GameVersion = '0.5.3'
            GameBuild = 748
            OriginalEnglishHash = '30A0230858D555CBF2900CD1B2936CA4A148CFFF8E09677870155D39EB338744'
            OriginalCatalogHash = '1E436E183F5CC451943F090AD2166B56D592EEBDB75C0D2AD210EEF7FDB26E85'
            PreviousPatchedFrenchHash = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
            PreviousPatchedCatalogHash = '581FE651C8CA4E89BFFC7F789995DA3EFA0EDAA40684F8160E7B2267BA370F4B'
            PatchedFrenchHash = '7C8D467B719EEEE955C0226248EC90004277842B5017436607E7A01EAE388305'
            PatchedCatalogHash = '7B78213D5C73446074C59F223BAE05199D7C65ABB6F7CA77484AA7BE33657A71'
            PayloadFrenchName = 'localization-string-tables-french(fr)_assets_all.v212.bundle'
            PayloadCatalogName = 'catalog.bin'
            BackupDirectoryName = 'sauvegarde-locale-24613101'
        },
        [pscustomobject]@{
            Name = 'Steam-24690909'
            SteamBuildId = '24690909'
            GameVersion = '0.5.4'
            GameBuild = 767
            OriginalEnglishHash = 'A39EB85FAE5C1EBBF6385D9D7798E6D8F8287D55402098FDF5AB96D288ACCA8F'
            OriginalCatalogHash = '647051CA4D8AAF4ED9E2BB13674E690333C689D9743F88D0DFB4DE3097FA820C'
            PreviousPatchedFrenchHash = $null
            PreviousPatchedCatalogHash = $null
            PatchedFrenchHash = '07995AA60F88CCAE1FDE1FA375819099906BC0EBCAA0B424358637D00AADDE73'
            PatchedCatalogHash = '1A6271C3E89DC351D3780BB3A84BD6CE793AA4DB9E75F98F5E377B5E9AED6203'
            PayloadFrenchName = 'localization-string-tables-french(fr)_assets_all.v213.bundle'
            PayloadCatalogName = 'catalog-24690909.bin'
            BackupDirectoryName = 'sauvegarde-locale-24690909'
        },
        [pscustomobject]@{
            Name = 'Steam-24816645'
            SteamBuildId = '24816645'
            GameVersion = '0.5.5'
            GameBuild = 783
            OriginalEnglishHash = 'CA2B6A9BCEFBC64D44FEFE5B10C5FA77419C5081095584B7B8516C0EC82811BE'
            OriginalCatalogHash = 'C48AAD223DB7A7DC3620CEBE29E8AF4C8F0B15990549B32A966DA48BF712F2BF'
            PreviousPatchedFrenchHash = $null
            PreviousPatchedCatalogHash = $null
            PatchedFrenchHash = '907B489269EFD5F359C456CA62EC9FB5C77621B8CCB17AE1122F64F9434D321B'
            PatchedCatalogHash = '0B47CD7DD74CDD840BABB1A5D4F696732F1116091C9035E53EB76D4488F5E28A'
            PayloadFrenchName = 'localization-string-tables-french(fr)_assets_all.bundle'
            PayloadCatalogName = 'catalog-24816645.bin'
            BackupDirectoryName = 'sauvegarde-locale-24816645'
        }
    )

    [pscustomobject]@{
        GameVersion          = $profiles[3].GameVersion
        GameBuild            = $profiles[3].GameBuild
        EnglishBundleName    = 'localization-string-tables-english(en)_assets_all.bundle'
        FrenchBundleName     = 'localization-string-tables-french(fr)_assets_all.bundle'
        LocalesBundleName    = 'localization-locales_assets_all.bundle'
        CatalogName          = 'catalog.bin'
        OriginalExecutableHash = '33B701F9128366079EF47495259361A094D83DD293AB03B60870997B36D60882'
        OriginalEnglishHash  = $profiles[3].OriginalEnglishHash
        OriginalFrenchHash   = 'C076AA88A443CC945992402D7DE40DCDFDC4DE27228745A37EC735E647C23A32'
        OriginalLocalesHash  = 'D4A2D1D0DC9773DFA75E07778EE90EF9F13252DE96DF2E1D72F4A8476E3BBDC7'
        OriginalCatalogHash  = $profiles[3].OriginalCatalogHash
        PreviousPatchedFrenchHash = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
        PatchedFrenchHash    = $profiles[3].PatchedFrenchHash
        PatchedLocalesHash   = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
        PatchedCatalogHash   = $profiles[3].PatchedCatalogHash
        Profiles             = $profiles
    }
}

function Get-GuildrunV21Paths {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $GameRoot,
        [Parameter(Mandatory = $true)] [string] $PayloadRoot,
        [Parameter(Mandatory = $true)] $Policy
    )

    $resolvedGameRoot = [IO.Path]::GetFullPath($GameRoot)
    $resolvedPayloadRoot = [IO.Path]::GetFullPath($PayloadRoot)
    $assetsRoot = Join-Path $resolvedGameRoot 'Guildrun_Data\StreamingAssets\aa'
    $bundlesRoot = Join-Path $assetsRoot 'StandaloneWindows64'

    [pscustomobject]@{
        GameRoot        = $resolvedGameRoot
        PayloadRoot     = $resolvedPayloadRoot
        Executable      = Join-Path $resolvedGameRoot 'Guildrun.exe'
        English         = Join-Path $bundlesRoot $Policy.EnglishBundleName
        French          = Join-Path $bundlesRoot $Policy.FrenchBundleName
        Locales         = Join-Path $bundlesRoot $Policy.LocalesBundleName
        Catalog         = Join-Path $assetsRoot $Policy.CatalogName
        PayloadFrench   = Join-Path $resolvedPayloadRoot $Policy.FrenchBundleName
        PayloadLocales  = Join-Path $resolvedPayloadRoot $Policy.LocalesBundleName
        PayloadCatalog  = Join-Path $resolvedPayloadRoot $Policy.CatalogName
        BackupRoot      = Join-Path $resolvedGameRoot 'Traduction_FR_V2.1\sauvegarde-locale-24816645'
        TransactionRoot = Join-Path $resolvedGameRoot 'Traduction_FR_V2.1\.transactions'
    }
}

function Set-GuildrunV21ProfilePaths {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $Profile
    )

    $Paths.PayloadCatalog = Join-Path $Paths.PayloadRoot $Profile.PayloadCatalogName
    $Paths.PayloadFrench = Join-Path $Paths.PayloadRoot $Profile.PayloadFrenchName
    $Paths.BackupRoot = Join-Path $Paths.GameRoot (Join-Path 'Traduction_FR_V2.1' $Profile.BackupDirectoryName)
    $Paths
}

function Get-GuildrunSha256 {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [string] $LiteralPath)

    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
        throw "Fichier introuvable : $LiteralPath"
    }
    (Get-FileHash -Algorithm SHA256 -LiteralPath $LiteralPath).Hash.ToUpperInvariant()
}

function Assert-GuildrunHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $LiteralPath,
        [Parameter(Mandatory = $true)] [string] $ExpectedHash,
        [Parameter(Mandatory = $true)] [string] $Label
    )

    $actual = Get-GuildrunSha256 -LiteralPath $LiteralPath
    if ($actual -ne $ExpectedHash.ToUpperInvariant()) {
        throw "$Label ne correspond pas a la version attendue (SHA-256 $actual)."
    }
    $actual
}

function Get-GuildrunV21State {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $Policy
    )

    if (-not (Test-Path -LiteralPath $Paths.Executable -PathType Leaf)) {
        throw 'Guildrun.exe est absent du dossier selectionne.'
    }

    $hashes = [ordered]@{
        Executable = Get-GuildrunSha256 -LiteralPath $Paths.Executable
        English = Get-GuildrunSha256 -LiteralPath $Paths.English
        French  = Get-GuildrunSha256 -LiteralPath $Paths.French
        Locales = Get-GuildrunSha256 -LiteralPath $Paths.Locales
        Catalog = Get-GuildrunSha256 -LiteralPath $Paths.Catalog
    }

    if ($hashes.Executable -ne $Policy.OriginalExecutableHash) {
        throw "Version inconnue : Guildrun.exe ne correspond a aucune version prise en charge."
    }
    $profiles = @($Policy.Profiles | Where-Object { $_.OriginalEnglishHash -eq $hashes.English })
    if ($profiles.Count -eq 0) {
        throw 'Version inconnue ou bundle anglais modifie. Faites verifier les fichiers du jeu par Steam.'
    }

    $matches = @()
    foreach ($profile in $profiles) {
        $isOriginal = $hashes.French -eq $Policy.OriginalFrenchHash -and
            $hashes.Locales -eq $Policy.OriginalLocalesHash -and
            $hashes.Catalog -eq $profile.OriginalCatalogHash
        $isInstalled = $hashes.French -eq $profile.PatchedFrenchHash -and
            $hashes.Locales -eq $Policy.PatchedLocalesHash -and
            $hashes.Catalog -eq $profile.PatchedCatalogHash
        $hasPreviousPatch = -not [string]::IsNullOrWhiteSpace([string]$profile.PreviousPatchedFrenchHash) -and
            -not [string]::IsNullOrWhiteSpace([string]$profile.PreviousPatchedCatalogHash)
        $isPreviousInstalled = $hasPreviousPatch -and
            $hashes.French -eq $profile.PreviousPatchedFrenchHash -and
            $hashes.Locales -eq $Policy.PatchedLocalesHash -and
            $hashes.Catalog -eq $profile.PreviousPatchedCatalogHash
        if ($isOriginal -or $isInstalled -or $isPreviousInstalled) {
            $name = if ($isOriginal) { 'Original' } elseif ($isInstalled) { 'Installed' } else { 'PreviousInstalled' }
            $matches += [pscustomobject]@{ Profile = $profile; Name = $name }
        }
    }

    if ($matches.Count -ne 1) {
        throw "Version inconnue ou etat partiellement patche : seuls les profils Guildrun officiels reconnus et les installations completes V2.1.1 a V2.1.4 sont acceptes. Aucun fichier n'a ete modifie."
    }

    $selected = $matches[0]

    [pscustomobject]@{
        Name        = $selected.Name
        Profile     = $selected.Profile
        SteamBuildId = $selected.Profile.SteamBuildId
        ExecutableHash = $hashes.Executable
        EnglishHash = $hashes.English
        FrenchHash  = $hashes.French
        LocalesHash = $hashes.Locales
        CatalogHash = $hashes.Catalog
    }
}

function Assert-GuildrunV21Payload {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $Policy
    )

    Assert-GuildrunHash -LiteralPath $Paths.PayloadLocales -ExpectedHash $Policy.PatchedLocalesHash -Label 'Bundle Locales distribue' | Out-Null
    $validatedFrench = @{}
    foreach ($profile in $Policy.Profiles) {
        if (-not $validatedFrench.ContainsKey($profile.PayloadFrenchName)) {
            $frenchPath = Join-Path $Paths.PayloadRoot $profile.PayloadFrenchName
            Assert-GuildrunHash -LiteralPath $frenchPath -ExpectedHash $profile.PatchedFrenchHash -Label "Bundle francais distribue $($profile.SteamBuildId)" | Out-Null
            $validatedFrench[$profile.PayloadFrenchName] = $true
        }
        $catalogPath = Join-Path $Paths.PayloadRoot $profile.PayloadCatalogName
        Assert-GuildrunHash -LiteralPath $catalogPath -ExpectedHash $profile.PatchedCatalogHash -Label "Catalogue distribue $($profile.SteamBuildId)" | Out-Null
    }
}

function Install-GuildrunFileAtomic {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Source,
        [Parameter(Mandatory = $true)] [string] $Destination,
        [Parameter(Mandatory = $true)] [string] $ExpectedHash
    )

    $temporary = $Destination + '.guildrun-fr-v21.new'
    $replaced = $Destination + '.guildrun-fr-v21.replaced'
    try {
        Copy-Item -LiteralPath $Source -Destination $temporary -Force
        Assert-GuildrunHash -LiteralPath $temporary -ExpectedHash $ExpectedHash -Label 'Fichier temporaire' | Out-Null
        if (Test-Path -LiteralPath $replaced) { Remove-Item -LiteralPath $replaced -Force }
        [IO.File]::Replace($temporary, $Destination, $replaced)
        Assert-GuildrunHash -LiteralPath $Destination -ExpectedHash $ExpectedHash -Label 'Fichier installe' | Out-Null
    }
    finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
        if (Test-Path -LiteralPath $replaced) { Remove-Item -LiteralPath $replaced -Force }
    }
}

function New-GuildrunTransactionBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $RegistryState
    )

    New-Item -ItemType Directory -Path $Paths.TransactionRoot -Force | Out-Null
    $root = Join-Path $Paths.TransactionRoot ([guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $entries = @(
        [pscustomobject]@{ Name = 'French'; Source = $Paths.French; Backup = (Join-Path $root 'french.bundle.before') },
        [pscustomobject]@{ Name = 'Locales'; Source = $Paths.Locales; Backup = (Join-Path $root 'locales.bundle.before') },
        [pscustomobject]@{ Name = 'Catalog'; Source = $Paths.Catalog; Backup = (Join-Path $root 'catalog.bin.before') }
    )
    foreach ($entry in $entries) {
        $entry | Add-Member -NotePropertyName Hash -NotePropertyValue (Get-GuildrunSha256 -LiteralPath $entry.Source)
        Copy-Item -LiteralPath $entry.Source -Destination $entry.Backup
        Assert-GuildrunHash -LiteralPath $entry.Backup -ExpectedHash $entry.Hash -Label "Sauvegarde transactionnelle $($entry.Name)" | Out-Null
    }
    [pscustomobject]@{ Root = $root; Entries = $entries; RegistryState = $RegistryState }
}

function Restore-GuildrunTransactionBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $Transaction
    )

    $destinations = @{ French = $Paths.French; Locales = $Paths.Locales; Catalog = $Paths.Catalog }
    foreach ($entry in $Transaction.Entries) {
        Install-GuildrunFileAtomic -Source $entry.Backup -Destination $destinations[$entry.Name] -ExpectedHash $entry.Hash
    }
    foreach ($entry in $Transaction.Entries) {
        Assert-GuildrunHash -LiteralPath $destinations[$entry.Name] -ExpectedHash $entry.Hash -Label "Fichier restaure $($entry.Name)" | Out-Null
    }
}

function Remove-GuildrunTransactionBackup {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $Transaction)
    if ($null -ne $Transaction -and (Test-Path -LiteralPath $Transaction.Root)) {
        Remove-Item -LiteralPath $Transaction.Root -Recurse -Force
    }
}

function ConvertTo-GuildrunRegistryRecord {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $State)

    if (-not [bool]$State.Exists) {
        return [pscustomobject]@{ Exists = $false; Kind = $null; ValueBase64 = $null; StringValues = $null }
    }

    $kind = [string]$State.Kind
    $bytes = $null
    $strings = $null
    switch ($kind) {
        'Binary'       { $bytes = [byte[]]$State.Value }
        'None'         { $bytes = [byte[]]$State.Value }
        'DWord'        { $bytes = [BitConverter]::GetBytes([int]$State.Value) }
        'QWord'        { $bytes = [BitConverter]::GetBytes([long]$State.Value) }
        'String'       { $bytes = [Text.Encoding]::Unicode.GetBytes([string]$State.Value) }
        'ExpandString' { $bytes = [Text.Encoding]::Unicode.GetBytes([string]$State.Value) }
        'MultiString'  { $strings = @([string[]]$State.Value) }
        default        { throw "Type de registre non pris en charge : $kind" }
    }
    [pscustomobject]@{
        Exists = $true
        Kind = $kind
        ValueBase64 = $(if ($null -eq $bytes) { $null } else { [Convert]::ToBase64String($bytes) })
        StringValues = $strings
    }
}

function ConvertFrom-GuildrunRegistryRecord {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $Record)

    if (-not [bool]$Record.Exists) {
        return [pscustomobject]@{ Exists = $false; Kind = $null; Value = $null }
    }
    $kind = [string]$Record.Kind
    $bytes = if ($null -eq $Record.ValueBase64) { $null } else { [Convert]::FromBase64String([string]$Record.ValueBase64) }
    $value = switch ($kind) {
        'Binary'       { [byte[]]$bytes; break }
        'None'         { [byte[]]$bytes; break }
        'DWord'        { [BitConverter]::ToInt32($bytes, 0); break }
        'QWord'        { [BitConverter]::ToInt64($bytes, 0); break }
        'String'       { [Text.Encoding]::Unicode.GetString($bytes); break }
        'ExpandString' { [Text.Encoding]::Unicode.GetString($bytes); break }
        'MultiString'  { [string[]]@($Record.StringValues); break }
        default        { throw "Type de registre sauvegarde non pris en charge : $kind" }
    }
    [pscustomobject]@{ Exists = $true; Kind = $kind; Value = $value }
}

function Get-GuildrunLocalePreferenceState {
    [CmdletBinding()]
    param([scriptblock] $RegistryReader)

    $displayPath = 'HKCU:\Software\Leyline\Guildrun'
    $subKey = 'Software\Leyline\Guildrun'
    $name = 'selected-locale_h3890535593'
    if ($null -ne $RegistryReader) {
        $state = & $RegistryReader $displayPath $name
        return ConvertFrom-GuildrunRegistryRecord (ConvertTo-GuildrunRegistryRecord $state)
    }

    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subKey, $false)
    if ($null -eq $key) { return [pscustomobject]@{ Exists = $false; Kind = $null; Value = $null } }
    try {
        $exists = @($key.GetValueNames()) -contains $name
        if (-not $exists) { return [pscustomobject]@{ Exists = $false; Kind = $null; Value = $null } }
        $kind = $key.GetValueKind($name).ToString()
        $value = $key.GetValue($name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        ConvertFrom-GuildrunRegistryRecord (ConvertTo-GuildrunRegistryRecord ([pscustomobject]@{ Exists = $true; Kind = $kind; Value = $value }))
    }
    finally { $key.Dispose() }
}

function Test-GuildrunLocalePreferenceEqual {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Left,
        [Parameter(Mandatory = $true)] $Right
    )
    $leftJson = ConvertTo-GuildrunRegistryRecord $Left | ConvertTo-Json -Depth 5 -Compress
    $rightJson = ConvertTo-GuildrunRegistryRecord $Right | ConvertTo-Json -Depth 5 -Compress
    $leftJson -ceq $rightJson
}

function Restore-GuildrunLocalePreferenceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $State,
        [scriptblock] $RegistryRestorer
    )

    $displayPath = 'HKCU:\Software\Leyline\Guildrun'
    $subKey = 'Software\Leyline\Guildrun'
    $name = 'selected-locale_h3890535593'
    if ($null -ne $RegistryRestorer) {
        & $RegistryRestorer $displayPath $name (ConvertFrom-GuildrunRegistryRecord (ConvertTo-GuildrunRegistryRecord $State))
        return
    }

    if (-not $State.Exists) {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subKey, $true)
        if ($null -ne $key) {
            try { $key.DeleteValue($name, $false) }
            finally { $key.Dispose() }
        }
        return
    }
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($subKey)
    try {
        $kind = [Microsoft.Win32.RegistryValueKind][Enum]::Parse([Microsoft.Win32.RegistryValueKind], [string]$State.Kind)
        $key.SetValue($name, $State.Value, $kind)
    }
    finally { $key.Dispose() }
}

function Assert-GuildrunLocalePreferenceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Expected,
        [scriptblock] $RegistryReader
    )
    $actual = Get-GuildrunLocalePreferenceState -RegistryReader $RegistryReader
    if (-not (Test-GuildrunLocalePreferenceEqual $actual $Expected)) {
        throw 'La preference Unity restauree ne correspond pas exactement a son etat sauvegarde.'
    }
}

function Read-GuildrunPersistentBackup {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $Paths)

    $manifestPath = Join-Path $Paths.BackupRoot 'manifest.json'
    $files = [ordered]@{
        French  = Join-Path $Paths.BackupRoot 'localization-string-tables-french(fr)_assets_all.bundle.backup'
        Locales = Join-Path $Paths.BackupRoot 'localization-locales_assets_all.bundle.backup'
        Catalog = Join-Path $Paths.BackupRoot 'catalog.bin.backup'
    }
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'Sauvegarde locale absente ou incomplete.' }
    foreach ($path in $files.Values) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Sauvegarde locale absente ou incomplete.' }
    }
    $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
    if ($manifest.FormatVersion -ne 4) { throw 'Format de sauvegarde locale non pris en charge.' }
    Assert-GuildrunHash -LiteralPath $files.French -ExpectedHash $manifest.FrenchSha256 -Label 'Sauvegarde locale French' | Out-Null
    Assert-GuildrunHash -LiteralPath $files.Locales -ExpectedHash $manifest.LocalesSha256 -Label 'Sauvegarde locale Locales' | Out-Null
    Assert-GuildrunHash -LiteralPath $files.Catalog -ExpectedHash $manifest.CatalogSha256 -Label 'Sauvegarde locale Catalog' | Out-Null
    if ($null -eq $manifest.LocalePreference) { throw 'Etat anterieur de la preference Unity absent de la sauvegarde.' }
    $registryState = ConvertFrom-GuildrunRegistryRecord $manifest.LocalePreference
    [pscustomobject]@{
        Manifest = $manifest
        French = $files.French; Locales = $files.Locales; Catalog = $files.Catalog
        FrenchHash = $manifest.FrenchSha256.ToUpperInvariant()
        LocalesHash = $manifest.LocalesSha256.ToUpperInvariant()
        CatalogHash = $manifest.CatalogSha256.ToUpperInvariant()
        RegistryState = $registryState
    }
}

function New-GuildrunPersistentBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Paths,
        [Parameter(Mandatory = $true)] $State,
        [Parameter(Mandatory = $true)] $RegistryState
    )

    if (Test-Path -LiteralPath $Paths.BackupRoot) {
        $existing = Read-GuildrunPersistentBackup -Paths $Paths
        if ($existing.FrenchHash -ne $State.FrenchHash -or $existing.LocalesHash -ne $State.LocalesHash -or $existing.CatalogHash -ne $State.CatalogHash) {
            throw 'Une sauvegarde locale differente existe deja. Elle est conservee et installation refusee.'
        }
        if (-not (Test-GuildrunLocalePreferenceEqual $existing.RegistryState $RegistryState)) {
            throw 'La preference Unity actuelle differe de la sauvegarde locale existante. Installation refusee pour conserver la sauvegarde exacte.'
        }
        return $existing
    }

    $parent = Split-Path -Parent $Paths.BackupRoot
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $creating = Join-Path $parent ('.sauvegarde-creation-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $creating -Force | Out-Null
    try {
        $copies = @(
            @($Paths.French, (Join-Path $creating 'localization-string-tables-french(fr)_assets_all.bundle.backup'), $State.FrenchHash),
            @($Paths.Locales, (Join-Path $creating 'localization-locales_assets_all.bundle.backup'), $State.LocalesHash),
            @($Paths.Catalog, (Join-Path $creating 'catalog.bin.backup'), $State.CatalogHash)
        )
        foreach ($copy in $copies) {
            Copy-Item -LiteralPath $copy[0] -Destination $copy[1]
            Assert-GuildrunHash -LiteralPath $copy[1] -ExpectedHash $copy[2] -Label 'Sauvegarde locale en creation' | Out-Null
        }
        [pscustomobject]@{
            FormatVersion = 4
            GameVersion = $State.Profile.GameVersion
            GameBuild = $State.Profile.GameBuild
            SteamBuildId = $State.SteamBuildId
            ProfileName = $State.Profile.Name
            CreatedAtUtc = [DateTime]::UtcNow.ToString('o')
            FrenchSha256 = $State.FrenchHash
            LocalesSha256 = $State.LocalesHash
            CatalogSha256 = $State.CatalogHash
            LocalePreference = ConvertTo-GuildrunRegistryRecord $RegistryState
        } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $creating 'manifest.json') -Encoding UTF8
        Move-Item -LiteralPath $creating -Destination $Paths.BackupRoot
    }
    catch {
        if (Test-Path -LiteralPath $creating) { Remove-Item -LiteralPath $creating -Recurse -Force }
        throw
    }
    Read-GuildrunPersistentBackup -Paths $Paths
}

function Assert-GuildrunOriginalPersistentBackup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] $Backup,
        [Parameter(Mandatory = $true)] $Policy,
        [Parameter(Mandatory = $true)] $Profile
    )

    if ($Backup.FrenchHash -ne $Policy.OriginalFrenchHash -or
        $Backup.LocalesHash -ne $Policy.OriginalLocalesHash -or
        $Backup.CatalogHash -ne $Profile.OriginalCatalogHash -or
        [string]$Backup.Manifest.SteamBuildId -ne [string]$Profile.SteamBuildId) {
        throw 'La sauvegarde locale existante ne correspond pas exactement aux fichiers officiels du profil. Installation refusee.'
    }
}

function Set-GuildrunFrenchLocale {
    [CmdletBinding()]
    param([scriptblock] $RegistryWriter)

    $value = [byte[]](102, 114, 0)
    if ($null -ne $RegistryWriter) {
        & $RegistryWriter 'HKCU:\Software\Leyline\Guildrun' 'selected-locale_h3890535593' $value
        return
    }
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Software\Leyline\Guildrun')
    try { $key.SetValue('selected-locale_h3890535593', $value, [Microsoft.Win32.RegistryValueKind]::Binary) }
    finally { $key.Dispose() }
}

function Invoke-GuildrunFailureHook {
    param([scriptblock] $FailureInjector, [string] $Stage)
    if ($null -ne $FailureInjector) { & $FailureInjector $Stage }
}

function Invoke-GuildrunV21Install {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $GameRoot,
        [Parameter(Mandatory = $true)] [string] $PayloadRoot,
        $Policy = (Get-GuildrunV21Policy),
        [scriptblock] $RegistryReader,
        [scriptblock] $RegistryWriter,
        [scriptblock] $RegistryRestorer,
        [scriptblock] $FailureInjector
    )

    $paths = Get-GuildrunV21Paths -GameRoot $GameRoot -PayloadRoot $PayloadRoot -Policy $Policy
    Assert-GuildrunV21Payload -Paths $paths -Policy $Policy
    $state = Get-GuildrunV21State -Paths $paths -Policy $Policy
    $paths = Set-GuildrunV21ProfilePaths -Paths $paths -Profile $state.Profile
    if ($state.Name -eq 'Installed') {
        $backup = Read-GuildrunPersistentBackup -Paths $paths
        Assert-GuildrunOriginalPersistentBackup -Backup $backup -Policy $Policy -Profile $state.Profile
        $registryState = Get-GuildrunLocalePreferenceState -RegistryReader $RegistryReader
        try {
            Set-GuildrunFrenchLocale -RegistryWriter $RegistryWriter
            $expectedFrench = [pscustomobject]@{ Exists = $true; Kind = 'Binary'; Value = [byte[]](102, 114, 0) }
            Assert-GuildrunLocalePreferenceState -Expected $expectedFrench -RegistryReader $RegistryReader
        }
        catch {
            Restore-GuildrunLocalePreferenceState -State $registryState -RegistryRestorer $RegistryRestorer
            Assert-GuildrunLocalePreferenceState -Expected $registryState -RegistryReader $RegistryReader
            throw
        }
        return [pscustomobject]@{ State = 'AlreadyInstalled'; BackupRoot = $paths.BackupRoot }
    }

    $registryState = Get-GuildrunLocalePreferenceState -RegistryReader $RegistryReader
    if ($state.Name -eq 'PreviousInstalled') {
        $backup = Read-GuildrunPersistentBackup -Paths $paths
        Assert-GuildrunOriginalPersistentBackup -Backup $backup -Policy $Policy -Profile $state.Profile
    }
    else {
        New-GuildrunPersistentBackup -Paths $paths -State $state -RegistryState $registryState | Out-Null
    }
    $transaction = New-GuildrunTransactionBackup -Paths $paths -RegistryState $registryState
    try {
        Install-GuildrunFileAtomic -Source $paths.PayloadFrench -Destination $paths.French -ExpectedHash $state.Profile.PatchedFrenchHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterFrench'
        Install-GuildrunFileAtomic -Source $paths.PayloadLocales -Destination $paths.Locales -ExpectedHash $Policy.PatchedLocalesHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterLocales'
        Install-GuildrunFileAtomic -Source $paths.PayloadCatalog -Destination $paths.Catalog -ExpectedHash $state.Profile.PatchedCatalogHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterCatalog'

        $final = Get-GuildrunV21State -Paths $paths -Policy $Policy
        if ($final.Name -ne 'Installed' -or $final.EnglishHash -ne $state.EnglishHash -or $final.ExecutableHash -ne $state.ExecutableHash) { throw 'Verification finale impossible.' }
        Set-GuildrunFrenchLocale -RegistryWriter $RegistryWriter
        $expectedFrench = [pscustomobject]@{ Exists = $true; Kind = 'Binary'; Value = [byte[]](102, 114, 0) }
        Assert-GuildrunLocalePreferenceState -Expected $expectedFrench -RegistryReader $RegistryReader
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterLocale'
        [pscustomobject]@{ State = $(if ($state.Name -eq 'PreviousInstalled') { 'Upgraded' } else { 'Installed' }); BackupRoot = $paths.BackupRoot }
    }
    catch {
        $failure = $_
        Restore-GuildrunTransactionBackup -Paths $paths -Transaction $transaction
        Restore-GuildrunLocalePreferenceState -State $transaction.RegistryState -RegistryRestorer $RegistryRestorer
        Assert-GuildrunLocalePreferenceState -Expected $transaction.RegistryState -RegistryReader $RegistryReader
        throw "Installation annulee ; les trois fichiers et la preference Unity ont ete restaures et verifies : $($failure.Exception.Message)"
    }
    finally {
        Remove-GuildrunTransactionBackup -Transaction $transaction
    }
}

function Invoke-GuildrunV21Restore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $GameRoot,
        [Parameter(Mandatory = $true)] [string] $PayloadRoot,
        $Policy = (Get-GuildrunV21Policy),
        [scriptblock] $RegistryReader,
        [scriptblock] $RegistryRestorer,
        [scriptblock] $FailureInjector
    )

    $paths = Get-GuildrunV21Paths -GameRoot $GameRoot -PayloadRoot $PayloadRoot -Policy $Policy
    $state = Get-GuildrunV21State -Paths $paths -Policy $Policy
    $paths = Set-GuildrunV21ProfilePaths -Paths $paths -Profile $state.Profile
    $backup = Read-GuildrunPersistentBackup -Paths $paths
    $registryState = Get-GuildrunLocalePreferenceState -RegistryReader $RegistryReader
    $transaction = New-GuildrunTransactionBackup -Paths $paths -RegistryState $registryState
    try {
        Install-GuildrunFileAtomic -Source $backup.French -Destination $paths.French -ExpectedHash $backup.FrenchHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterFrenchRestore'
        Install-GuildrunFileAtomic -Source $backup.Locales -Destination $paths.Locales -ExpectedHash $backup.LocalesHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterLocalesRestore'
        Install-GuildrunFileAtomic -Source $backup.Catalog -Destination $paths.Catalog -ExpectedHash $backup.CatalogHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterCatalogRestore'
        Assert-GuildrunHash -LiteralPath $paths.Executable -ExpectedHash $state.ExecutableHash -Label 'Executable apres restauration' | Out-Null
        Assert-GuildrunHash -LiteralPath $paths.English -ExpectedHash $state.EnglishHash -Label 'Bundle anglais apres restauration' | Out-Null
        Assert-GuildrunHash -LiteralPath $paths.French -ExpectedHash $backup.FrenchHash -Label 'French restaure' | Out-Null
        Assert-GuildrunHash -LiteralPath $paths.Locales -ExpectedHash $backup.LocalesHash -Label 'Locales restaure' | Out-Null
        Assert-GuildrunHash -LiteralPath $paths.Catalog -ExpectedHash $backup.CatalogHash -Label 'Catalog restaure' | Out-Null
        Restore-GuildrunLocalePreferenceState -State $backup.RegistryState -RegistryRestorer $RegistryRestorer
        Assert-GuildrunLocalePreferenceState -Expected $backup.RegistryState -RegistryReader $RegistryReader
        [pscustomobject]@{ State = 'Restored'; BackupRoot = $paths.BackupRoot }
    }
    catch {
        $failure = $_
        Restore-GuildrunTransactionBackup -Paths $paths -Transaction $transaction
        Restore-GuildrunLocalePreferenceState -State $transaction.RegistryState -RegistryRestorer $RegistryRestorer
        Assert-GuildrunLocalePreferenceState -Expected $transaction.RegistryState -RegistryReader $RegistryReader
        throw "Restauration annulee ; fichiers et preference Unity precedents retablis et verifies : $($failure.Exception.Message)"
    }
    finally {
        Remove-GuildrunTransactionBackup -Transaction $transaction
    }
}
