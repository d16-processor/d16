%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "assembler.h"
    #include "string.h"
    #include "instruction.h"
    #define YYDEBUG 1
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;
    extern int yyline;
    void yyerror(FILE * output_file, const char* s);
%}

%union{
    char* sval;
    struct _GList* list;
    int ival;
    struct _Instruction* instr;
    struct _OP* op;
	struct _Addr* addr;
}

%error-verbose

%token COMMA NEWLINE LBRACKET RBRACKET DIRECTIVE_WORD BYTE_FLAG PLUS COLON DIRECTIVE_ASCIZ DIRECTIVE_ASCII
%token <op> OPCODE
%token <ival> CONDITION_CODE
%token <sval> IDENTIFIER LABEL STRING
%token <ival> REGISTER IMMEDIATE CP_REGISTER NUMBER BACK_REFERENCE FORWARD_REFERENCE LOCAL_LABEL
%type <instr> instruction
%type <list> program
%type <addr> address
%parse-param {FILE* output_file}
%start start

%%
start: program {process_list($1, output_file);};
program:
    program instruction{$$=g_list_append($$, $2);}
	|program NEWLINE {$$=$1;}
    | {$$=NULL;}
;
address:
		IMMEDIATE {$$=addr_from_immediate($1);}
	|	IDENTIFIER {$$=addr_from_label($1);}
	|	NUMBER	{$$=addr_from_immediate($1);}
	|   BACK_REFERENCE {$$=addr_from_reference($1,0);}
	|   FORWARD_REFERENCE {$$=addr_from_reference($1,1);}

;
//Instruction* new_instrution_memi(OP* op, int rD, int rS, int immediate, bool byte, bool displacement);
instruction:
        OPCODE NEWLINE{$$=new_instruction($1);}
    |   OPCODE REGISTER NEWLINE {
		if($1->type == JMP ){
			$$=new_instruction_jmp($1,$2,AL);
		}else{
			$$=new_instruction_r($1,$2);
		}
	}
    |   OPCODE REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_rr($1,$2,$4);}
    |   OPCODE REGISTER COMMA address NEWLINE{$$=new_instruction_ri($1,$2,$4);}
    |   OPCODE REGISTER COMMA CP_REGISTER NEWLINE{$$=new_instruction_rc($1,$2,$4);}
    |   OPCODE CP_REGISTER COMMA REGISTER NEWLINE{$$=new_instruction_cr($1,$2,$4);}
    |   OPCODE REGISTER COMMA LBRACKET REGISTER RBRACKET NEWLINE{$$=new_instruction_mem($1,$2,$5,false);}//ld r3,[r4]
    |   OPCODE LBRACKET REGISTER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_mem($1,$6,$3,false);}//st [r4],r3

	|   OPCODE BYTE_FLAG REGISTER COMMA LBRACKET REGISTER RBRACKET NEWLINE{$$=new_instruction_mem($1,$3,$6,true);}//ld.b r3,[r4]
	|   OPCODE BYTE_FLAG LBRACKET REGISTER RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_mem($1,$7,$4,true);}//st.b [r4],r3

	|	OPCODE REGISTER COMMA LBRACKET address RBRACKET NEWLINE{$$=new_instruction_memi($1,$2,0,$5,false,false);}//ld r3,[23]
	|	OPCODE LBRACKET address RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$6,0,$3,false,false);}//st [23], r3

	|	OPCODE BYTE_FLAG REGISTER COMMA LBRACKET address RBRACKET NEWLINE{$$=new_instruction_memi($1,$3,0,$6,true,false);}//ld.b r3,[23]
	|	OPCODE BYTE_FLAG LBRACKET address RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$7,0,$4,true,false);}//st.b [23],r3

	|	OPCODE REGISTER COMMA LBRACKET REGISTER PLUS address RBRACKET NEWLINE{$$=new_instruction_memi($1,$2,$5,$7,false,true);}
	|	OPCODE LBRACKET REGISTER PLUS address RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$8,$3,$5,false,true);}
	|	OPCODE BYTE_FLAG REGISTER COMMA LBRACKET REGISTER PLUS address RBRACKET NEWLINE{$$=new_instruction_memi($1,$3,$6,$8,true,true);}
	|	OPCODE BYTE_FLAG LBRACKET REGISTER PLUS address RBRACKET COMMA REGISTER NEWLINE{$$=new_instruction_memi($1,$9,$4,$6,true,true);}
	|   OPCODE address NEWLINE {$$=new_instruction_jmpi($1,$2,AL);} //jump
	|   OPCODE CONDITION_CODE address NEWLINE {$$=new_instruction_jmpi($1,$3,$2);}
	|   OPCODE CONDITION_CODE REGISTER NEWLINE {$$=new_instruction_jmp($1,$3,$2);}
    |   DIRECTIVE_WORD NUMBER NEWLINE{int *i=malloc(sizeof(int)); *i = $2;$$=new_instruction_directive(D_WORD,i);}
    |   DIRECTIVE_ASCIZ STRING NEWLINE {$$=new_instruction_directive(D_ASCIZ,$2);}
    |   DIRECTIVE_ASCII STRING NEWLINE {$$=new_instruction_directive(D_ASCII,$2);}
	|   LABEL {$$=new_instruction_label(strdup($1));}
	|   LOCAL_LABEL {$$=new_instruction_local_label($1);}

;


%%
void yyerror(FILE * output_file, const char* s){
    fprintf(stderr, "Parse error on line %d: %s\n",yyline,s);
    exit(1);
}
