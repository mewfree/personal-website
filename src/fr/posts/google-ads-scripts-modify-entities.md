---
title: "Scripts Google Ads : modifier des entités"
date: 2018-03-31
tags: ["google ads", "adwords", "scripts", "scripts google ads", "scripts adwords", "modifier des entités", "modifier", "entités"]
---

# Comment modifier des entités à partir des scripts Google Ads?
Dans l'article [Scripts Google Ads : lire des données](/blog/google-ads-scripts-reading-data), on a vu comment lire des données dans un script Google Ads.
Maintenant, on va voir comment poser des actions et modifier des entités publicitaires (groupes d'annonces, mots-clés, annonces...).
Par exemple, ça nous permettrait d'automatiser l'optimisation récurrente qu'on fait peut-être chaque jour, chaque semaine ou chaque mois.

Voici quelques exemples :
- Parcourir tous les mots-clés et baisser le coût par clic (CPC) des mots-clés dont le coût par action (CPA) dépasse un certain seuil.
- Mettre à jour le texte de toutes les annonces qui correspondent à un certain modèle.
- etc.

On va mettre en place une version légèrement différente du premier exemple.

# Augmenter les enchères sur certains mots-clés
Imaginons qu'on a les poches profondes et qu'on veut rester en position 2 ou mieux en tout temps pour tous nos mots-clés.
D'abord, il va falloir trouver tous les mots-clés dont la position moyenne est pire que 2.
Ça devrait être facile à faire grâce à ce qu'on a appris dans le [tutoriel précédent](/blog/google-ads-scripts-reading-data).
Ensuite, on va augmenter les enchères de ces mots-clés d'un pourcentage arbitraire (+10 %) afin d'essayer de faire remonter la position moyenne à 2 ou mieux.

## Récupérer les mots-clés selon une position moyenne précise
Pour combiner la méthode `.withCondition()` avec une statistique (comme `Average Position`), il faut préciser une plage de dates avec `.forDateRange()`.
Google Ads fournit quelques plages prêtes à l'emploi comme `YESTERDAY`, `LAST_7_DAYS`, `LAST_30_DAYS`...
La liste complète des plages disponibles se trouve [ici](https://developers.google.com/adwords/scripts/docs/reference/adwordsapp/adwordsapp_keywordselector#forDateRange_2).
On peut aussi utiliser des dates personnalisées `dateFrom` et `dateTo` au format `YYYYMMDD` (exemple : `.forDateRange('20180401', '20180410')` pour les 10 premiers jours d'avril 2018).
Cette fois-ci, on va utiliser `LAST_7_DAYS`.
```javascript
function fetchingKeywords() {
  var keywords = AdsApp
      .keywords()
      .withCondition('AveragePosition > 2')
      .forDateRange('LAST_7_DAYS')
      .get();
}
```

Pour tester que la méthode `.withCondition()` fonctionne bien, on peut lire la position moyenne du résultat avec `keyword.getStatsFor('LAST_7_DAYS').getAveragePosition()`.
Évidemment, il faut utiliser la même plage de dates, sinon les résultats seraient différents.

```javascript
function fetchingKeywords() {
  var keywords = AdsApp
      .keywords()
      .withCondition('AveragePosition > 2')
      .forDateRange('LAST_7_DAYS')
      .get();

  while (keywords.hasNext()) {
    var keyword = keywords.next();
    Logger.log(keyword.getText());
    Logger.log(keyword.getStatsFor('LAST_7_DAYS').getAveragePosition());
  }
}

function main() {
  fetchingKeywords();
}
```

Ici, j'ai mis en commentaire le journal `keyword.getText()` pour protéger les renseignements confidentiels du client chez qui j'ai testé ce script, mais on voit bien que tous les mots-clés ont effectivement une position moyenne de 2 ou pire :
![Position moyenne des mots-clés](/images/keywords_avg_pos.png)

## Augmenter les CPC maximaux sur les mots-clés
Occupons-nous maintenant des enchères! C'est pas mal simple à faire avec `.bidding().setCpc()` sur l'entité `keyword`, mais d'abord, on a besoin du CPC maximal actuel pour calculer la nouvelle enchère (rappelez-vous qu'on veut augmenter les enchères de 10 %). On fait ça avec `.bidding().getCpc()`. Avec tout ça en main, la formule finale est très simple :
```javascript
  var new_bid = keyword.bidding().getCpc() * 1.1;
  keyword.bidding().setCpc(new_bid);
```

Tout ça aurait pu tenir sur une seule ligne, mais mettre l'enchère calculée dans sa propre variable rend le code plus lisible.

J'ai aussi changé le nom de notre fonction, puisqu'elle ne fait plus seulement récupérer les mots-clés : elle modifie aussi les enchères.

```javascript
function raiseBidsKeywords() {
  var keywords = AdsApp
      .keywords()
      .withCondition('AveragePosition > 2')
      .forDateRange('LAST_7_DAYS')
      .get();

  while (keywords.hasNext()) {
    var keyword = keywords.next();
    var new_bid = keyword.bidding().getCpc() * 1.1;
    keyword.bidding().setCpc(new_bid);
  }
}

function main() {
  raiseBidsKeywords();
}
```

Maintenant, si vous cliquez sur le bouton **Aperçu** (*Preview*), vous verrez pour la première fois des éléments apparaître dans la section __Modifications__ (*Changes*)! Ne vous inquiétez pas, aucun changement n'a encore été effectué : Google Ads vous montre seulement ce que seraient les modifications si vous exécutiez réellement le script.
![Aperçu des modifications sur les mots-clés](/images/keywords_change.png)

La dernière étape consiste à cliquer sur __Exécuter__ (*Run*) au lieu d'Aperçu. Faites attention : ça va vraiment modifier les CPC maximaux dans votre compte réel.

__Félicitations, votre script Google Ads a effectué des modifications en votre nom!__

Maintenant qu'on est satisfaits de notre script, comme il se base sur les données des 7 derniers jours, ce ne serait pas pratique qu'il roule automatiquement chaque semaine? Dans la liste des scripts Google Ads, vous pouvez régler la fréquence sur hebdomadaire (*Weekly*) et choisir le jour de la semaine et l'heure qui vous conviennent :
![Changement de fréquence d'exécution](/images/frequency_change.png)
