[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gameRoot = Split-Path -Parent $projectRoot
$payloadRoot = Join-Path $projectRoot 'payload'
$sourcesRoot = Join-Path $projectRoot 'sources'
. (Join-Path $projectRoot 'scripts\GuildrunV21.Common.ps1')
$policy = Get-GuildrunV21Policy
$passed = 0
$failed = 0
$results = New-Object System.Collections.Generic.List[string]

function Assert-True([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

function Invoke-Test([string] $Name, [scriptblock] $Body) {
    try {
        & $Body
        $script:passed++
        $results.Add("OK  $Name")
    }
    catch {
        $script:failed++
        $results.Add("ECHEC  $Name : $($_.Exception.Message)")
    }
}

function New-Fixture([string] $Name) {
    $root = Join-Path $workRoot $Name
    $bundleRoot = Join-Path $root 'Guildrun_Data\StreamingAssets\aa\StandaloneWindows64'
    New-Item -ItemType Directory -Path $bundleRoot -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $gameRoot 'Guildrun.exe') -Destination $root
    Copy-Item -LiteralPath (Join-Path $gameRoot 'Guildrun_Data\StreamingAssets\aa\StandaloneWindows64\localization-string-tables-english(en)_assets_all.bundle') -Destination $bundleRoot
    Copy-Item -LiteralPath (Join-Path $sourcesRoot 'localization-string-tables-french(fr)_assets_all.bundle.official') -Destination (Join-Path $bundleRoot $policy.FrenchBundleName)
    Copy-Item -LiteralPath (Join-Path $sourcesRoot 'localization-locales_assets_all.bundle.official') -Destination (Join-Path $bundleRoot $policy.LocalesBundleName)
    Copy-Item -LiteralPath (Join-Path $sourcesRoot 'catalog-24613101.bin.official') -Destination (Join-Path (Split-Path -Parent $bundleRoot) 'catalog.bin')
    $root
}

function Get-ContentHashes([string] $Root) {
    $paths = Get-GuildrunV21Paths -GameRoot $Root -PayloadRoot $payloadRoot -Policy $policy
    [ordered]@{
        Executable = Get-GuildrunSha256 $paths.Executable
        English = Get-GuildrunSha256 $paths.English
        French = Get-GuildrunSha256 $paths.French
        Locales = Get-GuildrunSha256 $paths.Locales
        Catalog = Get-GuildrunSha256 $paths.Catalog
    }
}

function New-MockRegistry([bool] $Exists, [string] $Kind, $Value) {
    $store = @{
        Exists = $Exists
        Kind = $(if ($Exists) { $Kind } else { $null })
        Value = $(if ($Value -is [byte[]]) { [byte[]]$Value.Clone() } else { $Value })
    }
    $reader = {
        param($path, $name)
        [pscustomobject]@{
            Exists = [bool]$store.Exists
            Kind = $store.Kind
            Value = $(if ($store.Value -is [byte[]]) { [byte[]]$store.Value.Clone() } elseif ($store.Value -is [string[]]) { [string[]]$store.Value.Clone() } else { $store.Value })
        }
    }.GetNewClosure()
    $writer = {
        param($path, $name, $newValue)
        $store.Exists = $true
        $store.Kind = 'Binary'
        $store.Value = [byte[]]$newValue.Clone()
    }.GetNewClosure()
    $restorer = {
        param($path, $name, $state)
        $store.Exists = [bool]$state.Exists
        $store.Kind = $state.Kind
        $store.Value = $(if ($state.Value -is [byte[]]) { [byte[]]$state.Value.Clone() } elseif ($state.Value -is [string[]]) { [string[]]$state.Value.Clone() } else { $state.Value })
    }.GetNewClosure()
    [pscustomobject]@{ Store = $store; Reader = $reader; Writer = $writer; Restorer = $restorer }
}

function Get-LocaleRecords([string] $BundlePath) {
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundle = $manager.LoadBundleFile([IO.Path]::GetFullPath($BundlePath), $true)
    $assets = $manager.LoadAssetsFileFromBundle($bundle, 0, $false)
    $records = @()
    foreach ($info in $assets.file.GetAssetsOfType([AssetsTools.NET.Extra.AssetClassID]::MonoBehaviour)) {
        try {
            $base = $manager.GetBaseField($assets, $info)
            $code = $base.Get('m_Identifier').Get('m_Code').AsString
            if ([string]::IsNullOrWhiteSpace($code)) { continue }
            $comments = @()
            $registry = $base.Get('references').AsManagedReferencesRegistry
            foreach ($reference in $registry.references) {
                if ($reference.data.TypeName -eq 'Comment') { $comments += $reference.data.Get('m_CommentText').AsString }
            }
            $records += [pscustomobject]@{
                Name = $base.Get('m_Name').AsString
                Code = $code
                PathId = $info.PathId
                MetadataCount = $base.Get('m_Metadata').Get('m_Items').Get('Array').Children.Count
                Comments = $comments
            }
        }
        catch { }
    }
    $records
}

function Get-ObjectHashes([string] $BundlePath) {
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundle = $manager.LoadBundleFile([IO.Path]::GetFullPath($BundlePath), $true)
    $assets = $manager.LoadAssetsFileFromBundle($bundle, 0, $false)
    $map = @{}
    foreach ($info in $assets.file.AssetInfos) {
        $assets.file.Reader.Position = $info.GetAbsoluteByteOffset($assets.file)
        $bytes = $assets.file.Reader.ReadBytes([int]$info.ByteSize)
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $map[$info.PathId.ToString()] = ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '') }
        finally { $sha.Dispose() }
    }
    $map
}

