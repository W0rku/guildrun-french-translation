# Contrôle de compatibilité V2.1.8

Contrôle du 15 septembre 2026 : Guildrun 0.5.9 build 842, Steam BuildID 25323618, branche releases/0.5.9, commit da85a54a.

English et catalog.bin ont changé. Guildrun.exe est inchangé. Steam a conservé chez l’utilisateur le French V2.1.4 et les Locales patchés ; le catalogue est redevenu officiel. Les CRC officiels attendent toujours les mêmes French et Locales officiels.

Une description de relique (Relics:21745596575236113) emploie désormais trois arguments : Furtivité au début du combat pendant {0} secondes, puis bonus critique {2} pendant Ruée {1}. Seule cette chaîne est corrigée depuis la baseline French V2.1.6. L’audit confirme 3923 clés English/French, aucune manquante, et des arguments, balises et métadonnées Smart String conformes. L’audit structurel ne constitue pas une comparaison sémantique exhaustive avec l’ancien English, non disponible localement.

Le catalogue patché repart de l’original 25323618. Les seuls octets modifiés sont 4723–4726 (CRC Locales) et 6143–6146 (CRC French).

La reprise d’un état Steam mixte V2.1.4/V2.1.6 exige sa sauvegarde officielle validée. La sauvegarde antérieure reste intacte ; une nouvelle sauvegarde associe French/Locales officiels et le nouveau catalogue officiel, avec la préférence d’avant la première installation. Le rollback remet exactement l’état mixte courant.

46/46 tests automatisés réussis, dont CRC, ressources embarquées, compatibilité historique, migration, refus sans sauvegarde et rollback. Aucun fichier actif du jeu n’a été modifié ni le jeu lancé pendant la préparation.

## Test manuel restant

Fermer Guildrun, lancer V2.1.8 et installer. Lancer normalement le jeu ; vérifier French (fr), les textes français et la nouvelle description de relique. English doit rester disponible. La validation réelle en jeu de V2.1.8 reste à effectuer.
