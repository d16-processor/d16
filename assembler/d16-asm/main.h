//
//  main.h
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#ifndef main_h
#define main_h
#include <glib.h>
#include "instruction.h"
void process_list(struct _GList*);
void print_elem(void* element, void* data);
void free_elem(void* element);
void assemble_instruction(Instruction* i, uint16_t** data);
#endif /* main_h */
