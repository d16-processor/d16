//
//  label.h
//  d16-asm
//
//  Created by Michael Nolan on 6/28/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#ifndef label_h
#define label_h

#include <stdio.h>
typedef enum{
	ADDR_NONE,
	ADDR_LABEL,
	ADDR_IMMEDIATE,

}Addr_Type;

struct _Addr{
	int immediate;
	char* lblname;
	Addr_Type type;
};
typedef struct _Addr Address;
Address* addr_from_immediate(int imm);
Address* addr_from_label(char* label);
#endif /* label_h */
