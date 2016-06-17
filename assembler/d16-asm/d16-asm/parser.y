%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "main.h"
    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;
    void yyerror(const char* s);
    %}
%union{
    char* sval;
}
%token <sval> IDENTIFIER
%start start
%%
start: IDENTIFIER {printf("%s\n",$1);};
%%
void yyerror(const char* s){
    fprintf(stderr, "Parse error: %s\n",s);
    exit(1);
}