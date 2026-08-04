$ErrorActionPreference = 'Stop'

function Get-GuildrunV21Policy {
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        GameVersion          = '0.5.3'
        GameBuild            = 748
        EnglishBundleName    = 'localization-string-tables-english(en)_assets_all.bundle'
        FrenchBundleName     = 'localization-string-tables-french(fr)_assets_all.bundle'
        LocalesBundleName    = 'localization-locales_assets_all.bundle'
        CatalogName          = 'catalog.bin'
        OriginalExecutableHash = '33B701F9128366079EF47495259361A094D83DD293AB03B60870997B36D60882'
        OriginalEnglishHash  = '8D9798819E3A2DDEE313E0BCB426030B540B7FD3195AA7BB8B24559983606629'
        OriginalFrenchHash   = 'C076AA88A443CC945992402D7DE40DCDFDC4DE27228745A37EC735E647C23A32'
        OriginalLocalesHash  = 'D4A2D1D0DC9773DFA75E07778EE90EF9F13252DE96DF2E1D72F4A8476E3BBDC7'
        OriginalCatalogHash  = 'DC16E4280C5FAD3526AEC223B3C41F9A46B519D3EED96E1364EB20DA6A6A5783'
        PatchedFrenchHash    = '67FF94F910B89A8B625E4D4D2398D189114FC1368FFD5C35C5948E980A905E2E'
        PatchedLocalesHash   = 'D2885F99C6DB7495ABCF9D9F453AC0225AAFE80304FF29604BAB48ECE812AA9C'
        PatchedCatalogHash   = '57A6EA642CE9DE2D89EB8F57FE083C66030834A8519806087D2EFE722A1231CC'
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
        BackupRoot      = Join-Path $resolvedGameRoot 'Traduction_FR_V2.1\sauvegarde-locale'
        TransactionRoot = Join-Path $resolvedGameRoot 'Traduction_FR_V2.1\.transactions'
    }
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
        throw "Version inconnue : Guildrun.exe n'est pas celui de Guildrun $($Policy.GameVersion) build $($Policy.GameBuild)."
    }
    if ($hashes.English -ne $Policy.OriginalEnglishHash) {
        throw 'Version inconnue ou bundle anglais modifie. Faites verifier les fichiers du jeu par Steam.'
    }

    $isOriginal = $hashes.French -eq $Policy.OriginalFrenchHash -and
        $hashes.Locales -eq $Policy.OriginalLocalesHash -and
        $hashes.Catalog -eq $Policy.OriginalCatalogHash
    $isInstalled = $hashes.French -eq $Policy.PatchedFrenchHash -and
        $hashes.Locales -eq $Policy.PatchedLocalesHash -and
        $hashes.Catalog -eq $Policy.PatchedCatalogHash

    if (-not $isOriginal -and -not $isInstalled) {
        throw "Version inconnue ou etat partiellement patche : seuls Guildrun $($Policy.GameVersion) build $($Policy.GameBuild) officiel et V2.1 complet sont acceptes. Aucun fichier n'a ete modifie."
    }

    [pscustomobject]@{
        Name        = $(if ($isOriginal) { 'Original' } else { 'Installed' })
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

    Assert-GuildrunHash -LiteralPath $Paths.PayloadFrench -ExpectedHash $Policy.PatchedFrenchHash -Label 'Bundle francais distribue' | Out-Null
    Assert-GuildrunHash -LiteralPath $Paths.PayloadLocales -ExpectedHash $Policy.PatchedLocalesHash -Label 'Bundle Locales distribue' | Out-Null
    Assert-GuildrunHash -LiteralPath $Paths.PayloadCatalog -ExpectedHash $Policy.PatchedCatalogHash -Label 'Catalogue distribue' | Out-Null
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
            GameVersion = '0.5.3'
            GameBuild = 748
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
    if ($state.Name -eq 'Installed') {
        Read-GuildrunPersistentBackup -Paths $paths | Out-Null
        Set-GuildrunFrenchLocale -RegistryWriter $RegistryWriter
        $expectedFrench = [pscustomobject]@{ Exists = $true; Kind = 'Binary'; Value = [byte[]](102, 114, 0) }
        Assert-GuildrunLocalePreferenceState -Expected $expectedFrench -RegistryReader $RegistryReader
        return [pscustomobject]@{ State = 'AlreadyInstalled'; BackupRoot = $paths.BackupRoot }
    }

    $registryState = Get-GuildrunLocalePreferenceState -RegistryReader $RegistryReader
    New-GuildrunPersistentBackup -Paths $paths -State $state -RegistryState $registryState | Out-Null
    $transaction = New-GuildrunTransactionBackup -Paths $paths -RegistryState $registryState
    try {
        Install-GuildrunFileAtomic -Source $paths.PayloadFrench -Destination $paths.French -ExpectedHash $Policy.PatchedFrenchHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterFrench'
        Install-GuildrunFileAtomic -Source $paths.PayloadLocales -Destination $paths.Locales -ExpectedHash $Policy.PatchedLocalesHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterLocales'
        Install-GuildrunFileAtomic -Source $paths.PayloadCatalog -Destination $paths.Catalog -ExpectedHash $Policy.PatchedCatalogHash
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterCatalog'

        $final = Get-GuildrunV21State -Paths $paths -Policy $Policy
        if ($final.Name -ne 'Installed' -or $final.EnglishHash -ne $state.EnglishHash -or $final.ExecutableHash -ne $state.ExecutableHash) { throw 'Verification finale impossible.' }
        Set-GuildrunFrenchLocale -RegistryWriter $RegistryWriter
        $expectedFrench = [pscustomobject]@{ Exists = $true; Kind = 'Binary'; Value = [byte[]](102, 114, 0) }
        Assert-GuildrunLocalePreferenceState -Expected $expectedFrench -RegistryReader $RegistryReader
        Invoke-GuildrunFailureHook -FailureInjector $FailureInjector -Stage 'AfterLocale'
        [pscustomobject]@{ State = 'Installed'; BackupRoot = $paths.BackupRoot }
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
