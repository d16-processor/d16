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
}
%token <sval> IDENTIFIER
%type <list> program
%start start
%%
start: program {print_list($1);};
program:
    program IDENTIFIER {$$=g_list_append($$, new_instruction(strdup($2)));}
    | {$$=NULL;}
;


%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}