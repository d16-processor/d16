%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "main.h"
    #include "string.h"
    #include "instruction.h"
    #define YYDEBUG 1
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

%error-verbose

%token COMMA NEWLINE LBRACKET RBRACKET DIRECTIVE_WORD
%token <op> OPCODE
%token <sval> IDENTIFIER
%token <ival> REGISTER IMMEDIATE CP_REGISTER NUMBER
%type <instr> instruction
%type <list> program
%start start

%%
start: program {process_list($1);};
program:
    program instruction{$$=g_list_append($$, $2);}
	|program NEWLINE {$$=$1;}
    | {$$=NULL;}
;
instruction:
        OPCODE NEWLINE{$$=new_instruction($1);}
    |   OPCODE REGISTER NEWLINE {$$=new_instruction_r($1,$2);}
    |   OPCODE REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_rr($1,$2,$4);}
    |   OPCODE REGISTER COMMA IMMEDIATE NEWLINE{$$=new_instruction_ri($1,$2,$4);}
    |   OPCODE REGISTER COMMA CP_REGISTER NEWLINE{$$=new_instruction_rc($1,$2,$4);}
    |   OPCODE CP_REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_cr($1,$2,$4);}
    |   OPCODE REGISTER COMMA LBRACKET REGISTER RBRACKET NEWLINE{$$=new_instruction_rr($1,$2,$5);}
    |   OPCODE LBRACKET REGISTER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_rr($1,$6,$3);}
	|	OPCODE REGISTER COMMA LBRACKET IMMEDIATE RBRACKET NEWLINE{$$=new_instruction_ri($1,$2,$5);}
	|	OPCODE LBRACKET IMMEDIATE RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_ri($1,$6,$3);}
    |   DIRECTIVE_WORD NUMBER NEWLINE{int *i=malloc(sizeof(int)); *i = $2;$$=new_instruction_directive(D_WORD,i);};

;


%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}