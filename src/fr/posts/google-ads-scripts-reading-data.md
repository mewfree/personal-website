---
title: "Scripts Google Ads : lire des données"
date: 2018-03-22
tags: ["google ads", "adwords", "scripts", "scripts google ads", "scripts adwords", "lire des données", "données", "lecture"]
---

# Comment lire des données à partir des scripts Google Ads?
Dans l'article [Brève introduction aux scripts Google Ads](/blog/brief-introduction-to-google-ads-scripts), on a vu comment créer notre premier script Google Ads. Maintenant, on va essayer d'en faire quelque chose d'utile. Une des premières étapes, c'est d'apprendre à lire les données de nos campagnes à partir des scripts Google Ads.

## Obtenir la liste des campagnes actives
Pour obtenir une liste de campagnes, on va utiliser [`AdsApp.CampaignSelector`](https://developers.google.com/adwords/scripts/docs/reference/adwordsapp/adwordsapp_campaignselector). Comme premier exemple tout simple, on va essayer de récupérer toutes nos campagnes *actives*.

Tout d'abord, pour structurer un peu notre code, on va créer une fonction à l'extérieur de `main()`. On peut l'appeler `getAllActiveCampaigns()` et la déclarer comme ceci : `function getAllActiveCampaigns() {}`. Rappelez-vous que seul ce qui se trouve dans `main()` s'exécute; il faudra donc appeler `getAllActiveCampaigns()` à l'intérieur plus tard, mais on va l'omettre pour l'instant.

`AdsApp.campaigns().get()` va récupérer *toutes* les campagnes. Si on veut pouvoir réutiliser ce résultat, il faut le stocker dans une variable :

```javascript
function getAllActiveCampaigns() {
  var campaigns = AdsApp.campaigns().get();
}
```

Mais rappelez-vous qu'on veut seulement les campagnes *actives*. On peut utiliser `.withCondition()` pour ajouter un filtre :

```javascript
function getAllActiveCampaigns() {
  var campaigns = AdsApp
      .campaigns()
      .withCondition('Status = ENABLED')
      .get();
}
```

Remarquez l'indentation sur plusieurs lignes pour améliorer la lisibilité. C'est 100 % facultatif, mais fortement recommandé.

D'autres exemples de conditions pourraient être : `.withCondition('Impressions > 1000')`, `.withCondition("Name CONTAINS 'Canada'")`... Ces conditions peuvent aussi être enchaînées les unes après les autres.

Pour nous faciliter la vie, Google Ads retourne quelques méthodes utilitaires avec la liste des campagnes récupérées. Ça peut être très pratique pour parcourir les résultats en boucle. Voici un exemple avec une boucle `while() {}`, combinée aux méthodes `.next()` et `.hasNext()` des scripts Google Ads :
```javascript
function getAllActiveCampaigns() {
  var campaigns = AdsApp
      .campaigns()
      .withCondition('Status = ENABLED')
      .get();

  while (campaigns.hasNext()) {
    var campaign = campaigns.next();
  }
}
```

Si vous essayez de faire rouler ce code maintenant, il ne fera rien, parce que la boucle est essentiellement vide. Affichons le nom de la campagne dans les journaux : `Logger.log(campaign.getName());`.

Essayons d'aller un peu plus loin. On peut facilement récupérer le budget d'une campagne avec `.getBudget()`, mais cette méthode retourne seulement un nombre entier (par exemple, pour un budget de 100 $, la réponse sera 100). On va donc aussi récupérer le code de devise. `AdsApp.currentAccount().getCurrencyCode()` devrait faire l'affaire!

Voici le résultat final :
```javascript
function getAllActiveCampaigns() {
  var campaigns = AdsApp
      .campaigns()
      .withCondition('Status = ENABLED')
      .get();

  while (campaigns.hasNext()) {
    var campaign = campaigns.next();
    Logger.log(campaign.getName());
    Logger.log('Daily Budget: ' + campaign.getBudget() + AdsApp.currentAccount().getCurrencyCode());
  }
}

function main() {
  getAllActiveCampaigns();
}
```

Dans l'interface des scripts Google Ads, vos campagnes *actives* ainsi que leurs budgets respectifs devraient apparaître :
![Résultat final](/images/final_result.png)

(Évidemment, vos propres résultats seront différents des miens 😊).

## Obtenir une liste de groupes d'annonces
Avec ce qu'on vient d'apprendre sur la lecture des campagnes ci-dessus, obtenir une liste de groupes d'annonces va être vraiment facile. Il suffit de remplacer `AdsApp.campaigns()` par `AdsApp.adGroups()` ainsi que quelques noms de variables.
```javascript
function getAllAdGroups() {
  var adGroups = AdsApp
      .adGroups()
      .get();

  while (adGroups.hasNext()) {
    var adGroup = adGroups.next();
    Logger.log(adGroup.getName());
  }
}
```

Comme les budgets sont définis au niveau des campagnes, vous auriez une erreur en essayant d'exécuter `adGroup.getBudget()`; je l'ai donc simplement omis ici.
![Résultat des groupes d'annonces](/images/ag_result.png)

## Obtenir la liste des annonces dans un groupe d'annonces
Même chose pour les annonces : on peut simplement remplacer `AdsApp.adGroups()` par `AdsApp.ads()`. Mais faisons les choses un peu différemment cette fois-ci. Allons chercher les annonces qui se trouvent dans un groupe d'annonces précis.

On peut tout simplement sélectionner un groupe d'annonces par son nom avec `.withCondition()`. La condition `if (adGroup.hasNext()) {}` est présente au cas où notre « recherche » ne retournerait aucun groupe d'annonces. Ensuite, on peut afficher dans les journaux la première et la deuxième partie du titre (dans le cas des annonces textuelles grand format).
```javascript
function getAdsInAdGroup() {
  var adGroup = AdsApp
      .adGroups()
      .withCondition("Name = 'Ad Group #1'")
      .get();

  if (adGroup.hasNext()) {
    var ads = adGroup.next().ads().get();
    while (ads.hasNext()) {
      var ad = ads.next();
      Logger.log(ad.getHeadlinePart1());
      Logger.log(ad.getHeadlinePart2());
    }
  }
}
```

__Vous devriez maintenant être à l'aise pour lire des campagnes, des groupes d'annonces et des annonces avec les scripts Google Ads!__