function Get-BundleInternalCrc([string] $BundlePath) {
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
    $manager = New-Object AssetsTools.NET.Extra.AssetsManager
    $bundle = $manager.LoadBundleFile([IO.Path]::GetFullPath($BundlePath), $true)
    $directory = $bundle.file.BlockAndDirInfo.DirectoryInfos[0]
    $bundle.file.DataReader.Position = $directory.Offset
    foreach ($byte in $bundle.file.DataReader.ReadBytes([int]$directory.DecompressedSize)) {
        $crc = [uint32]($table[($crc -bxor $byte) -band 0xFF] -bxor ($crc -shr 8))
    }
    [uint32]($crc -bxor [uint32]::MaxValue)
}

function New-PreviousPayload {
    $root = Join-Path $workRoot 'previous-payload'
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $french = Join-Path $root $policy.FrenchBundleName
    $locales = Join-Path $root $policy.LocalesBundleName
    Copy-Item -LiteralPath (Join-Path $sourcesRoot 'localization-string-tables-french(fr)_assets_all.v211.bundle') -Destination $french
    Copy-Item -LiteralPath (Join-Path $payloadRoot $policy.LocalesBundleName) -Destination $locales
    $frenchCrc = Get-BundleInternalCrc $french
    $localesCrc = Get-BundleInternalCrc $locales
    foreach ($profile in $policy.Profiles) {
        $sourceName = if ($profile.SteamBuildId -eq '24551494') { 'catalog.bin.official' } else { 'catalog-24613101.bin.official' }
        $catalog = [IO.File]::ReadAllBytes((Join-Path $sourcesRoot $sourceName))
        [BitConverter]::GetBytes([uint32]$localesCrc).CopyTo($catalog, 4723)
        [BitConverter]::GetBytes([uint32]$frenchCrc).CopyTo($catalog, 6143)
        $catalogPath = Join-Path $root $profile.PayloadCatalogName
        [IO.File]::WriteAllBytes($catalogPath, $catalog)
        Assert-True ((Get-GuildrunSha256 $catalogPath) -eq $profile.PreviousPatchedCatalogHash) "Catalogue V2.1.1 simule incorrect pour $($profile.SteamBuildId)."
    }
    Assert-True ((Get-GuildrunSha256 $french) -eq $policy.PreviousPatchedFrenchHash) 'Bundle French V2.1.1 simule incorrect.'
    $root
}

function Get-PreviousPolicy {
    $previous = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
    $previous.PatchedFrenchHash = $previous.PreviousPatchedFrenchHash
    foreach ($profile in $previous.Profiles) { $profile.PatchedCatalogHash = $profile.PreviousPatchedCatalogHash }
    $previous.PatchedCatalogHash = $previous.Profiles[1].PatchedCatalogHash
    $previous
}

function New-ReleaseJson([string] $Tag, [string] $AssetName, [string] $DownloadUrl, [string] $Digest, [string] $Body) {
    [ordered]@{
        tag_name = $Tag
        html_url = "https://github.com/W0rku/guildrun-french-translation/releases/tag/$Tag"
        body = $Body
        draft = $false
        prerelease = $false
        assets = @(
            [ordered]@{
                name = $AssetName
                state = 'uploaded'
                browser_download_url = $DownloadUrl
                digest = $Digest
            }
        )
    } | ConvertTo-Json -Depth 6 -Compress
}

function Get-ByteDiffOffsets([string] $BeforePath, [string] $AfterPath) {
    $before = [IO.File]::ReadAllBytes($BeforePath)
    $after = [IO.File]::ReadAllBytes($AfterPath)
    if ($before.Length -ne $after.Length) { throw 'Les catalogues compares ont des tailles differentes.' }
    $offsets = @()
    for ($index = 0; $index -lt $before.Length; $index++) {
        if ($before[$index] -ne $after[$index]) { $offsets += $index }
    }
    $offsets
}

