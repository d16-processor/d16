//
//  label.c
//  d16-asm
//
//  Created by Michael Nolan on 6/28/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include "label.h"
#include <stdlib.h>
Address* addr_from_immediate(int imm){
	Address* a = malloc(sizeof(Address));
	a->immediate = imm;
	a->type = ADDR_IMMEDIATE;
	return a;
}
Address* addr_from_label(char* label){
	Address* a = malloc(sizeof(Address));
	a->lblname = label;
	a->type = ADDR_LABEL;
	return a;
}