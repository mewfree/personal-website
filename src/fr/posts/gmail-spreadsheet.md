---
title: "🧨 Propulsez vos feuilles de calcul avec l'envoi gratuit de courriels 📮"
date: 2020-05-20
tags: ["email", "marketing", "google", "sheets", "spreadsheet"]
---

# Introduction
Saviez-vous qu'il est possible d'envoyer des courriels gratuitement directement à partir de Google Sheets?

Que vous soyez propriétaire d'une petite entreprise qui souhaite envoyer des nouvelles de son produit à ses utilisateurs, marketer à la recherche d'une solution d'infolettre gratuite ou fondateur d'une startup qui veut lancer ses courriels de prospection sans payer pour un CRM coûteux, cet article est fait pour vous.

# Configuration de la feuille de calcul
[Voici un modèle de feuille de calcul que je vais utiliser comme exemple](https://docs.google.com/spreadsheets/d/1Jg9fIoUMBI75eDGbEJGevcU2HHH59hTlK-v0k_A8Al4/edit?usp=sharing).

![Exemple de feuille de calcul Google Sheets](/images/spreadsheet_sample.png)

N'hésitez pas à la dupliquer en cliquant sur __Fichier > Créer une copie__ (*File > Make a copy*).

Vous pouvez aussi créer une nouvelle feuille de calcul Google Sheets (le moyen le plus rapide est d'aller sur [sheet.new](https://sheet.new)) si vous voulez partir de zéro.

Les __colonnes A, B et C__ parlent pas mal d'elles-mêmes. Vous devriez remplacer les noms et courriels fictifs par les vraies données des personnes à qui vous voulez envoyer un courriel.

La __colonne D__ sert de modèle pour l'objet de notre courriel : `=CONCATENATE(INDEX(SPLIT(A2, " "), 1), ", have you heard about X?")`.

`INDEX(SPLIT(A2, " "), 1)` signifie : « prends la valeur dans `A2`, sépare-la selon les espaces et prends le premier élément obtenu ». Comme on n'a qu'une seule colonne pour le nom complet, ça nous permet de nous adresser au destinataire uniquement par son prénom. Si vous avez des colonnes distinctes pour le prénom et le nom de famille, cette astuce n'est pas nécessaire, mais la formule va quand même fonctionner (à moins que votre destinataire ait une espace dans son prénom).

`CONCATENATE()` permet de combiner ce prénom extrait de la colonne du nom complet avec le reste du modèle d'objet.

Même principe dans la __colonne E__, avec une petite subtilité : ce serait un peu plate d'avoir tout notre message sur une seule ligne, alors `CHAR(10)` nous permet d'insérer des sauts de ligne!
`=CONCATENATE("Hi ", INDEX(SPLIT(A2, " "), 1), ", how are you?", CHAR(10), CHAR(10), "I just wanted to introduce you to my new project: X", CHAR(10), CHAR(10), "Cheers,", CHAR(10), "Damien")`

Remplacez les colonnes D et E par le vrai texte que vous voulez envoyer.

# Créer des brouillons de courriels
Vous pouvez en lire davantage sur la création d'un projet Google Apps Script à partir d'une feuille de calcul dans la section « Comment accéder à Google Apps Script? » de mon article précédent [Comment importer automatiquement des données Facebook Ads dans Google Sheets?](/blog/pull-facebook-ads-google-spreadsheet).

Dans __Extensions > Apps Script__, copiez et collez ceci :
```javascript
function run() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var data = sheet.getRange(2, 1, sheet.getLastRow()-1, sheet.getLastColumn()).getValues();
  data.forEach(function(row) {
    var email = row[2]; // Third column
    var title = row[3]; // Forth column
    var content = row[4]; // Fifth column
    GmailApp.createDraft(email, title, content);
  });
}
```

Quelques explications autour de `sheet.getRange(2, 1, sheet.getLastRow()-1, sheet.getLastColumn())` :

`getRange()` retourne la plage de valeurs à partir de la première ligne, de la première colonne, du nombre de lignes et du nombre de colonnes qu'on lui passe.

* `2` signifie que la plage commence à la 2e ligne, puisque la première contient seulement les noms des colonnes.
* `1` signifie que la plage commence à la 1re colonne.
* `sheet.getLastRow()` compte le nombre total de lignes dans la feuille. On soustrait `1` pour exclure la première ligne qui contient les en-têtes.
* `sheet.getLastColumn()` compte le nombre de colonnes dans la feuille.

Le résultat est un tableau de tableaux. Pour parcourir ce tableau, on peut utiliser `.forEach()`, qui va exécuter la fonction fournie pour chaque ligne de la plage de données.

Les tableaux commencent à l'indice 0 en JavaScript, donc le premier élément d'un tableau est accessible avec `array[0]`. J'ai ajouté des commentaires dans le code pour que ce soit plus clair.

`GmailApp.createDraft()` crée un brouillon de courriel dans le compte Gmail que vous utilisez au moment de faire rouler le script.

Faisons-le rouler en sélectionnant la fonction `run` et en cliquant sur le bouton Exécuter (*Run*) ▶️ directement dans l'éditeur de script.

Attention : on va probablement vous demander d'autoriser votre propre script à lire et envoyer des courriels à partir de votre compte.

Allez ensuite jeter un coup d'œil dans la [section Brouillons (*Drafts*) de votre compte Gmail](https://mail.google.com/mail/u/0/#drafts) :

![Brouillons générés dans Gmail](/images/gmail_drafts.png)

Bravo! Vous venez de générer des brouillons de courriels automatiquement.

# Envoyer les courriels
C'est en fait la partie la plus facile!

Vous pourriez les envoyer manuellement depuis l'interface de Gmail, mais ce n'est pas très amusant...

Pour les envoyer automatiquement à l'aide de notre script, ajoutez simplement `.send()` après la création du brouillon dans le code :

`GmailApp.createDraft(email, title, content).send();`

__Code final :__
```javascript
function run() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var data = sheet.getRange(2, 1, sheet.getLastRow()-1, sheet.getLastColumn()).getValues();
  data.forEach(function(row) {
    var email = row[2]; // Third column
    var title = row[3]; // Forth column
    var content = row[4]; // Fifth column
    GmailApp.createDraft(email, title, content).send();
  });
}
```

# Conclusion
J'espère que vous avez apprécié cette petite astuce Google Sheets, réalisable en seulement 10 lignes de code! Il y a plein de trucs chouettes que vous pouvez faire avec ça, mais s'il vous plaît, n'en abusez pas 🙏.

N'hésitez pas à [me contacter](/about) si vous avez des questions à propos de cet article.
