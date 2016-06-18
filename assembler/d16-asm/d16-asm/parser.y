%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "main.h"
    #include "string.h"
    #include "instruction.h"
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;
    void yyerror(const char* s);
    %}
%union{
    char* sval;
    struct _GList* list;
    int ival;
    struct _Instruction* instr;
}
%token COMMA
%token <sval> IDENTIFIER
%token <ival> REGISTER IMMEDIATE CP_REGISTER
%type <instr> instruction
%type <list> program
%start start
%%
start: program {print_list($1);};
program:
    program instruction {$$=g_list_append($$, $2);}
    | {$$=NULL;}
;
instruction:
        IDENTIFIER {$$=new_instruction(strdup($1));}
    |   IDENTIFIER REGISTER {$$=new_instruction_r(strdup($1),$2);}
    |   IDENTIFIER REGISTER COMMA REGISTER{$$=new_instruction_rr(strdup($1),$2,$4);}
    |   IDENTIFIER REGISTER COMMA IMMEDIATE{$$=new_instruction_ri(strdup($1),$2,$4);}
    |   IDENTIFIER REGISTER COMMA CP_REGISTER {$$=new_instruction_rc(strdup($1),$2,$4);}
    |   IDENTIFIER CP_REGISTER COMMA REGISTER {$$=new_instruction_cr(strdup($1),$2,$4);}
;


%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}