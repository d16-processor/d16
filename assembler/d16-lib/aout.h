//
// Created by Michael Nolan on 7/27/16.
//

#ifndef D16_ASM_AOUT_H
#define D16_ASM_AOUT_H

#include <stdint.h>
typedef struct _aout_header {
    uint32_t a_magic;
    uint32_t a_text;
    uint32_t a_data;
    uint32_t a_bss;
    uint32_t a_syms;
    uint32_t a_entry;
    uint32_t a_trsize;
    uint32_t a_drsize;
}aout_header;

typedef struct _reloc_entry {
    uint32_t address;
    uint32_t index:24;
    uint32_t pc_rel:1;
    uint32_t length:2;
    uint32_t extern:1;
    uint32_t spare:4;
} a_reloc_entry;

typedef struct _symbol_entry{
    uint32_t name_offset;
    uint8_t type;
    uint8_t spare;
    uint16_t debug_info;
    uint32_t value;
} a_symbol_entry;
#endif //D16_ASM_AOUT_H
