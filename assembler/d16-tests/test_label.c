//
//  test_label.c
//  d16-asm
//
//  Created by Michael Nolan on 6/28/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include "test_label.h"
#include "label.h"
#include "unity.h"
#include <stdlib.h>

void test_addr_immediate(void){
	Address *a = addr_from_immediate(45);
	TEST_ASSERT_EQUAL_INT_MESSAGE(ADDR_IMMEDIATE, a->type, "Incorrect address type");
	TEST_ASSERT_EQUAL_INT_MESSAGE(45, a->immediate, "Incorrect Immediate value");
	TEST_ASSERT_EQUAL_PTR(NULL, a->lblname);
	free(a);
}
void test_addr_label(void){
	Address *a = addr_from_label("abc");
	TEST_ASSERT_EQUAL_INT_MESSAGE(ADDR_LABEL, a->type, "Incorrect address type");
	TEST_ASSERT_EQUAL_STRING_MESSAGE("abc", a->lblname, "Incorrect label name");
	free(a);
}
void test_label_run_all_tests(void){
	RUN_TEST(test_addr_immediate);
	RUN_TEST(test_addr_label);
}




