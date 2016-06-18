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
    SHL,
    SHR,
    ROL,
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
};
typedef struct _Instruction Instruction;
struct _OP* op(char*,enum _Op_Type);

Instruction* new_instruction(OP*);
Instruction* new_instruction_r(OP*,int);
Instruction* new_instruction_rr(OP*,int,int);
Instruction* new_instruction_ri(OP*,int,int);
Instruction* new_instruction_cr(OP*,int,int);
Instruction* new_instruction_rc(OP*,int,int);
int instruction_length(Instruction*);
uint8_t build_reg_selector(Instruction *);
#endif /* instruction_h */
