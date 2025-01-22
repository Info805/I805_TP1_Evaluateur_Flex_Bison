# Exercice 2

## Ajout de la gestion des variables.

### Analyse lexicale
Source pour l'analyseur lexical (Flex) : *[calc.l](calc.l)*

Un identificateur doit commencer par une lettre et peut contenir des chiffres, des lettres et des underscores.

```flex
ident = [a-zA-Z][a-zA-Z0-9_]*
```

Ajout de la reconnaissance des lexèmes pour les variables : `LET`, `'='` , `IDENT`.
Dans le cas des identificateurs, on renvoie aussi la position de la chaîne dans la table de symboles au moyen de la variable [`yylval`](https://www.gnu.org/software/bison/manual/bison.html#index-yylval-1).

```lex
\=                  { return '='; }
{let}               { return LET; }
{ident}             { yylval.index = addSymbol(yytext); return IDENT; }
{decimalnumber}     { yylval.number = atoi(yytext); return NUMBER; }
```
La table des symbole est géré dans [symboltable.c](./symboltable.c).

### Analyse syntaxique
Source de l'analyseur syntaxique : *[calc.y](calc.y)*

Le type de l'attribut associé aux symboles de l'analyseur syntaxique,
, [`YYSTYPE`](https://www.gnu.org/software/bison/manual/bison.html#index-YYSTYPE),
peut être défini dans la spécification Yacc/Bison avec [`%union`](https://www.gnu.org/software/bison/manual/bison.html#Union-Decl) :

```yacc
%union { int number; int index; }
```
On ajoute également dans les déclarations, les nouveaux symboles terminaux renvoyés par l'analyseur lexical en précisant leur type :

```
%token LET '=' 

%token <number> NUMBER
%token <index> IDENT
```

De même pour le type des non-terminaux :

```yacc
%type <number> expr
```

On ajoute ensuite les règles pour prendre en les variables dans la syntaxe.

On a une règle pour les déclarations et modifications de variables :

```
expr    : LET IDENT '=' expr
        | IDENT
        | ...
	    ;
```

### Évaluation des expressions
Pour la prise en compte des variables, l'analyseur lexical fait remonter avec le lexème IDENT, 
la position, dans la table des symboles, de la chaîne de caractères qui correspond au nom de la variable.

Au niveau de Yacc/Bison (analyseur syntaxique) on va devoir gérer les valeurs des variables. 
Une solution peut consister à les stocker dans un tableau : 

```yacc
%{: 
// gestion de la memoire (TMAX dest le nombre max d'identificateurs)
int memory[TMAX];
%}
```

Ensuite suivant qu'on utilise la variable dans les expressions ou une affectation, 
on fait un accès en lecture ou en écriture.

```
expr    : LET IDENT '=' expr    { memory[$2] = $4; $$ = $4; }
        | IDENT                 { $$ = memory[$1]; }
        | ...
```

#### Gestion des erreurs d'évaluation (variable indéfinie) : 
En cas d'une erreur lors d'une affectation, la variable n'est pas modifiée.

```
expr    : LET IDENT '=' expr    { if (!error) memory[$2] = $4; $$ = $4; }
```


