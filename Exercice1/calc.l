%{
/* declations C */
#include <stdlib.h>
#include "calc.tab.h"
%}

/* -- lex options -- */
%option noyywrap

/* -- definitions regulieres -- */
decimalnumber       0|[1-9][0-9]*
mod                 mod|MOD

%%
  /* --- regles lexicales --- */

\+                  { return '+'; }
\-                  { return '-'; }
\*                  { return '*'; }
\/                  { return '/'; }
{mod}               { return '%'; }
\;                  { return ';'; }
\(                  { return '('; }
\)                  { return ')'; }
{decimalnumber}     { yylval = atoi(yytext); return NUMBER; }
[[:space:]]+        { /* rien a faire */ }
.                   { return *yytext; }

%%
/* code c additionnel */

int main (int argc, char* argv[]){
    if (argc > 1){
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yyparse();
    return 0;
}
