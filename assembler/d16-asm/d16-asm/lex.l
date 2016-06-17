%{
    #include <stdio.h>
    #include "y.tab.h"
    extern int yylex();
%}
%option header-file="lex.yy.h"
%option noyywrap

%%
[a-zA-Z][a-zA-Z0-9]*     { yylval.sval = strdup(yytext); return IDENTIFIER;}
. {return yytext[0];}

%%
