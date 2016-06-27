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
	Instruction* i2 = new_instruction_r(op("jmp",JMP), 5);
	TEST_ASSERT_EQUAL_INT(I_TYPE_JMP, i2->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(5, i2->rD, "Incorrect RD value");
	free(i2);
}
void test_instruction_rr_3(void){
	Instruction* i = new_instruction_rr(op("and",AND), 0, 4);
	TEST_ASSERT_EQUAL_INT(I_TYPE_RR, i->type);
	TEST_ASSERT_EQUAL_INT_MESSAGE(0, i->rD,"Incorrect rD value");
	TEST_ASSERT_EQUAL_INT_MESSAGE(4, i->rS,"Incorrect rS value");
	free(i);
}
void test_instruction_run_all_tests(void){
	RUN_TEST(test_op);
	RUN_TEST(test_instruction_1);
	RUN_TEST(test_instruction_r_2);
	RUN_TEST(test_instruction_rr_3);
}