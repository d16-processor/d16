%{
    #include <stdio.h>
    #include "parser.h"
    #include "instruction.h"
    #define YY_NO_INPUT
    extern int yylex();
%}
%option header-file="lex.yy.h"
%option noyywrap
%option nounput

%%
\n {return NEWLINE;};
[ \t]          ;
, {return COMMA;}
\x5b {printf("[ Bracket\n");return LBRACKET;};
\x5d {printf("] Bracket\n");return RBRACKET;};
[cC][rR][0-9][1-9]? {yylval.ival = atoi(yytext+2); return CP_REGISTER;}
[rR][0-7] {yylval.ival = yytext[1] - '0'; return REGISTER;}
.dw {return DIRECTIVE_WORD;}


nop {yylval.op = op(strdup(yytext),NOP); return OPCODE;};
add {yylval.op = op(strdup(yytext),ADD); return OPCODE;};
sub {yylval.op = op(strdup(yytext),SUB); return OPCODE;};
push {yylval.op = op(strdup(yytext),PUSH); return OPCODE;};
pop {yylval.op = op(strdup(yytext),POP); return OPCODE;};
mov {yylval.op = op(strdup(yytext),MOV); return OPCODE;};
and {yylval.op = op(strdup(yytext),AND); return OPCODE;};
or {yylval.op = op(strdup(yytext),OR); return OPCODE;};
xor {yylval.op = op(strdup(yytext),XOR); return OPCODE;};
not {yylval.op = op(strdup(yytext),NOT); return OPCODE;};
neg {yylval.op = op(strdup(yytext),NEG); return OPCODE;};
ld {yylval.op = op(strdup(yytext),LD); return OPCODE;};
st {yylval.op = op(strdup(yytext),ST); return OPCODE;};
cmp {yylval.op = op(strdup(yytext),CMP); return OPCODE;};
jmp {yylval.op = op(strdup(yytext),JMP); return OPCODE;};
call {yylval.op = op(strdup(yytext),CALL); return OPCODE;};
spec {yylval.op = op(strdup(yytext),SPEC); return OPCODE;};
shl {yylval.op = op(strdup(yytext),SHL); return OPCODE;};
shr {yylval.op = op(strdup(yytext),SHR); return OPCODE;};
rol {yylval.op = op(strdup(yytext),ROL); return OPCODE;};
rcl {yylval.op = op(strdup(yytext),RCL); return OPCODE;};
ldcp {yylval.op = op(strdup(yytext),LDCP); return OPCODE;};
stcp {yylval.op = op(strdup(yytext),STCP); return OPCODE;};

#-?[0-9]* {yylval.ival = atoi(yytext+1); return IMMEDIATE;};
#0x[0-9a-fA-F]* {yylval.ival = (int)strtol(yytext+1,NULL,16); return IMMEDIATE;};
-?[0-9]+ {yylval.ival = atoi(yytext); return NUMBER;}
0x[0-9a-fA-F]+ {yylval.ival = (int)strtol(yytext,NULL,16); return NUMBER;};
'[a-zA-z][a-zA-Z0-9]*' {printf("Identifier %s\n",yytext);yylval.sval = strdup(yytext); return IDENTIFIER;};
. {return yytext[0];}

%%
