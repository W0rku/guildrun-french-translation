# Guildrun Demo — Traduction française V2.1

Cette version cible exclusivement **Guildrun Demo 0.5.3, build 748**. Elle utilise le véritable Locale Unity `French (fr)` et ne remplace jamais le bundle anglais.

## Changement du Locale

Le bundle `localization-locales_assets_all.bundle` est reconstruit depuis l'original Steam. Dans l'objet `UnityEngine.Localization.Locale` nommé `French (fr)`, PathID `996707670718014713`, l'unique métadonnée `Comment = "EDITOR"` est retirée. Aucun autre objet sérialisé ne change.

Le Locale `Japanese (ja)` conserve son commentaire `EDITOR` et reste masqué. `GameAssembly.dll`, `globalgamemanagers.assets`, `resources.assets`, le bundle anglais et le nom `French (fr)` restent intacts.

## Fichiers de jeu gérés

L'installation écrit uniquement ces trois fichiers :

1. `Guildrun_Data/StreamingAssets/aa/StandaloneWindows64/localization-string-tables-french(fr)_assets_all.bundle`
2. `Guildrun_Data/StreamingAssets/aa/StandaloneWindows64/localization-locales_assets_all.bundle`
3. `Guildrun_Data/StreamingAssets/aa/catalog.bin`

Le bundle anglais est contrôlé avant et après l'opération, mais n'est jamais écrit.

## Flux transactionnel

1. Vérification de `Guildrun.exe`, des trois fichiers officiels et du bundle anglais par SHA-256.
2. Vérification des trois fichiers embarqués dans le payload.
3. Refus immédiat d'une version inconnue ou d'un mélange officiel/patché, sans création de sauvegarde.
4. Capture de l'existence, du type et du contenu exact de `selected-locale_h3890535593`.
5. Copie exacte des trois originaux dans `Traduction_FR_V2.1/sauvegarde-locale`, avec manifeste SHA-256 et état antérieur de la préférence Unity.
6. Création d'une sauvegarde transactionnelle temporaire des trois fichiers et de la préférence.
7. Remplacement atomique de French, Locales, puis `catalog.bin`, avec contrôle après chaque écriture.
8. Contrôle final du triplet V2.1 et du bundle anglais.
9. Écriture de `fr\0` en `REG_BINARY` dans `HKCU\Software\Leyline\Guildrun`, valeur `selected-locale_h3890535593`.
10. Si une étape échoue, restauration automatique des trois fichiers et de la préférence précédente, puis vérification.

Lors d'une restauration manuelle, l'installateur remet la valeur, son type et son contenu précédents. Si la valeur n'existait pas avant l'installation, elle est supprimée. Aucune restauration ne force arbitrairement `en`.

## Utilisation

- Interface graphique : exécuter `Installeur/Guildrun_Demo_FR_Installer_V2.1.exe` en administrateur.
- Script : `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\installer_traduction.ps1`
- Restauration : `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\restaurer_sauvegarde.ps1`

## Reconstruction et tests

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\reconstruire_payload_v21.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Run-Tests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Installeur\compiler_installeur.ps1
```

La bibliothèque `AssetsTools.NET.dll` sert uniquement à reconstruire et inspecter le bundle Unity. Elle n'est pas embarquée dans l'installateur.

## Test manuel dans le jeu

1. Dans Steam, vérifier les fichiers du jeu et confirmer que la build affichée est 0.5.3 build 748.
2. Lancer l'installateur V2.1 et sélectionner le dossier contenant `Guildrun.exe`.
3. Cliquer sur **Installer la V2.1** et attendre le message de réussite.
4. Lancer le jeu normalement, sans `-language=en`.
5. Ouvrir Settings > Language : `French (fr)` doit apparaître et `Japanese (ja)` doit rester absent.
6. Sélectionner `French (fr)` si nécessaire, revenir au menu puis ouvrir plusieurs écrans de jeu pour confirmer le chargement des textes français.
7. Fermer et relancer le jeu : le Locale français doit rester sélectionné.
8. Quitter le jeu, utiliser **Restaurer la sauvegarde**, puis vérifier avec Steam si l'on souhaite confirmer le retour exact aux fichiers officiels.

La V2.1 n'est ni publiée sur GitHub ni associée à une Release.
