//
// Created by Michael Nolan on 7/27/16.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aout.h"
#include "assembler.h"
#define INITIAL_CAPACITY 128
char*       aout_strings = NULL;
size_t      string_size = 0;
size_t      string_capacity = 0;
GArray*     symbol_array = NULL;
GHashTable* symbol_table;
GArray*     reloc_array = NULL;

uint32_t add_string(char* string) {
    if (aout_strings == NULL) {
        aout_strings = malloc(INITIAL_CAPACITY);
        string_capacity = INITIAL_CAPACITY;
    }
    size_t length = strlen(string) + 1;
    if (string_size + length > string_capacity) {
        string_capacity = (string_size + length) * 2;
        aout_strings = realloc(aout_strings, string_capacity);
    }
    strcpy(aout_strings + string_size, string);
    int to_return = (int)string_size;
    string_size += (int)length;
    return to_return;
}

a_symbol_entry gen_symbol_entry(char* string, uint32_t address, a_type type) {
#ifdef DEBUG
    printf("Generating a symbol entry for label: %s\n", string);
#endif

    a_symbol_entry* entry = malloc(sizeof(a_symbol_entry));
    entry->type = type;
    entry->value = address;
    entry->name_offset = add_string(string);

    g_array_append_val(symbol_array, entry);

    g_hash_table_insert(symbol_table, string, entry);
    return *entry;
}

a_reloc_entry gen_reloc_entry(char* label, uint32_t address) {
#ifdef DEBUG
    printf("Generating a reloc entry for label: %s\n", label);
#endif
    a_reloc_entry entry;
    entry.address = address;
    a_symbol_entry* symb = g_hash_table_lookup(symbol_table, label);
    if (symb != NULL) {
        entry.index = symb->name_offset;
    } else {
        entry.index = add_string(label);
    }
    entry.pc_rel = 0;
    entry.length = A_LENGTH_16_BITS;
    entry.extern_entry = 0;
    g_array_append_val(reloc_array, entry);
    free(label);
    return entry;
}

void aout_process_instructions(GList* instructions, int size, FILE* file) {
    uint16_t* instruction_buffer = malloc(size);
    uint16_t* buf_save = instruction_buffer;
    reloc_array = g_array_new(FALSE, FALSE, sizeof(a_reloc_entry));
    symbol_array = g_array_new(FALSE, FALSE, sizeof(a_symbol_entry*));
    symbol_table = g_hash_table_new(g_str_hash, g_str_equal);
    g_list_foreach(instructions,
                   (void (*)(void*, void*)) & assemble_instruction,
                   &instruction_buffer);
    aout_header header;
    header.a_magic = A_MAGIC;
    header.a_text = size;
    header.a_data = 0;
    header.a_bss = 0;
    if (symbol_array == NULL) {
        header.a_syms = 0;
    } else {
        header.a_syms = symbol_array->len * sizeof(a_symbol_entry);
    }
    header.a_entry = 0;
    if (reloc_array == NULL) {
        header.a_trsize = 0;
    } else {
        header.a_trsize = reloc_array->len * sizeof(reloc_array);
    }
    header.a_drsize = 0;

    fwrite(&header, sizeof(aout_header), 1, file);
    fwrite(buf_save, sizeof(uint16_t), size / 2, file);
    if (symbol_array != NULL) {
        for (int i = 0; i < symbol_array->len; i++) {
            a_symbol_entry* entry =
                g_array_index(symbol_array, a_symbol_entry*, i);
            fwrite(entry, sizeof(a_symbol_entry), 1, file);
        }
    }
    if (reloc_array != NULL) {
        fwrite(reloc_array->data, reloc_array->len, sizeof(a_reloc_entry),
               file);
    }
    fwrite(aout_strings, string_size, sizeof(char), file);
    fflush(file);
    free(buf_save);
    buf_save = NULL;
    instruction_buffer = NULL;
}