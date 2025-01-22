%{
/* code a ajouter dans les declarations c */
#include <stdio.h>

int yylex(void);
void yyerror(const char *s);

// gestion des erreurs d'evaluation
int error = 0;

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
instr   : expr ';'              { if (!error) printf("Eval = %d\n", $1); error = 0; }
        | error ';'             { error = 0; } // reprise d'erreur
        ;
expr    : expr '+' expr         { $$ = $1 + $3; }
        | expr '-' expr         { $$ = $1 - $3; }
        | expr '*' expr         { $$ = $1 * $3; }
        | expr '/' expr         { if (error) {
                                    $$ = 0;
                                  } else if ($3 == 0)  {
                                    $$ = 0; error = 1; yyerror("division by zero error");
                                  } else {
                                    $$ = $1 / $3;
                                  }
                                }
        | expr '%' expr         { if( error) {
                                    $$ = 0;
                                  } else if ($3 == 0)  {
                                    $$ = 0; error = 1; yyerror("division by zero error");
                                  } else {
                                    $$ = $1 % $3;
                                  }
                                }
        | '-' expr              { $$ = - $2;    }   %prec UMINUS
        | '(' expr ')'          { $$ = $2;      }
        | NUMBER                { $$ = $1;      }
        ;

%%

/* code c additionnel */
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}
