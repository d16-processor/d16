//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
#include <string.h>
#include <glib.h>
#include "instruction.h"

FILE* output_file;
#ifndef TESTING
extern int yyparse (void);
extern FILE* yyin;
int main(int argc, const char * argv[]) {
    
    if(argc != 3){
        fprintf(stderr, "Usage d16-asm [file] [output]\n");
        exit(-1);
    }
    FILE* f = fopen(argv[1], "r");
    FILE* o = fopen(argv[2], "wb");
    if(f == NULL){
        fprintf(stderr, "Error opening file %s\n",argv[1]);
        exit(-1);
    }
    if(o == NULL){
        fprintf(stderr, "Error opening file %s for writing\n",argv[2]);
        exit(2);
    }
    yyin = f;
    output_file = o;
    do {
        yyparse();
    } while (!feof(yyin));
    fclose(f);
    fclose(o);
    return 0;
}
#endif
void print_elem(void* element, void* data){
    Instruction* i = (Instruction* ) element;
    switch (i->type) {
        case I_TYPE_NONE:
            printf("%s",i->opcode);
            break;
        case I_TYPE_R:
            printf("%s r%d", i->opcode, i->rD);
            break;
        case I_TYPE_RR:
            printf("%s r%d, r%d",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RIMM:
            printf("%s r%d, #%d",i->opcode,i->rD,i->immediate);
            break;
        case I_TYPE_CR:
            printf("%s cr%d, r%d",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RC:
            printf("%s r%d, cr%d", i->opcode, i->rD, i->rS);
            break;
        case I_TYPE_DIRECTIVE:
            printf("%s %d",i->opcode, *(int*)i->dir_data);
            break;
		case I_TYPE_MEM:
			if(i->op_type == LD){
				printf("%s r%d,[r%d]",i->opcode,i->rD,i->rS);
			}else{
				printf("%s [r%d],r%d",i->opcode,i->rS,i->rD);
			}
			break;
		case I_TYPE_MEMI:{
				char opcode_new[8];
				char address[12];
				if(i->flags & M_BYTE){
					snprintf(opcode_new, sizeof(opcode_new), "%s.b",i->opcode);
				}else{
					strncpy(opcode_new, i->opcode, sizeof(opcode_new));
				}
				if(i->flags & M_DISP){
					snprintf(address, sizeof(address), "r%d+0x%04x",i->rS,i->immediate);
				}else{
					snprintf(address, sizeof(address), "0x%04x",i->immediate);
				}
				if(i->op_type == LD){
					printf("%s r%d,[%s]",opcode_new,i->rD,address);
				}else{
					printf("%s [%s],r%d",opcode_new,address,i->rD);
				}
				break;
			}
		case I_TYPE_JMP:
			printf("%s.%s r%d",i->opcode,cc_to_str(i->cc), i->rD);
			break;
		case I_TYPE_JMPI:
			printf("%s.%s 0x%04x",i->opcode,cc_to_str(i->cc), i->immediate);
			break;
    }
    printf(" length: %d\n",instruction_length(i));
    
}
void free_elem(void* element){
    Instruction *i = (Instruction*)element;
    free(i->opcode);
    free(i);
}
void sum_program_length(void* elem, void* data) {
    size_t* sz = (size_t*) data;
    Instruction* i = (Instruction*) elem;
    *sz += instruction_length(i);
}
void assemble_instruction(Instruction* i, uint16_t** data){
    if(i->type == I_TYPE_RIMM){
        if(i->op_type == MOVB){
            **data = (i->op_type + (i->rD & 7)) << 8 | (i->immediate & 0xff);
            *data+=1;
        }else if(i->op_type == SHLI || i->op_type == SHRI || i->op_type == ROLI || i->op_type == RCLI){
            **data = i->op_type<<8 | build_shift_selector(i);
            *data += 1;
        }
        else{
            **data = i->op_type<<8 | build_reg_selector(i);
            *data += 1;
            **data = i->immediate & 0xffff;
            *data += 1;
        }
    }else if(i->type == I_TYPE_MEM){
		**data = i->op_type<<8 | build_mem_selector(i);
		*data += 1;
	}else if(i->type == I_TYPE_MEMI){
		**data = i->op_type<<8 | build_mem_selector(i);
		*data += 1;
		**data = i->immediate & 0xffff;
		*data += 1;
	}else if (i->type == I_TYPE_DIRECTIVE){
        if(i->dir_type == D_WORD){
            **data = *(int*)i->dir_data;
            *data+=1;
        }
    }
	else if (i->type == I_TYPE_JMPI|| i->type == I_TYPE_JMP){
		**data = i->op_type <<8 | build_jmp_selector(i);
		*data += 1;
		if(i->type == I_TYPE_JMPI){
			**data = i->immediate;
			*data += 1;
		}

	}
    else{
        **data = i->op_type<<8 | build_reg_selector(i);
        *data += 1;
    }


}
void process_list(struct _GList* list){
    size_t output_size = 0;
    g_list_foreach(list, &print_elem, NULL);
    g_list_foreach(list, &sum_program_length , &output_size);
    printf("Program length: %zu\n",output_size);
    output_size *= 2;
    uint16_t* buffer = malloc(output_size);
    uint16_t* buf_save = buffer;
    g_list_foreach(list, (void(*)(void*,void*))&assemble_instruction, &buffer);
    fwrite(buf_save, sizeof(uint8_t), output_size, output_file);
    #ifdef DEBUG
    for(int i=0;i<output_size/2;i++){
        printf("0x%04x\n",buf_save[i]);
    }
    #endif
    g_list_free_full(list, &free_elem);
}