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
    struct _OP* op;
}
%token COMMA NEWLINE
%token <op> OPCODE
%token <sval> IDENTIFIER
%token <ival> REGISTER IMMEDIATE CP_REGISTER
%type <instr> instruction
%type <list> program
%start start
%%
start: program {print_list($1);};
program:
    program instruction NEWLINE{$$=g_list_append($$, $2);}
    | {$$=NULL;}
;
instruction:
        OPCODE {$$=new_instruction(strdup($1->str));}
    |   OPCODE REGISTER {$$=new_instruction_r(strdup($1->str),$2);}
    |   OPCODE REGISTER COMMA REGISTER{$$=new_instruction_rr(strdup($1->str),$2,$4);}
    |   OPCODE REGISTER COMMA IMMEDIATE{$$=new_instruction_ri(strdup($1->str),$2,$4);}
    |   OPCODE REGISTER COMMA CP_REGISTER {$$=new_instruction_rc(strdup($1->str),$2,$4);}
    |   OPCODE CP_REGISTER COMMA REGISTER {$$=new_instruction_cr(strdup($1->str),$2,$4);}
;


%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}