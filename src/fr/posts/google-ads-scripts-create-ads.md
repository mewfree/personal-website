---
title: "Scripts Google Ads : créer des annonces par programmation"
date: 2018-04-20
tags: ["google ads", "adwords", "scripts", "scripts google ads", "scripts adwords", "automatisation", "programmation", "créer des entités", "créer des groupes d'annonces", "créer des mots-clés", "créer des annonces"]
---

# Comment créer des entités à partir des scripts Google Ads
Aujourd'hui, je vais vous présenter un nouveau concept des scripts Google Ads : les `Builders` (constructeurs)!
Pour une raison qui m'échappe, les constructeurs sont disponibles pour les groupes d'annonces, les mots-clés et les annonces, mais pas pour les campagnes...
Par contre, je vous partagerai peut-être quelques trucs plus tard pour contourner ça 😉.

__Pour les besoins de ce tutoriel, imaginons qu'on possède des ateliers de réparation de vélos dans toutes les grandes villes des États-Unis et qu'on veut générer automatiquement des annonces pour chaque atelier.__

Commençons avec un nouveau script. Personnellement, je vais l'appeler « new US cities ».

# Construire les groupes d'annonces
Pour créer un nouveau groupe d'annonces, il faut d'abord sélectionner une campagne. Les campagnes peuvent être sélectionnées par identifiant (ID) ou par nom de campagne.

J'ai pris les devants et créé manuellement une nouvelle campagne sur le Réseau de Recherche appelée `united_states-cities`, puisque Google Ads ne nous permet pas encore de créer une campagne par script. Vous pouvez aussi utiliser une campagne existante.

Si vous connaissez l'identifiant de votre campagne (vous pouvez ajouter `ID de campagne` / `campaign ID` comme colonne dans l'interface Google Ads), c'est la façon la plus sûre de sélectionner une campagne tout en étant certain de ne rien sélectionner d'autre (ce qui pourrait arriver si vous avez des campagnes aux noms semblables).
```javascript
var campaign = AdsApp.campaigns()
    .withIds([1374655888])
    .get()
    .next();
```

Sélectionner une campagne par son nom (moins sûr, mais plus lisible pour un humain) :
```javascript
var campaign = AdsApp.campaigns()
    .withCondition("Name = 'united_states-cities'")
    .withLimit(1)
    .get()
    .next();
```
J'ai glissé un `.withLimit(1)` là-dedans juste pour être sûr qu'on sélectionne une seule campagne.

Une fois qu'on a sélectionné la campagne dans laquelle on veut créer nos nouveaux groupes d'annonces, voici comment on en ajoute un nouveau :
```javascript
var campaign = AdsApp.campaigns()
    .withCondition("Name = 'united_states-cities'")
    .withLimit(1)
    .get()
    .next();

 var adGroupBuilder = campaign.newAdGroupBuilder();

 adGroupOperation = adGroupBuilder
    .withName('Ad group name')
    .withStatus('PAUSED')
    .build();
```

J'ai ajouté `.withStatus('PAUSED')` par mesure de sécurité, question d'avoir le temps de réviser ce qu'on crée avant la mise en ligne!

