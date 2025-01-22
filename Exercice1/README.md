# Exercice 1

## Évaluateur d'expressions arithmétiques infixées sur les nombres entiers.

### Analyse lexicale
Source pour l'analyseur lexical (Lex/Flex) : *[calc.l](calc.l)*

On reconnait les différents mots du langage (lexème) : 
- opérateurs arithmétiques : +, -, /, *
- les parenthèses ouvrantes et fermante : (, )
- les entiers : `0|[1-9][0-9]*`
- les espaces (espaces, tabulation, passage à la ligne) : `[[:space:]]`
- le lexème indiquant la fin d'une expression : ;


### Analyse syntaxique
Source de l'analyseur syntaxique : *[calc.y](calc.y)*

Il s'agit de reconnaître la syntaxe (grammaire du langage).
Il travaille à partir des lexèmes (token) qui remontent de l'analyseur lexical. 
Tous les lexèmes sont déclarés comme des symboles terminaux.

```yacc
%token '+' '-' '*' '/' '(' ')' ';' '%' ' NUMBER
```

Les règles de la grammaire décrivent le langage :
- on a une suite d'instructions (au moins une)
- chaque instruction est terminée par un point-virgule
- une expression est soit :
    - un entier (lexème NUMBER)
    - une expression arithmétique simple : expression_gauche opérateur expression_droite
    - une expression parenthèsée : ( expression )
    
```yacc
/* on a une liste d'instructions (avec au moins une instruction) */
linstr  : instr
        | linstr instr
        ;
/* une instruction est une expression terminee par un point virgule */
instr   : expr ';'
        | error ';'
        ;
expr    : expr '+' expr
        | expr '-' expr
        | expr '*' expr
        | expr '/' expr
        | expr '%' expr
        | '(' expr ')'
        | NUMBER
        | IDENT
        ;
```

Les règles du genre : `expr: expr '+' expr` introduisent des ambiguïtés dans la grammaire 
(ce que n'aime pas l'analyseur). 
Il faut dont lever ces ambiguïtés, soit en réécrivant les règles (cf. exemple donné en cours pour les expressions arithmétique), 
soit en précisant (comme le permet l'analyseur syntaxique) l'associativité et la priorité des opérateurs :

```yacc
%left '+' '-'
%left '*' '/' '%'
```

On liste les opérateurs du moins prioritaire au plus prioritaire.

### Évaluation des expressions
Pour l'évaluation des expressions, il faut aussi disposer des valeurs des entiers reconnus par l'analyseur lexical. 
Avec Yacc/Bison cela peut se faire en utilisant une variable globale partagée, `yylval`, lors de la remontée du lexème par l'analyseur lexical :

```JFLEX
{decimalnumber}     { yylval = atoi(yytext); return NUMBER; }
```

Le type de yylval est configurable. Par défaut c'est un entier (`int`).

Au niveau de Yacc/Bison (analyseur syntaxique), on peut avoir une valeur associée à chacun des symboles (terminaux ou non terminaux). 


Pour calculer les valeurs associées aux symboles non terminaux, on ajoute des actions sémantiques dans les règles :  
`expr: expr '+' expr { $$ = $1 + $3; } `

On ajoute aussi une action sémantique pour afficher la valeur finale de l'expression :  
`instr: expr ';' { printf("Eval = %d\n", $1); }`

Dans les règles `$$` corespond à la valeur associée au symbole en partie droite.  
`$1`, `$2`, `$3`, ..., à la valeur des symboles en partie gauche.

```
/* grammaire */
/* grammaire */
/* on a une liste d'instructions (avec au moins une instruction) */
linstr  : instr
        | linstr instr
        ;
/* une instruction est une expression terminee par un point virgule */
instr   : expr ';'              { printf("Eval = %d\n", $1); }
        | error ';'             // reprise d'erreur
        ;
expr    : expr '+' expr         { $$ = $1 + $3; }
        | expr '-' expr         { $$ = $1 - $3; }
        | expr '*' expr         { $$ = $1 * $3; }
        | expr '/' expr         { $$ = $1 / $3; }
        | expr '%' expr         { $$ = $1 % $3; }
        | '(' expr ')'          { $$ = $2;      }
        | NUMBER                { $$ = $1;      }
        ;
```

La règle `instr: error ';'` permet de gérér les erreurs syntaxiques en définissant un point de reprise d'erreur après l'obtention d'un point virgule.

### Prise en compte du moins unaire
Le moins unaire pose un problème particulier du fait qu'on utilise le même token que pour l'opérateur binaire moins.

On peut le résoudre en ajoutant une règle de priorité spécifique : 

```
%left '+' '-'
%left '*' '/' '%'
%right UMINUS
```

On précise ensuite au niveau de la règle de réécriture la priorité à utiliser :

```
expr    : expr '+' expr { $$ = $1 + $3; }
        | expr '-' expr { $$ = $1 - $3; }
        | '-' expr      { $$ = - $2;    }   %prec UMINUS
        ...
```

### Gestion des erreurs d'évaluation (division par zéro)
Pour éviter que l'interpréteur ne s'arrête lors d'une erreur d'execution (division par zéro par exemple), 
on peut tester si la valeur est différente de zéro avant d'effectuer l'opération. 
Dans le cas contraire on suspend l'évaluation tant qu'on est pas arrivé à un point de reprise d'erreur (obtention d'un point virgule).

