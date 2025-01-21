%{
/* code a ajouter dans les declarations c */
#include <stdio.h>

int yylex(void);
void yyerror(const char *s);

%}

/* declarations (token, non terminaux, etc.) */
%token '+' '-' '*' '/' '(' ')' ';' '%' NUMBER

/* priorite des operateurs */
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
instr   : expr ';'              { printf("Eval = %d\n", $1); }
        | error ';'             // reprise d'erreur
        ;
expr    : expr '+' expr         { $$ = $1 + $3; }
        | expr '-' expr         { $$ = $1 - $3; }
        | expr '*' expr         { $$ = $1 * $3; }
        | expr '/' expr         { $$ = $1 / $3; }
        | expr '%' expr         { $$ = $1 % $3; }
        | '-' expr              { $$ = - $2;    }   %prec UMINUS
        | '(' expr ')'          { $$ = $2;      }
        | NUMBER                { $$ = $1;      }
        ;

%%

/* code c additionnel */
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}
