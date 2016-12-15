//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "assembler.h"
#include "instruction.h"
#include "parser.h"
extern int   yyparse(FILE*);
extern FILE* yyin;
extern int   yydebug;
bool         binary_mode = false;

int main(int argc, char* const argv[]) {
    FILE* o = NULL;
    opterr = 0;
    int c;
    setenv("POSIXLY_CORRECT", "1", 1);
    while (optind < argc) {
        if ((c = getopt(argc, argv, "o:bh")) != -1) {
            switch (c) {
                case 'o':
                    o = fopen(optarg, "wb");
                    break;
                case 'b':
                    binary_mode = true;
                    break;
                case 'h':
                    puts("Usage: d16 [-bh] -o [outputfile] [input]\n");
                    exit(0);
                    break;
            }
        } else {
            if (yyin == NULL) {
                yyin = fopen(argv[optind], "r");
            }
            optind++;
        }
    }

    if (yyin == NULL) {
        fprintf(stderr, "d16: No input files specified\n");
        exit(-1);
    }
    if (o == NULL) {
        o = fopen("a.out", "wb");
    }

    init_hash_table();
    do {
        yyparse(o);
    } while (!feof(yyin));
    fclose(yyin);
    fclose(o);
    return 0;
}