$dll = Join-Path $projectRoot 'tools\vendor\AssetsTools.NET.dll'
[void][Reflection.Assembly]::LoadFrom($dll)
$updateServiceSource = Join-Path $projectRoot 'Installeur\InstallerUpdateService.cs'
if (-not (Test-Path -LiteralPath $updateServiceSource)) { $updateServiceSource = Join-Path $projectRoot 'installer\InstallerUpdateService.cs' }
Add-Type -Path $updateServiceSource -ReferencedAssemblies @('System.dll', 'System.Core.dll', 'System.Web.Extensions.dll')
$workRoot = Join-Path $PSScriptRoot ('.work-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workRoot | Out-Null
$previousPayloadRoot = New-PreviousPayload
$previousPolicy = Get-PreviousPolicy

try {
    Invoke-Test 'Version installateur identique : statut Installateur a jour' {
        $json = New-ReleaseJson 'v2.1.2' 'Guildrun_Demo_FR_Installer_V2.1.2.exe' 'https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.2/Guildrun_Demo_FR_Installer_V2.1.2.exe' ('sha256:' + ('A' * 64)) ''
        [Func[string,string]]$fetch = { param($url) $json }.GetNewClosure()
        $result = [GuildrunFrenchInstallerV21.InstallerUpdateService]::CheckLatestRelease([Version]'2.1.2', $fetch)
        Assert-True ($result.State -eq [GuildrunFrenchInstallerV21.InstallerUpdateState]::UpToDate) 'Version identique annoncee comme mise a jour.'
    }

    Invoke-Test 'Release plus recente : version, asset et digest SHA-256 sont exposes' {
        $expected = 'B' * 64
        $json = New-ReleaseJson 'v2.1.3' 'Guildrun_Demo_FR_Installer_V2.1.3.exe' 'https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.3/Guildrun_Demo_FR_Installer_V2.1.3.exe' ('sha256:' + $expected) ''
        [Func[string,string]]$fetch = { param($url) $json }.GetNewClosure()
        $result = [GuildrunFrenchInstallerV21.InstallerUpdateService]::CheckLatestRelease([Version]'2.1.2', $fetch)
        Assert-True ($result.State -eq [GuildrunFrenchInstallerV21.InstallerUpdateState]::Available) 'Nouvelle Release non detectee.'
        Assert-True ($result.Release.TagName -eq 'v2.1.3' -and $result.Release.AssetName -eq 'Guildrun_Demo_FR_Installer_V2.1.3.exe') 'Release ou asset incorrect.'
        Assert-True ($result.Release.ExpectedSha256 -eq $expected) 'Digest GitHub non extrait.'
    }

    Invoke-Test 'Une Release plus ancienne ne provoque jamais de downgrade' {
        $json = New-ReleaseJson 'v2.1.1' 'Guildrun_Demo_FR_Installer_V2.1.1.exe' 'https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.1/Guildrun_Demo_FR_Installer_V2.1.1.exe' $null ''
        [Func[string,string]]$fetch = { param($url) $json }.GetNewClosure()
        $result = [GuildrunFrenchInstallerV21.InstallerUpdateService]::CheckLatestRelease([Version]'2.1.2', $fetch)
        Assert-True ($result.State -eq [GuildrunFrenchInstallerV21.InstallerUpdateState]::UpToDate) 'Downgrade propose.'
    }

    Invoke-Test 'GitHub inaccessible : statut non bloquant Unavailable' {
        [Func[string,string]]$fetch = { param($url) throw 'reseau indisponible simule' }
        $result = [GuildrunFrenchInstallerV21.InstallerUpdateService]::CheckLatestRelease([Version]'2.1.2', $fetch)
        Assert-True ($result.State -eq [GuildrunFrenchInstallerV21.InstallerUpdateState]::Unavailable) 'Erreur reseau propagee au lieu d etre absorbee.'
        Assert-True ($result.ErrorMessage -match 'indisponible') 'Cause reseau non conservee pour diagnostic.'
    }

    Invoke-Test 'Un asset hors du depot GitHub attendu est refuse' {
        $json = New-ReleaseJson 'v2.1.3' 'Guildrun_Demo_FR_Installer_V2.1.3.exe' 'https://example.com/Guildrun_Demo_FR_Installer_V2.1.3.exe' $null ''
        [Func[string,string]]$fetch = { param($url) $json }.GetNewClosure()
        $result = [GuildrunFrenchInstallerV21.InstallerUpdateService]::CheckLatestRelease([Version]'2.1.2', $fetch)
        Assert-True ($result.State -eq [GuildrunFrenchInstallerV21.InstallerUpdateState]::Unavailable) 'URL externe acceptee.'
    }

    Invoke-Test 'Le SHA-256 peut etre lu dans les notes si le digest GitHub est absent' {
        $expected = 'C' * 64
        $asset = 'Guildrun_Demo_FR_Installer_V2.1.3.exe'
        $json = New-ReleaseJson 'v2.1.3' $asset "https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.3/$asset" $null ("SHA-256 $expected  $asset")
        $release = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ParseLatestRelease($json)
        Assert-True ($release.ExpectedSha256 -eq $expected) 'SHA-256 des notes non extrait.'
    }

    Invoke-Test 'Une Release sans empreinte reste utilisable avec verification de version interne' {
        $asset = 'Guildrun_Demo_FR_Installer_V2.1.3.exe'
        $json = New-ReleaseJson 'v2.1.3' $asset "https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.3/$asset" $null ''
        $release = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ParseLatestRelease($json)
        Assert-True ($null -eq $release.ExpectedSha256) 'Empreinte inventee alors qu elle est absente.'
    }

    Invoke-Test 'La verification SHA-256 accepte le bon fichier et refuse toute divergence' {
        $path = Join-Path $workRoot 'update-hash-fixture.exe'
        [IO.File]::WriteAllBytes($path, [Text.Encoding]::UTF8.GetBytes('installateur simule'))
        $expected = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ComputeSha256($path)
        $actual = [GuildrunFrenchInstallerV21.InstallerUpdateService]::VerifySha256($path, $expected)
        Assert-True ($actual -eq $expected) 'Bon SHA-256 refuse.'
        $thrown = $false
        try { [GuildrunFrenchInstallerV21.InstallerUpdateService]::VerifySha256($path, ('0' * 64)) | Out-Null } catch { $thrown = $true }
        Assert-True $thrown 'Mauvais SHA-256 accepte.'
    }

    Invoke-Test 'L identite et la version internes du nouvel EXE correspondent a sa Release' {
        $installerPath = Join-Path $projectRoot 'Installeur\Guildrun_Demo_FR_Installer_V2.1.2.exe'
        if (-not (Test-Path -LiteralPath $installerPath)) { $installerPath = Join-Path $projectRoot 'installer\Guildrun_Demo_FR_Installer_V2.1.2.exe' }
        $hash = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ComputeSha256($installerPath)
        $asset = 'Guildrun_Demo_FR_Installer_V2.1.2.exe'
        $json = New-ReleaseJson 'v2.1.2' $asset "https://github.com/W0rku/guildrun-french-translation/releases/download/v2.1.2/$asset" ('sha256:' + $hash) ''
        $release = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ParseLatestRelease($json)
        $validated = [GuildrunFrenchInstallerV21.InstallerUpdateService]::ValidateDownloadedInstaller($installerPath, $release)
        Assert-True ($validated -eq $hash) 'Identite de l EXE compile non validee.'
    }

    Invoke-Test 'Le Steam BuildID 24613101 officiel est reconnu par ses SHA-256' {
        $root = New-Fixture 'official-current-profile'
        $paths = Get-GuildrunV21Paths -GameRoot $root -PayloadRoot $payloadRoot -Policy $policy
        $state = Get-GuildrunV21State $paths $policy
        Assert-True ($state.Name -eq 'Original' -and $state.SteamBuildId -eq '24613101') 'Profil Steam courant non reconnu.'
    }

    Invoke-Test 'Les profils 24551494 et 24613101 sont tous deux declares strictement' {
        Assert-True (($policy.Profiles.SteamBuildId -join ',') -eq '24551494,24613101') 'Liste de profils incorrecte.'
        Assert-True ($policy.Profiles[0].OriginalEnglishHash -eq '8D9798819E3A2DDEE313E0BCB426030B540B7FD3195AA7BB8B24559983606629') 'Hash English historique incorrect.'
        Assert-True ($policy.Profiles[1].OriginalEnglishHash -eq '30A0230858D555CBF2900CD1B2936CA4A148CFFF8E09677870155D39EB338744') 'Nouveau hash English incorrect.'
        Assert-True ($policy.Profiles[0].PreviousPatchedCatalogHash -eq '57A6EA642CE9DE2D89EB8F57FE083C66030834A8519806087D2EFE722A1231CC') 'Catalogue V2.1.1 historique non declare.'
        Assert-True ($policy.Profiles[1].PreviousPatchedCatalogHash -eq '581FE651C8CA4E89BFFC7F789995DA3EFA0EDAA40684F8160E7B2267BA370F4B') 'Catalogue V2.1.1 courant non declare.'
    }

    Invoke-Test 'L audit des 3919 cles French ne trouve plus de cle, format ou balise divergente' {
        $root = New-Fixture 'translation-audit'
        $paths = Get-GuildrunV21Paths $root $payloadRoot $policy
        & (Join-Path $projectRoot 'tools\auditer_traduction_v212.ps1') -EnglishBundle $paths.English | Out-Null
    }

    $officialRecords = Get-LocaleRecords (Join-Path $sourcesRoot 'localization-locales_assets_all.bundle.official')
    $patchedRecords = Get-LocaleRecords (Join-Path $payloadRoot 'localization-locales_assets_all.bundle')
    Invoke-Test 'French apparait dans AvailableLocales apres suppression de Comment=EDITOR' {
        $french = $patchedRecords | Where-Object Code -eq 'fr'
        Assert-True ($french.PathId -eq 996707670718014713) 'PathID French incorrect.'
        Assert-True ($french.Name -eq 'French (fr)') 'Nom French modifie.'
        Assert-True (-not ($french.Comments -contains 'EDITOR')) 'French est toujours marque EDITOR.'
        $available = $patchedRecords | Where-Object { -not ($_.Comments -contains 'EDITOR') }
        Assert-True ($available.Code -contains 'fr') 'French reste filtre.'
    }

    Invoke-Test 'Japanese reste masque avec son Comment=EDITOR intact' {
        $japanese = $patchedRecords | Where-Object Code -eq 'ja'
        Assert-True ($japanese.Comments -contains 'EDITOR') 'Comment Japanese a change.'
        $available = $patchedRecords | Where-Object { -not ($_.Comments -contains 'EDITOR') }
        Assert-True (-not ($available.Code -contains 'ja')) 'Japanese devient visible.'
    }

    Invoke-Test 'Seul objet Locale French change dans le bundle Locales' {
        $before = Get-ObjectHashes (Join-Path $sourcesRoot 'localization-locales_assets_all.bundle.official')
        $after = Get-ObjectHashes (Join-Path $payloadRoot 'localization-locales_assets_all.bundle')
        $changed = @($before.Keys | Where-Object { $before[$_] -ne $after[$_] })
        Assert-True ($changed.Count -eq 1 -and $changed[0] -eq '996707670718014713') ("Objets modifies : " + ($changed -join ','))
    }

    Invoke-Test 'Le Locale selectionne est exactement fr' {
        $capture = @{}
        Set-GuildrunFrenchLocale -RegistryWriter { param($path,$name,$value) $capture.Path=$path; $capture.Name=$name; $capture.Value=$value }.GetNewClosure()
        Assert-True ($capture.Name -eq 'selected-locale_h3890535593') 'Nom de valeur registre incorrect.'
        Assert-True (([Text.Encoding]::UTF8.GetString($capture.Value)).Trim([char]0) -eq 'fr') 'Valeur registre differente de fr.'
    }

    Invoke-Test 'Les deux catalogues chargent les CRC French et Locales V2.1' {
        $frenchCrc = Get-BundleInternalCrc (Join-Path $payloadRoot $policy.FrenchBundleName)
        $localesCrc = Get-BundleInternalCrc (Join-Path $payloadRoot $policy.LocalesBundleName)
        foreach ($profile in $policy.Profiles) {
            $catalog = [IO.File]::ReadAllBytes((Join-Path $payloadRoot $profile.PayloadCatalogName))
            Assert-True ([BitConverter]::ToUInt32($catalog, 6143) -eq $frenchCrc) "CRC French incorrect pour $($profile.SteamBuildId)."
            Assert-True ([BitConverter]::ToUInt32($catalog, 4723) -eq $localesCrc) "CRC Locales incorrect pour $($profile.SteamBuildId)."
            Assert-True ((Get-GuildrunSha256 (Join-Path $payloadRoot $profile.PayloadCatalogName)) -eq $profile.PatchedCatalogHash) "Hash catalogue incorrect pour $($profile.SteamBuildId)."
        }
        Assert-True ((Get-GuildrunSha256 (Join-Path $payloadRoot $policy.FrenchBundleName)) -eq $policy.PatchedFrenchHash) 'Bundle French traduit incorrect.'
    }

    Invoke-Test 'Chaque catalogue officiel ne change qu aux huit octets CRC necessaires' {
        $legacyDiff = @(Get-ByteDiffOffsets (Join-Path $sourcesRoot 'catalog.bin.official') (Join-Path $payloadRoot 'catalog-24551494.bin'))
        $currentDiff = @(Get-ByteDiffOffsets (Join-Path $sourcesRoot 'catalog-24613101.bin.official') (Join-Path $payloadRoot 'catalog.bin'))
        $expected = '4723,4724,4725,4726,6143,6144,6145,6146'
        Assert-True (($legacyDiff -join ',') -eq $expected) "Diff historique incorrect: $($legacyDiff -join ',')"
        Assert-True (($currentDiff -join ',') -eq $expected) "Diff courant incorrect: $($currentDiff -join ',')"
    }

    Invoke-Test 'L installateur V2.1.2 embarque exactement les quatre payloads verifies' {
        $installerDirectory = if (Test-Path -LiteralPath (Join-Path $projectRoot 'Installeur')) { 'Installeur' } else { 'installer' }
        $installerPath = Join-Path $projectRoot (Join-Path $installerDirectory 'Guildrun_Demo_FR_Installer_V2.1.2.exe')
        Assert-True (Test-Path -LiteralPath $installerPath -PathType Leaf) 'Installateur V2.1.2 non compile.'
        $assembly = [Reflection.Assembly]::LoadFile([IO.Path]::GetFullPath($installerPath))
        $expectedResources = [ordered]@{
            'GuildrunFRV21.French' = $policy.PatchedFrenchHash
            'GuildrunFRV21.Locales' = $policy.PatchedLocalesHash
            'GuildrunFRV21.CatalogCurrent' = $policy.Profiles[1].PatchedCatalogHash
            'GuildrunFRV21.CatalogLegacy' = $policy.Profiles[0].PatchedCatalogHash
        }
        foreach ($entry in $expectedResources.GetEnumerator()) {
            $stream = $assembly.GetManifestResourceStream($entry.Key)
            Assert-True ($null -ne $stream) "Ressource embarquee absente : $($entry.Key)."
            $sha = [Security.Cryptography.SHA256]::Create()
            try { $actual = ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '') }
            finally { $sha.Dispose(); $stream.Dispose() }
            Assert-True ($actual -eq $entry.Value) "Ressource embarquee incorrecte : $($entry.Key)."
        }
    }

    Invoke-Test 'Le profil historique selectionne son propre catalogue patche' {
        $root = New-Fixture 'legacy-profile'
        $paths = Get-GuildrunV21Paths $root $payloadRoot $policy
        Copy-Item -LiteralPath (Join-Path $sourcesRoot 'catalog.bin.official') -Destination $paths.Catalog -Force
        $legacyPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
        $fixtureEnglish = Get-GuildrunSha256 $paths.English
        $legacyPolicy.Profiles[0].OriginalEnglishHash = $fixtureEnglish
        $legacyPolicy.Profiles[1].OriginalEnglishHash = ('0' * 64)
        $state = Get-GuildrunV21State $paths $legacyPolicy
        Assert-True ($state.SteamBuildId -eq '24551494') 'Profil historique non selectionne.'
        $registry = New-MockRegistry $false $null $null
        Invoke-GuildrunV21Install $root $payloadRoot $legacyPolicy $registry.Reader $registry.Writer $registry.Restorer | Out-Null
        Assert-True ((Get-GuildrunSha256 $paths.Catalog) -eq $legacyPolicy.Profiles[0].PatchedCatalogHash) 'Catalogue historique non installe.'
    }

    $installRoot = New-Fixture 'install-restore'
    $beforeInstall = Get-ContentHashes $installRoot
    $installRegistry = New-MockRegistry $false $null $null
    Invoke-Test 'Installation transactionnelle reussie sur les trois fichiers' {
        $result = Invoke-GuildrunV21Install -GameRoot $installRoot -PayloadRoot $payloadRoot -RegistryReader $installRegistry.Reader -RegistryWriter $installRegistry.Writer -RegistryRestorer $installRegistry.Restorer
        Assert-True ($result.State -eq 'Installed') 'Installation non terminee.'
        $after = Get-ContentHashes $installRoot
        Assert-True ($after.French -eq $policy.PatchedFrenchHash -and $after.Locales -eq $policy.PatchedLocalesHash -and $after.Catalog -eq $policy.PatchedCatalogHash) 'Triplet V2.1 incomplet.'
    }

    Invoke-Test 'Le bundle English reste strictement intact pendant installation' {
        $after = Get-ContentHashes $installRoot
        Assert-True ($after.English -eq $beforeInstall.English -and $after.English -eq $policy.OriginalEnglishHash) 'English a change.'
    }

    Invoke-Test 'Seuls les trois fichiers de jeu prevus changent' {
        $after = Get-ContentHashes $installRoot
        $changed = @($beforeInstall.Keys | Where-Object { $beforeInstall[$_] -ne $after[$_] })
        Assert-True (($changed -join ',') -eq 'French,Locales,Catalog') ("Fichiers changes : " + ($changed -join ','))
    }

    Invoke-Test 'La sauvegarde locale contient les trois originaux exacts' {
        $paths = Get-GuildrunV21Paths $installRoot $payloadRoot $policy
        $backup = Read-GuildrunPersistentBackup $paths
        Assert-True ($backup.FrenchHash -eq $policy.OriginalFrenchHash -and $backup.LocalesHash -eq $policy.OriginalLocalesHash -and $backup.CatalogHash -eq $policy.OriginalCatalogHash) 'Sauvegarde inexacte.'
        Assert-True (-not $backup.RegistryState.Exists) 'Absence initiale de la preference non sauvegardee.'
    }

    Invoke-Test 'La restauration remet exactement les trois fichiers officiels et supprime une preference initialement absente' {
        Invoke-GuildrunV21Restore -GameRoot $installRoot -PayloadRoot $payloadRoot -RegistryReader $installRegistry.Reader -RegistryRestorer $installRegistry.Restorer | Out-Null
        $restored = Get-ContentHashes $installRoot
        foreach ($name in $beforeInstall.Keys) { Assert-True ($restored[$name] -eq $beforeInstall[$name]) "$name non restaure." }
        Assert-True (-not $installRegistry.Store.Exists) 'Preference initialement absente non supprimee.'
    }

    Invoke-Test 'Un echec apres Locales restaure automatiquement les trois fichiers' {
        $root = New-Fixture 'rollback'
        $registry = New-MockRegistry $false $null $null
        $before = Get-ContentHashes $root
        $thrown = $false
        try { Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer -FailureInjector { param($stage) if($stage -eq 'AfterLocales'){throw 'echec simule'} } | Out-Null }
        catch { $thrown = $true }
        Assert-True $thrown 'Echec simule non propage.'
        $after = Get-ContentHashes $root
        foreach ($name in $before.Keys) { Assert-True ($after[$name] -eq $before[$name]) "$name non restaure apres echec." }
    }

    Invoke-Test 'Une installation V2.1.1 complete est reconnue comme mise a niveau autorisee' {
        $script:upgradeRoot = New-Fixture 'upgrade-v211-v212'
        $script:upgradeOriginalHashes = Get-ContentHashes $script:upgradeRoot
        $script:upgradeRegistry = New-MockRegistry $true 'String' 'de-DE'
        Invoke-GuildrunV21Install -GameRoot $script:upgradeRoot -PayloadRoot $previousPayloadRoot -Policy $previousPolicy -RegistryReader $script:upgradeRegistry.Reader -RegistryWriter $script:upgradeRegistry.Writer -RegistryRestorer $script:upgradeRegistry.Restorer | Out-Null
        $paths = Get-GuildrunV21Paths $script:upgradeRoot $payloadRoot $policy
        $state = Get-GuildrunV21State $paths $policy
        Assert-True ($state.Name -eq 'PreviousInstalled') 'La V2.1.1 complete n est pas reconnue.'
        $paths = Set-GuildrunV21ProfilePaths $paths $state.Profile
        $script:upgradeManifestPath = Join-Path $paths.BackupRoot 'manifest.json'
        $script:upgradeManifestHash = Get-GuildrunSha256 $script:upgradeManifestPath
        $script:upgradeBackup = Read-GuildrunPersistentBackup $paths
    }

    Invoke-Test 'La mise a niveau V2.1.1 vers V2.1.2 conserve la sauvegarde originale exacte' {
        $beforeEnglish = (Get-ContentHashes $script:upgradeRoot).English
        $result = Invoke-GuildrunV21Install -GameRoot $script:upgradeRoot -PayloadRoot $payloadRoot -Policy $policy -RegistryReader $script:upgradeRegistry.Reader -RegistryWriter $script:upgradeRegistry.Writer -RegistryRestorer $script:upgradeRegistry.Restorer
        Assert-True ($result.State -eq 'Upgraded') 'Etat de mise a niveau inattendu.'
        $after = Get-ContentHashes $script:upgradeRoot
        Assert-True ($after.French -eq $policy.PatchedFrenchHash -and $after.Locales -eq $policy.PatchedLocalesHash -and $after.Catalog -eq $policy.PatchedCatalogHash) 'Triplet V2.1.2 incomplet apres mise a niveau.'
        Assert-True ($after.English -eq $beforeEnglish) 'English a change pendant la mise a niveau.'
        Assert-True ((Get-GuildrunSha256 $script:upgradeManifestPath) -eq $script:upgradeManifestHash) 'Le manifeste de sauvegarde originale a ete reecrit.'
        $paths = Get-GuildrunV21Paths $script:upgradeRoot $payloadRoot $policy
        $state = Get-GuildrunV21State $paths $policy
        $paths = Set-GuildrunV21ProfilePaths $paths $state.Profile
        $backup = Read-GuildrunPersistentBackup $paths
        Assert-True ($backup.FrenchHash -eq $script:upgradeBackup.FrenchHash -and $backup.LocalesHash -eq $script:upgradeBackup.LocalesHash -and $backup.CatalogHash -eq $script:upgradeBackup.CatalogHash) 'La sauvegarde originale a change.'
    }

    Invoke-Test 'Apres mise a niveau, Restaurer remet les officiels et la preference anterieure a V2.1.1' {
        Invoke-GuildrunV21Restore -GameRoot $script:upgradeRoot -PayloadRoot $payloadRoot -Policy $policy -RegistryReader $script:upgradeRegistry.Reader -RegistryRestorer $script:upgradeRegistry.Restorer | Out-Null
        $restored = Get-ContentHashes $script:upgradeRoot
        foreach ($name in $script:upgradeOriginalHashes.Keys) { Assert-True ($restored[$name] -eq $script:upgradeOriginalHashes[$name]) "$name non restaure apres mise a niveau." }
        Assert-True ($script:upgradeRegistry.Store.Exists -and $script:upgradeRegistry.Store.Kind -eq 'String' -and $script:upgradeRegistry.Store.Value -ceq 'de-DE') 'Preference precedant V2.1.1 non restauree.'
    }

    Invoke-Test 'Un echec de mise a niveau restaure exactement V2.1.1 et conserve sa sauvegarde' {
        $root = New-Fixture 'upgrade-rollback'
        $registry = New-MockRegistry $true 'Binary' ([byte[]](101, 115, 0))
        Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $previousPayloadRoot -Policy $previousPolicy -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer | Out-Null
        $before = Get-ContentHashes $root
        $paths = Get-GuildrunV21Paths $root $payloadRoot $policy
        $state = Get-GuildrunV21State $paths $policy
        $paths = Set-GuildrunV21ProfilePaths $paths $state.Profile
        $manifestPath = Join-Path $paths.BackupRoot 'manifest.json'
        $manifestHash = Get-GuildrunSha256 $manifestPath
        $thrown = $false
        try {
            Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -Policy $policy -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer -FailureInjector { param($stage) if ($stage -eq 'AfterCatalog') { throw 'echec upgrade simule' } } | Out-Null
        }
        catch { $thrown = $true }
        Assert-True $thrown 'Echec de mise a niveau non propage.'
        $after = Get-ContentHashes $root
        foreach ($name in $before.Keys) { Assert-True ($after[$name] -eq $before[$name]) "$name V2.1.1 non restaure." }
        Assert-True (([BitConverter]::ToString([byte[]]$registry.Store.Value)) -eq '66-72-00') 'Preference fr V2.1.1 non restauree apres rollback.'
        Assert-True ((Get-GuildrunSha256 $manifestPath) -eq $manifestHash) 'Sauvegarde originale modifiee pendant le rollback.'
    }

    Invoke-Test 'Preference absente avant installation : existence et absence sont restaurees' {
        $root = New-Fixture 'registry-absent'
        $registry = New-MockRegistry $false $null $null
        Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer | Out-Null
        Assert-True ($registry.Store.Exists -and $registry.Store.Kind -eq 'Binary') 'fr non ecrit en REG_BINARY.'
        Assert-True (([Text.Encoding]::UTF8.GetString([byte[]]$registry.Store.Value)).Trim([char]0) -eq 'fr') 'Valeur fr incorrecte.'
        Invoke-GuildrunV21Restore -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryRestorer $registry.Restorer | Out-Null
        Assert-True (-not $registry.Store.Exists) 'Valeur initialement absente conservee apres restauration.'
    }

    Invoke-Test 'Preference en avant installation : type et contenu exacts sont restaures' {
        $root = New-Fixture 'registry-en'
        $original = [byte[]](101, 110, 0)
        $registry = New-MockRegistry $true 'Binary' $original
        Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer | Out-Null
        Invoke-GuildrunV21Restore -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryRestorer $registry.Restorer | Out-Null
        Assert-True ($registry.Store.Exists -and $registry.Store.Kind -eq 'Binary') 'Type REG_BINARY en non restaure.'
        Assert-True (([BitConverter]::ToString([byte[]]$registry.Store.Value)) -eq '65-6E-00') 'Octets en non restaures.'
    }

    Invoke-Test 'Autre langue avant installation : la valeur utilisateur n est jamais remplacee par en' {
        $root = New-Fixture 'registry-other'
        $registry = New-MockRegistry $true 'String' 'de-DE'
        Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer | Out-Null
        Invoke-GuildrunV21Restore -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryRestorer $registry.Restorer | Out-Null
        Assert-True ($registry.Store.Exists -and $registry.Store.Kind -eq 'String' -and $registry.Store.Value -ceq 'de-DE') 'Autre langue ou type non restaure exactement.'
    }

    Invoke-Test 'Rollback apres erreur : la preference precedente est restauree avec les fichiers' {
        $root = New-Fixture 'registry-rollback'
        $registry = New-MockRegistry $true 'Binary' ([byte[]](101, 115, 0))
        $before = Get-ContentHashes $root
        $thrown = $false
        try {
            Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer -FailureInjector { param($stage) if ($stage -eq 'AfterLocale') { throw 'echec apres registre' } } | Out-Null
        }
        catch { $thrown = $true }
        Assert-True $thrown 'Echec apres ecriture du registre non propage.'
        Assert-True ($registry.Store.Kind -eq 'Binary' -and ([BitConverter]::ToString([byte[]]$registry.Store.Value)) -eq '65-73-00') 'Preference es non restauree apres rollback.'
        $after = Get-ContentHashes $root
        foreach ($name in $before.Keys) { Assert-True ($after[$name] -eq $before[$name]) "$name non restaure avec le registre." }
    }

    Invoke-Test 'Restauration manuelle exacte : existence, type et contenu reviennent ensemble' {
        $root = New-Fixture 'registry-manual-exact'
        $original = [byte[]](112, 116, 45, 66, 82, 0)
        $registry = New-MockRegistry $true 'Binary' $original
        Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryWriter $registry.Writer -RegistryRestorer $registry.Restorer | Out-Null
        Invoke-GuildrunV21Restore -GameRoot $root -PayloadRoot $payloadRoot -RegistryReader $registry.Reader -RegistryRestorer $registry.Restorer | Out-Null
        $expected = [pscustomobject]@{ Exists = $true; Kind = 'Binary'; Value = $original }
        $actual = Get-GuildrunLocalePreferenceState -RegistryReader $registry.Reader
        Assert-True (Test-GuildrunLocalePreferenceEqual $actual $expected) 'Etat complet de la preference non restaure.'
    }

    Invoke-Test 'Une version inconnue est refusee sans aucune ecriture' {
        $root = New-Fixture 'unknown'
        $paths = Get-GuildrunV21Paths $root $payloadRoot $policy
        $bytes = [IO.File]::ReadAllBytes($paths.Executable); $bytes[0] = $bytes[0] -bxor 1; [IO.File]::WriteAllBytes($paths.Executable,$bytes)
        $before = Get-ContentHashes $root
        $thrown = $false
        try { Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryWriter { } | Out-Null } catch { $thrown = $true }
        Assert-True $thrown 'Version inconnue acceptee.'
        $after = Get-ContentHashes $root
        foreach ($name in $before.Keys) { Assert-True ($after[$name] -eq $before[$name]) "$name ecrit sur version inconnue." }
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $root 'Traduction_FR_V2.1'))) 'Dossier de sauvegarde cree sur version inconnue.'
    }

    Invoke-Test 'Un etat partiellement patche est refuse sans ecriture' {
        $root = New-Fixture 'partial'
        $paths = Get-GuildrunV21Paths $root $payloadRoot $policy
        Copy-Item -LiteralPath $paths.PayloadFrench -Destination $paths.French -Force
        $before = Get-ContentHashes $root
        $thrown = $false
        try { Invoke-GuildrunV21Install -GameRoot $root -PayloadRoot $payloadRoot -RegistryWriter { } | Out-Null } catch { $thrown = $true }
        Assert-True $thrown 'Etat partiel accepte.'
        $after = Get-ContentHashes $root
        foreach ($name in $before.Keys) { Assert-True ($after[$name] -eq $before[$name]) "$name ecrit sur etat partiel." }
    }
}
finally {
    $resolvedWork = [IO.Path]::GetFullPath($workRoot)
    $resolvedTests = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\') + '\'
    if ($resolvedWork.StartsWith($resolvedTests, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedWork)) {
        Remove-Item -LiteralPath $resolvedWork -Recurse -Force
    }
}

$results | ForEach-Object { Write-Host $_ }
Write-Host "RESULTAT : $passed tests reussis, $failed echec(s)."
if ($failed -gt 0) { exit 1 }
