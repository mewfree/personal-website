---
title: "Comment importer automatiquement des données Facebook Ads dans Google Sheets?"
date: 2020-02-02
tags: ["facebook", "marketing", "api", "insights", "martech", "google spreadsheets", "spreadsheets", "google apps script"]
---

# Introduction
On sait tous à quel point les marketers aiment les feuilles de calcul. Elles sont polyvalentes, permettent de faire des analyses rapides et ne demandent aucune connaissance en programmation.

Elles servent aussi souvent de tableaux de bord internes pour mesurer et suivre la performance des publicités.

Mais saviez-vous qu'il est possible d'utiliser JavaScript pour faire rouler des scripts directement dans Google Sheets? Une fonctionnalité peu connue nous permet même d'écrire nos propres fonctions personnalisées qu'on peut ensuite utiliser dans n'importe quelle cellule de n'importe quel onglet.

C'est cette fonctionnalité de Google Apps Script qu'on va utiliser pour importer automatiquement nos données Facebook Ads directement dans nos feuilles de calcul.

# Comment accéder à Google Apps Script?
D'abord, créons une nouvelle feuille de calcul Google Sheets avec l'URL bien pratique [sheet.new](https://sheet.new), ou ouvrez votre tableau de bord marketing de tous les jours.

Vous devriez voir une feuille de calcul Google Sheets vide, comme ci-dessous.

![Feuille de calcul Google Sheets vide](/images/empty_sheet.png)

Ensuite, cliquez sur : __Extensions > Apps Script__

![Menu pour ouvrir l'éditeur de script](/images/script_editor_menu.png)

Une nouvelle fenêtre de navigateur devrait s'ouvrir et afficher l'éditeur de code (IDE) de Google Apps Script avec une fonction `myFunction` vide.

![Script vide dans Google Apps Script](/images/empty_script.png)

~~Notez que Google Apps Script ne prend pas en charge ES6, mais seulement d'anciennes versions de JavaScript.~~

Mise à jour : depuis l'introduction du moteur d'exécution V8 par Google dans Google Apps Script, il est [maintenant possible d'utiliser la syntaxe ECMAScript moderne](https://developers.google.com/apps-script/guides/v8-runtime#modern_ecmascript_syntax).

# Découvrir Google Apps Script
## « Hello, World! » dans Google Apps Script
Faisons un petit « Hello, World! » rapide dans Google Apps Script.

Une des principales différences avec du JavaScript classique, c'est que l'affichage dans les journaux (*logs*) ne se fait pas avec `console.log()`, mais plutôt avec `Logger.log()`.

Insérez `Logger.log('Hello, World');` dans la fonction de base :
```javascript
function myFunction() {
  Logger.log('Hello, World!');
}
```

Enregistrez 💾 ou utilisez le raccourci Ctrl/Cmd + S.

Ensuite, faites rouler le script ▶️.

Allez dans Afficher > Journaux (*View > Logs*) ou utilisez le raccourci Ctrl/Cmd + Entrée pour ouvrir la fenêtre des journaux.

Bravo, vous venez d'exécuter votre premier script Google Apps Script!
![Journaux affichant Hello World](/images/logs_hello_world_700.png)

## Exemple de base d'une fonction personnalisée
Créons une fonction personnalisée toute simple pour montrer comment on peut bâtir nos propres fonctions dans Google Sheets.

Remplacez le code dans l'éditeur Google Apps Script par ceci :
```javascript
function double(number) {
  return number * 2;
}
```

Le but de cette fonction est de retourner le double du nombre fourni en entrée.

Enregistrez 💾 et essayez votre nouvelle fonction dans votre feuille de calcul :
![Exemple de la fonction double dans Google Sheets](/images/double_example.gif)

Bravo, vous venez d'enrichir votre chiffrier avec la puissance de JavaScript!

## Comment faire une requête HTTP(S)
Passons maintenant aux choses sérieuses : faire des appels à des API externes.

On va utiliser [UrlFetchApp](https://developers.google.com/apps-script/reference/url-fetch/url-fetch-app) de Google Apps Script.

Voici l'exemple le plus basique d'une requête HTTP utilisant `UrlFetchApp` dans Google Apps Script :
```javascript
function FBInsights() {
  var response = UrlFetchApp.fetch('https://example.com');

  Logger.log(response.getContentText());
}
```

Enregistrez 💾 et vous devriez voir apparaître une demande d'autorisation, puisque c'est la première fois qu'on fait rouler un script capable d'interroger des données externes.

Cliquez sur __Examiner les autorisations__ (*Review Permissions*) lorsque la fenêtre s'affiche.

![Avertissement d'application non vérifiée](/images/unsafe_app_600.png)
Cliquez sur __Paramètres avancés__ (*Advanced*), puis sur __Accéder à {nom du projet} (non sécurisé)__ (*Go to {project name} (unsafe)*) — c'est sans danger puisque c'est vous qui avez créé le projet.

![Fenêtre de confirmation des autorisations](/images/this_will_allow_650.png)
Cliquez sur __Autoriser__ (*Allow*).

![Exemple de réponse HTML dans les journaux](/images/logs_example.png)
Comme vous pouvez le voir ci-dessus, on a récupéré toute la réponse HTML d'une requête GET vers `example.com`.

Passons maintenant à la vraie affaire avec l'API Facebook Insights.

# Interroger l'API Facebook Insights
## S'authentifier
L'API Facebook Marketing a besoin de vous authentifier pour que vous — et seulement vous — puissiez accéder à vos données.

Vous allez avoir besoin d'un jeton d'accès (*access token*). Vous pouvez lire mon article [Bien démarrer avec l'API Facebook Marketing](/blog/getting-started-with-facebook-marketing-api) pour savoir comment en obtenir un.

Exemple pour afficher dans les journaux les statistiques Facebook Insights d'hier :
```javascript
function FBInsights(entity_id) {
  var access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN';
  var url = 'https://graph.facebook.com/v16.0/'
    + entity_id
    + '/insights'
    + '?date_preset=yesterday'
    + '&access_token=' + access_token

  var response = UrlFetchApp.fetch(url);
  var json = response.getContentText();
  var data = JSON.parse(json);

  return data;
}

function run() {
  Logger.log(FBInsights('act_XXXXXXXXXXXXXXXX'));
}
```

Remarquez que comme la réponse de Facebook est en format JSON, on utilise `JSON.parse()` pour analyser la réponse.

N'oubliez pas de remplacer `access_token` par votre propre jeton d'accès et de mettre votre propre identifiant de compte Facebook lorsque `FBInsights()` est appelée dans `run()` (ou n'importe quel autre identifiant d'entité, comme un identifiant de campagne ou d'ensemble de publicités).

Une fonction `run()` est nécessaire pour envelopper la fonction `FBInsights()` afin de pouvoir l'exécuter avec des paramètres. N'oubliez pas de sélectionner `run()` comme fonction à exécuter avant de cliquer sur ▶️.
![Sélectionner la fonction run dans la barre d'outils](/images/change_function.png)

Ouvrez les Journaux (*Logs*) et vous devriez voir les données de votre entité pour la journée d'hier.
![Données d'hier dans les journaux](/images/yesterday_logs.png)

## Interroger avec des dates personnalisées
Ajustons notre script existant pour pouvoir utiliser une date personnalisée :

```javascript
function FBInsights(entity_id, date) {
  var access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN';
  var url = 'https://graph.facebook.com/v16.0/'
    + entity_id
    + '/insights'
    + '?time_range=' + encodeURIComponent(JSON.stringify({'since': date, 'until': date}))
    + '&access_token=' + access_token

  var response = UrlFetchApp.fetch(url);
  var json = response.getContentText();
  var data = JSON.parse(json);

  return data;
}

function run() {
  Logger.log(FBInsights('act_XXXXXXXXXXXXXXXX', '2020-01-20'));
}
```

L'API Facebook Insights attend un objet au format `{'since': YYYY-MM-DD, 'until': YYYY-MM-DD}` pour le paramètre `time_range`. On utilise `JSON.stringify()` pour transformer un objet JavaScript natif en JSON, qu'on encode ensuite avec `encodeURIComponent()`.

En mettant la même date dans `since` et `until`, on obtient les résultats pour cette journée précise.

## Choisir un champ
```javascript
function FBInsights(entity_id, date, field) {
  var access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN';
  var url = 'https://graph.facebook.com/v16.0/'
    + entity_id
    + '/insights'
    + '?time_range=' + encodeURIComponent(JSON.stringify({'since': date, 'until': date}))
    + '&fields=' + field
    + '&access_token=' + access_token

  var response = UrlFetchApp.fetch(url);
  var json = response.getContentText();
  var data = JSON.parse(json);

  return parseFloat(data['data'][0][field]);
}

function run() {
  Logger.log(FBInsights('act_XXXXXXXXXXXXXXXX', '2020-01-20', 'spend'));
}
```

Ce changement ajoute `field` comme paramètre de la fonction, inclut le paramètre de requête nécessaire dans l'URL et ajuste le `return` pour ne retourner que la valeur de ce champ précis, convertie en nombre décimal (`float`).

Pour en savoir plus sur tous les champs possibles, référez-vous à mon [Guide de l'API Facebook Insights](/blog/guide-facebook-insights-api).

# Démo finale
Vous pouvez maintenant utiliser `=FBInsights("entity_id", TEXT("date", "yyyy-mm-dd"), "field_name")` directement dans vos feuilles de calcul! `=TEXT()` est pratique pour convertir n'importe quelle date au format `YYYY-MM-DD` exigé par Facebook.

Voici un exemple pour récupérer les dépenses correspondant aux dates dans la colonne A. La formule que j'utilise dans l'exemple ci-dessous : `=FBInsights("REPLACE_BY_YOUR_ENTITY_ID", TEXT(A2, "yyyy-mm-dd"), "spend")`

![Dépenses par date dans Google Sheets](/images/spend_by_date.gif)

Maintenant, essayez-le vous-même avec différents champs (`clicks`, `impressions`...)!

P.-S. : Pour les besoins de cet article, j'ai ajouté `* Math.random()` dans mon instruction `return` pour multiplier mes dépenses par un nombre aléatoire afin de masquer mes vraies données de dépenses.

# Conclusion
Non seulement vous avez appris à créer votre propre fonction personnalisée dans Google Sheets, mais vous avez aussi appris à interroger l'API Facebook Marketing et l'API Insights. En combinant les deux, vous pouvez aller chercher vos données Facebook Ads directement depuis Google Sheets.

Si vous aimeriez faire quelque chose de similaire avec des données Google Ads, allez lire [Connecter les scripts Google Ads à Google Sheets](/blog/google-ads-google-spreadsheets).

N'hésitez pas à [me contacter](/about) si vous avez des questions à propos de cet article.
