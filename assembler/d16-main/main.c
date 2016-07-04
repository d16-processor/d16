//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include "assembler.h"
#include <string.h>
#include "instruction.h"

extern int yyparse (FILE* output_file);
extern FILE* yyin;
int main(int argc, const char * argv[]) {
    
    if(argc != 3){
        fprintf(stderr, "Usage d16-asm [file] [output]\n");
        exit(-1);
    }
    FILE* f = fopen(argv[1], "r");
    FILE* o = fopen(argv[2], "wb");
    if(f == NULL){
        fprintf(stderr, "Error opening file %s\n",argv[1]);
        exit(-1);
    }
    if(o == NULL){
        fprintf(stderr, "Error opening file %s for writing\n",argv[2]);
        exit(2);
    }
    yyin = f;

	  init_hash_table();
    do {
        yyparse(o);
    } while (!feof(yyin));
    fclose(f);
    fclose(o);
    return 0;
}
