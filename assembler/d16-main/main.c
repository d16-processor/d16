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
#include <unistd.h>
extern int yyparse (FILE*);
extern FILE* yyin;
extern int yydebug;
bool binary_mode = false;
int main(int argc, char * const argv[]) {
    FILE *f,*o;
    opterr = 0;
    int c;
    while ((c=getopt(argc,argv,"o:bh")) != -1){
        switch(c){
            case 'o':
                o = fopen(optarg,"wb");
                break;
            case 'b':
                binary_mode = true;
                break;
            case 'h':
                puts("Usage: d16 [-bh] -o [outputfile] [input]\n");
                exit(0);
                break;
        }
    }
    if(optind<argc) f = fopen(argv[optind],"r");
    else{
        fprintf(stderr,"d16: No input files specified\n");
        exit(-1);
    }
    if(o==NULL){
        o=fopen("a.out","wb");
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
