# Contrôle de compatibilité V2.1.5

## Mise à jour Guildrun contrôlée

- Version : `0.5.6`
- Build du jeu : `792`
- Steam BuildID : `24930839`
- English : `CA2B6A9BCEFBC64D44FEFE5B10C5FA77419C5081095584B7B8516C0EC82811BE`
- French officiel : `C076AA88A443CC945992402D7DE40DCDFDC4DE27228745A37EC735E647C23A32`
- Locales officiel : `D4A2D1D0DC9773DFA75E07778EE90EF9F13252DE96DF2E1D72F4A8476E3BBDC7`
- Catalog officiel : `C48AAD223DB7A7DC3620CEBE29E8AF4C8F0B15990549B32A966DA48BF712F2BF`

Les cinq fichiers contrôlés sont identiques au profil précédent. Les tables English et French contiennent toujours `3 919` clés, sans divergence de Smart String, d’argument ou de balise. Aucun bundle ni catalogue n’a donc été reconstruit.

La mise à jour Steam peut supprimer la préférence Unity `selected-locale_h3890535593`. L’installateur V2.1.5 reconnaît le payload V2.1.4 déjà installé, accepte sa sauvegarde locale exacte et recrée transactionnellement la valeur `fr` sans réécrire inutilement les fichiers du jeu.

La suite finale compte `41/41` tests automatisés réussis, dont la reproduction de cette disparition de préférence. Les tests utilisent uniquement des installations simulées.
