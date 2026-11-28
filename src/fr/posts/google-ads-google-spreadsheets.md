---
title: "Connecter les scripts Google Ads à Google Sheets"
date: 2018-05-10
tags: ["google ads", "adwords", "scripts", "scripts google ads", "scripts adwords", "google sheets", "feuilles de calcul", "connexion"]
---

Aujourd'hui, on va découvrir un des outils les plus puissants des scripts Google Ads : pouvoir lire et écrire des données depuis et vers Google Sheets. C'est sans aucun doute une de mes fonctionnalités préférées et j'ai vraiment hâte de vous partager ça.

# Comment lire des données Google Sheets à partir des scripts Google Ads
## Ouvrir notre feuille de calcul
La première étape pour lire des données Google Sheets, c'est de choisir avec quelle feuille de calcul on veut travailler 🙂.
Avec un peu de chance, vous avez déjà un projet ou un chiffrier précis en tête.

Vous pouvez ouvrir une feuille de calcul soit par son identifiant (ID), soit par son URL :
- `SpreadsheetApp.openByID();`
- `SpreadsheetApp.openByUrl();`

Il n'y a aucune différence entre les deux, mais j'ai une petite préférence pour la deuxième option, que je trouve plus simple et plus naturelle.

Allons-y tout de suite. Pour les besoins de ce tutoriel, je vais utiliser cette feuille de calcul comme exemple : [https://docs.google.com/spreadsheets/d/1ARKwW\_kAf8rJJ9\_XP4kl\_\_kc56inghZdBtNrClfRlvc/edit](https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit).

```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );
  Logger.log(spreadsheet.getName());
}
```

Si vous exécutez ou prévisualisez ce code dans les scripts Google Ads, vous remarquerez qu'il faut accorder des autorisations supplémentaires pour que le script puisse rouler :
![Nouvelles autorisations](/images/scripts_permissions.png)

Une fois que c'est fait, vous devriez pouvoir voir le nom de votre feuille de calcul dans les journaux (*Logs*).
![Nom de la feuille de calcul dans les journaux](/images/spreadsheet_name_log.png)

## Sélectionner un onglet
Une feuille de calcul peut contenir plusieurs onglets (feuilles). On peut sélectionner un onglet soit par son nom (`spreadsheet.getSheetByName('sheet_name')`), soit par sa position (`spreadsheet.getSheets()[0]` pour le premier onglet, `spreadsheet.getSheets()[1]` pour le deuxième...).

Je vais utiliser `.getSheetByName()` pour que mon script continue de fonctionner même si je réorganise l'ordre des onglets.

```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );

  Logger.log(spreadsheet.getName());

  var sheet = spreadsheet.getSheetByName('read');
  Logger.log(sheet.getSheetName());
}
```

Ça devrait afficher `read` dans les journaux, puisque c'est l'onglet qu'on a sélectionné et sur lequel on travaille en ce moment 👍.

## Lire des valeurs
Encore une fois, plusieurs options s'offrent à nous!

Une solution pas mal directe consiste à utiliser `sheet.getSheetValues(startRow, startColumn, numRows, numColumns)`. Gardez en tête que la numérotation des lignes et des colonnes commence à 1 dans les feuilles de calcul. Une valeur de -1 correspond à la dernière ligne ou à la dernière colonne contenant des données. Donc, pour récupérer les valeurs d'un onglet au complet, on ferait ceci : `sheet.getSheetValues(1, 1, -1, -1)`.

Une autre solution consiste à utiliser `.getRange()` suivi de `.getValues()` pour une sélection en grille, ou `.getValue()` pour une seule cellule (ou la première cellule de la plage). Cette fonction accepte un nombre flexible d'arguments :
- `.getRange(a1Notation)` : utilise la même notation que dans une formule de feuille de calcul, ce qui est peut-être le plus naturel pour vous. Exemples : `sheet.getRange('A1').getValue()` vous donne le contenu de la première cellule (A1), `sheet.getRange('A1:A5').getValues()` vous donne le contenu des 5 premières lignes de la première colonne, `sheet.getRange('A1:C10').getValues()` vous donne le contenu de la grille `A1:C10`.
- `.getRange(row, column)` : pour une seule cellule. Exemple : `sheet.getRange(1, 1).getValue()` pour obtenir la valeur de la première cellule (première colonne, première ligne) de l'onglet. Ça correspond à la cellule A1.
- `.getRange(row, column, numRows)` : pour une sélection « verticale ». Exemple : `sheet.getRange(2, 1, 4).getValues()` pour obtenir les valeurs de la première colonne, à partir de la deuxième ligne jusqu'à la ligne 5.
- `.getRange(row, column, numRows, numColumns)` : même principe que pour `.getSheetValues`.

## Exemple concret
Vous vous souvenez de mes faux ateliers de réparation de vélos dans l'article [Scripts Google Ads : créer des annonces par programmation](/blog/google-ads-scripts-create-ads)?

J'avais codé en dur la liste des ateliers et des villes directement dans le script, mais maintenant on serait capable de lire ces données directement à partir d'une feuille de calcul!

Dans ma [feuille de calcul d'exemple](https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit), j'ai des données dans A1:C6 avec le nom de l'atelier dans la colonne A, le nom de la ville dans la colonne B et la population de la ville dans la colonne C, ainsi que des en-têtes sur la première ligne. Lisons tout ça :
```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );

  var sheet = spreadsheet.getSheetByName('read');

  var data = sheet.getSheetValues(2, 1, -1, -1);
  Logger.log(data);
}
```

Résultat :
```
[[NYCycle, New York City, 2.0320876E7], [Angel'bikes, Los Angeles, 1.3131431E7], [Chicago Bike Shop, Chicago, 9512999.0], [Houston Cycle, Houston, 6313158.0], [Phillie Bikes, Philadelphia, 6096120.0]]
```

Comme vous pouvez le voir, on a reçu un tableau de tableaux. Parcourons le tableau principal en boucle et assignons les valeurs pour rendre tout ça plus simple :
```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );

  var sheet = spreadsheet.getSheetByName('read');

  var data = sheet.getSheetValues(2, 1, -1, -1);

  data.forEach(function(row) {
    var city = row[1];
    Logger.log(city);
  });
}
```

Résultat :
```
New York City
Los Angeles
Chicago
Houston
Philadelphia
```

Génial! Il serait maintenant possible de combiner ce script avec celui de mon article [Scripts Google Ads : créer des annonces par programmation](/blog/google-ads-scripts-create-ads) pour créer des annonces automatiquement à partir des données d'une feuille de calcul!

# Comment écrire des données des scripts Google Ads vers Google Sheets
Je vais réutiliser les notions vues dans [Scripts Google Ads : lire des données](/blog/google-ads-scripts-reading-data) pour lire les données des groupes d'annonces d'une campagne précise et les écrire dans notre [feuille de calcul d'exemple](https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit).

Mettons d'abord toutes ces données dans un tableau. On peut parcourir la liste des groupes d'annonces en boucle et ajouter chaque nom de groupe d'annonces et ses statistiques dans le tableau. J'ai initialisé le tableau de données avec les en-têtes de colonnes.

```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );

  var sheet = spreadsheet.getSheetByName('write');

  var adGroups = AdsApp
    .adGroups()
    .withCondition('CampaignName = "united_states-cities"')
    .get();

  var data = [['ad group name',
               'yesterday impressions',
               'yesterday clicks',
               'yesterday avg CPC',
               'yesterday cost'
              ]];

  while (adGroups.hasNext()) {
    var adGroup = adGroups.next();
    data.push([
      adGroup.getName(),
      adGroup.getStatsFor('YESTERDAY').getImpressions(),
      adGroup.getStatsFor('YESTERDAY').getClicks(),
      adGroup.getStatsFor('YESTERDAY').getAverageCpc(),
      adGroup.getStatsFor('YESTERDAY').getCost()
    ]);
  }

  Logger.log(data);
}
```

`.getStatsFor(date_range)` est une méthode pratique pour obtenir des statistiques sur une plage de dates précise. D'autres plages comme `LAST_7_DAYS` ou `LAST_MONTH` peuvent être utilisées.

Résultat :
```
[[ad group name, yesterday impressions, yesterday clicks, yesterday avg CPC, yesterday cost], [philadelphia, 0, 0, 0.0, 0.0], [chicago, 0, 0, 0.0, 0.0], [los_angeles, 0, 0, 0.0, 0.0], [houston, 0, 0, 0.0, 0.0], [new_york_city, 0, 0, 0.0, 0.0]]
```

Ces données proviennent d'une campagne en pause, donc toutes les statistiques sont à 0, mais vous devriez voir vos vrais chiffres. Nos données sont maintenant bien structurées. La dernière étape consiste à écrire les données dans l'onglet en ajoutant `.setValues()` à la fin.

## Script final
```javascript
function main() {
  var spreadsheet = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/1ARKwW_kAf8rJJ9_XP4kl__kc56inghZdBtNrClfRlvc/edit'
  );

  var sheet = spreadsheet.getSheetByName('write');

  var adGroups = AdsApp
    .adGroups()
    .withCondition('CampaignName = "united_states-cities"')
    .get();

  var data = [['ad group name',
               'yesterday impressions',
               'yesterday clicks',
               'yesterday avg CPC',
               'yesterday cost'
              ]];

  while (adGroups.hasNext()) {
    var adGroup = adGroups.next();
    data.push([
      adGroup.getName(),
      adGroup.getStatsFor('YESTERDAY').getImpressions(),
      adGroup.getStatsFor('YESTERDAY').getClicks(),
      adGroup.getStatsFor('YESTERDAY').getAverageCpc(),
      adGroup.getStatsFor('YESTERDAY').getCost()
    ]);
  }

  Logger.log(data);

  sheet
    .getRange(1, 1, data.length, data[0].length)
    .setValues(data);
}
```

J'utilise la longueur du tableau et la longueur du premier élément du tableau pour savoir automatiquement quelle plage sélectionner, puisque la « grille » de données et la plage doivent être exactement de la même taille.

Petit avertissement : même en prévisualisant le script (*Preview*), les données seront réellement écrites dans la feuille de calcul! Alors soyez prudent.

## Résultat dans la feuille de calcul
![Résultat dans l'onglet write](/images/write_sheet_result.png)

C'est vraiment pratique si vous souhaitez avoir votre propre tableau de bord personnalisé directement dans Google Sheets. Si vous voulez que ces données soient mises à jour automatiquement chaque jour, je vous suggère d'activer les mises à jour quotidiennes grâce à la fonction de fréquence disponible sur la page d'accueil des scripts Google Ads :
![Fréquence quotidienne](/images/daily_frequency.png)

**Votre feuille de calcul sera maintenant mise à jour chaque jour à l'heure de votre choix avec les données de vos campagnes et groupes d'annonces!**

**Merci de votre lecture et n'hésitez pas à me contacter si vous avez des suggestions ou des remarques.**
