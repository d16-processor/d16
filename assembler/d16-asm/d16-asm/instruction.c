//
//  instruction.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include "instruction.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
char* opcodes_str[] = {
    "nop",
    "add",
    "sub",
    "push",
    "pop",
    "mov",
    "and",
    "or",
    "xor",
    "not",
    "neg",
    "ld",
    "st",
    "cmp",
    "jmp",
    "call",
    "spec",
    "shl",
    "shr",
    "rol",
    "rcl",
    "ldcp",
    "stcp"
};
struct _OP* op(char* str,enum _Op_Type op_type){
    OP *op = malloc(sizeof(op));
    op->str = str;
    op->type = op_type;
    return op;
}


Instruction* gen_instruction_internal(OP *op){
    Instruction* i = malloc(sizeof(Instruction));
    i->opcode = op->str;
    i->op_type = op->type;
    free(op);
    return i;
}
Instruction* new_instruction(OP* op){
    Instruction *i = gen_instruction_internal(op);
    i->type = I_TYPE_NONE;
    return i;
}
Instruction* new_instruction_r(OP* op, int rD){
    Instruction *i = gen_instruction_internal(op);
    i->rD = rD;
    i->type= I_TYPE_R;
    return i;

}
Instruction* new_instruction_rr(OP* op, int rD, int rS){
    Instruction *i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_RR;
    return i;
}
Instruction* new_instruction_ri(OP* op, int rD, int imm){
    Instruction *i = gen_instruction_internal(op);
    i->rD = rD;
    i->immediate = imm;
    i->op_type--;
    i->type= I_TYPE_RIMM;
    return i;

}
Instruction* new_instruction_cr(OP* op, int rD, int rS){
    Instruction *i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_CR;
    return i;
}
Instruction* new_instruction_rc(OP* op, int rD, int rS){
    Instruction *i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type= I_TYPE_RC;
    return i;
}