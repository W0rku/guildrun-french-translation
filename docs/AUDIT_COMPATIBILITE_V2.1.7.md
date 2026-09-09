# Contrôle de compatibilité V2.1.7

## Version Steam contrôlée

- Version : `0.5.7`
- Build interne : `824`
- Steam BuildID : `25119884`
- Branche : `releases/0.5.7`
- Commit du jeu : `e42eca01`

## Résultat

Les cinq fichiers contrôlés par l’installateur sont identiques au profil précédent :

- `Guildrun.exe` : inchangé
- English : inchangé
- French : inchangé
- Locales : inchangé
- `catalog.bin` : inchangé

`resources.assets` et `GameAssembly.dll` ont changé, mais aucune modification de ces fichiers n’est requise. Les tables English et French restent à `3 923` clés et le catalogue V2.1.6 reste compatible.

Steam a supprimé la préférence Unity `selected-locale_h3890535593`. La V2.1.7 ajoute le BuildID `25119884` au profil 0.5.7 et reprend deux états strictement reconnus : French V2.1.4 avec sauvegarde V2.1.4, ou French V2.1.6 avec sauvegarde V2.1.6. Dans les deux cas, `fr` est réactivé transactionnellement et la restauration exacte reste disponible.

La suite finale compte `43/43` tests automatisés réussis dans des installations simulées.
