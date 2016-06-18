%{
    #include <stdio.h>
    #include "y.tab.h"
    #include "instruction.h"
    extern int yylex();
%}
%option header-file="lex.yy.h"
%option noyywrap

%%
\n {return NEWLINE;};
[ \t]          ;
, {return COMMA;}
[cC][rR][0-9][1-9]? {yylval.ival = atoi(yytext+2); return CP_REGISTER;}
[rR][0-7] {yylval.ival = yytext[1] - '0'; return REGISTER;}
nop {yylval.op = op(strdup(yytext),NOP); return OPCODE;};
add {yylval.op = op(strdup(yytext),ADD); return OPCODE;};
sub {yylval.op = op(strdup(yytext),SUB); return OPCODE;};
#-?[0-9]* {yylval.ival = atoi(yytext); return IMMEDIATE;}
[a-zA-z][a-zA-Z0-9]* {yylval.sval = strdup(yytext); return IDENTIFIER;};
. {return yytext[0];}

%%
