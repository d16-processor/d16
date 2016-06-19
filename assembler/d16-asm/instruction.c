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
    OP *op = calloc(1,sizeof(op));
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
    i->op_type|= 0x80;
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
Instruction* new_instruction_directive(Dir_Type type, void* data){
    Instruction *i = calloc(1, sizeof(Instruction));
    i->dir_type = type;
    switch (type) {
        case D_WORD:
            i->opcode = strdup(".db");
            break;
        case D_ASCIZ:
            i->opcode = strdup(".asciz");
            break;
    }
    i->type = I_TYPE_DIRECTIVE;
    i->dir_data = data;
    return i;
}
uint8_t build_reg_selector(Instruction* i){
    if(i->type == I_TYPE_RR){
        return (i->rS & 0x7)<<3 | (i->rD &0x7);
    }
    else if(i->type == I_TYPE_R || i->type == I_TYPE_RIMM){
        return i->rD & 0x7;
    }
    return 0;
}
uint8_t build_shift_selector(Instruction* i){
    return i->rD || (i->immediate & 0xF)<<3;
}

int instruction_length(Instruction* i){
    if(i->type == I_TYPE_RIMM){
        if(i->op_type == MOVI && ((unsigned int)i->immediate) < 255 ){
            i->op_type = MOVB;
            return 1;
        }
        else if(i->op_type == SHLI || i->op_type == SHRI || i->op_type == ROLI || i->op_type == RCLI){
            return 1;
        }
        if(i->op_type == MOVB){
            return 1;
        }
        return 2;
    }

    return 1;
}