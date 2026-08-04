# Étude courte — distribution par patch différentiel

## But

Remplacer à terme les trois fichiers complets du payload par des deltas calculés sur les fichiers officiels et appliqués localement, tout en conservant les mêmes contrôles transactionnels.

## Candidats

- **French bundle** : delta binaire (bsdiff, xdelta3 ou Zstandard patch-from) entre le SHA officiel `C076…3A32` et le SHA traduit `67FF…5E2E`.
- **Locales bundle** : delta binaire entre `D4A2…BDC7` et `D288…AA9C`. Le delta doit porter sur le bundle final compressé ou reconstruire de manière déterministe le flux Unity, jamais effectuer une recherche/remplacement ambiguë.
- **catalog.bin** : patch structuré de huit octets, aux offsets `4723–4726` et `6143–6146`, avec vérification des octets avant et du SHA final.

## Flux proposé

1. Vérifier le SHA-256 de chaque source officielle.
2. Créer la sauvegarde exacte des trois sources.
3. Appliquer chaque delta vers un fichier temporaire dans le même volume.
4. Vérifier le SHA-256 final attendu de chaque fichier temporaire.
5. Effectuer les trois remplacements atomiques.
6. En cas d'erreur, restaurer les trois sauvegardes et contrôler leurs SHA-256.

## Décision avant adoption

Comparer la taille et le temps d'application de `bsdiff`, `xdelta3` et Zstandard sur les deux bundles. Retenir un format dont l'implémentation Windows peut être embarquée, dont la licence est compatible, et qui refuse strictement une source de SHA inconnu. Le catalogue, lui, peut utiliser un minuscule patch interne auditable plutôt qu'un moteur de delta généraliste.
