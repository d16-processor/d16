//
// Created by Michael Nolan on 7/27/16.
//

#include "aout.h"
#include <stdlib.h>
#include <string.h>
#define INITIAL_CAPACITY 128
char* aout_strings = NULL;
size_t string_size =0;
size_t string_capacity = 0;

uint32_t add_string(char* string){
    if(aout_strings == NULL){
        aout_strings = malloc(INITIAL_CAPACITY);
        string_capacity = INITIAL_CAPACITY;
    }
    size_t length = strlen(string) + 1;
    if(string_size + length < string_capacity){
        string_capacity = (string_size+length)*2;
        aout_strings = realloc(aout_strings,string_capacity);
    }
    strcpy(aout_strings+string_size,string);
    int to_return = (int) string_size;
    string_size += (int)length;
    return to_return;
}

a_symbol_entry gen_symbol_entry(char* string, uint32_t address, a_type type){
    a_symbol_entry entry;
    entry.type = type;
    entry.value = address;
    entry.name_offset = add_string(string);
    return entry;
}

