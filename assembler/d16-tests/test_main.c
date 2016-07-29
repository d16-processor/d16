//
//  test_main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/27/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include "test_main.h"
#include "assembler.h"
#include "unity.h"
uint16_t  data[128];
uint16_t* ptr_copy;

void test_reset(void) {
    memset(data, 0, sizeof(data));
    ptr_copy = data;
}
void test_assemble_ADD(void) {
    test_reset();
    Instruction* i = new_instruction_rr(op("add", ADD), 3, 2);

    assemble_instruction(i, &ptr_copy);
    uint16_t array_compare[] = {0x0113, 0};
    TEST_ASSERT_EQUAL_HEX16_ARRAY(array_compare, data, 2);
    free(i);
}
void test_assemble_SUBI(void) {
    test_reset();
    Instruction* i =
        new_instruction_ri(op("sub", SUB), 2, addr_from_immediate(0xf34d));
    assemble_instruction(i, &ptr_copy);
    uint16_t array_compare[] = {0x8202, 0xf34d, 0};
    TEST_ASSERT_EQUAL_HEX16_ARRAY(array_compare, data, 3);
    free(i);
}
void test_assemble_SHRI(void) {
    test_reset();
    Instruction* i =
        new_instruction_ri(op("shr", SHR), 4, addr_from_immediate(3));
    assemble_instruction(i, &ptr_copy);
    uint16_t array_compare[] = {0x9a04, 0x0003, 0};
    TEST_ASSERT_EQUAL_HEX16_ARRAY(array_compare, data, 2);
    free(i);
}

void main_run_all_tests() {
    printf("Running all tests for main.c\n");
    RUN_TEST(test_assemble_ADD);
    RUN_TEST(test_assemble_SUBI);
    RUN_TEST(test_assemble_SHRI);
}
