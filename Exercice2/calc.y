%{
/* code a ajouter dans les declarations c */
#include <stdio.h>
#include "calc.tab.h"
#include "symboltable.h"

int yylex(void);
void yyerror(const char *s);
void evalerror(const char *s, YYLTYPE* loc);

// gestion de la memoire (TMAX dest le nombre max d'identificateurs)
int memory[TMAX];
// gestion des erreurs d'evaluation
int error = 0;

%}

/* declarations (token, non terminaux, etc.) */
%locations
%union { int number; int index; }
%token '+' '-' '*' '/' '(' ')' ';' '%' '=' LET UMINUS
%token <number> NUMBER
%token <index> IDENT

%type <number> expr

/* priorite des operateurs */
%right '='
%left '+' '-'
%left '*' '/' '%'
%right UMINUS

%%
/* grammaire */
/* on a une liste d'instructions (avec au moins une instruction) */
linstr  : instr
        | linstr instr
        ;
/* une instruction est une expression terminee par un point virgule */
instr   : expr ';'              { if (!error) printf("Ligne %d, Colonne %d: Eval = %d\n", @1.first_line, @1.first_column, $1); error = 0; }
        | error ';'             { error = 0; } // reprise d'erreur
        ;
expr    : expr '+' expr         { $$ = $1 + $3; }
        | expr '-' expr         { $$ = $1 - $3; }
        | expr '*' expr         { $$ = $1 * $3; }
        | expr '/' expr         { if (error) {
                                    $$ = 0;
                                  } else if ($3 == 0)  {
                                    $$ = 0; error = 1; evalerror("division by zero error", &@3);
                                  } else {
                                    $$ = $1 / $3;
                                  }
                                }
        | expr '%' expr         { if( error) {
                                    $$ = 0;
                                  } else if ($3 == 0)  {
                                    $$ = 0; error = 1; evalerror("division by zero error", &@3);
                                  } else {
                                    $$ = $1 % $3;
                                  }
                                }
        | '-' expr              { $$ = - $2;    }   %prec UMINUS
        | '(' expr ')'          { $$ = $2;      }
        | LET IDENT '=' expr    { if (!error) memory[$2] = $4; $$ = $4; }
        | NUMBER                { $$ = $1;      }
        | IDENT                 { $$ = memory[$1]; }
        ;

%%

/* code c additionnel */
void yyerror(const char *s) {
    fprintf(stderr, "Ligne %d, Colonne %d: %s\n", yylloc.first_line, yylloc.first_column, s);
}

void evalerror(const char *s, YYLTYPE* loc) {
    if (loc != NULL) {
        fprintf(stderr, "Ligne %d, Colonne %d: %s\n", loc->first_line, loc->first_column, s);
    } else {
        fprintf(stderr, "%s\n", s);
    }
}
