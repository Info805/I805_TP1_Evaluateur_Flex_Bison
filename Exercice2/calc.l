%{
/* declations C */
#include <stdlib.h>
#include "calc.tab.h"
#include "symboltable.h"

#define YY_USER_ACTION update_line_col();

void update_line_col();
%}

/* -- lex options -- */
%option noyywrap
%option yylineno

/* -- definitions regulieres -- */
decimalnumber       0|[1-9][0-9]*
ident               [a-zA-Z][a-zA-Z0-9_]*
let                 let|LET
mod                 mod|MOD
comment1            "//".*
comment2            "/*"([^*]|("*"+[^/*]))*"*"+"/"
comment             {comment1}|{comment2}

%%
  /* --- regles lexicales --- */

\+                  { return '+'; }
\-                  { return '-'; }
\*                  { return '*'; }
\/                  { return '/'; }
{mod}               { return '%'; }
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

void update_line_col(){
    yylloc.first_line = yylloc.last_line;
    yylloc.first_column = yylloc.last_column;
    // we are in the same line
    if (yylloc.first_line == yylineno){
        yylloc.last_column += yyleng;
    } else {
        yylloc.last_line = yylineno;
        yylloc.last_column= (yytext + yyleng) - strrchr(yytext, '\n');
    }
}

int main (int argc, char* argv[]){
    if (argc > 1){
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yyparse();
    return 0;
}
