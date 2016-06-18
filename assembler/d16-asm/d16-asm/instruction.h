//
//  instruction.h
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#ifndef instruction_h
#define instruction_h

#include <stdio.h>
#include <glib.h>
typedef struct{
    char* opcode;
    int rD;
    int rS;
    int immediate;
}Instruction;

Instruction* new_instruction(char*);
#endif /* instruction_h */
