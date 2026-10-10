# Contrôle de compatibilité V2.1.10

Contrôle du 11 octobre 2026 : Guildrun 0.5.12 build 907, Steam BuildID 25751498, branche releases/0.5.12, commit du jeu 996685a4.

Guildrun.exe, English et le catalogue officiel conservent les empreintes du profil 25323618. L’installation locale conservait French V2.1.4 et Locales modifié avec le catalogue officiel : cet état est repris uniquement avec sa sauvegarde officielle validée.

Deux corrections UI sont appliquées au bundle V2.1.8 : description complète de Défense (100/200/300 points et dégâts reçus 1/2, 1/3, 1/4) et mana gagné toutes les deux secondes. Les formulations suivent les tables anglaises installées. Audit complet : 3923 clés, deux changements déclarés, aucune clé manquante ni divergence de Smart Strings, arguments ou balises.

French V2.1.10 SHA-256 : D8E23CC8C4C1FB925056C1014D9317EDC9FF2E003FDCF20CB95FBECE93BBF885.

Catalogue V2.1.10 SHA-256 : F8FD7F62131E2A23EAB04B1C29053ABDBD5FF8587ED991D0FF90102FC842CCF5. Seuls les huit octets CRC de French et Locales changent par rapport à l’officiel.

47/47 tests automatisés, dont mise à niveau d’un triplet V2.1.9 complet puis reprise du même patch après remplacement du catalogue par Steam, conservation du manifeste original et restauration exacte des fichiers et de la préférence. Les anciennes builds compatibles restent reconnues.

Le patch a été installé dans le dossier de jeu local avec vérification des empreintes finales et du maintien d’English. Le jeu n’a pas été lancé ; aucun contrôle visuel en partie n’est revendiqué.

Reconstruction : tools/reconstruire_payload_v2110.ps1, audit : tools/auditer_traduction_v2110.ps1. Sources officielles et bibliothèque AssetsTools.NET locales nécessaires, exclues du dépôt.
