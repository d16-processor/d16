//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/26/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include "unity.h"
#include "test_instruction.h"
#include "test_main.h"
int main(void){
	UNITY_BEGIN();
	test_instruction_run_all_tests();
	main_run_all_tests();
	return UNITY_END();
}