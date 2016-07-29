//
// Created by Michael Nolan on 7/27/16.
//

#include "test_aout.h"
#include "Unity/unity.h"
#include "aout.h"
void test_string() {
    int loc = add_string("Testing123");
    TEST_ASSERT_EQUAL_INT(0, loc);
    TEST_ASSERT_EQUAL_STRING("Testing123", aout_strings);
    int loc2 = add_string("Another one!");
    TEST_ASSERT_EQUAL_INT(11, loc2);
    TEST_ASSERT_EQUAL_STRING("Another one!", aout_strings + loc2);
}

void test_gen_symbol_entry(void) {
    a_symbol_entry entry = gen_symbol_entry("main", 0x5252, A_TEXT);
    TEST_ASSERT_EQUAL_INT(0x5252, entry.value);
    TEST_ASSERT_EQUAL_INT(A_TEXT, entry.type);
    TEST_ASSERT_EQUAL_STRING("main", entry.name_offset + aout_strings);
}

void test_aout_run_all_tests(void) {
    printf("Run all tests for aout.c\n");
    RUN_TEST(test_string);
    RUN_TEST(test_gen_symbol_entry);
}