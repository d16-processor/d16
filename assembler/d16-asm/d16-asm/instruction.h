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
    I_TYPE_CR,
    I_TYPE_DIRECTIVE 
}Instruction_Type;
enum _Dir_Type{
    D_WORD,
    D_ASCIZ,
};
typedef enum _Dir_Type Dir_Type;
enum _Op_Type{
    NOP=0,
    ADDI,
    ADD,
    SUBI,
    SUB,
    PUSHI,
    PUSH,
    POP,
    MOVB,
    MOVI=0x10,
    MOV,
    ANDI,
    AND,
    ORI,
    OR,
    XORI,
    XOR,
    NOT,
    NEG,
    LDI,
    LD,
    STI,
    ST,
    CMPI,
    CMP,
    JMPI,
    JMP,
    CALLI,
    CALL,
    SPEC,
    SHLI,
    SHL,
    SHRI,
    SHR,
    ROLI,
    ROL,
    RCLI,
    RCL,
    LDCP,
    STCP
} ;
struct _OP{
    char* str;
    enum _Op_Type type;
} ;
typedef struct _OP OP;
typedef enum _Op_Type Op_Type;
struct _Instruction{
    char* opcode;
    int rD;
    int rS;
    int immediate;
    Op_Type op_type;
    Instruction_Type type;
    Dir_Type dir_type;
    void* dir_data;
};
typedef struct _Instruction Instruction;
struct _OP* op(char*,enum _Op_Type);

Instruction* new_instruction(OP*);
Instruction* new_instruction_r(OP*,int);
Instruction* new_instruction_rr(OP*,int,int);
Instruction* new_instruction_ri(OP*,int,int);
Instruction* new_instruction_cr(OP*,int,int);
Instruction* new_instruction_rc(OP*,int,int);
Instruction* new_instruction_directive(Dir_Type, void* data);
int instruction_length(Instruction*);
uint8_t build_reg_selector(Instruction *);
uint8_t build_shift_selector(Instruction* i);
#endif /* instruction_h */
