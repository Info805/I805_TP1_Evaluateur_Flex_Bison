%{
/* declations C */
#include <stdlib.h>
#include "calc.tab.h"
#include "symboltable.h"
%}

/* -- lex options -- */
%option noyywrap

/* -- definitions regulieres -- */
decimalnumber       0|[1-9][0-9]*
ident               [a-zA-Z][a-zA-Z0-9_]*
let                 let|LET
comment1            "//".*
comment2            "/*"([^*]|("*"+[^/*]))*"*"+"/"
comment             {comment1}|{comment2}

%%
  /* --- regles lexicales --- */

\+                  { return '+'; }
\-                  { return '-'; }
\*                  { return '*'; }
\/                  { return '/'; }
\;                  { return ';'; }
\=                  { return '='; }
\(                  { return '('; }
\)                  { return ')'; }
{let}               { return LET; }
{ident}             { yylval.index = addSymbol(yytext); return IDENT; }
{decimalnumber}     { yylval.number = atoi(yytext); return NUMBER; }
[[:space:]]+        { /* rien a faire */ }
{comment}           { /* commentaire pas d'action */}
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
