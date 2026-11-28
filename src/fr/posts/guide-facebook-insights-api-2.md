---
title: "Guide de l'API Facebook Insights (partie 2)"
date: 2020-01-21
tags: ["facebook", "marketing", "api", "insights", "martech"]
---

# Introduction
Bienvenue dans le premier article publié en 2020! Petit rappel : ceci est la deuxième partie d'un guide sur la façon d'utiliser l'API Facebook Insights avec Python, donc si vous n'avez pas encore vu le [Guide de l'API Facebook Insights](/blog/guide-facebook-insights-api) (partie 1), je vous suggère de le lire en premier.

Certaines fonctionnalités plus avancées de l'API Facebook Insights n'avaient pas été couvertes dans la partie 1, alors voici le reste!

# Requêtes avancées avec l'API Facebook Insights
## Niveau (`level`)
Dans [l'article précédent](/blog/guide-facebook-insights-api), on a vu comment obtenir des résultats pour un compte publicitaire, une campagne, un ensemble de publicités, etc. Par contre, les résultats ne donnaient que le total global de cette entité. Et si vous voulez accéder aux résultats de tout votre compte, mais détaillés par campagne ou même par ensemble de publicités?

C'est là que le paramètre `level` (niveau) entre en jeu.

Voici un exemple de code Python pour obtenir les résultats d'un compte au niveau des campagnes, qui devrait vous sembler familier si vous avez lu [mon article précédent](/blog/guide-facebook-insights-api).

```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

app_id = 'REPLACE_BY_YOUR_APP_ID'
app_secret = 'REPLACE_BY_YOUR_APP_SECRET'
access_token = 'REPLACE_BY_YOUR_ACCESS_TOKEN'

FacebookAdsApi.init(app_id, app_secret, access_token)

params = {
    'level': 'campaign', # <== level mechanism
}

fields = [
    'campaign_name',
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Remarquez comment j'ai ajouté `campaign_name` à la liste des champs afin de différencier chaque campagne.

Résultat :
```python
[<AdsInsights> {
    "campaign_name": "campaign_a",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "9501.20"
}, <AdsInsights> {
    "campaign_name": "campaign_b",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "22702.47"
}, <AdsInsights> {
    "campaign_name": "campaign_c",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "11404.52"
}, <AdsInsights> {
    "campaign_name": "campaign_d",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "8752.67"
}]
```

Comme vous pouvez le constater, les résultats ne semblent pas triés d'une quelconque façon. Passez à la section suivante pour apprendre à les trier.

## Tri (`sort`)
Vous avez peut-être remarqué que les résultats de Facebook n'arrivent habituellement dans aucun ordre particulier. Voici comment préciser un tri pour que le résultat JSON soit déjà ordonné dès que vous le recevez de l'API.

Voici comment faire :

Ajoutez un paramètre `sort` dans votre liste de paramètres (`params`). Comme il est possible de trier selon plusieurs champs, ce paramètre prend un tableau de chaînes de caractères. Chaque chaîne est construite selon le format `{field}_{direction}`, où `field` est le champ selon lequel vous voulez trier et `direction` est soit `ascending` (croissant), soit `descending` (décroissant).

Exemple : `spend_descending` pour trier les résultats par dépenses, du plus élevé au plus bas.

### Exemple de code Python :
```python
(...)

params = {
    'level': 'campaign',
    'sort': ['spend_descending'], # <== sorting mechanism
}

fields = [
    'campaign_name',
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "campaign_name": "campaign_b",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "22702.47"
}, <AdsInsights> {
    "campaign_name": "campaign_c",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "11404.52"
}, <AdsInsights> {
    "campaign_name": "campaign_a",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "9501.20"
}, <AdsInsights> {
    "campaign_name": "campaign_d",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "8752.67"
}]
```

Les résultats sont maintenant triés par dépenses, en ordre décroissant (du plus élevé au plus bas)!

## Filtrage (`filtering`)
Le filtrage se construit à partir d'un champ (le champ ou la colonne sur lequel on souhaite filtrer, par exemple `campaign.name` ou `impressions`), d'un opérateur (par exemple `CONTAIN` ou `STARTS_WITH` pour les champs de texte comme les noms d'entités, ou `GREATER_THAN` // `LESS_THAN` pour les champs numériques comme les impressions) et d'une valeur (ce contre quoi on filtre, par exemple « 5000 » pour ne récupérer que les campagnes ayant dépensé plus de 5 000 $).

On peut les combiner en un ou plusieurs objets sous le paramètre `filtering`.

Voici la liste exhaustive des opérateurs :
* `EQUAL`
* `NOT_EQUAL`
* `GREATER_THAN`
* `GREATER_THAN_OR_EQUAL`
* `LESS_THAN`
* `LESS_THAN_OR_EQUAL`
* `IN_RANGE`
* `NOT_IN_RANGE`
* `CONTAIN`
* `NOT_CONTAIN`
* `IN`
* `NOT_IN`
* `STARTS_WITH`
* `ANY`
* `ALL`
* `AFTER`
* `BEFORE`
* `NONE`

Voici quelques exemples :

### Filtrer par dépenses
```python
(...)

params = {
    'filtering': [
        {
            'field': 'spend',
            'operator': 'GREATER_THAN',
            'value': 20000,
        },
    ],
    'level': 'campaign',
}'

fields = [
    'campaign_name',
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "campaign_name": "campaign_b",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "22702.47"
}]
```
^ Seules les campagnes ayant dépensé plus de 20 000 $ ont été récupérées

### Filtrer par nom de campagne
```python
(...)

params = {
    'filtering': [
        {
            'field': 'campaign.name',
            'operator': 'CONTAIN',
            'value': '_c',
        },
    ],
    'level': 'campaign',
}'

