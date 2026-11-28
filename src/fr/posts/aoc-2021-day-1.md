---
title: "✨ Advent of Code : jour 1 en Julia"
date: 2021-12-01
tags: ["advent of code", "2021", "julia", "programmation fonctionnelle"]
---

# Introduction
Inspiré par les [nombreux](https://www.swyx.io/learn-in-public/) [articles](https://medium.com/my-learning-journal/why-you-should-learn-in-public-4fd3a6239549) sur l'apprentissage en public (*learning in public*), j'ai décidé d'écrire un billet de blog sur ce que j'ai appris lors du premier jour d'Advent of Code 2021.

Chaque année, j'ai vraiment hâte de participer à [Advent of Code](https://adventofcode.com/). Ces casse-têtes quotidiens sont super le fun et c'est tellement satisfaisant d'arriver à une solution qui fonctionne. Par contre, comme la difficulté monte vite, c'est pas mal difficile de réussir tous les défis jusqu'à la fin — mais bon, au moins j'ai fait le jour 1!

Cette année, comme [l'an dernier](https://github.com/mewfree/advent-of-meow-2020), j'ai décidé d'utiliser [Julia](https://julialang.org/). J'aime bien le décrire comme « aussi simple que Python, aussi rapide que C », mais il y a aussi certaines fonctionnalités que j'adore (un REPL rapide et génial, les *pipes* (`|>`), les fonctions vectorisées...).

# Lecture des données d'entrée
Lire et analyser les données d'entrée est la première étape pour résoudre un casse-tête d'Advent of Code.

Mon meilleur conseil pour Advent of Code, c'est de tester votre code sur l'exemple public (personnellement, je l'enregistre dans un fichier `test_input` à côté de mon vrai fichier privé `input`).

## Méthode initiale
Comme j'avais aussi résolu [l'Advent of Code de l'an dernier](https://github.com/mewfree/advent-of-meow-2020) en Julia, je me suis rappelé [la méthode que j'utilisais](https://github.com/mewfree/advent-of-meow-2020/blob/main/day-01/solution.jl#L1), qui consiste essentiellement à :
- lire le fichier comme une chaîne de caractères
- découper selon les sauts de ligne
- pour chaque ligne, convertir la chaîne en entier

```julia
input = open(f->read(f, String), "test_input") |> f->split(f, "\n") |> a->map(s->parse(Int, s), a)
```

Mais je n'en étais pas satisfait et j'avais toujours l'impression qu'il devait y avoir une meilleure façon de faire...

## Une méthode plus propre
Après quelques recherches, j'ai découvert [Delimited Files](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/), qui fait partie de la bibliothèque standard de Julia!
Plus précisément, la méthode `readdlm` qui permet de lire un fichier sous forme de matrice tout en gérant la conversion en entiers ou en nombres à virgule flottante en même temps.

```julia
julia> using DelimitedFiles

julia> input = readdlm("test_input", Int)
10×1 Matrix{Int64}:
 199
 200
 208
 210
 200
 207
 240
 269
 260
 263
```

Ce qu'on veut par contre, c'est un vecteur (ce qu'on appellerait un tableau ou une liste dans la plupart des autres langages — essentiellement une matrice à une dimension du point de vue de Julia), mais la fonction `vec` s'en occupe facilement pour nous :
```julia
julia> input = readdlm("test_input", Int) |> vec
10-element Vector{Int64}:
 199
 200
 208
 210
 200
 207
 240
 269
 260
 263
```

# Solution de la partie 1
## Map -> Reduce
Bon, passons aux choses sérieuses. Je ne vais pas réexpliquer [le casse-tête du jour 1](https://adventofcode.com/2021/day/1) ici — je vous recommande d'y jeter un coup d'œil par vous-même d'abord!
On veut savoir si l'élément `n` est plus petit que l'élément `n+1`, ou plutôt si l'élément `n` est plus grand que l'élément `n-1`.
Mon premier réflexe est d'appliquer un `map` sur les données d'entrée, en utilisant `enumerate` pour obtenir l'indice du `n`-ième élément et m'en servir pour le comparer au `n-1`-ième élément. Un petit [opérateur ternaire](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation) est nécessaire pour gérer le cas du premier élément.

```julia
julia> map(x -> x[1] - 1 == 0 ? false : x[2] > input[x[1] - 1], enumerate(input))
10-element Vector{Bool}:
 0
 1
 1
 1
 0
 1
 1
 1
 0
 1
```

Maintenant qu'on a une liste de booléens (ou de uns et de zéros), un petit `reduce` nous permet d'additionner les valeurs :
```julia
julia> reduce(+, map(x -> x[1] - 1 == 0 ? false : x[2] > input[x[1] - 1], enumerate(input)))
7
```

## Zip -> Map -> Sum
En partageant ma première solution avec mes collègues et en regardant celles des autres, j'ai vite reçu deux commentaires :
- `reduce` n'est pas nécessaire et un simple `sum` fait le travail
- `zip` peut être très utile! (J'oublie toujours l'existence de `zip`...)

```julia
julia> map(((x, y),) -> x < y, zip(input, input[2:end]))
9-element Vector{Bool}:
 1
 1
 1
 0
 1
 1
 1
 0
 1
```

Quelques explications sur le code ci-dessus.
Voici ce que fait `zip` :
```julia
julia> zip(input, input[2:end]) |> collect
9-element Vector{Tuple{Int64, Int64}}:
 (199, 200)
 (200, 208)
 (208, 210)
 (210, 200)
 (200, 207)
 (207, 240)
 (240, 269)
 (269, 260)
 (260, 263)
```

Rappelez-vous que les indices en Julia commencent à 1 et non à 0 (comme dans d'autres langages orientés mathématiques comme R ou MATLAB), ce qui veut dire qu'on combine le vecteur initial avec le même vecteur à partir du 2e élément. Le résultat est un vecteur de tuples.

La notation `((x, y),) -> x < y` permet de déstructurer le tuple directement dans la liste des paramètres, au lieu de devoir faire quelque chose comme `x -> x[1] < x[2]` (ce que vous trouverez peut-être plus propre, mais pas moi, même si c'est techniquement plus court).

En enchaînant un `sum` à la fin :
```julia
julia> map(((x, y),) -> x < y, zip(input, input[2:end])) |> sum
7
```

## Diff
J'étais pas mal satisfait de cette solution, mais en jetant un coup d'œil au génial [fil de solutions](https://www.reddit.com/r/adventofcode/comments/r66vow/2021_day_1_solutions/) sur [/r/adventofcode](https://www.reddit.com/r/adventofcode/), j'ai vu quelqu'un utiliser une simple fonction `diff` en R.

Et à mon grand bonheur, Julia a aussi [une fonction `diff`](https://docs.julialang.org/en/v1/base/arrays/#Base.diff)!
```julia
julia> diff(input)
9-element Vector{Int64}:
   1
   8
   2
 -10
   7
  33
  29
  -9
   3
```

Elle calcule automatiquement la différence entre les éléments consécutifs d'un tableau ou d'un vecteur.

En appliquant `map` sur ce résultat pour vérifier s'il est positif :
```julia
julia> map(x -> x > 0, diff(input))
9-element Vector{Bool}:
 1
 1
 1
 0
 1
 1
 1
 0
 1
```

Et encore une fois, on enchaîne avec un `sum` à la fin :
```julia
julia> map(x -> x > 0, diff(input)) |> sum
7
```

## Solution finale
En résumé, ça nous donne un *one-liner* :
```julia
julia> readdlm("test_input", Int) |> vec |> v->map(x -> x > 0, diff(v)) |> sum
7
```

# Solution de la partie 2
Pas beaucoup d'évolution ici, mais on va profiter de tout ce qu'on a appris dans la partie 1.

On doit créer des fenêtres glissantes de taille 3. Ça ne me tentait pas de l'implémenter moi-même puisque je n'aime pas réinventer la roue, donc j'ai cherché une méthode déjà disponible.

La méthode [`Partition`](https://juliafolds.github.io/Transducers.jl/dev/reference/manual/#Transducers.Partition) de [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl) avait l'air de faire l'affaire.

```julia
julia> using Transducers

julia> windows = input |> Transducers.Partition(3; step = 1) |> Map(copy) |> collect
8-element Vector{Vector{Int64}}:
 [199, 200, 208]
 [200, 208, 210]
 [208, 210, 200]
 [210, 200, 207]
 [200, 207, 240]
 [207, 240, 269]
 [240, 269, 260]
 [269, 260, 263]
```
Parfait.

En utilisant la [syntaxe du point pour vectoriser une fonction](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized), on peut obtenir la somme de chaque fenêtre :
```julia
julia> sum.(windows)
8-element Vector{Int64}:
 607
 618
 618
 617
 647
 716
 769
 792
```

Et on peut réutiliser exactement la même approche que dans la partie 1 pour calculer les différences et compter combien de fois la valeur a augmenté.

Ou si vous tenez vraiment à un *one-liner*...
```julia
julia> readdlm("test_input", Int) |> vec |> Transducers.Partition(3; step = 1) |> Map(copy) |> collect |> w->map(x -> sum(x), w) |> v->map(x -> x > 0, diff(v)) |> sum
5
```

# Conclusion
Voici le script complet, qui est [disponible sur GitHub](https://github.com/mewfree/advent-of-meow-2021/blob/main/day-01/solution.jl) :
```julia
using DelimitedFiles
using Transducers

input = readdlm("input", Int) |> vec
compare(vec) = map(x -> x > 0, diff(vec))
windows = input |> Transducers.Partition(3; step = 1) |> Map(copy) |> collect

println("Part 1: ", input |> compare |> sum)
println("Part 2: ", sum.(windows) |> compare |> sum)
```

Pas mal satisfait de ce résultat! Je ne pense pas qu'il reste grand-chose à améliorer.

Mes principaux apprentissages :
- `readdlm` est super utile
- `zip` peut être plus propre que de jongler avec `enumerate` et les indices
- les fonctions vectorisées, c'est génial!

Je ne pense pas que ça sera soutenable de continuer à bloguer sur les prochains casse-têtes d'Advent of Code, mais j'espère que c'était une lecture intéressante et que vous avez appris quelque chose.
