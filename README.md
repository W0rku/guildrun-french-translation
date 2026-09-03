# Guildrun — Traduction française

> Traduction communautaire non officielle pour Guildrun Demo.

Ce projet ajoute **Français** comme une véritable langue dans le menu du jeu. La traduction française possède son propre Locale et ses propres textes : elle ne remplace pas **English**, qui reste intact et disponible à tout moment.

L’installation est contrôlée, sauvegarde les fichiers concernés et peut restaurer exactement leur état précédent.

## Version V2.1.6

Guildrun a été mis à jour en version `0.5.7`, build `814`, Steam BuildID `25060342`. La V2.1.6 reconnaît cette version et conserve les cinq BuildID antérieurs déjà compatibles.

Cette mise à jour ajoute quatre textes d’interface : **Victoires totales** et **Meilleure série**, avec leurs variantes chiffrées. Si Steam a laissé l’ancien French/Locales patché avec le nouveau catalogue officiel, la V2.1.6 reprend cet état uniquement après validation de la sauvegarde officielle V2.1.4, puis crée une sauvegarde 0.5.7 complète et restaurable.

L’installateur vérifie également en arrière-plan la dernière Release publique stable. Le statut de sa propre version reste distinct de la compatibilité Guildrun : une panne GitHub ne bloque jamais l’installation ou la restauration du patch. Lorsqu’une version plus récente existe, le bouton **Mettre à jour** télécharge son EXE, contrôle son SHA-256, puis valide son identité et sa version internes avant lancement.

L’audit porte sur **3 923 clés** : aucune clé manquante, aucun argument, aucune balise de gameplay et aucune métadonnée Smart String divergents. L’ensemble passe **42/42 tests automatisés**. Voir le [fonctionnement de la mise à jour automatique](docs/MISE_A_JOUR_INSTALLATEUR.md).

La V2.1.6 est la version stable actuelle. Les installateurs précédents la proposent automatiquement. Voir le [contrôle de compatibilité V2.1.6](docs/AUDIT_COMPATIBILITE_V2.1.6.md).

## Installation

1. Télécharger `Guildrun_Demo_FR_Installer_V2.1.6.exe` depuis la page [Releases](https://github.com/W0rku/guildrun-french-translation/releases).
2. Fermer Guildrun.
3. Lancer l’installateur, sélectionner le dossier du jeu et installer le français.

Au prochain lancement, choisir **French (fr)** dans les paramètres de langue si nécessaire.

## Revenir en anglais ou restaurer le jeu

- **English reste disponible dans le jeu** : pour jouer en anglais sans retirer la traduction, sélectionner simplement **English** dans le menu des langues.
- Pour retirer les modifications de la traduction, fermer le jeu, relancer le même installateur et choisir **Restaurer**. Cette fonction remet les fichiers et la préférence de langue exactement dans leur état précédent.

## Compatibilité

- Guildrun Demo `0.5.3`, build `748`
- Steam BuildID `24551494`
- Steam BuildID `24613101`
- Guildrun Demo `0.5.4`, build `767`
- Steam BuildID `24690909`
- Guildrun Demo `0.5.5`, build `783`
- Steam BuildID `24816645`
- Guildrun Demo `0.5.6`, build `792`
- Steam BuildID `24930839`
- Guildrun Demo `0.5.7`, build `814`
- Steam BuildID `25060342`
- Windows x64 / Steam

Une mise à jour de Guildrun peut modifier les fichiers contrôlés par l’installateur et nécessiter une nouvelle version du patch. Si la version est inconnue, l’installation est refusée sans modifier le jeu.

## Téléchargement et vérification

La version stable est disponible dans les [Releases GitHub](https://github.com/W0rku/guildrun-french-translation/releases/tag/v2.1.6).

**Guildrun_Demo_FR_Installer_V2.1.6.exe**

```text
SHA-256  D45DF44A66F4CCFC4FB2AE3FEA1D3765F7A18F622240DAB72946CDBF5AE9D8B4
```

La V2.1.6 a réussi **42/42 tests automatisés**, y compris la compatibilité avec les six BuildID, la migration sûre de l’état laissé par Steam 0.5.7, la restauration exacte, le refus sans écriture d’un état inconnu, les rollbacks et la mise à jour automatique.

## Code source et fichiers du jeu

Le code source de l’installateur, les scripts, les tests et la documentation sont visibles dans ce dépôt. Les bundles, catalogues, sauvegardes, payloads et autres fichiers propriétaires de Guildrun ne sont pas inclus dans Git.

La licence du dépôt couvre uniquement le code propre au projet. Voir [LICENSE](LICENSE) et [NOTICE](NOTICE).

Guildrun est la propriété de ses ayants droit. Ce projet n’est ni affilié, ni approuvé, ni soutenu par Leyline.
