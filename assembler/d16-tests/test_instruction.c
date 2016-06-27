//
//  test_instruction.c
//  d16-asm
//
//  Created by Michael Nolan on 6/26/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "unity.h"
#include "instruction.h"

void test_op(void){
	struct _OP* op_test = op("add", ADD);
	TEST_ASSERT_MESSAGE(op_test != NULL, "op() returned a null pointer!");
	TEST_ASSERT_EQUAL_STRING("add",op_test->str);
	TEST_ASSERT_EQUAL_INT(ADD, op_test->type);
	free(op_test);
}
void test_instruction_1(void){
	Instruction* i = new_instruction(op("nop",NOP));
	TEST_ASSERT_EQUAL_INT(I_TYPE_NONE, i->type);
	free(i);
}
void test_instruction_r_2(void){
	Instruction* i = new_instruction_r(op("not",NOT), 3);
	TEST_ASSERT_EQUAL_INT(I_TYPE_R, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(3, i->rD,"Incorrect RD value");
	free(i);

}
void test_instruction_rr_3(void){
	Instruction* i = new_instruction_rr(op("and",AND), 0, 4);
	TEST_ASSERT_EQUAL_INT(I_TYPE_RR, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(0, i->rD,"Incorrect rD value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(4, i->rS,"Incorrect rS value");
	free(i);
}
void test_instruction_ri_3(void){
	Instruction* i = new_instruction_ri(op("add",ADD), 5, 345);
	TEST_ASSERT_EQUAL_INT(I_TYPE_RIMM, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(ADDI, i->op_type, "Incorrect opcode");
	TEST_ASSERT_EQUAL_INT_MESSAGE(5, i->rD, "Incorrect rD value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(345, i->immediate, "Incorrect immediate");
	free(i);
}
void test_instruction_mem_4(void){
	Instruction* i = new_instruction_mem(op("ld",LD), 0,3, true);
	TEST_ASSERT_EQUAL_INT(I_TYPE_MEM, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(0, i->rD, "Incorrect rD value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(3, i->rS, "Incorrect rS value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(M_BYTE, i->flags, "Incorrect flags for MEM instruction");
	free(i);
}
void test_instruction_memi_5(void){
	Instruction *i = new_instruction_memi(op("st",ST), 3, 4, 2567, false, true);
	TEST_ASSERT_EQUAL_INT(I_TYPE_MEMI, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(3, i->rD, "Incorrect rD value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(4, i->rS, "Incorrect rS value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(M_DISP, i->flags, "Incorrect MEM flags");
	TEST_ASSERT_EQUAL_INT_MESSAGE(2567, i->immediate, "Incorrect Immediate");
	TEST_ASSERT_EQUAL_INT_MESSAGE(STI, i->op_type, "Incorrect opcode");
	free(i);
}
void test_instruction_jmpi_3(void){
	Instruction* i = new_instruction_jmpi(op("jmp",JMP), 23, EQ);
	TEST_ASSERT_EQUAL_INT(I_TYPE_JMPI,i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(23, i->immediate, "Incorrect Immediate");
	TEST_ASSERT_EQUAL_INT_MESSAGE(EQ, i->cc, "Incorrect Condition code");
	TEST_ASSERT_EQUAL_INT_MESSAGE(JMPI, i->op_type, "Incorrect opcode");
	free(i);
}
void test_reg_selector(void){
	Instruction* i = new_instruction_rr(op("sub", SUB), 4, 3);
	uint8_t sel = build_reg_selector(i);
	TEST_ASSERT_EQUAL_INT(0b00011100, sel);
	free(i);
	Instruction* i2 = new_instruction_ri(op("add",ADD), 3, 45);
	sel = build_reg_selector(i2);
	TEST_ASSERT_EQUAL_INT(0b00000011, sel);
	free(i2);
}
void test_shift_selector(void){
	Instruction* i = new_instruction_ri(op("shl",SHL), 4, 5);
	TEST_ASSERT_EQUAL_INT_MESSAGE(5<<3|4, build_shift_selector(i), "Incorrect selector for shli");

}

void test_instruction_length(void){
	Instruction *rr = new_instruction_rr(op("add",ADD), 3, 2);
	Instruction *ri = new_instruction_ri(op("xor",XOR), 0, 234);
	Instruction *memi = new_instruction_memi(op("ld",LD), 3, 4, 1234, false, false);
	Instruction *shift = new_instruction_ri(op("shl",SHL), 3, 2);
	Instruction *mov_special = new_instruction_ri(op("mov",MOV), 3, 24);
	Instruction *mov_general = new_instruction_ri(op("mov",MOV), 5, 1456);
	Instruction *jmpi = new_instruction_jmpi(op("jmp",JMP), 34, AL);
	TEST_ASSERT_EQUAL_INT_MESSAGE(1, instruction_length(rr), "Incorrect RR instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(2, instruction_length(ri), "Incorrect RI instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(2, instruction_length(memi), "Incorrect MemI instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(1, instruction_length(shift), "Incorrect Shift instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(1, instruction_length(mov_special), "Incorrect Special movi instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(2, instruction_length(mov_general), "Incorrect General movi instruction length");
	TEST_ASSERT_EQUAL_INT_MESSAGE(2, instruction_length(jmpi), "Incorrect JmpI instruction length");
	free(rr);
	free(ri);
	free(memi);
	free(shift);
	free(mov_special);
	free(mov_general);
	free(jmpi);

}
void test_instruction_run_all_tests(void){
	RUN_TEST(test_op);
	RUN_TEST(test_instruction_1);
	RUN_TEST(test_instruction_r_2);
	RUN_TEST(test_instruction_rr_3);
	RUN_TEST(test_instruction_ri_3);
	RUN_TEST(test_instruction_mem_4);
	RUN_TEST(test_instruction_memi_5);
	RUN_TEST(test_instruction_jmpi_3);
	RUN_TEST(test_reg_selector);
	RUN_TEST(test_shift_selector);
	RUN_TEST(test_instruction_length);
}