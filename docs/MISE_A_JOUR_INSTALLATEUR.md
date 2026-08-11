# Mise à jour automatique de l’installateur

La vérification de l’installateur est volontairement séparée de la compatibilité du jeu.

| Statut | Source | Effet sur l’installation française |
|---|---|---|
| Version de l’installateur | Dernière Release publique stable GitHub | Aucun : information et bouton de mise à jour uniquement. |
| Compatibilité Guildrun | SHA-256 de `Guildrun.exe`, English, French, Locales et `catalog.bin` | Autorise ou refuse les écritures du patch. |

## Flux

1. Au premier affichage, une tâche d’arrière-plan appelle `GET /repos/W0rku/guildrun-french-translation/releases/latest` avec un délai maximal court.
2. La version du tag est comparée à l’`AssemblyVersion` de l’EXE courant. Une version GitHub identique ou inférieure ne provoque jamais de downgrade.
3. Seul un asset `Guildrun_Demo_FR_Installer_V*.exe` possédant une URL HTTPS sous le chemin Releases du dépôt attendu est accepté.
4. Au clic sur **Mettre à jour**, l’asset est téléchargé dans un dossier temporaire propre à sa version.
5. Le SHA-256 est vérifié lorsqu’il est fourni par le champ `digest` GitHub ou les notes de version.
6. La version interne et l’identité de l’assembly téléchargé sont toujours vérifiées.
7. Le nouvel EXE est lancé avec le dossier Guildrun déjà sélectionné. L’ancien installateur se ferme seulement après un lancement réussi.

Toute erreur réseau, JSON, URL, hash, identité ou lancement est interceptée. L’installateur courant reste ouvert et l’installation/restauration française reste disponible.

## Tests ajoutés

- version identique ;
- version plus récente ;
- refus d’un downgrade ;
- GitHub indisponible ;
- refus d’une URL extérieure au dépôt ;
- digest GitHub ;
- repli SHA-256 depuis les notes ;
- Release sans empreinte ;
- bon et mauvais SHA-256 ;
- identité et version internes de l’EXE compilé.
