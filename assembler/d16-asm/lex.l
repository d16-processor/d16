%{
    #include <stdio.h>
    #include "parser.h"
    #include "instruction.h"
    #define YY_NO_INPUT
    extern int yylex();
	int yyline = 1;
%}
%option header-file="lex.yy.h"
%option noyywrap
%option nounput

%%
\n {yyline++;return NEWLINE;};
[ \t]          ;
, {return COMMA;}
\x5b {return LBRACKET;};
\x5d {return RBRACKET;};
[cC][rR][0-9][1-9]? {yylval.ival = atoi(yytext+2); return CP_REGISTER;}
[rR][0-7] {yylval.ival = yytext[1] - '0'; return REGISTER;}
.dw {return DIRECTIVE_WORD;}
\.b {return BYTE_FLAG;}
\+ {return PLUS;}
\: {return COLON;}
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
adc {yylval.op = op(strdup(yytext), ADC); return OPCODE;};
sbb {yylval.op = op(strdup(yytext), SBB); return OPCODE;};

\.nv {yylval.ival = NV; return CONDITION_CODE;}
\.eq {yylval.ival = EQ; return CONDITION_CODE;}
\.ne {yylval.ival = NE; return CONDITION_CODE;}
\.os {yylval.ival = OS; return CONDITION_CODE;}
\.oc {yylval.ival = OC; return CONDITION_CODE;}
\.hi {yylval.ival = HI; return CONDITION_CODE;}
\.ls {yylval.ival = LS; return CONDITION_CODE;}
\.p {yylval.ival = P; return CONDITION_CODE;}
\.n {yylval.ival = N; return CONDITION_CODE;}
\.cs {yylval.ival = CS; return CONDITION_CODE;}
\.cc {yylval.ival = CC; return CONDITION_CODE;}
\.ge {yylval.ival = GE; return CONDITION_CODE;}
\.g {yylval.ival = G; return CONDITION_CODE;}
\.le {yylval.ival = LE; return CONDITION_CODE;}
\.l {yylval.ival = L; return CONDITION_CODE;}
\.al {yylval.ival = AL; return CONDITION_CODE;}

#-?[0-9]* {yylval.ival = atoi(yytext+1); return IMMEDIATE;};
#0x[0-9a-fA-F]* {yylval.ival = (int)strtol(yytext+1,NULL,16); return IMMEDIATE;};
-?[0-9]+ {yylval.ival = atoi(yytext); return NUMBER;}
0x[0-9a-fA-F]+ {yylval.ival = (int)strtol(yytext,NULL,16); return NUMBER;};
[a-zA-Z][a-zA-Z0-9]*\: {
	char* label = strdup(yytext);
	char* colon = strchr(label,':');
	*colon = '\0';
	yylval.sval = label;
	printf("label: %s\n",label);
	return LABEL;
}
[a-zA-Z][a-zA-Z0-9]* {printf("Identifier %s\n",yytext);yylval.sval = strdup(yytext); return IDENTIFIER;};

. {return yytext[0];}

%%
