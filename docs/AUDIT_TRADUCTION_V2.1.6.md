# Audit traduction V2.1.6

L’audit compare les tables English officielles de Guildrun 0.5.7 au payload French V2.1.6 reconstruit.

- English : `3 923` clés
- French V2.1.6 : `3 923` clés
- Clés ajoutées : `4`
- Clés manquantes ou supplémentaires : `0`
- Divergences Smart String, arguments ou balises : `0`

## Ajouts

| Table | ID | Français | Smart |
|---|---:|---|:---:|
| UI | 95887992982994944 | Victoires totales : {0} | oui |
| UI | 95887993016549376 | Meilleure série : {0} | oui |
| UI | 95887993033326592 | Meilleure série | non |
| UI | 95887993033326593 | Victoires totales | non |

Le manifeste `translations/corrections-v2.1.6.fr.json` déclare exactement ces quatre ajouts. La reconstruction les ordonne par ID pour produire un bundle déterministe.
