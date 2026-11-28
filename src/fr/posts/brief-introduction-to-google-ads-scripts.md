---
title: "Brève introduction aux scripts Google Ads"
date: 2018-03-08
tags: ["google ads", "adwords", "scripts", "scripts google ads", "scripts adwords", "introduction"]
---

# Qu'est-ce que les scripts Google Ads?
Les scripts Google Ads permettent d'automatiser des campagnes Google Ads à l'aide d'une version légèrement modifiée de JavaScript pour lire, créer, modifier et supprimer des « entités » Google Ads (campagnes, groupes d'annonces, mots-clés, annonces...). Les scripts Google Ads sont hébergés directement dans Google Ads et vous n'avez pas besoin de serveur pour les faire rouler : Google Ads s'occupe de tout pour vous.

Créons notre premier script Google Ads tout de suite!

## Comment y accéder?
### Avec la nouvelle interface Google Ads
La façon la plus simple, c'est de profiter du nouveau raccourci clavier de Google Ads : tapez <kbd>gt</kbd> n'importe où dans l'interface. Une fois la barre de recherche affichée, cherchez simplement « scripts » et appuyez sur <kbd>Entrée</kbd>.
![Résultat du raccourci gt script](/images/gt_script.png)

Sinon, en passant par les menus de l'interface, cliquez sur l'icône de clé anglaise dans le coin supérieur droit et vous trouverez « Scripts » dans la section « Actions groupées » (*Bulk actions*).
![Interface actuelle de Google Ads](/images/full_interface_scripts.png)

### Avec l'ancienne interface Google Ads
Si vous n'utilisez pas encore la nouvelle interface Google Ads, vous trouverez les scripts dans le menu de gauche, sous la section « Opérations groupées » (*Bulk operations*).
![Ancienne interface Google Ads](/images/old_interface_scripts.png)

Pour le reste du tutoriel, je vais utiliser la nouvelle interface Google Ads par souci de commodité.

# Notre premier script Google Ads
Si vous n'avez jamais utilisé les scripts Google Ads auparavant, votre liste de scripts devrait être vide. Vous pouvez en créer un premier en cliquant sur le gros bouton « + » dans un cercle.
![Bouton plus dans un cercle](/images/creating_first_script.png)
Voici ce que vous devriez voir :
![Script AdWords vide](/images/empty_adwords_script.png)
Vous pouvez le nommer comme vous voulez. Je vais appeler le mien « Our first AdWords Script ». Un astérisque (\*) devant le nom du script indique qu'il y a des modifications non enregistrées.

Vous pouvez ignorer le bouton « API avancées » (*Advanced APIs*) pour le moment : il sert uniquement à se connecter à d'autres services Google comme BigQuery, etc.

Ce gros avertissement un peu intimidant sur fond jaune nous indique qu'il faut autoriser (*Authorize*) le script avant qu'il puisse poser des actions sur notre compte Google Ads. C'est sans danger de l'autoriser dès maintenant puisque notre script ne fait encore rien. On devra peut-être l'autoriser de nouveau plus tard si on le connecte à Google Sheets pour lire ou écrire des données, par exemple.

Juste en dessous se trouve un grand espace (presque) vide où la magie va opérer.

```javascript
function main() {
}
```

Il faut écrire notre code à l'intérieur de la fonction `main()` pour qu'il s'exécute. C'est la tradition, quand on essaie un nouveau langage ou une nouvelle interface de programmation, d'écrire un [programme « Hello, World! »](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) qui affiche simplement `Hello, World!`. Dans une application JavaScript normale, on écrirait `console.log("Hello, World!");`, mais comme les scripts Google Ads diffèrent un peu du JavaScript standard, notre programme devient `Logger.log("Hello, World!");`. En passant, on peut utiliser des guillemets simples (`'`) au lieu des guillemets doubles (`"`), c'est simplement une question de préférence personnelle. Je vais utiliser des guillemets simples pour le reste du tutoriel parce que c'est ce que je préfère.

Voici ce que vous devriez avoir maintenant :
```javascript
function main() {
  Logger.log('Hello, World!');
}
```

Vous pouvez maintenant cliquer sur le bouton **Aperçu** (*Preview*). Ça va enregistrer votre script automatiquement et le faire rouler en mode aperçu. Quand les scripts s'exécutent en mode « Aperçu », ils ne s'appliquent pas vraiment à votre compte Google Ads et n'y apportent aucune modification. C'est seulement quand vous cliquez sur le bouton **Exécuter** (*Run*) que vos scripts modifient réellement votre compte Google Ads. Pour l'instant, on va seulement utiliser le mode Aperçu.

Vous remarquerez que la section **Modifications** (*Changes*) reste vide. C'est parce qu'on n'a encore posé aucune action sur nos entités Google Ads et qu'on a seulement joué avec les journaux (*Logs*). Cliquez donc sur la section **Journaux** (*Logs*) et voici ce que vous devriez voir :
![Premier résultat Hello World](/images/hello_world_first_result.png)

__Félicitations! Vous venez d'exécuter votre premier script Google Ads!__

Vous pouvez continuer d'en apprendre plus sur les scripts Google Ads en lisant mon prochain article : [Scripts Google Ads : lire des données](/blog/google-ads-scripts-reading-data).