À cette fin, on peut ajouter un booléen dans la partie _declaration c_ : 

```
%{
/* code a ajouter dans les declarations c */
...
// gestion des erreurs d'evaluation
int error = 0;
....
%}
```

qu'on utilisera dans les actions sémantiques des règles de la grammaire : 

```yacc
/* grammaire */
/* on a une liste d'instructions (avec au moins une instruction) */
linstr  : instr
        | linstr instr
        ;
/* une instruction est une expression terminee par un point virgule */
instr   : expr ';'          { if (!error) printf("Eval = %d\n", $1); error = 0; }
        | error ';'         { error = 0; } // reprise d'erreur
        ;
expr    : expr '+' expr     { $$ = $1 + $3; }
        | expr '-' expr     { $$ = $1 - $3; }
        | expr '*' expr     { $$ = $1 * $3; }
        | expr '/' expr     { if (error) {
                                $$ = 0;
                              } else if ($3 == 0)  {
                                $$ = 0; error = 1; yyerror("division by zero error");
                              } else {
                                $$ = $1 / $3;
                              }
                            }
        | expr '%' expr     { if( error) {
                                $$ = 0;
                              } else if ($3 == 0)  {
                                $$ = 0; error = 1; yyerror("division by zero error");
                              } else {
                                $$ = $1 % $3;
                              }
                            }
        | '(' expr ')'      { $$ = $2; }
        | NUMBER            { $$ = $1; }
        ;
```

### Utilisation du numéro de ligne et de colonne et écriture des messages d'erreur.
Il est possible avec Bison de gerer les numéros de ligne et de colonne des lexèmes et des symboles.

L'analyseur lexical doit les initialiser dans la variable `yylloc`, lors de la remontée des lexèmes. Bison est alors à même de les propager alors au niveau des règles de la grammaire, 
ce qui permet des les utiliser dans les actions sémantiques et les messages d'erreur.

__Passage numero de ligne et de colonne dans Flex :__

L'option `%option yylineno` permet de disposer dans la variable `yylineno` du numero de ligne du token courrant. Ensuite la macro `YY_USER_ACTION`, appelée après chaque reconnaissance de token, permet de calculer la ligne et la colonne de debut et de fin et chaque token.

__Utilisation dans Bison : `@$` et `@n`__

Dans les actions sémantiques de Bison, `@$` et `@n` permettent d'accéder,
respectivement, à la position du symbole de gauche de règle et à ceux des symboles en partie droite de règle (`@1`, `@2`, `@3`, ... ). Pour plus de détails voir
[GNU Bison - Tracking Locations](https://www.gnu.org/software/bison/manual/bison.html#Tracking-Locations).

```
instr: expr ';' { if (!error) printf("Ligne %d, Colonne %d: Eval = %d\n", @1.first_line, @1.first_column, $1); error = 0; }
```

__Affichage des messages d'erreur :__

La méthode utilisée par défaut pour rapporter les erreurs de syntaxe est `void yyerror(const char *s)`.  
Il est necessaire de la définir.
