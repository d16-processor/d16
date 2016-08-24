//
//  instruction.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include "instruction.h"
GHashTable* labels;
extern bool binary_mode;
void        init_hash_table(void) {
    labels = g_hash_table_new(g_str_hash, g_str_equal);
}
char* opcodes_str[] = {"nop", "add", "sub", "push", "pop",  "mov",
                       "and", "or",  "xor", "not",  "neg",  "ld",
                       "st",  "cmp", "jmp", "call", "spec", "shl",
                       "shr", "rol", "rcl", "ldcp", "stcp"};
static int  local_count_table[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
struct _OP* op(char* str, enum _Op_Type op_type) {
    OP* op = calloc(1, sizeof(op));
    op->str = str;
    op->type = op_type;
    return op;
}

Instruction* gen_instruction_internal(OP* op) {
    Instruction* i = calloc(1, sizeof(Instruction));
    i->opcode = op->str;
    i->op_type = op->type;
    i->address = NULL;
    free(op);
    op = NULL;
    return i;
}
Instruction* new_instruction(OP* op) {
    Instruction* i = gen_instruction_internal(op);
    i->type = I_TYPE_NONE;
    return i;
}
Instruction* new_instruction_r(OP* op, int rD) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    if (i->op_type == JMP) {
        printf("Cannot use this function for generating jump instructions!\n");
        exit(1);
    } else {
        i->type = I_TYPE_R;
    }
    return i;
}
Instruction* new_instruction_rr(OP* op, int rD, int rS) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type = I_TYPE_RR;
    return i;
}
Instruction* new_instruction_ri(OP* op, int rD, Address* addr) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->address = addr;
    i->op_type |= 0x80;
    i->type = I_TYPE_RIMM;
    return i;
}
Instruction* new_instruction_cr(OP* op, int rD, int rS) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type = I_TYPE_CR;
    return i;
}
Instruction* new_instruction_rc(OP* op, int rD, int rS) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->type = I_TYPE_RC;
    return i;
}
Instruction* new_instruction_mem(OP* op, int rD, int rS, bool byte) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->rS = rS;
    i->flags = byte ? M_BYTE : M_NONE;
    i->type = I_TYPE_MEM;
    return i;
}
Instruction* new_instruction_memi(OP* op, int rD, int rS, Address* addr,
                                  bool byte, bool displacement) {
    Instruction* i = gen_instruction_internal(op);
    i->op_type |= 0x80;
    i->rD = rD;
    i->rS = rS;
    i->address = addr;
    i->flags = byte ? M_BYTE : M_NONE;
    i->flags |= displacement ? M_DISP : M_NONE;
    i->type = I_TYPE_MEMI;
    return i;
}
Instruction* new_instruction_jmp(OP* op, int rD, condition_code cc) {
    Instruction* i = gen_instruction_internal(op);
    i->rD = rD;
    i->cc = cc;
    i->type = I_TYPE_JMP;
    return i;
}
Instruction* new_instruction_jmpi(OP* op, Address* addr, condition_code cc) {
    Instruction* i = gen_instruction_internal(op);
    i->address = addr;
    i->op_type |= 0x80;
    i->rD = 0;
    i->cc = cc;
    i->type = I_TYPE_JMPI;

    return i;
}
Instruction* new_instruction_label(char* name) {
    Instruction* i = calloc(1, sizeof(Instruction));
    i->type = I_TYPE_LABEL;
    i->opcode = name;
    g_hash_table_insert(labels, name, NULL);
    return i;
}
Instruction* new_instruction_local_label(int num) {
    Instruction* i = calloc(1, sizeof(Instruction));
    i->type = I_TYPE_LOCAL_LABEL;
    char* lblname = malloc(16);
    sprintf(lblname, ".L%d\002%d", num, local_count_table[num]);
    ++local_count_table[num];
    i->opcode = lblname;
    return i;
}
Instruction* new_instruction_directive(Dir_Type type, void* data) {
    Instruction* i = calloc(1, sizeof(Instruction));
    i->dir_type = type;
    switch (type) {
        case D_WORD:
            i->opcode = strdup(".db");
            break;
        case D_ASCII:
            i->opcode = strdup(".ascii");
            break;
        case D_ASCIZ:
            i->opcode = strdup(".asciz");
            break;
    }
    i->type = I_TYPE_DIRECTIVE;
    i->dir_data = data;
    return i;
}

void set_label_address(const char* label, unsigned int address) {
    g_hash_table_insert(labels, (void*)label, GINT_TO_POINTER(address));
}
void resolve_address(Address* addr) {
    if (addr != NULL) {
        if (addr->type == ADDR_LABEL) {
            if (g_hash_table_contains(labels, addr->lblname)) {
                addr->immediate =
                    GPOINTER_TO_INT(g_hash_table_lookup(labels, addr->lblname));

            } else if (binary_mode) {
                fprintf(stderr, "No label named %s\n", addr->lblname);
                exit(1);
            }
        }
    }
}
uint8_t build_reg_selector(Instruction* i) {
    if (i->type == I_TYPE_RR) {
        return (i->rS & 0x7) << 3 | (i->rD & 0x7);
    } else if (i->type == I_TYPE_R || i->type == I_TYPE_RIMM) {
        return i->rD & 0x7;
    }
    return 0;
}
uint8_t build_mem_selector(Instruction* i) {
    return (i->flags & 3) << 6 | (i->rS & 7) << 3 | (i->rD & 0x7);
}
uint8_t build_shift_selector(Instruction* i) {
    return i->rD | (i->address->immediate & 0xF) << 3;
}
uint8_t build_jmp_selector(Instruction* i) {
    return (i->cc & 0xf) << 3 | i->rD;
}

int instruction_length(Instruction* i) {
    if (i->type == I_TYPE_DIRECTIVE) {
        if (i->dir_type == D_ASCIZ) {
            char* str = (char*)i->dir_data;
            int   len = (int)(strlen(str) + 1 +
                            1); // 1 for ending NULL, 1 for rounding up
            return len / 2;

        } else if (i->dir_type == D_ASCII) {
            char* str = (char*)i->dir_data;
            int   len = (int)(strlen(str) + 1); // 1 for ending NULL
            return len / 2;
        } else {
            return 1;
        }
    }
    if (i->type == I_TYPE_LABEL || i->type == I_TYPE_LOCAL_LABEL) {
        return 0;
    }
    if (i->type == I_TYPE_RIMM) {
        if (i->op_type == MOVI && i->address->type == ADDR_IMMEDIATE) {
            if (((unsigned)i->address->immediate) < 255) {
                i->op_type = MOVB;
                return 1;
            }
        }
        if (i->op_type == MOVB) {
            return 1;
        }
        return 2;
    } else if (i->type == I_TYPE_MEMI) {
        return 2;
    } else if (i->type == I_TYPE_JMPI) {
        return 2;
    }

    return 1;
}
char* cc_strs[] = {"nv", "eq", "ne", "os", "oc", "hi", "ls", "p",
                   "n",  "cs", "cc", "ge", "g",  "le", "l",  "al"};
char* cc_to_str(condition_code cc) { return cc_strs[cc]; }
