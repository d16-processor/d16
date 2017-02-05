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
#include "macro.h"
#include "parser.h"
extern struct yy_buffer_state* read_string(char*);
extern void                    yy_delete_buffer(struct yy_buffer_state*);
extern int                     yyparse(FILE*);
extern FILE*                   yyin;
extern int                     yydebug;
bool                           binary_mode = false;

int main(int argc, char* const argv[]) {
    FILE* o = NULL;
    FILE* in = NULL;
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
            if (in == NULL) {
                in = fopen(argv[optind], "r");
            }
            optind++;
        }
    }

    if (in == NULL) {
        fprintf(stderr, "d16: No input files specified\n");
        exit(-1);
    }
    if (o == NULL) {
        o = fopen("a.out", "wb");
    }
    GString* input = read_replace_macros(in);
    struct yy_buffer_state* yystate = read_string(input->str);
    init_hash_table();
    yyparse(o);
    yy_delete_buffer(yystate);
    g_string_free(input, true);
    fclose(o);
    return 0;
}
