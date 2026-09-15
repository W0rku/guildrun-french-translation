# Guildrun — Traduction française

> Traduction communautaire non officielle pour Guildrun Demo.

Ce projet ajoute **Français** comme une véritable langue dans le menu du jeu. La traduction française possède son propre Locale et ses propres textes : elle ne remplace pas **English**, qui reste intact et disponible à tout moment.

L’installation est contrôlée, sauvegarde les fichiers concernés et peut restaurer exactement leur état précédent.

## Version V2.1.8

Guildrun a été mis à jour en version `0.5.9`, build `842`, Steam BuildID `25323618`. La V2.1.8 reconnaît cette version et conserve les sept BuildID antérieurs déjà compatibles.

English et le catalogue officiel ont changé. Une description de relique a été adaptée au nouvel effet de début de combat et à ses trois paramètres. Le catalogue est reconstruit à partir de la nouvelle version officielle ; English reste intact.

Steam peut conserver un ancien French V2.1.4 ou V2.1.6 avec le nouveau catalogue. L’installateur ne reprend cet état qu’avec la sauvegarde officielle correspondante, conserve la préférence antérieure et réactive `fr` transactionnellement.

L’installateur vérifie également en arrière-plan la dernière Release publique stable. Le statut de sa propre version reste distinct de la compatibilité Guildrun : une panne GitHub ne bloque jamais l’installation ou la restauration du patch. Lorsqu’une version plus récente existe, le bouton **Mettre à jour** télécharge son EXE, contrôle son SHA-256, puis valide son identité et sa version internes avant lancement.

L’audit porte sur **3 923 clés** : aucune clé manquante, aucun argument, aucune balise de gameplay et aucune métadonnée Smart String divergents. L’ensemble passe **46/46 tests automatisés**. Voir le [fonctionnement de la mise à jour automatique](docs/MISE_A_JOUR_INSTALLATEUR.md).

La V2.1.8 est la version stable actuelle. Les installateurs précédents la proposent automatiquement. Voir le [contrôle de compatibilité V2.1.8](docs/AUDIT_COMPATIBILITE_V2.1.8.md).

## Installation

1. Télécharger `Guildrun_Demo_FR_Installer_V2.1.8.exe` depuis la page [Releases](https://github.com/W0rku/guildrun-french-translation/releases).
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
- Guildrun Demo `0.5.7`, build `824`
- Steam BuildID `25119884`
- Guildrun Demo `0.5.9`, build `842`
- Steam BuildID `25323618`
- Windows x64 / Steam

Une mise à jour de Guildrun peut modifier les fichiers contrôlés par l’installateur et nécessiter une nouvelle version du patch. Si la version est inconnue, l’installation est refusée sans modifier le jeu.

## Téléchargement et vérification

La version stable est disponible dans les [Releases GitHub](https://github.com/W0rku/guildrun-french-translation/releases/tag/v2.1.8).

**Guildrun_Demo_FR_Installer_V2.1.8.exe**

```text
SHA-256  7FDE08C179C983CCD64C545DF7EA831E86C46FBB51C2A2770F38C58A14C6C5EB
```

La V2.1.8 a réussi **46/46 tests automatisés**, y compris la compatibilité avec les sept BuildID, la reprise des installations V2.1.4 et V2.1.6 après mise à jour Steam, la restauration exacte, le refus sans écriture d’un état inconnu, les rollbacks et la mise à jour automatique.

## Code source et fichiers du jeu

Le code source de l’installateur, les scripts, les tests et la documentation sont visibles dans ce dépôt. Les bundles, catalogues, sauvegardes, payloads et autres fichiers propriétaires de Guildrun ne sont pas inclus dans Git.

La licence du dépôt couvre uniquement le code propre au projet. Voir [LICENSE](LICENSE) et [NOTICE](NOTICE).

Guildrun est la propriété de ses ayants droit. Ce projet n’est ni affilié, ni approuvé, ni soutenu par Leyline.
