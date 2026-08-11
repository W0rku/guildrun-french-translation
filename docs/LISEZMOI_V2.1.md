# Guildrun Demo — Traduction française V2.1.2

Cette révision cible **Guildrun Demo 0.5.3, build 748** et reconnaît deux profils Steam : BuildID `24551494` et BuildID `24613101`. Elle utilise le véritable Locale Unity `French (fr)` et ne remplace jamais le bundle anglais.

La V2.1.2 corrige dix entrées françaises : trois libellés « Choisissez… » affichant une syntaxe de formatage littérale, un sélecteur Smart String `plural`, cinq descriptions dont les arguments ou balises divergeaient de l’anglais, et une clé absente des tables françaises. Les tables English et French contiennent désormais chacune 3 919 clés.

## Mise à jour de l’installateur

Au démarrage, l’interface interroge en arrière-plan la dernière Release publique de `W0rku/guildrun-french-translation`. Ce contrôle possède son propre libellé : il est indépendant de la détection et de la compatibilité de Guildrun.

- version identique ou plus ancienne sur GitHub : **Installateur à jour ✓** ;
- version plus récente : **Mise à jour disponible — vX.X.X** et bouton **Mettre à jour** ;
- GitHub inaccessible ou réponse invalide : **Mise à jour non vérifiée**, sans désactiver l’installation ni la restauration du patch.

Le téléchargement accepte uniquement un asset `.exe` provenant des Releases du dépôt attendu. Son SHA-256 est vérifié depuis le `digest` GitHub, ou depuis les notes de version lorsqu’il y figure. Même sans empreinte publiée, l’identité d’assembly et la version interne doivent correspondre exactement à la Release. Le nouvel installateur reçoit le dossier Guildrun sélectionné, est lancé, puis l’ancien se ferme uniquement si ce lancement réussit.

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
3. Refus immédiat d'une version inconnue ou d'un mélange officiel/patché, tout en reconnaissant une V2.1.1 complète comme source de mise à niveau.
4. Capture de l'existence, du type et du contenu exact de `selected-locale_h3890535593`.
5. Copie exacte des trois originaux dans la sauvegarde locale propre au profil (`sauvegarde-locale` ou `sauvegarde-locale-24613101`), avec manifeste SHA-256 et état antérieur de la préférence Unity.
6. Création d'une sauvegarde transactionnelle temporaire des trois fichiers et de la préférence.
7. Remplacement atomique de French, Locales, puis `catalog.bin`, avec contrôle après chaque écriture.
8. Contrôle final du triplet V2.1.2 et du bundle anglais.
9. Écriture de `fr\0` en `REG_BINARY` dans `HKCU\Software\Leyline\Guildrun`, valeur `selected-locale_h3890535593`.
10. Si une étape échoue, restauration automatique des trois fichiers et de la préférence précédente, puis vérification.

Lors d'une restauration manuelle, l'installateur remet la valeur, son type et son contenu précédents. Si la valeur n'existait pas avant l'installation, elle est supprimée. Aucune restauration ne force arbitrairement `en`.

Lors d’une mise à niveau depuis V2.1.1, la sauvegarde locale originale n’est jamais réécrite. Un échec remet exactement le triplet V2.1.1 et sa préférence courante ; la restauration manuelle continue de remettre l’état officiel précédant la première installation.

## Utilisation

- Interface graphique : exécuter `Installeur/Guildrun_Demo_FR_Installer_V2.1.2.exe` en administrateur.
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
2. Lancer l'installateur V2.1.2 et sélectionner le dossier contenant `Guildrun.exe`.
3. Cliquer sur **Installer la V2.1** et attendre le message de réussite.
4. Lancer le jeu normalement, sans `-language=en`.
5. Ouvrir Settings > Language : `French (fr)` doit apparaître et `Japanese (ja)` doit rester absent.
6. Sélectionner `French (fr)` si nécessaire, revenir au menu puis ouvrir plusieurs écrans de jeu pour confirmer le chargement des textes français.
7. Fermer et relancer le jeu : le Locale français doit rester sélectionné.
8. Quitter le jeu, utiliser **Restaurer** pour remettre l’état précédent, puis vérifier avec Steam si l'on souhaite confirmer le retour exact aux fichiers officiels.

La compilation V2.1.2 locale a réussi 37/37 tests automatisés, dont neuf scénarios propres à la mise à jour de l’installateur. Un test d’intégration contre GitHub a également confirmé la lecture de la Release publique V2.1.1 et de son digest SHA-256. La compilation doit encore être validée manuellement dans le jeu avant toute nouvelle Release ; la Release stable V2.1.1 reste inchangée.
