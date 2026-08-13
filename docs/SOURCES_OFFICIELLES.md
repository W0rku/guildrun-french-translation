# Sources officielles

Les reconstructions locales utilisent sans modification les sources Steam officielles des profils Guildrun pris en charge :

- `localization-string-tables-french(fr)_assets_all.bundle.official`
- `localization-locales_assets_all.bundle.official`
- `catalog.bin.official` (Steam BuildID 24551494)
- `catalog-24613101.bin.official` (Steam BuildID 24613101)
- `catalog-24690909.bin.official` (Guildrun 0.5.4 build 767, Steam BuildID 24690909)

La reconstruction French utilise aussi les baselines traduites V2.1.1 et V2.1.2, conservées uniquement en local.

Le script `tools/reconstruire_payload_v21.ps1` refuse tous ces fichiers si leur SHA-256 diffère des valeurs documentées. Il applique uniquement les corrections déclarées dans `translations/corrections-v2.1.2.fr.json` puis `translations/corrections-v2.1.3.fr.json`. Les sources officielles, les baselines propriétaires et le payload restent exclus du dépôt ; le bundle Locales est inchangé et les catalogues restent propres à chaque profil.
