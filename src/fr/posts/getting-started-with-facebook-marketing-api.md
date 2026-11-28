---
title: "Bien démarrer avec l'API Facebook Marketing"
date: 2019-02-20
tags: ["facebook", "marketing", "api", "facebook marketing api", "martech"]
---

# Qu'est-ce que l'API Facebook Marketing?
L'API Facebook Marketing est une façon de créer, lire, modifier et supprimer automatiquement des campagnes, des ensembles de publicités, des publicités, des créatifs et plus encore sur la plateforme publicitaire de Facebook — qui couvre le fil d'actualité Facebook, Facebook Messenger, Instagram (stories et fil), etc. — à partir de votre langage de programmation préféré.

[En savoir plus sur le site de Facebook](https://developers.facebook.com/docs/marketing-apis/).

# Générer un jeton d'accès
Rendez-vous sur [https://developers.facebook.com/docs/marketing-apis/](https://developers.facebook.com/docs/marketing-apis/) et suivez les étapes pour créer une nouvelle application publicitaire (*Ads App*). Assurez-vous de sélectionner « Implement Marketing API » et « Get Started with the Ads Insights API », comme montré ci-dessous.

![Interface de choix de scénario pour une nouvelle application Facebook](/images/create_new_fb_app.png)

Vous devriez ensuite pouvoir accéder à la page de votre application à l'adresse [https://developers.facebook.com/apps/](https://developers.facebook.com/apps/).

Allez dans Paramètres > Général (*Settings > Basic*). Copiez et collez votre identifiant d'application (*App ID*) et votre clé secrète (*App Secret*) en lieu sûr.

![Paramètres généraux de l'application Facebook](/images/fb_settings_basic.png)

Allez dans Produits > Marketing API > Outils (*Products > Marketing API > Tools*). Sélectionnez `ads_management` et `ads_read`. Cliquez sur Obtenir un jeton (*Get Token*). Votre jeton d'accès va apparaître à l'écran. Copiez-le et collez-le en lieu sûr.

![Produits Marketing API Outils](/images/fb_marketingapi_tools.png)

Vous allez avoir besoin de ces identifiants tout au long de ce tutoriel. Assurez-vous que personne d'autre ne puisse avoir accès à votre jeton d'accès, puisqu'il peut servir à lire, créer, modifier et supprimer n'importe quelle publicité dans vos comptes publicitaires.

# Notre première requête à l'API Facebook Marketing
Une excellente façon d'interagir avec l'API Facebook Marketing, c'est de passer par le paquet Python officiel [`facebook-python-business-sdk`](https://github.com/facebook/facebook-python-business-sdk). D'autres paquets similaires existent pour Ruby, Node.js, etc., mais je vais utiliser Python dans ce tutoriel.

Vous pouvez installer le paquet en exécutant `pip3 install facebook_business` dans un terminal (le paquet était auparavant distribué sous le nom `facebookads`, alors assurez-vous d'utiliser la version plus récente `facebook_business`). Si vous n'avez pas d'expérience avec `pip`, je vous suggère de jeter un coup d'œil à [la documentation officielle de Python sur l'installation de paquets](https://packaging.python.org/tutorials/installing-packages/).

Voici un exemple de code qui montre l'authentification de base avec l'API et qui affiche la liste de vos comptes publicitaires Facebook.

```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.user import User

app_id = 'REPLACE_BY_YOUR_APP_ID'
app_secret = 'REPLACE_BY_YOUR_APP_SECRET'
access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN'

FacebookAdsApi.init(app_id, app_secret, access_token)

me = User(fbid='me')
my_accounts = list(me.get_ad_accounts())
print(my_accounts)
```

Enregistrez ce script sous `index.py` (par exemple) et faites-le rouler. Vous devriez voir quelque chose de similaire apparaître dans votre terminal :

![Récupération des comptes publicitaires Facebook](/images/get_fb_accounts.png)

🚀 Bravo! Vous venez de faire rouler votre premier script basé sur l'API Facebook Marketing.

(Bien sûr, j'ai plusieurs comptes publicitaires Facebook, mais c'est parfaitement normal si vous n'en avez qu'un seul.)

Ce n'est pas encore super excitant puisqu'on n'accède qu'à des renseignements de base pour l'instant, mais restez à l'affût pour d'autres articles sur ce blog à propos de tout ce que vous pouvez faire avec l'API Facebook Marketing.
