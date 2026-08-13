# Audit de traduction V2.1.3

## Mise à jour Guildrun contrôlée

- Version : `0.5.4`
- Build du jeu : `767`
- Steam BuildID : `24690909`
- English officiel : `A39EB85FAE5C1EBBF6385D9D7798E6D8F8287D55402098FDF5AB96D288ACCA8F`
- Catalog officiel : `647051CA4D8AAF4ED9E2BB13674E690333C689D9743F88D0DFB4DE3097FA820C`

`Guildrun.exe`, le French officiel et le bundle Locales officiel sont inchangés. L’installateur V2.1.2 refusait donc correctement le nouveau couple English/catalog tant qu’aucun profil compatible n’était publié.

## Résultat de l’audit

- English : `3 919` clés
- French V2.1.3 : `3 919` clés
- Clé manquante ou supplémentaire : `0`
- Divergence SmartFormatTag : `0`
- Divergence d’arguments : `0`
- Divergence de balises de gameplay : `0`
- Corrections French ciblées pour la 0.5.4 : `11`

La mise à jour du jeu a modifié treize textes English, sans ajouter ni supprimer de clé. Deux changements sont uniquement typographiques et étaient déjà correctement rendus en français ; onze textes French ont été adaptés.

## Compatibilité multi-profils

Les BuildID `24551494` et `24613101` conservent exactement le French V2.1.2 déjà validé. Le BuildID `24690909` utilise le French V2.1.3 et un catalogue reconstruit depuis son catalog officiel. Pour chaque profil, seules les deux valeurs CRC French et Locales nécessaires sont modifiées dans le catalogue distribué.

La suite finale compte `39/39` tests automatisés réussis. Les tests utilisent des installations simulées et ne modifient pas le dossier Steam actif.
