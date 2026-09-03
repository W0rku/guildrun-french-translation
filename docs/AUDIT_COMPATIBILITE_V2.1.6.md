# Contrôle de compatibilité V2.1.6

## Version Steam contrôlée

- Version : `0.5.7`
- Build interne : `814`
- Steam BuildID : `25060342`
- Branche : `releases/0.5.7`
- Commit du jeu : `b2089864`

## Résultat

`Guildrun.exe`, French officiel et Locales officiel sont inchangés. English et `catalog.bin` ont changé. Les tables English contiennent désormais `3 923` clés ; quatre nouvelles clés UI ont été ajoutées à French V2.1.6 :

- `Total Wins: {0}` → `Victoires totales : {0}`
- `Highest Streak: {0}` → `Meilleure série : {0}`
- `Highest Streak` → `Meilleure série`
- `Total Wins` → `Victoires totales`

Les deux chaînes paramétrées conservent leur métadonnée Smart String. L’audit ne trouve aucune clé, variable, balise ou structure divergente.

Le catalogue patché est reconstruit depuis le catalogue officiel BuildID `25060342`. Seuls les CRC Locales et French changent, aux offsets `4723–4726` et `6143–6146`.

Steam peut laisser un état mixte après la mise à jour : nouvel English, nouveau catalogue officiel, ancien French V2.1.4 et Locales patché. L’installateur ne migre cet état précis que si la sauvegarde locale V2.1.4 contient les fichiers officiels attendus et passe toutes les vérifications SHA-256. Il crée alors une sauvegarde 0.5.7 exacte avant toute copie. Les autres états partiels restent refusés sans écriture.

La suite finale compte `42/42` tests automatisés réussis dans des installations simulées.
