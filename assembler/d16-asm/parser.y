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

%token COMMA NEWLINE LBRACKET RBRACKET DIRECTIVE_WORD BYTE_FLAG PLUS
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
//Instruction* new_instrution_memi(OP* op, int rD, int rS, int immediate, bool byte, bool displacement);
instruction:
        OPCODE NEWLINE{$$=new_instruction($1);}
    |   OPCODE REGISTER NEWLINE {$$=new_instruction_r($1,$2);}
    |   OPCODE REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_rr($1,$2,$4);}
    |   OPCODE REGISTER COMMA IMMEDIATE NEWLINE{$$=new_instruction_ri($1,$2,$4);}
    |   OPCODE REGISTER COMMA CP_REGISTER NEWLINE{$$=new_instruction_rc($1,$2,$4);}
    |   OPCODE CP_REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_cr($1,$2,$4);}
    |   OPCODE REGISTER COMMA LBRACKET REGISTER RBRACKET NEWLINE{$$=new_instruction_mem($1,$2,$5,false);}
    |   OPCODE LBRACKET REGISTER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_mem($1,$6,$3,false);}
	|   OPCODE BYTE_FLAG REGISTER COMMA LBRACKET REGISTER RBRACKET NEWLINE{$$=new_instruction_mem($1,$3,$6,true);}
	|   OPCODE BYTE_FLAG LBRACKET REGISTER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_mem($1,$7,$4,true);}
	|	OPCODE REGISTER COMMA LBRACKET NUMBER RBRACKET NEWLINE{$$=new_instruction_memi($1,$2,0,$5,false,false);}
	|	OPCODE LBRACKET NUMBER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,0,$6,$3,false,false);}
	|	OPCODE BYTE_FLAG REGISTER COMMA LBRACKET NUMBER RBRACKET NEWLINE{$$=new_instruction_memi($1,$3,0,$6,true,false);}
	|	OPCODE BYTE_FLAG LBRACKET NUMBER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,0,$7,$4,true,false);}
	|	OPCODE REGISTER COMMA LBRACKET REGISTER PLUS NUMBER RBRACKET NEWLINE{$$=new_instruction_memi($1,$2,$5,$7,false,true);}
	|	OPCODE LBRACKET REGISTER PLUS NUMBER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$8,$3,$5,false,true);}
	|	OPCODE BYTE_FLAG REGISTER COMMA LBRACKET REGISTER PLUS NUMBER RBRACKET NEWLINE{$$=new_instruction_memi($1,$3,$6,$8,true,true);}
	|	OPCODE BYTE_FLAG LBRACKET REGISTER PLUS NUMBER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$9,$4,$6,true,true);}
    |   DIRECTIVE_WORD NUMBER NEWLINE{int *i=malloc(sizeof(int)); *i = $2;$$=new_instruction_directive(D_WORD,i);};

;


%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}