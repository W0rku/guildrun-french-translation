# Sources officielles

Les reconstructions locales utilisent sans modification les sources Steam officielles de Guildrun Demo 0.5.3 build 748 :

- `localization-locales_assets_all.bundle.official`
- `catalog.bin.official` (Steam BuildID 24551494)
- `catalog-24613101.bin.official` (Steam BuildID 24613101)

Le script `tools/reconstruire_payload_v21.ps1` refuse de les utiliser si leur SHA-256 diffère des valeurs documentées. Les sources officielles et le payload restent exclus du dépôt ; les bundles French et Locales V2.1 sont inchangés entre les deux profils.
