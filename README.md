# Guildrun — Traduction française V2.1.1

Projet communautaire non officiel ajoutant la traduction française native de Guildrun Demo, sans remplacer ni modifier le bundle anglais officiel.

## Compatibilité

- Guildrun Demo `0.5.3`
- Build interne `748`
- Steam BuildID `24551494` ou `24613101`
- Windows x64 / Steam

La compatibilité est volontairement stricte : l’installateur vérifie les SHA-256 de `Guildrun.exe`, des bundles English, French et Locales, ainsi que de `catalog.bin`. Une version inconnue ou un état partiellement patché est refusé avant toute écriture.

## Fonctionnement

Le projet active le véritable Locale Unity `French (fr)`. Il retire uniquement la métadonnée `Comment = "EDITOR"` du Locale français, conserve Japanese masqué et installe le bundle de textes français. Le bundle English reste officiel et n’est jamais remplacé.

Trois fichiers du jeu sont concernés :

1. `localization-string-tables-french(fr)_assets_all.bundle`
2. `localization-locales_assets_all.bundle`
3. `catalog.bin`

La préférence Unity `HKCU\Software\Leyline\Guildrun\selected-locale_h3890535593` fait partie de la transaction : son existence, son type et son contenu antérieurs sont sauvegardés puis restaurés exactement en cas d’échec ou de restauration manuelle.

## Installation

L’exécutable signé ou compilé sera disponible **uniquement dans GitHub Releases**. Aucun `.exe`, bundle ou fichier propriétaire du jeu n’est versionné dans ce dépôt.

1. Vérifier les fichiers de Guildrun Demo dans Steam.
2. Télécharger l’installateur depuis la page Releases du dépôt.
3. Fermer le jeu.
4. Exécuter l’installateur en administrateur.
5. Sélectionner le dossier contenant `Guildrun.exe`.
6. Cliquer sur **Installer la V2.1**.
7. Lancer le jeu et choisir `French (fr)` dans les paramètres si nécessaire.

L’installateur refuse toute build inconnue, crée une sauvegarde locale exacte avant modification et restaure automatiquement les trois fichiers ainsi que la préférence Unity si une étape échoue.

## Restauration

1. Fermer Guildrun.
2. Relancer le même installateur.
3. Sélectionner le dossier du jeu.
4. Cliquer sur **Restaurer la sauvegarde**.

Les trois fichiers originaux sont remis depuis la sauvegarde locale et contrôlés par SHA-256. La préférence de langue précédente est également restaurée ; si elle n’existait pas avant l’installation, elle est supprimée.

## Validation

- **22/22 tests automatisés réussis** ;
- rollback des fichiers et du registre testé ;
- refus sans écriture des versions inconnues et états partiels testé ;
- bundle English vérifié intact ;
- **test manuel en jeu validé sur Steam BuildID 24613101**.

Les tests automatisés sont dans [`tests/Run-Tests.ps1`](tests/Run-Tests.ps1). Ils nécessitent une copie locale légitime des fichiers officiels et du payload, tous deux volontairement exclus du dépôt.

## Reconstruction locale

Le script [`tools/reconstruire_payload_v21.ps1`](tools/reconstruire_payload_v21.ps1) documente et automatise la reconstruction depuis des fichiers officiels fournis localement par l’utilisateur. `AssetsTools.NET` doit être obtenu séparément ; aucun binaire tiers n’est inclus.

Compilation locale de l’installateur, après reconstruction du payload :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\installer\compiler_installeur.ps1
```

## Contenu et licences

La licence de ce dépôt couvre uniquement le code et la documentation propres au projet. Guildrun, ses ressources, ses traductions compilées, ses marques et ses fichiers restent la propriété de leurs ayants droit et ne sont pas distribués ici. Voir [`NOTICE`](NOTICE).

Ce projet n’est pas officiel et n’est ni affilié, ni approuvé, ni soutenu par Leyline.
