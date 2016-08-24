//
//  label.h
//  d16-asm
//
//  Created by Michael Nolan on 6/28/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#ifndef label_h
#define label_h
#include <stdbool.h>
#include <stdio.h>
typedef enum {
    ADDR_NONE,
    ADDR_LABEL,
    ADDR_IMMEDIATE,
    ADDR_LOC_LABEL
} Addr_Type;

struct _Addr {
    int       immediate;
    char*     lblname;
    bool      direction; // 0 = back, 1=forward
    Addr_Type type;
};
typedef struct _Addr Address;
Address* addr_from_immediate(int imm);
Address* addr_from_label(char* label);
Address* addr_from_reference(int ref, bool dir);
#endif /* label_h */
