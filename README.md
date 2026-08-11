# Guildrun — Traduction française

> Traduction communautaire non officielle pour Guildrun Demo.

Ce projet ajoute **Français** comme une véritable langue dans le menu du jeu. La traduction française possède son propre Locale et ses propres textes : elle ne remplace pas **English**, qui reste intact et disponible à tout moment.

L’installation est contrôlée, sauvegarde les fichiers concernés et peut restaurer exactement leur état précédent.

## Correctifs V2.1.2 en préparation

L’audit du 11 août 2026 confirme que Steam utilise toujours le BuildID `24613101` : les fichiers du jeu n’ont pas changé depuis la dernière version compatible. Le problème visible sur l’écran de sélection des héros venait de la table French V2.1.1, qui affichait littéralement une expression de formatage.

Les sources V2.1.2 corrigent dix entrées ciblées, ajoutent l’unique clé French manquante et alignent les arguments, balises et métadonnées Smart String sur English. L’audit porte désormais sur **3 919 clés** et la suite passe **28/28 tests automatisés**. La mise à niveau transactionnelle depuis une V2.1.1 complète est également couverte.

Cette compilation doit encore être validée manuellement en jeu. En attendant, la Release stable et son installateur V2.1.1 restent inchangés. Voir le [rapport d’audit](docs/AUDIT_TRADUCTION_V2.1.2.md).

## Installation

1. Télécharger `Guildrun_Demo_FR_Installer_V2.1.1.exe` depuis la page [Releases](https://github.com/W0rku/guildrun-french-translation/releases).
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
- Windows x64 / Steam

Une mise à jour de Guildrun peut modifier les fichiers contrôlés par l’installateur et nécessiter une nouvelle version du patch. Si la version est inconnue, l’installation est refusée sans modifier le jeu.

## Téléchargement et vérification

La version stable est disponible dans les [Releases GitHub](https://github.com/W0rku/guildrun-french-translation/releases/tag/v2.1.1).

**Guildrun_Demo_FR_Installer_V2.1.1.exe**

```text
SHA-256  79F52E55D7CBEE5F847661F64FA84C69C7B0989E44606484CB30DDA6C9A10667
```

La Release V2.1.1 a réussi **22/22 tests automatisés** et a été validée manuellement sur Steam BuildID `24613101`. Les sources V2.1.2 en préparation passent **28/28 tests automatisés** mais ne remplacent pas encore cette Release.

## Code source et fichiers du jeu

Le code source de l’installateur, les scripts, les tests et la documentation sont visibles dans ce dépôt. Les bundles, catalogues, sauvegardes, payloads et autres fichiers propriétaires de Guildrun ne sont pas inclus dans Git.

La licence du dépôt couvre uniquement le code propre au projet. Voir [LICENSE](LICENSE) et [NOTICE](NOTICE).

Guildrun est la propriété de ses ayants droit. Ce projet n’est ni affilié, ni approuvé, ni soutenu par Leyline.
