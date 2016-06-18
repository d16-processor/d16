//
//  instruction.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include "instruction.h"
#include <stdlib.h>
Instruction* new_instruction(char* string){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    return i;
}