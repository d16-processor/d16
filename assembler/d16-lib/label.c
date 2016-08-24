//
//  label.c
//  d16-asm
//
//  Created by Michael Nolan on 6/28/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdlib.h>
#include "label.h"
Address* addr_from_immediate(int imm) {
    Address* a = calloc(1, sizeof(Address));
    a->immediate = imm;
    a->type = ADDR_IMMEDIATE;
    return a;
}
Address* addr_from_label(char* label) {      // foo
    Address* a = calloc(1, sizeof(Address)); // bar
    a->lblname = label;
    a->type = ADDR_LABEL;
    return a;
}
Address* addr_from_reference(int ref, bool dir) {
    Address* a = calloc(1, sizeof(Address));
    a->direction = dir;
    a->type = ADDR_LOC_LABEL;
    a->immediate = ref;
    return a;
}