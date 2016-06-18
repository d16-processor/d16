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
    i->type = I_TYPE_NONE;
    return i;
}
Instruction* new_instruction_r(char* string, int rD){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    i->rD = rD;
    i->type= I_TYPE_R;
    return i;

}
Instruction* new_instruction_rr(char* string, int rD, int rS){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_RR;
    return i;
}
Instruction* new_instruction_ri(char* string, int rD, int imm){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    i->rD = rD;
    i->immediate = imm;
    i->type= I_TYPE_RIMM;
    return i;

}
Instruction* new_instruction_cr(char* string, int rD, int rS){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_CR;
    return i;
}
Instruction* new_instruction_rc(char* string, int rD, int rS){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = string;
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_RC;
    return i;
}