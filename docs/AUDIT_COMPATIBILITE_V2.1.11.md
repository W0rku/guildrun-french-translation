# Contrôle de compatibilité V2.1.11

Contrôle du 14 octobre 2026 : Guildrun 0.5.13 build 944, Steam BuildID 25907365, branche releases/0.5.13, commit du jeu 7c7d4099.

Les cinq fichiers contrôlés dans le jeu installé ont les mêmes empreintes que l’installation V2.1.10 : Guildrun.exe, English, French, Locales et catalog.bin. Le triplet patché est complet et la préférence Unity vaut toujours fr (REG_BINARY 66-72-00). Aucune réparation des fichiers de jeu n’est nécessaire.

La V2.1.11 ajoute la build Steam 25907365 et le build interne 944 comme alias du même profil, en conservant les anciennes builds, les sauvegardes et les douze ressources embarquées. Le payload V2.1.10 conserve les corrections Défense et mana toutes les deux secondes. Aucun nouveau texte ni bundle n’est généré.

47/47 tests automatisés réussis : installation, restauration, rollback, migration Steam, mise à niveau V2.1.9, contrôle des ressources embarquées et mise à jour automatique. L’audit des 3923 clés reste conforme : aucune clé manquante, aucun argument, aucune balise de gameplay ou Smart String divergent.

Le jeu n’a pas été lancé pour un contrôle visuel. La préférence française et les fichiers actifs sont vérifiés directement.

SHA-256 installateur : DE49B7F86A4BE44048FEB2C9D1ED71E32D325204E03D78410B8BC773937E3A3E.
