//
// Created by Michael Nolan on 7/27/16.
//

#ifndef D16_ASM_AOUT_H
#define D16_ASM_AOUT_H
#include <glib.h>
#include <stdint.h>
#include <stdio.h>
typedef enum { A_TEXT, A_BSS, A_DATA } a_type;
typedef struct _aout_header {
    uint32_t a_magic;
    uint32_t a_text;
    uint32_t a_data;
    uint32_t a_bss;
    uint32_t a_syms;
    uint32_t a_entry;
    uint32_t a_trsize;
    uint32_t a_drsize;
} aout_header;

typedef struct _reloc_entry {
    unsigned int address;
    unsigned int index : 24;
    unsigned int pc_rel : 1;
    unsigned int length : 2;
    unsigned int extern_entry : 1;
    unsigned int spare : 4;
} a_reloc_entry;

typedef struct _symbol_entry {
    uint32_t name_offset;
    uint8_t  type;
    uint8_t  spare;
    uint16_t debug_info;
    uint32_t value;
} a_symbol_entry;
#define A_LENGTH_16_BITS 0b01
#define A_MAGIC 0x0107ffff
char*    aout_strings;
uint32_t add_string(char* string);
void           delete_tables();
void           create_tables();
a_symbol_entry gen_symbol_entry(char* string, uint32_t address, a_type type);
a_reloc_entry gen_reloc_entry(char* label, uint32_t address);
void aout_process_instructions(GList* instructions, int size, FILE*);
#endif // D16_ASM_AOUT_H
