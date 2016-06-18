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
typedef enum{
    I_TYPE_NONE,
    I_TYPE_R,
    I_TYPE_RR,
    I_TYPE_RIMM,
    I_TYPE_RC,
    I_TYPE_CR
}Instruction_Type;
struct _Instruction{
    char* opcode;
    int rD;
    int rS;
    int immediate;
    Instruction_Type type;
};
typedef struct _Instruction Instruction;

Instruction* new_instruction(char*);
Instruction* new_instruction_r(char*,int);
Instruction* new_instruction_rr(char*,int,int);
Instruction* new_instruction_ri(char*,int,int);
Instruction* new_instruction_cr(char*,int,int);
Instruction* new_instruction_rc(char*,int,int);
#endif /* instruction_h */
