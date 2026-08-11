# Sources officielles

Les reconstructions locales utilisent sans modification les sources Steam officielles de Guildrun Demo 0.5.3 build 748 :

- `localization-string-tables-french(fr)_assets_all.bundle.official`
- `localization-locales_assets_all.bundle.official`
- `catalog.bin.official` (Steam BuildID 24551494)
- `catalog-24613101.bin.official` (Steam BuildID 24613101)

La reconstruction French utilise aussi `localization-string-tables-french(fr)_assets_all.v211.bundle`, baseline traduite V2.1.1 conservée uniquement en local.

Le script `tools/reconstruire_payload_v21.ps1` refuse tous ces fichiers si leur SHA-256 diffère des valeurs documentées. Il applique ensuite uniquement les corrections déclarées dans `translations/corrections-v2.1.2.fr.json`. Les sources officielles, la baseline propriétaire et le payload restent exclus du dépôt ; le bundle Locales est inchangé depuis la V2.1.1 et les catalogues restent propres à chaque profil.
