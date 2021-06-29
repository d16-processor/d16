%{
    #include <stdio.h>
    #include "parser.h"
    #include "instruction.h"
    #include <glib.h>
    #define YY_NO_INPUT
    extern int yylex();
	int yyline = 1;
%}
%option header-file="lex.yy.h"
%option noyywrap
%option nounput
%option batch
%option caseless
%%
\;.*\n {yyline++;return NEWLINE;} ;
\n {yyline++;return NEWLINE;};
[ \t]          ;
, {return COMMA;}
\x5b {return LBRACKET;};
\x5d {return RBRACKET;};
[cC][rR][0-9][0-9]? {yylval.ival = atoi(yytext+2); return CP_REGISTER;}
flags {yylval.ival = 0; return CP_REGISTER;}
[rR][0-7] {yylval.ival = yytext[1] - '0'; return REGISTER;}
\.dw {return DIRECTIVE_WORD;}
\.db {return DIRECTIVE_BYTE;}
\.align {return DIRECTIVE_ALIGN;}
\.dd {return DIRECTIVE_DWORD;}
\.asciz {return DIRECTIVE_ASCIZ;}
\.ascii {return DIRECTIVE_ASCII;}
\.global {return DIRECTIVE_GLOBAL;}
\.b {return BYTE_FLAG;}
\+ {return PLUS;}
\: {return COLON;}
[0-9]b {yylval.ival = *yytext-'0'; return BACK_REFERENCE;}
[0-9]f {yylval.ival = *yytext-'0'; return FORWARD_REFERENCE;}
[0-9]\: {yylval.ival = *yytext-'0'; return LOCAL_LABEL;}
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
ret {yylval.op = op(strdup(yytext),SPEC); return OPCODE;};
shl {yylval.op = op(strdup(yytext),SHL); return OPCODE;};
shr {yylval.op = op(strdup(yytext),SHR); return OPCODE;};
rol {yylval.op = op(strdup(yytext),ROL); return OPCODE;};
rcl {yylval.op = op(strdup(yytext),RCL); return OPCODE;};
ldcp {yylval.op = op(strdup(yytext),LDCP); return OPCODE;};
stcp {yylval.op = op(strdup(yytext),STCP); return OPCODE;};
adc {yylval.op = op(strdup(yytext), ADC); return OPCODE;};
sbb {yylval.op = op(strdup(yytext), SBB); return OPCODE;};
set {yylval.op = op(strdup(yytext), SET); return OPCODE;};
test {yylval.op = op(strdup(yytext), TEST); return OPCODE;};
kill {yylval.op = op(strdup(yytext), KILL); return OPCODE;};
pushlr {yylval.op = op(strdup(yytext),PUSHLR); return OPCODE;};
sar {yylval.op = op(strdup(yytext),SAR); return OPCODE;};
flush {yylval.op = op(strdup(yytext),FLUSH); return OPCODE;};
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
[a-zA-Z_][a-zA-Z0-9_]*\: {
	char* label = strdup(yytext);
	char* colon = strchr(label,':');
	*colon = '\0';
	yylval.sval = label;
	return LABEL;
}
[a-zA-Z_][a-zA-Z0-9_]* {yylval.sval = strdup(yytext); return IDENTIFIER;};
L?\"(\\.|[^\\"])*\" {
    char* str = strdup(yytext+1);
    char* end = str + (strlen(str)-1);
    *end = '\0';
    yylval.sval = g_strcompress(str);
    free(str);
    return STRING;

}
\'.*\' {
    char *str = strdup(yytext+1);
    char *end = str + (strlen(str) - 1);
    *end = '\0';
    char *compr = g_strcompress(str);
    yylval.ival = compr[0];
    g_free(compr);
    free(str);
    return NUMBER;
}
. {return yytext[0];}

%%
struct yy_buffer_state* read_string(char* string){
    return yy_scan_string(string);
}
