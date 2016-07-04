//
//  main.h
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//
#include <glib.h>
#include "instruction.h"

#ifndef main_h
#define main_h
void process_list(struct _GList* list, FILE* output_file);
void print_elem(void* element, void* data);
void free_elem(void* element);
void assemble_instruction(Instruction* i, uint16_t** data);
#endif /* main_h */
