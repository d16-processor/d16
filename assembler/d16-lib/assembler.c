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
void print_elem(void* element, void* data){
    Instruction* i = (Instruction* ) element;
	char addr_string[128];
	if(i->address != NULL){
		if(i->address->type == ADDR_IMMEDIATE){
			snprintf(addr_string, sizeof(addr_string), "0x%04x",i->address->immediate);
		}else{
			strncpy(addr_string, i->address->lblname, sizeof(addr_string));
		}
	}
    switch (i->type) {
        case I_TYPE_NONE:
            fprintf(stdout,"%s",i->opcode);
            break;
        case I_TYPE_R:
            fprintf(stdout,"%s r%d", i->opcode, i->rD);
            break;
        case I_TYPE_RR:
            fprintf(stdout,"%s r%d, r%d",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RIMM:
            fprintf(stdout,"%s r%d, %s",i->opcode,i->rD,addr_string);
            break;
        case I_TYPE_CR:
            fprintf(stdout,"%s cr%d, r%d",i->opcode,i->rD, i->rS);
            break;
        case I_TYPE_RC:
            fprintf(stdout,"%s r%d, cr%d", i->opcode, i->rD, i->rS);
            break;
        case I_TYPE_DIRECTIVE:
            fprintf(stdout,"%s %d",i->opcode, *(int*)i->dir_data);
            break;
		case I_TYPE_MEM:
			if(i->op_type == LD){
				fprintf(stdout,"%s r%d,[r%d]",i->opcode,i->rD,i->rS);
			}else{
				fprintf(stdout,"%s [r%d],r%d",i->opcode,i->rS,i->rD);
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
					snprintf(address, sizeof(address), "r%d+%s",i->rS,addr_string);
				}else{
					snprintf(address, sizeof(address), "%s",addr_string);
				}
				if(i->op_type == LD){
					fprintf(stdout,"%s r%d,[%s]",opcode_new,i->rD,address);
				}else{
					fprintf(stdout,"%s [%s],r%d",opcode_new,address,i->rD);
				}
				break;
			}
		case I_TYPE_JMP:
			fprintf(stdout,"%s.%s r%d",i->opcode,cc_to_str(i->cc), i->rD);
			break;
		case I_TYPE_JMPI:
			fprintf(stdout,"%s.%s %s",i->opcode,cc_to_str(i->cc), addr_string);
			break;
		case I_TYPE_LABEL:
			fprintf(stdout, "%s:",i->opcode);
			break;
    }
    fprintf(stdout," length: %d\n",instruction_length(i));
    
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
	if(i->type == I_TYPE_LABEL){
		set_label_address(i->opcode, 2*(int)*sz);
	}
}
void assemble_instruction(Instruction* i, uint16_t** data){
	if(i->type != I_TYPE_LABEL){
		resolve_address(i->address);
		if(i->type == I_TYPE_RIMM){
			if(i->op_type == MOVB){
				**data = (i->op_type + (i->rD & 7)) << 8 | (i->address->immediate & 0xff);
				*data+=1;
			}else if(i->op_type == SHLI || i->op_type == SHRI || i->op_type == ROLI || i->op_type == RCLI){
				**data = i->op_type<<8 | build_shift_selector(i);
				*data += 1;
			}
			else{
				**data = i->op_type<<8 | build_reg_selector(i);
				*data += 1;
				**data = i->address->immediate & 0xffff;
				*data += 1;
			}
		}else if(i->type == I_TYPE_MEM){
			**data = i->op_type<<8 | build_mem_selector(i);
			*data += 1;
		}else if(i->type == I_TYPE_MEMI){
			**data = i->op_type<<8 | build_mem_selector(i);
			*data += 1;
			**data = i->address->immediate & 0xffff;
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
				**data = i->address->immediate;
				*data += 1;
			}

		}
		else{
			**data = i->op_type<<8 | build_reg_selector(i);
			*data += 1;
		}
	}
	free(i->address);

}
void process_list(struct _GList* list, FILE* output_file){
    size_t output_size = 0;
    g_list_foreach(list, &print_elem, NULL);
    g_list_foreach(list, &sum_program_length , &output_size);
    fprintf(stdout,"Program length: %zu\n",output_size);
    output_size *= 2;
    uint16_t* buffer = malloc(output_size);
    uint16_t* buf_save = buffer;
    g_list_foreach(list, (void(*)(void*,void*))&assemble_instruction, &buffer);
    fwrite(buf_save, sizeof(uint8_t), output_size, output_file);
    #ifdef DEBUG
    for(int i=0;i<output_size/2;i++){
        fprintf(stdout,"0x%04x\n",buf_save[i]);
    }
    #endif
    g_list_free_full(list, &free_elem);
}