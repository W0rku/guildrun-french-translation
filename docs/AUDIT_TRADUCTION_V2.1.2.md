# Audit de traduction V2.1.2

## État de la mise à jour Steam

Le contrôle du 11 août 2026 ne montre aucun changement du profil de localisation connu :

- Guildrun `0.5.3`, build `748` ;
- Steam BuildID `24613101` ;
- `Guildrun.exe`, English, French, Locales et `catalog.bin` possèdent les mêmes SHA-256 que l’installation V2.1.1 reconnue.

Le texte de la capture n’est donc pas une régression d’un nouveau bundle Steam. Il révèle des défauts déjà présents dans la table French V2.1.1.

## Corrections ciblées

Dix entrées seulement changent dans le bundle French :

| Table | Key ID | Correction |
|---|---:|---|
| UI | `4757517696221205` | Remplace le format littéral par « Choisissez un héros ». |
| UI | `5855615528976384` | Remplace le format littéral par « Choisissez votre récompense ». |
| UI | `5855615566725120` | Remplace le format littéral par « Choisissez un objet ». |
| UI | `80337992714018816` | Rétablit le sélecteur Unity `plural`, qui ne doit pas être traduit. |
| PassiveAbilities | `9816540996943951` | Rétablit l’argument `{3}` et les balises de Temporisation. |
| PassiveAbilities | `9816540996943953` | Rétablit les arguments `{0}` à `{6}` et les balises de gameplay. |
| Relics | `11913064820228119` | Retire un argument `{1}` absent du texte English. |
| Items | `21745534101078102` | Rétablit la description de Furtivité et ses arguments `{0}`/`{1}`. |
| Relics | `21745596575236142` | Rétablit l’argument `{2}` de Temporisation. |
| PassiveAbilities | `83960963810713600` | Ajoute la clé française manquante « Attaque gagnée ». |

## Contrôles

- English : 3 919 clés ;
- French V2.1.2 : 3 919 clés ;
- aucune clé manquante ou supplémentaire ;
- mêmes métadonnées Smart String pour toutes les clés ;
- mêmes arguments de format et mêmes balises de gameplay ;
- 10 modifications déclarées, aucune autre entrée française modifiée ;
- English et Locales restent identiques à la V2.1.1 ;
- les catalogues changent uniquement aux huit octets CRC prévus.

La reconstruction est pilotée par `translations/corrections-v2.1.2.fr.json` et vérifiée par `tools/auditer_traduction_v212.ps1`.
