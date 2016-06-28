//
//  instruction.h
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#ifndef instruction_h
#define instruction_h
#include <inttypes.h>
#include <stdio.h>
#include <glib.h>
#include <stdbool.h>
#include "label.h"
typedef enum{
    I_TYPE_NONE,
    I_TYPE_R,
    I_TYPE_RR,
    I_TYPE_RIMM,
    I_TYPE_RC,
    I_TYPE_CR,
    I_TYPE_DIRECTIVE,
	I_TYPE_MEM,
	I_TYPE_MEMI,
	I_TYPE_JMP,
	I_TYPE_JMPI,
	I_TYPE_LABEL
}Instruction_Type;
typedef enum {
	M_NONE=0,
	M_BYTE=2,
	M_DISP=1
} mem_flags;
enum _Dir_Type{
    D_WORD,
    D_ASCIZ,
};
typedef enum _condition_code{
	NV=0,
	EQ=1,
	NE,
	OS,
	OC,
	HI,
	LS,
	P,
	N,
	CS,
	CC,
	GE,
	G,
	LE,
	L,
	AL=15
} condition_code;
typedef enum _Dir_Type Dir_Type;
enum _Op_Type{
	NOP=0,
	ADD,
	SUB,
	PUSH,
	POP,
	MOVB,
	MOV=0x0D,
	AND,
	OR,
	XOR,
	NOT,
	NEG,
	LD,
	ST,
	CMP,
	JMP,
	CALL,
	SPEC,
	SHL,
	SHR,
	ROL,
	RCL,
	LDCP,
	STCP,
	ADC,
	SBB,

	ADDI=0x81,
	SUBI=0x82,
	PUSHI=0x83,
	MOVI=0x8D,
	ANDI=0x8e,
	ORI=0x8f,
	XORI=0x90,
	LDI=0x93,
	STI=0x94,
	CMPI=0x95,
	JMPI=0x96,
	CALLI=0x97,
	SHLI=0x99,
	SHRI=0x9a,
	ROLI=0x9b,
	RCLI=0x9c,
	ADCI=0x9f,
	SBBI=0xA0
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
    Address* address;
	condition_code cc;
    Op_Type op_type;
    Instruction_Type type;
    Dir_Type dir_type;
	mem_flags flags;
    void* dir_data;
};
typedef struct _Instruction Instruction;
struct _OP* op(char*,enum _Op_Type);
void init_hash_table(void);
Instruction* new_instruction(OP*);
Instruction* new_instruction_r(OP*,int);
Instruction* new_instruction_rr(OP*,int,int);
Instruction* new_instruction_ri(OP*,int,Address* addr);
Instruction* new_instruction_cr(OP*,int,int);
Instruction* new_instruction_rc(OP*,int,int);
Instruction* new_instruction_memi(OP* op, int rD, int rS, Address* addr, bool byte, bool displacement);
Instruction* new_instruction_mem(OP* op, int rD, int rS, bool byte);
Instruction* new_instruction_jmp(OP* op, int rD, condition_code cc);
Instruction* new_instruction_jmpi(OP* op, Address* addr, condition_code cc);
Instruction* new_instruction_directive(Dir_Type, void* data);
Instruction* new_instruction_label(char* name);
void set_label_address(const char* label_name, unsigned int address);
void resolve_address(Address* addr);
char* cc_to_str(condition_code cc);
int instruction_length(Instruction*);
uint8_t build_reg_selector(Instruction *);
uint8_t build_shift_selector(Instruction* i);
uint8_t build_mem_selector(Instruction* i);
uint8_t build_jmp_selector(Instruction* i);
#endif /* instruction_h */
