%{
    #include <stdio.h>
    #include "y.tab.h"
    extern int yylex();
%}
%option header-file="lex.yy.h"
%option noyywrap

%%
[ \t\n]          ;
, {return COMMA;}
[rR][0-7] {yylval.ival = yytext[1] - '0'; return REGISTER;}
#-?[0-9]* {yylval.ival = atoi(yytext); return IMMEDIATE;}
[a-zA-Z][a-zA-Z0-9]*     { yylval.sval = strdup(yytext); return IDENTIFIER;}
. {return yytext[0];}

%%
