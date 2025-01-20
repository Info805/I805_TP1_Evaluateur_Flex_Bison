%{
/* code a ajouter dans les declarations c */
#include <stdio.h>
#include "symboltable.h"

int yylex(void);
void yyerror(const char *s);

// gestion de la memoire (TMAX dest le nombre max d'identificateurs)
int memory[TMAX];

%}

/* declarations (token, non terminaux, etc.) */
%union { int number; int index; }
%token '+' '-' '*' '/' '(' ')' ';' '=' LET
%token <number> NUMBER
%token <index> IDENT

%type <number> expr

/* priorite des operateurs */
%right '='
%left '+' '-'
%left '*' '/'

%%
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
        | '(' expr ')'          { $$ = $2;      }
        | LET IDENT '=' expr    { $$ = $4; memory[$2] = $4; }
        | NUMBER                { $$ = $1;      }
        | IDENT                 { $$ = memory[$1]; }
        ;

%%

/* code c additionnel */
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}