Si vous faites un aperçu du script ci-dessus dans votre fonction `main()`, vous devriez voir quelque chose apparaître pour la première fois dans la section **MODIFICATIONS** (*CHANGES*) :
![Aperçu du constructeur de groupe d'annonces](/images/ag_builder_preview.png)

Comme toujours, c'est ce que notre script Google Ads ferait s'il était réellement exécuté.

En tant que faux propriétaire d'ateliers de réparation de vélos pour ce tutoriel, j'ai une liste de villes où mes ateliers sont situés et pour lesquelles je veux faire de la publicité sur Google Search. En JavaScript, les listes (appelées tableaux ou *arrays*) se définissent comme ceci : `var cities = ['New York City', 'Los Angeles', 'Chicago', 'Houston', 'Philadelphia'];`

Il est aussi possible de lire une liste de ce genre à partir d'une feuille de calcul Google Sheets, mais je garde ça pour un autre tutoriel 😉.

On voudrait probablement créer un groupe d'annonces pour chacune de ces villes :
```javascript
  var campaign = AdsApp.campaigns()
      .withCondition("Name = 'united_states-cities'")
      .withLimit(1)
      .get()
      .next();

  var adGroupBuilder = campaign.newAdGroupBuilder();

  var cities = ['New York City', 'Los Angeles', 'Chicago', 'Houston', 'Philadelphia'];

  cities.forEach(function(city) {
    adGroupBuilder
      .withName(city)
      .withStatus('PAUSED')
      .build();
  });
```

Bon, tout ça est bien beau, mais si vous aimez la standardisation autant que moi, vous allez vouloir des noms de groupes d'annonces plus faciles à traiter par ordinateur — par exemple `new_york_city` plutôt que `New York City`. On peut simplement convertir le nom en minuscules et remplacer les espaces par des traits de soulignement (`city.toLowerCase().replace(/ /g, '_')`).
![Aperçu des groupes d'annonces par ville](/images/ag_builder_cities_preview.png)

# 🙌

# Ajouter des mots-clés à nos groupes d'annonces
Les mots-clés se construisent avec la même technique que les groupes d'annonces, à quelques particularités près : ils comportent aussi une enchère (habituellement un CPC) et une URL, si celle-ci n'est pas définie au niveau de l'annonce.
```javascript
 var keywordOperation = adGroup.newKeywordBuilder()
    .withText('keyword')
    .withCpc(0.5)
    .withFinalUrl('https://www.example.com')
    .build();
 var keyword = keywordOperation.getResult();
 ```

On a quelques façons différentes d'ajouter des mots-clés aux groupes d'annonces qu'on vient de créer. Après la création de chaque groupe d'annonces, on peut y ajouter les mots-clés tout de suite, ou bien attendre que tous les groupes d'annonces soient créés avant de les sélectionner et d'ajouter tous les mots-clés d'un coup.

J'ai choisi de suivre la première solution, mais tout est possible!

D'abord, il va falloir modifier un peu notre script précédent pour récupérer le « résultat » (le groupe d'annonces nouvellement créé) grâce à `.getResult()`. Ensuite, il faut décider quels mots-clés on veut ajouter. C'est une bonne idée d'utiliser des modificateurs de requête large (parfois abrégés BMM, pour *broad match modifiers*), puisque Google Ads peut être un peu trop zélé avec les mots-clés en requête large ordinaires. Voici une courte liste en prenant Chicago comme exemple :
- +bike +repair +chicago
- +bike +repair +shop +chicago
- +bike +shop +chicago

Certains mots-clés peuvent se chevaucher, mais on va maximiser notre niveau de qualité (*Quality Score*) et remporter le plus d'enchères au CPC de cette façon.

Ça n'a pas l'air trop compliqué, sauf que beaucoup de noms de villes américaines contiennent des espaces (et je ne parle même pas des noms de villes francophones avec des traits d'union comme Aix-en-Provence en France ou Saint-Jérôme au Québec), mais j'ai un truc pour gérer ça. En ajoutant un `+` devant notre mot-clé et en remplaçant chaque espace par `[espace]+`, on devrait obtenir notre mot-clé avec modificateurs de requête large.

Exemple : `Logger.log('+' + 'bike repair Chicago'.replace(/ /g, ' +'));` nous donne `+bike +repair +chicago`!

Je ne veux pas me répéter, alors je vais mettre mes mots-clés dans une liste qu'on peut parcourir en boucle.

Notez aussi que je ne vais pas inclure tout le code à chaque fois : je vais remplacer les morceaux manquants par « (...) ». Je mettrai une version finale complète à la fin du tutoriel, alors ne vous inquiétez pas.

```javascript
(...)

cities.forEach(function(city) {
  var adGroupOperation = adGroupBuilder
    .withName(city.toLowerCase().replace(/ /g, '_'))
    .withStatus('PAUSED')
    .build();

  var adGroup = adGroupOperation.getResult();

  var keywords = [
    'bike repair ' + city,
    'bike repair shop ' + city,
    'bike shop ' + city
  ];

  keywords.forEach(function(keyword) {
    adGroup.newKeywordBuilder()
      .withText('+' + keyword.toLowerCase().replace(/ /g, ' +'))
      .withCpc(1.5) // $/€/£1.50 bid as a placeholder
      .withFinalUrl('https://www.example.com')
      .build();
  });
});

(...)
```

Jetez maintenant un coup d'œil aux résultats de l'aperçu.

![Aperçu du constructeur de mots-clés](/images/kw_builder_preview.png)

# 😍

Parmi les améliorations possibles à cette partie du script, on pourrait inclure plus de mots-clés (comme « bicycle shop » au lieu de seulement « bike shop ») ainsi que des mots-clés en expression exacte (*phrase match*) et en mot-clé exact (*exact match*), mais vous devriez être capable de trouver comment faire 😉. Rappelez-vous que Google Ads déduit le type de correspondance à partir du texte du mot-clé : par exemple, `"bike repair shop chicago"` est une expression exacte et `[bike repair shop chicago]` est un mot-clé exact. Il suffit donc d'ajouter des guillemets doubles ou des crochets autour de notre modèle de mot-clé, et le tour est joué!

# Toute campagne publicitaire a besoin... d'annonces textuelles grand format
Vous connaissez la routine maintenant! Les annonces textuelles grand format (*Expanded Text Ads*) ont leur propre constructeur :
```javascript
 var adOperation = adGroup.newAd().expandedTextAdBuilder()
    .withHeadlinePart1('First ad headline')
    .withHeadlinePart2('Second ad headline')
    .withDescription('Ad description')
    .withPath1('path1')
    .withPath2('path2')
    .withFinalUrl('https://www.example.com')
    .build();
 var ad = adOperation.getResult();
```

Quelques trucs à garder en tête :
- Chaque titre a une limite de 30 caractères
- La ligne de description a une limite de 80 caractères

Après quelques ajustements, voici à quoi ressemble notre script final :
```javascript
function main() {
  var campaign = AdsApp.campaigns()
      .withCondition("Name = 'united_states-cities'")
      .withLimit(1)
      .get()
      .next();

  var adGroupBuilder = campaign.newAdGroupBuilder();

  var cities = [
    'New York City',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Philadelphia'
  ];

  cities.forEach(function(city) {
    var adGroupOperation = adGroupBuilder
      .withName(city.toLowerCase().replace(/ /g, '_'))
      .withStatus('PAUSED')
      .build();

    var adGroup = adGroupOperation.getResult();

    var keywords = [
      'bike repair ' + city,
      'bike repair shop ' + city,
      'bike shop ' + city
    ];

    keywords.forEach(function(keyword) {
      adGroup.newKeywordBuilder()
        .withText('+' + keyword.toLowerCase().replace(/ /g, ' +'))
        .withCpc(1.5)
        .withFinalUrl('https://www.example.com')
        .build();
    });

    adGroup.newAd().expandedTextAdBuilder()
      .withHeadlinePart1(city + ' Bike Repair Shop')
      .withHeadlinePart2('Fast & professional')
      .withDescription('Repair Your Bike Here & Buy Accessories. ' +
                       'Book Your Appointment Now!')
      .withPath1('bike-repair')
      .withPath2(city.toLowerCase().replace(/ /g, '_'))
      .withFinalUrl('https://www.example.com')
      .build()
  });
}
```

Allez-y et exécutez-le après vous être assuré qu'aucune erreur ne se produit pendant l'aperçu.

# Résultats

## Liste des mots-clés :
![Résultat des mots-clés](/images/keywords_result.png)

## Liste des annonces :
![Résultat des annonces](/images/ads_result.png)

C'est quand même impressionnant d'avoir créé ces annonces automatiquement. Ça ne demanderait presque aucun effort pour étendre le tout à n'importe quel nombre de villes! La dernière étape consiste à réactiver vos groupes d'annonces dès que vous êtes prêt à lancer 🚀.
