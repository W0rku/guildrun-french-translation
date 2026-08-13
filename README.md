# Guildrun — Traduction française

> Traduction communautaire non officielle pour Guildrun Demo.

Ce projet ajoute **Français** comme une véritable langue dans le menu du jeu. La traduction française possède son propre Locale et ses propres textes : elle ne remplace pas **English**, qui reste intact et disponible à tout moment.

L’installation est contrôlée, sauvegarde les fichiers concernés et peut restaurer exactement leur état précédent.

## Version V2.1.3

Guildrun a été mis à jour en version `0.5.4`, build `767`, Steam BuildID `24690909`. La V2.1.3 reconnaît strictement cette nouvelle version et conserve les deux profils `0.5.3` déjà compatibles.

La mise à jour du jeu ne retire et n’ajoute aucune clé, mais modifie plusieurs textes et paramètres de gameplay. La V2.1.3 adapte **11 entrées françaises** et utilise un payload propre à chaque version du jeu : French V2.1.2 reste associé aux builds `0.5.3`, tandis que French V2.1.3 est réservé au build `0.5.4`.

L’installateur vérifie également en arrière-plan la dernière Release publique stable. Le statut de sa propre version reste distinct de la compatibilité Guildrun : une panne GitHub ne bloque jamais l’installation ou la restauration du patch. Lorsqu’une version plus récente existe, le bouton **Mettre à jour** télécharge son EXE, contrôle son SHA-256, puis valide son identité et sa version internes avant lancement.

L’audit porte sur **3 919 clés** : aucune clé manquante, aucun argument, aucune balise de gameplay et aucune métadonnée Smart String divergents. L’ensemble passe **39/39 tests automatisés**. Voir le [fonctionnement de la mise à jour automatique](docs/MISE_A_JOUR_INSTALLATEUR.md).

La V2.1.3 est la version stable actuelle. Les installateurs V2.1.2 la proposent automatiquement dès que la Release publique est disponible. Voir le [rapport d’audit V2.1.3](docs/AUDIT_TRADUCTION_V2.1.3.md).

## Installation

1. Télécharger `Guildrun_Demo_FR_Installer_V2.1.3.exe` depuis la page [Releases](https://github.com/W0rku/guildrun-french-translation/releases).
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
- Windows x64 / Steam

Une mise à jour de Guildrun peut modifier les fichiers contrôlés par l’installateur et nécessiter une nouvelle version du patch. Si la version est inconnue, l’installation est refusée sans modifier le jeu.

## Téléchargement et vérification

La version stable est disponible dans les [Releases GitHub](https://github.com/W0rku/guildrun-french-translation/releases/tag/v2.1.3).

**Guildrun_Demo_FR_Installer_V2.1.3.exe**

```text
SHA-256  9B1881796B54C797785B7263F7F89B090E8CBF76FB09F21164EE0CD2CA7A6A41
```

La V2.1.3 a réussi **39/39 tests automatisés**, y compris la compatibilité avec les trois BuildID, le routage des payloads par version, le refus sans écriture du nouveau hash English lorsqu’il est inconnu, les rollbacks transactionnels et la mise à jour automatique.

## Code source et fichiers du jeu

Le code source de l’installateur, les scripts, les tests et la documentation sont visibles dans ce dépôt. Les bundles, catalogues, sauvegardes, payloads et autres fichiers propriétaires de Guildrun ne sont pas inclus dans Git.

La licence du dépôt couvre uniquement le code propre au projet. Voir [LICENSE](LICENSE) et [NOTICE](NOTICE).

Guildrun est la propriété de ses ayants droit. Ce projet n’est ni affilié, ni approuvé, ni soutenu par Leyline.
