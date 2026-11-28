---
title: "Guide de l'API Facebook Insights"
date: 2019-07-14
tags: ["facebook", "marketing", "api", "insights", "martech"]
---

# Qu'est-ce que l'API Facebook Insights?
L'API Facebook Insights, c'est ce qui nous permet d'interroger les résultats provenant de la plateforme publicitaire de Facebook.
Elle inclut essentiellement n'importe quel type de statistique qu'on retrouve dans le Gestionnaire de publicités Facebook.

Dans la suite de l'article [Bien démarrer avec l'API Facebook Marketing](/blog/getting-started-with-facebook-marketing-api), on va utiliser le paquet Python `facebook-python-business-sdk`. Référez-vous à cet article pour obtenir votre `app id`, votre `app secret` et votre `access token` (jeton d'accès).

Note : je vais remplacer les renseignements confidentiels par des astérisques (`*`) dans les exemples de code ci-dessous.

# Récupération de données de base
## Récupération de données au niveau du compte
La façon la plus simple d'obtenir des « insights » (statistiques) à partir de l'API Facebook ressemble à ceci :
```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

app_id = 'REPLACE_BY_YOUR_APP_ID'
app_secret = 'REPLACE_BY_YOUR_APP_SECRET'
access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN'

FacebookAdsApi.init(app_id, app_secret, access_token)

insights = AdAccount('act_****************').get_insights()

print(insights)
```

Par contre, comme vous pouvez le voir, on n'a précisé aucune plage de dates, aucune colonne et aucune répartition (*breakdown*).
Facebook choisit donc automatiquement les 30 derniers jours comme plage de dates, avec les colonnes d'impressions et de dépenses, sans aucune répartition.

Résultat :
```python
[<AdsInsights> {
    "account_id": "****************",
    "date_start": "2019-04-13",
    "date_stop": "2019-05-12",
    "impressions": "*****",
    "spend": "****.**"
}]
```

Notez aussi que le niveau le plus élevé de statistiques qu'on peut obtenir de l'API Facebook se situe au niveau du compte.
Si vous gérez plusieurs comptes et que vous voulez additionner les dépenses de l'ensemble de vos comptes, vous allez devoir interroger chaque compte un par un et faire la somme vous-même.

## Récupération de données à d'autres niveaux
Obtenir des statistiques au niveau d'une campagne, c'est vraiment simple. Il suffit de remplacer l'objet `AdAccount` par `Campaign`.
```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.campaign import Campaign

app_id = 'REPLACE_BY_YOUR_APP_ID'
app_secret = 'REPLACE_BY_YOUR_APP_SECRET'
access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN'

FacebookAdsApi.init(app_id, app_secret, access_token)

insights = Campaign('*****************').get_insights()

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "account_id": "****************",
    "campaign_id": "******************",
    "date_start": "2019-05-03",
    "date_stop": "2019-06-01",
    "impressions": "*****",
    "spend": "****.**"
}]
```

Remarquez comment le champ `campaign_id` apparaît maintenant dans le résultat.

Pour les données au niveau d'un ensemble de publicités ou d'une publicité, importez respectivement `AdSet` ou `Ad` à partir de `facebook_business.adobjects.adset` et `facebook_business.adobjects.ad`, puis utilisez `AdSet(<AdSetID>).get_insights()` ou `Ad(<AdID>).get_insights()` pour récupérer vos statistiques.

# Personnaliser les plages de dates, les champs, le tri et plus encore
Les requêtes ci-dessus font le travail, mais vous voulez probablement récupérer des données pour des périodes précises et des champs en particulier! C'est ce qu'on va voir dans cette section.

## Personnaliser la plage de dates
### Utiliser les plages de dates prédéfinies
Facebook offre une longue liste de plages de dates prédéfinies (*date presets*) qui devraient couvrir pas mal tous les cas d'utilisation :
- `today`
- `yesterday`
- `last_3d`
- `last_7d`
- `last_14d`
- `last_28d`
- `last_30d`
- `last_90d`
- `this_week_mon_today`
- `this_week_sun_today`
- `last_week_mon_sun`
- `last_week_sun_sat`
- `this_month`
- `last_month`
- `this_quarter`
- `last_quarter`
- `this_year`
- `last_year`
- `lifetime`

Ces plages prédéfinies peuvent être passées en paramètres à notre requête `get_insights()`. Voici un exemple avec `last_7d` :
```python
(...)

params = {'date_preset': 'last_7d'}

insights = AdAccount('act_****************').get_insights(params = params)

print(insights)
```

Les résultats ne vont maintenant inclure que les données des 7 derniers jours 😊

### Utiliser une période personnalisée
Si vous voulez des données pour une plage précise qui ne figure pas dans les options prédéfinies ci-dessus, vous pouvez aussi utiliser une date `since` (depuis) et une date `until` (jusqu'à), au format AAAA-MM-JJ.

```python
(...)

params = {'time_range': {'since': '2019-01-01', 'until': '2019-01-05'}}

insights = AdAccount('act_****************').get_insights(params = params)

print(insights)
```

Vous pouvez confirmer que la requête fonctionne bien puisque le résultat comprend `date_start` et `date_stop` :
```python
[<AdsInsights> {
    "account_id": "****************",
    "date_start": "2019-01-01",
    "date_stop": "2019-01-05",
    "impressions": "*******",
    "spend": "*****.**"
}]
```

## Personnaliser les champs
### Champs courants
De la même manière qu'on peut passer différents paramètres à notre requête `get_insights()`, on peut passer `fields`, qui est une liste des différents champs qu'on souhaite récupérer de l'API Facebook Insights. Vous trouverez la liste complète dans [la documentation officielle de Facebook sur les paramètres et les champs](https://developers.facebook.com/docs/marketing-api/insights/parameters). Voici un exemple avec les champs les plus courants que la plupart des marketers veulent obtenir :

```python
(...)

params = {'date_preset': 'last_7d'}

fields = [
    'account_name',
    'impressions',
    'clicks',
    'cpm',
    'ctr',
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params, fields = fields
)

print(insights)
```

Et le résultat inclut maintenant ces champs supplémentaires :
```python
[<AdsInsights> {
    "account_name": "Damien Gonot tutorial account",
    "clicks": "*****",
    "cpm": "4.50",
    "ctr": "1.50",
    "date_start": "2019-07-07",
    "date_stop": "2019-07-13",
    "impressions": "*******",
    "spend": "*****.**"
}]
```

### Actions / Conversions et coût par action (CPA)
Récupérer les données de conversion avec l'API Facebook Insights est un peu particulier : il faut inclure `actions` dans la liste des champs, et l'API va retourner la liste complète de toutes les actions suivies par Facebook. Voici un exemple :
```python
(...)

params = {'date_preset': 'last_7d'}

fields = [
    'account_name',
    'impressions',
    'clicks',
    'cpm',
    'ctr',
    'spend',
    'actions',
]

insights = AdAccount('act_****************').get_insights(
    params = params, fields = fields
)

print(insights)
```

Et le résultat :
```python
[<AdsInsights> {
    "account_name": "Damien Gonot tutorial account",
    "actions": [
        (...)
        {
            "action_type": "comment",
            "value": "****"
        },
        {
            "action_type": "link_click",
            "value": "******"
        },
        {
            "action_type": "mobile_app_install",
            "value": "*****"
        },
        {
            "action_type": "app_custom_event.fb_mobile_search",
            "value": "******"
        },
        {
            "action_type": "app_custom_event.fb_mobile_add_to_cart",
            "value": "*****"
        },
        {
            "action_type": "app_custom_event.fb_mobile_add_to_wishlist",
            "value": "*****"
        },
        (...)
]
```

Selon la façon dont vos conversions sont configurées, vous allez obtenir des résultats différents. Pour calculer votre CPA (coût par action), vous pouvez soit le calculer vous-même, soit utiliser le CPA calculé par Facebook.

D'abord, aller chercher les dépenses est pas mal direct une fois qu'on réalise que l'objet `AdsInsights` se trouve dans une liste :
```python
spend = insights[0]['spend']
```

Aller chercher le nombre d'actions est un peu plus délicat, puisque `actions` est une liste d'objets. Je vais essayer de trouver `mobile_app_installs` comme exemple; remplacez-le par n'importe quel nom d'action que vous voulez récupérer :
```python
mobile_app_installs = next(action for action in insights[0]['actions'] if action['action_type'] == 'mobile_app_install')['value']
```

En mettant le tout ensemble et en gardant en tête que les nombres retournés par l'API Facebook Insights sont en fait des chaînes de caractères :

```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

app_id = 'REPLACE_BY_YOUR_APP_ID'
app_secret = 'REPLACE_BY_YOUR_APP_SECRET'
access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN'

FacebookAdsApi.init(app_id, app_secret, access_token)

params = {'date_preset': 'last_7d'}

fields = [
    'account_name',
    'impressions',
    'clicks',
    'cpm',
    'ctr',
    'spend',
    'actions',
]

insights = AdAccount('act_****************').get_insights(
    params = params, fields = fields
)

spend = insights[0]['spend']
mobile_app_installs = next(action for action in insights[0]['actions'] if action['action_type'] == 'mobile_app_install')['value']
cpa = float(spend)/int(mobile_app_installs)
print('CPA:', round(cpa, 2))
```

C'est tout pour le moment, mais il reste encore quelques détails à couvrir :
- une autre façon de récupérer le CPA
- calculer le ROAS (*Return on Ad Spend*, retour sur les dépenses publicitaires)
- trier les résultats
- récupérer les données à différents niveaux
- les répartitions par période/jour et selon d'autres facteurs
- les fenêtres d'attribution

Merci de votre lecture et ~~restez à l'affût pour la partie 2~~! N'hésitez pas à [me contacter](/about) si vous avez encore des questions.

__Mise à jour du 2020-01-21 : j'ai finalement publié [la partie 2 du Guide de l'API Facebook Insights](/blog/guide-facebook-insights-api-2)!__
