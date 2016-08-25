//
//  main.c
//  d16-asm
//
//  Created by Michael Nolan on 6/17/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aout.h"
#include "instruction.h"
#include "parser.h"

extern bool binary_mode;
FILE*       output_file;
static int  local_label_count[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void print_elem(void* element, void* data) {
    Instruction* i = (Instruction*)element;
    char         addr_string[128];
    if (i->address != NULL) {
        if (i->address->type == ADDR_IMMEDIATE) {
            snprintf(addr_string, sizeof(addr_string), "0x%04x",
                     i->address->immediate);
        } else {
            strncpy(addr_string, i->address->lblname, sizeof(addr_string));
        }
    }
    switch (i->type) {
        case I_TYPE_NONE:
            fprintf(stdout, "%s", i->opcode);
            break;
        case I_TYPE_R:
            fprintf(stdout, "%s r%d", i->opcode, i->rD);
            break;
        case I_TYPE_RR:
            fprintf(stdout, "%s r%d, r%d", i->opcode, i->rD, i->rS);
            break;
        case I_TYPE_RIMM:
            fprintf(stdout, "%s r%d, %s", i->opcode, i->rD, addr_string);
            break;
        case I_TYPE_CR:
            fprintf(stdout, "%s cr%d, r%d", i->opcode, i->rD, i->rS);
            break;
        case I_TYPE_RC:
            fprintf(stdout, "%s r%d, cr%d", i->opcode, i->rD, i->rS);
            break;
        case I_TYPE_DIRECTIVE:
            fprintf(stdout, "%s %d", i->opcode, *(int*)i->dir_data);
            break;
        case I_TYPE_MEM:
            if (i->op_type == LD) {
                fprintf(stdout, "%s r%d,[r%d]", i->opcode, i->rD, i->rS);
            } else {
                fprintf(stdout, "%s [r%d],r%d", i->opcode, i->rS, i->rD);
            }
            break;
        case I_TYPE_MEMI: {
            char opcode_new[8];
            char address[12];
            if (i->flags & M_BYTE) {
                snprintf(opcode_new, sizeof(opcode_new), "%s.b", i->opcode);
            } else {
                strncpy(opcode_new, i->opcode, sizeof(opcode_new));
            }
            if (i->flags & M_DISP) {
                snprintf(address, sizeof(address), "r%d+%s", i->rS,
                         addr_string);
            } else {
                snprintf(address, sizeof(address), "%s", addr_string);
            }
            if (i->op_type == LD) {
                fprintf(stdout, "%s r%d,[%s]", opcode_new, i->rD, address);
            } else {
                fprintf(stdout, "%s [%s],r%d", opcode_new, address, i->rD);
            }
            break;
        }
        case I_TYPE_JMP:
            fprintf(stdout, "%s.%s r%d", i->opcode, cc_to_str(i->cc), i->rD);
            break;
        case I_TYPE_JMPI:
            fprintf(stdout, "%s.%s %s", i->opcode, cc_to_str(i->cc),
                    addr_string);
            break;
        case I_TYPE_LABEL:
            fprintf(stdout, "%s:", i->opcode);
            break;
        case I_TYPE_LOCAL_LABEL:
            fprintf(stdout, "How did a local label get here?");
            break;
    }
    fprintf(stdout, " length: %d\n", instruction_length(i));
}

void free_elem(void* element) {
    Instruction* i = (Instruction*)element;
    free(i->opcode);
    i->opcode = NULL;
    free(i);
    i = NULL;
}

void sum_program_length(void* elem, void* data) {
    size_t*      sz = (size_t*)data;
    Instruction* i = (Instruction*)elem;
    *sz += instruction_length(i);
    if (i->address != NULL && i->address->type == ADDR_LOC_LABEL) {
        i->address->type = ADDR_LABEL;

        i->address->lblname = malloc(16);
        int lblindex = local_label_count[i->address->immediate];

        if (i->address->direction == 0) {
            if (lblindex == 0) {
                fprintf(stderr, "Error: No backwards label for %d\n",
                        i->address->immediate);
                exit(1);
            }
            sprintf(i->address->lblname, ".L%d\002%d", i->address->immediate,
                    lblindex - 1);
        } else {
            sprintf(i->address->lblname, ".L%d\002%d", i->address->immediate,
                    lblindex);
        }
    }
    if (i->type == I_TYPE_LOCAL_LABEL) {
        i->type = I_TYPE_LABEL;
        int lblnum = *(i->opcode + 2) - '0';
        ++local_label_count[lblnum];
    }
    if (i->type == I_TYPE_LABEL) {
        set_label_address(i->opcode, 2 * (int)*sz);
        if (!binary_mode) {
            gen_symbol_entry(i->opcode, *sz * 2, A_TEXT, i->flags == L_GLOBAL);
        }
    }
}

int ip = 0;

void assemble_instruction(Instruction* i, void* d) {
    uint16_t** data = (uint16_t**)d;
    if (i->type != I_TYPE_LABEL) {
        resolve_address(i->address);
        if (i->type == I_TYPE_RIMM) {
            if (i->op_type == MOVB) {
                **data = (i->op_type + (i->rD & 7)) << 8 |
                         (i->address->immediate & 0xff);
                *data += 1;
            } else {
                **data = i->op_type << 8 | build_reg_selector(i);
                *data += 1;
                if (i->address->type == ADDR_LABEL && !binary_mode) {
                    a_symbol_entry* symb = lookup_symbol(i->address->lblname);
                    if (symb != NULL && symb->spare == A_SYM_LOCAL) {
                        **data = symb->value & 0xffff;
                        gen_anonymous_reloc_entry(ip);
                    } else {
                        **data = 0;
                        gen_reloc_entry(i->address->lblname, ip);
                    }
                } else {
                    **data = i->address->immediate & 0xffff;
                }
                *data += 1;
            }
        } else if (i->type == I_TYPE_MEM) {
            **data = i->op_type << 8 | build_mem_selector(i);
            *data += 1;
        } else if (i->type == I_TYPE_MEMI) {
            **data = i->op_type << 8 | build_mem_selector(i);
            *data += 1;
            if (i->address->type == ADDR_LABEL && !binary_mode) {
                a_symbol_entry* symb = lookup_symbol(i->address->lblname);
                if (symb != NULL && symb->spare == A_SYM_LOCAL) {
                    **data = symb->value & 0xffff;
                    gen_anonymous_reloc_entry(ip);
                } else {
                    **data = 0;
                    gen_reloc_entry(i->address->lblname, ip);
                }
            } else {
                **data = i->address->immediate & 0xffff;
            }
            *data += 1;
        } else if (i->type == I_TYPE_DIRECTIVE) {
            switch (i->dir_type) {
                case D_WORD: {
                    **data = *(int*)i->dir_data;
                    *data += 1;
                    break;
                }
                case D_ASCIZ:
                case D_ASCII: {
                    char* str = i->dir_data;
                    strcpy((char*)*data, str);
                    *data += instruction_length(i);
                }
            }
        } else if (i->type == I_TYPE_JMPI || i->type == I_TYPE_JMP) {
            **data = i->op_type << 8 | build_jmp_selector(i);
            *data += 1;
            if (i->type == I_TYPE_JMPI) {
                if (i->address->type == ADDR_LABEL && !binary_mode) {
                    a_symbol_entry* symb = lookup_symbol(i->address->lblname);
                    if (symb != NULL && symb->spare == A_SYM_LOCAL) {
                        **data = symb->value & 0xffff;
                        gen_anonymous_reloc_entry(ip);
                    } else {
                        **data = 0;
                        gen_reloc_entry(i->address->lblname, ip);
                    }
                } else {
                    **data = i->address->immediate & 0xffff;
                }

                *data += 1;
            }

        } else {
            **data = i->op_type << 8 | build_reg_selector(i);
            *data += 1;
        }
    }
    // free(i->address);
    //
    // i->address = NULL;
    ip += instruction_length(i) * 2;
}

void process_list(struct _GList* list, FILE* output_file) {
    size_t output_size = 0;
    create_tables();
    // g_list_foreach(list, &print_elem, NULL);
    g_list_foreach(list, &sum_program_length, &output_size);
    fprintf(stdout, "Program length: %zu bytes\n", output_size * 2);
    output_size *= 2;
#ifdef DEBUG
    g_list_foreach(list, &print_elem, NULL);
#endif
    if (binary_mode) {
        uint16_t* buffer = malloc(output_size);
        uint16_t* buf_save = buffer;
        g_list_foreach(list, (void (*)(void*, void*)) & assemble_instruction,
                       &buffer);
        fwrite(buf_save, sizeof(uint8_t), output_size, output_file);
#ifdef DEBUG
        for (int i = 0; i < output_size / 2; i++) {
            fprintf(stdout, "0x%04x\n", buf_save[i]);
        }
#endif
    } else {
        aout_process_instructions(list, output_size, output_file);
    }
    g_list_free_full(list, &free_elem);
}
