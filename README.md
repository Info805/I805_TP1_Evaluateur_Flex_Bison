# TP1 Compilation : Evaluateur d'expressions arithmétiques infixées
On utilise Flex pour l'analyseur lexical et Bison pour l'analyseur syntaxique.

**Sous Dossier [Exercice1](Exercice1) :**  
Correction de l'exercice 1, évaluateur d'expressions arithmétiques infixées sur les nombres entiers.

Différentes versions pour l'exercice 1 :  
- v1 : 4 opérateurs uniquement (+, -, *, /) - pas de gestion des erreurs : 
[branche Exercice1_v1](../Exercice1_v1/Exercice1)
- v2 : ajout des opérateurs pour le modulo et le moins unaire - gestion des erreurs (division par zéro) : 
[branche Exercice1_v2](../Exercice1_v2/Exercice1)
- v3 : ajout de la gestion des numéros de ligne et de colonne : 
[branche Exercice1_v3](../Exercice1_v3/Exercice1)
    
**Sous Dossier [Exercice2](Exercice2) :**  
Correction de l'exercice 2, ajout de l'utilisation de variables et gestion des commentaires.

Différentes versions  pour l'exercice 2 :  
- v1 : 4 opérateurs uniquement (+, -, *, /) - pas de gestion des erreurs : 
[branche Exercice2_v1](../Exercice2_v1/Exercice2)
- v2 : ajout des opérateurs pour le modulo et le moins unaire - gestion des erreurs (division par zéro) : 
[branche Exercice2_v2](../Exercice2_v2/Exercice2)
- v3 : ajout de la gestion des numéros de ligne et de colonne : 
[branche Exercice2_v3](../Exercice2_v3/Exercice2)

Normalement l'exécution de la tâche all (`make all`) devrait générer exécutable pour chaque exercice 
(Exercice1/calc.exe et Exercice2/calc.exe).  
On peut les utiliser pour lancer l'analyseur : 

```bash
Exercice2/calc.exe tpEvaluateurSource.txt
```

Ce qui donne alors le résultat suivant :  

Fichier source :

```text
12 + 5; 		/* ceci est un commentaire */
10 / 2 - 3;  99; 	/* le point-virgule separe les expressions à évaluer */
/* l'évaluation donne toujours un nombre entier */
((30 * 1) + 4) mod 5;	/* cinq opérateurs binaires */
erreur + 5;		/* il peut avoir des erreurs */
 8 / 0 + 6;		/* après une erreur(division par zéro), on peut continuer */
 8 / (6 -3*2) + 6; /* autre exemple de division par zéro */
3 + * 5;		/* encore erreur */
3 * -4;			/* un opérateur opérateur unaire */
5 +
4; /* expression sur plus d'une ligne */

let prixHt = 200; 	/* une variable prend valeur lors de sa déclaration */
let prixTtc =  prixHt * 119 / 100;
prixTtc + 100;
14 / x;			/* erreur */
5 # + 2;    /* attention il faut signaler erreur */
10 * 3;     // reste ligne est commentaire
5;
 /**** fin ***/
```

Résultat :

```text
Ligne 1, Colonne 1: Eval = 17
Ligne 2, Colonne 1: Eval = 2
Ligne 2, Colonne 14: Eval = 99
Ligne 4, Colonne 1: Eval = 4
Ligne 5, Colonne 1: Eval = 5
Ligne 6, Colonne 6: division by zero error
Ligne 7, Colonne 6: division by zero error
Ligne 8, Colonne 5: syntax error
Ligne 9, Colonne 1: Eval = -12
Ligne 10, Colonne 1: Eval = 9
Ligne 13, Colonne 1: Eval = 200
Ligne 14, Colonne 1: Eval = 238
Ligne 15, Colonne 1: Eval = 338
Ligne 16, Colonne 6: division by zero error
Ligne 17, Colonne 3: syntax error
Ligne 18, Colonne 1: Eval = 30
Ligne 19, Colonne 1: Eval = 5
```

## Documentation

- documentation Flex : 
    - wikipedia : https://en.wikipedia.org/wiki/Flex_(lexical_analyser_generator)
    - manuel : https://westes.github.io/flex/manual/
- documentation GNU Bison : 
    - wikipedia : https://en.wikipedia.org/wiki/GNU_Bison
    - manuel : https://www.gnu.org/software/bison/manual/bison.html

