# Guildrun — Traduction française

> Traduction communautaire non officielle pour Guildrun Demo.

Ce projet ajoute **Français** comme une véritable langue dans le menu du jeu. La traduction française possède son propre Locale et ses propres textes : elle ne remplace pas **English**, qui reste intact et disponible à tout moment.

L’installation est contrôlée, sauvegarde les fichiers concernés et peut restaurer exactement leur état précédent.

## Version V2.1.2

L’audit du 11 août 2026 confirme que Steam utilise toujours le BuildID `24613101` : les fichiers du jeu n’ont pas changé depuis la dernière version compatible. Le problème visible sur l’écran de sélection des héros venait de la table French V2.1.1, qui affichait littéralement une expression de formatage.

Les sources V2.1.2 corrigent dix entrées ciblées, ajoutent l’unique clé French manquante et alignent les arguments, balises et métadonnées Smart String sur English. L’audit porte désormais sur **3 919 clés** et la mise à niveau transactionnelle depuis une V2.1.1 complète est couverte.

À partir de V2.1.2, l’installateur vérifie également en arrière-plan la dernière Release publique stable. Le statut de sa propre version reste distinct de la compatibilité Guildrun : une panne GitHub ne bloque jamais l’installation ou la restauration du patch. Lorsqu’une version plus récente existe, un bouton **Mettre à jour** permet de télécharger son EXE depuis la Release attendue, de contrôler son SHA-256 lorsqu’il est publié, puis de valider son identité et sa version internes avant lancement.

L’ensemble passe **37/37 tests automatisés**. Voir le [fonctionnement de la mise à jour automatique](docs/MISE_A_JOUR_INSTALLATEUR.md).

La V2.1.2 est la version stable actuelle. Les utilisateurs de V2.1.1 doivent effectuer ce passage une dernière fois depuis la page Releases ; les mises à jour suivantes pourront être proposées directement dans l’installateur. Voir le [rapport d’audit](docs/AUDIT_TRADUCTION_V2.1.2.md).

## Installation

1. Télécharger `Guildrun_Demo_FR_Installer_V2.1.2.exe` depuis la page [Releases](https://github.com/W0rku/guildrun-french-translation/releases).
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

La version stable est disponible dans les [Releases GitHub](https://github.com/W0rku/guildrun-french-translation/releases/tag/v2.1.2).

**Guildrun_Demo_FR_Installer_V2.1.2.exe**

```text
SHA-256  B8CD0C7240F31E856C62C5A78F755A6A8D79BA1C932014100397DEB0337BD8E6
```

La V2.1.2 a réussi **37/37 tests automatisés**, y compris la compatibilité avec les deux BuildID, la mise à niveau transactionnelle depuis V2.1.1 et le contrôle automatique des Releases GitHub.

## Code source et fichiers du jeu

Le code source de l’installateur, les scripts, les tests et la documentation sont visibles dans ce dépôt. Les bundles, catalogues, sauvegardes, payloads et autres fichiers propriétaires de Guildrun ne sont pas inclus dans Git.

La licence du dépôt couvre uniquement le code propre au projet. Voir [LICENSE](LICENSE) et [NOTICE](NOTICE).

Guildrun est la propriété de ses ayants droit. Ce projet n’est ni affilié, ni approuvé, ni soutenu par Leyline.
