//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <glib.h>
#include "instruction.h"
extern int yyparse (void);
extern FILE* yyin;
int main(int argc, const char * argv[]) {
    if(argc != 2){
        fprintf(stderr, "Usage d16-asm [file]\n");
        exit(-1);
    }
    FILE* f = fopen(argv[1], "r");
    if(f == NULL){
        fprintf(stderr, "Error opening file %s\n",argv[1]);
        exit(-1);
    }
    yyin = f;
    do {
        yyparse();
    } while (!feof(yyin));
    fclose(f);
    return 0;
}
void print_elem(void* element, void* data){
    Instruction* i = (Instruction* ) element;
    switch (i->type) {
        case I_TYPE_NONE:
            printf("%s\n",i->opcode);
            break;
        case I_TYPE_R:
            printf("%s r%d\n", i->opcode, i->rD);
            break;
        case I_TYPE_RR:
            printf("%s r%d, r%d\n",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RIMM:
            printf("%s r%d, #%d\n",i->opcode,i->rD,i->immediate);
            break;
        case I_TYPE_CR:
            printf("%s cr%d, r%d\n",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RC:
            printf("%s r%d, cr%d\n", i->opcode, i->rD, i->rS);
            break;

    }
    
}
void free_elem(void* element){
    Instruction *i = (Instruction*)element;
    free(i->opcode);
    free(i);
}
void print_list(struct _GList* list){
    g_list_foreach(list, &print_elem, NULL);
    g_list_free_full(list, &free_elem);
}