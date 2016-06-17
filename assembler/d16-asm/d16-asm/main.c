//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include "y.tab.h"
extern int yyparse (void);
extern FILE* yyin;
int main(int argc, const char * argv[]) {
    if(argc != 2){
        fprintf(stderr, "Usage stackyII-cc [file]\n");
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