fields = [
    'campaign_name',
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "campaign_name": "campaign_c",
    "date_start": "2019-12-13",
    "date_stop": "2020-01-11",
    "spend": "11404.52"
}]
```
^ Seule la campagne dont le nom contient `_c` a été récupérée

Notez que votre premier réflexe pourrait être d'utiliser `campaign_name` comme champ, mais si vous faites ça, Facebook va vous retourner une erreur :
`Filter campaign_name is not valid any more, please use campaign.name instead`.

## Intervalle de temps (`time_increment` : données mensuelles ou quotidiennes)
Par défaut, l'API Facebook Insights retourne le résultat cumulé pour l'ensemble de la plage de dates (`all_days`).

Si vous voulez obtenir les données pour chaque mois ou chaque jour (données mensuelles ou quotidiennes), vous devez utiliser le paramètre `time_increment`.

`time_increment` peut prendre l'une des valeurs suivantes :
* un entier (si vous voulez des données regroupées par blocs de 1, 2, 3... jours — je ne suis pas sûr de la raison pour laquelle vous voudriez des groupes de plus d'une journée en dehors des données hebdomadaires ou mensuelles, mais n'hésitez pas à [me contacter](/about) si c'est votre cas afin que j'en apprenne plus sur votre besoin)
* `monthly`
* `all_days` (mais c'est déjà la valeur par défaut)

### Exemple de données quotidiennes :
```python
(...)

params = {
    'time_increment': 1, # <== daily data mechanism
    'date_preset': 'last_3d',
}

fields = [
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultats :
```python
[<AdsInsights> {
    "date_start": "2020-01-09",
    "date_stop": "2020-01-09",
    "spend": "8000.00"
}, <AdsInsights> {
    "date_start": "2020-01-10",
    "date_stop": "2020-01-10",
    "spend": "8200.00"
}, <AdsInsights> {
    "date_start": "2020-01-11",
    "date_stop": "2020-01-11",
    "spend": "10000.00"
}]
```

### Exemple de données mensuelles :
```python
(...)

params = {
    'time_increment': 'monthly', # <== monthly data
    'date_preset': 'last_quarter',
}

fields = [
    'spend',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "date_start": "2019-10-01",
    "date_stop": "2019-10-31",
    "spend": "100000.00"
}, <AdsInsights> {
    "date_start": "2019-11-01",
    "date_stop": "2019-11-30",
    "spend": "125000.00"
}, <AdsInsights> {
    "date_start": "2019-12-01",
    "date_stop": "2019-12-31",
    "spend": "150000.00"
}]
```

## Répartitions (`breakdowns`)
Tout ça, c'est bien beau, mais qu'est-ce qu'on fait si on veut ventiler nos résultats selon la plateforme de diffusion (Facebook/Instagram/Messenger...), l'âge, le pays et plus encore?

Encore une fois, il suffit d'ajouter `breakdowns` comme paramètre avec une liste de répartitions.

Voici la liste exhaustive des répartitions disponibles :
* `ad_format_asset`
* `age`
* `body_asset`
* `call_to_action_asset`
* `country`
* `description_asset`
* `gender`
* `image_asset`
* `impression_device`
* `link_url_asset`
* `product_id`
* `region`
* `title_asset`
* `video_asset`
* `dma`
* `frequency_value`
* `hourly_stats_aggregated_by_advertiser_time_zone`
* `hourly_stats_aggregated_by_audience_time_zone`
* `place_page_id`
* `publisher_platform`
* `platform_position`
* `device_platform`

Seulement certaines répartitions peuvent être combinées entre elles. Pour en savoir plus, consultez [la documentation officielle de Facebook sur la combinaison des répartitions](https://developers.facebook.com/docs/marketing-api/insights/breakdowns#combiningbreakdowns).

### Exemple de répartition par âge :
```python
(...)

params = {
    'breakdowns': ['age'], # <== breakdown mechanism
    'date_preset': 'last_7d',
}

fields = [
    'impressions',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "age": "18-24",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "78505"
}, <AdsInsights> {
    "age": "25-34",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "82575"
}, <AdsInsights> {
    "age": "35-44",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "32155"
}, <AdsInsights> {
    "age": "45-54",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "18055"
}, <AdsInsights> {
    "age": "55-64",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "10316"
}, <AdsInsights> {
    "age": "65+",
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "6243"
}]
```

### Exemple de répartition par plateforme de diffusion :
```python
(...)

params = {
    'breakdowns': ['publisher_platform'], # <== breakdown mechanism
    'date_preset': 'last_7d',
}

fields = [
    'impressions',
]

insights = AdAccount('act_****************').get_insights(
    params = params,
    fields = fields,
)

print(insights)
```

Résultat :
```python
[<AdsInsights> {
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "3458",
    "publisher_platform": "audience_network"
}, <AdsInsights> {
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "401304",
    "publisher_platform": "facebook"
}, <AdsInsights> {
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "104504",
    "publisher_platform": "instagram"
}, <AdsInsights> {
    "date_start": "2020-01-14",
    "date_stop": "2020-01-20",
    "impressions": "154",
    "publisher_platform": "messenger"
}]
```

# Conclusion
C'est tout pour aujourd'hui : on a fait le tour de la majorité des fonctionnalités offertes par l'API Facebook Insights. Merci d'avoir suivi le guide!

Consultez [la documentation officielle de Facebook sur Insights](https://developers.facebook.com/docs/marketing-api/reference/ad-account/insights) pour voir l'ensemble complet des options disponibles.

N'hésitez pas à [me contacter](/about) si vous avez des questions à propos de cet article.
