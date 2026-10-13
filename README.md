# Guildrun — Traduction française

Traduction communautaire non officielle pour Guildrun Demo. Ajoute **French (fr)** au menu des langues, avec sauvegarde et restauration exactes. English reste disponible.

## Version finale V2.1.11

Cette version reconnaît officiellement la mise à jour 0.5.13. Les fichiers de localisation sont identiques à ceux de la build précédente ; le payload français V2.1.10 et ses corrections sont conservés.

Compatible avec **Guildrun Demo 0.5.13, build 944, Steam BuildID 25907365**.

- L’installation reprend les fichiers de traduction conservés par Steam après une mise à jour et réactive le français.
- L’infobulle **Défense** affiche l’explication complète : 100 de Défense = 1/2 des dégâts reçus, 200 = 1/3, 300 = 1/4, etc.
- L’infobulle **Régénération de mana** indique le mana gagné **toutes les 2 secondes**.
- Les installations V2.1.8 et V2.1.9 sont mises à niveau en conservant leur sauvegarde originale.

## Installation

1. Télécharger [Guildrun_Demo_FR_Installer_V2.1.11.exe](https://github.com/W0rku/guildrun-french-translation/releases/latest/download/Guildrun_Demo_FR_Installer_V2.1.11.exe).
2. Fermer Guildrun, lancer l’installateur et sélectionner le dossier contenant `Guildrun.exe`.
3. Installer le français. Au prochain lancement, sélectionner **French (fr)** si nécessaire.

L’installateur vérifie automatiquement les nouvelles versions publiées sur GitHub. Le bouton **Mettre à jour** contrôle l’empreinte et la version interne du fichier téléchargé. Voir [la mise à jour automatique](docs/MISE_A_JOUR_INSTALLATEUR.md).

## Restauration

Pour jouer en anglais, sélectionner **English** dans les paramètres. Pour retirer le patch, fermer le jeu et choisir **Restaurer** dans l’installateur : les fichiers officiels et la préférence de langue antérieure sont restaurés.

## Compatibilité et validation

Windows x64 / Steam. Profils validés : 0.5.3 (748), 0.5.4 (767), 0.5.5 (783), 0.5.6 (792), 0.5.7 (814/824), 0.5.9 (842), 0.5.10 (864) et 0.5.12 (907) et 0.5.13 (944). Une version dont les empreintes sont inconnues est refusée avant écriture.

**47/47 tests automatisés** : installation, migration après Steam, mise à niveau V2.1.9, restauration, rollback, identité de l’EXE et mise à jour automatique. Audit des **3 923 clés** : aucune clé manquante, aucun argument, balisage de gameplay ou Smart String divergent. Voir [le contrôle V2.1.11](docs/AUDIT_COMPATIBILITE_V2.1.11.md).

La page [Releases](https://github.com/W0rku/guildrun-french-translation/releases) contient uniquement la version finale actuelle.

## Sources

Le dépôt contient le code de l’installateur, les scripts, les corrections et les tests. Les bundles, catalogues et sauvegardes propriétaires ne sont pas inclus dans Git. La licence couvre le code propre au projet : [LICENSE](LICENSE), [NOTICE](NOTICE).

SHA-256 de l’installateur : `DE49B7F86A4BE44048FEB2C9D1ED71E32D325204E03D78410B8BC773937E3A3E`
