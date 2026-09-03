# Sources officielles

Les reconstructions locales utilisent sans modification les sources Steam officielles des profils Guildrun pris en charge :

- `localization-string-tables-french(fr)_assets_all.bundle.official`
- `localization-locales_assets_all.bundle.official`
- `catalog.bin.official` (Steam BuildID 24551494)
- `catalog-24613101.bin.official` (Steam BuildID 24613101)
- `catalog-24690909.bin.official` (Guildrun 0.5.4 build 767, Steam BuildID 24690909)
- `catalog-24816645.bin.official` (Guildrun 0.5.5 build 783, Steam BuildID 24816645)
- `catalog-25060342.bin.official` (Guildrun 0.5.7 build 814, Steam BuildID 25060342)

Guildrun 0.5.6 build 792 (Steam BuildID 24930839) conserve exactement les mêmes fichiers English, French, Locales et catalog que le profil 24816645 ; aucune nouvelle source propriétaire ni reconstruction de payload n’est nécessaire.

Guildrun 0.5.7 build 814 (Steam BuildID 25060342) apporte un nouveau bundle English et un nouveau `catalog.bin`. French et Locales officiels restent identiques. La reconstruction V2.1.6 repart du payload French V2.1.4 et ajoute quatre clés UI.

La reconstruction French utilise aussi les baselines traduites V2.1.1 à V2.1.4, conservées uniquement en local.

Le script `tools/reconstruire_payload_v21.ps1` refuse tous ces fichiers si leur SHA-256 diffère des valeurs documentées. Il applique uniquement les corrections déclarées dans les manifestes `translations/corrections-v2.1.2.fr.json` à `translations/corrections-v2.1.6.fr.json`. Les sources officielles, les baselines propriétaires et le payload restent exclus du dépôt ; le bundle Locales est inchangé et les catalogues restent propres à chaque profil.
