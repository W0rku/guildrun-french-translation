# Audit de traduction V2.1.4

## Mise à jour Guildrun contrôlée

- Version : `0.5.5`
- Build du jeu : `783`
- Steam BuildID : `24816645`
- English officiel : `CA2B6A9BCEFBC64D44FEFE5B10C5FA77419C5081095584B7B8516C0EC82811BE`
- Catalog officiel : `C48AAD223DB7A7DC3620CEBE29E8AF4C8F0B15990549B32A966DA48BF712F2BF`

`Guildrun.exe`, le French officiel et le bundle Locales officiel sont inchangés. L’installateur V2.1.3 refusait correctement le nouveau couple English/catalog tant qu’aucun profil compatible n’était publié.

## Résultat de l’audit

- English : `3 919` clés
- French V2.1.4 : `3 919` clés
- Clé manquante ou supplémentaire : `0`
- Divergence SmartFormatTag : `0`
- Divergence d’arguments : `0`
- Divergence de balises de gameplay : `0`
- Corrections French ciblées pour la 0.5.5 : `7`

Les corrections couvrent uniquement les textes dont la structure ou le sens a changé, notamment la résistance à l’étourdissement, deux capacités, deux modificateurs, un passif et une relique.

## Compatibilité multi-profils

Les BuildID `24551494`, `24613101` et `24690909` conservent exactement leurs payloads déjà validés. Le BuildID `24816645` utilise le French V2.1.4 et un catalogue reconstruit depuis son catalog officiel. Pour chaque profil, seules les deux valeurs CRC French et Locales nécessaires sont modifiées dans le catalogue distribué.

La suite finale compte `39/39` tests automatisés réussis. Les tests utilisent des installations simulées et ne modifient pas le dossier Steam actif.
