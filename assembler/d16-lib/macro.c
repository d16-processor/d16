#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "macro.h"
GHashTable* macro_table;
/*
 * Searches for a macro declaration and adds it to the macro table
 *
 * A macro declaration looks like this:
 *      .macro name
 *      mov \2, \1 ; mov arg2, arg1
 *      .endm
 */
char* get_macro_name(char* string) {
    string += strlen(".macro ");
    char* strstart = string;
    while (*string && !isspace(*string))
        string++;
    char* name = calloc(sizeof(char), (string - strstart) + 1);
    strncpy(name, strstart, string - strstart);
    // name[(string-strstart)+1] = '\0';
    return name;
}
void build_macro_table(GString* string) {
    if (string == NULL)
        return;
    char* str = string->str;
    char  c = 0;
    while ((c = *str) != 0) {
        if (c == '.') {
            if (strncmp(str, ".macro", strlen(".macro")) == 0) {
                char* end = strstr(str, ".endm") + strlen(".endm");
                char* macstr = calloc(sizeof(char), end - str + 1);
                strncpy(macstr, str, end - str);
                macstr[end - str + 1] = '\0';
                //puts(macstr);
                g_string_erase(string, (str - string->str), end - str);
                char* name = get_macro_name(macstr);
                //printf("macro name: %s\n", name);
                g_hash_table_insert(macro_table, name, macstr);
                free(name);
            }
        }
        str++;
    }
}
/*
 *  Replaces macros in the code with their expanded value.
 *  For instance, given the macro below:
 *  .macro tst
 *  mov \2,\1
 *  .endm
 *  the code
 *  `tst(r3,r2)
 *  is replaced by
 *  mov r2, r3
 *
 */

void extract_body(GString* string) {
    char* str = string->str;
    char* lineend = strchr(str, '\n');
    g_string_erase(string, 0, lineend - str);
    str = string->str;
    char* end = strstr(str, ".endm");
    g_string_truncate(string, end - str);
}
void strip_newlines(char* str){
    while(*str != 0){
        if(*str == '\n'){
            *str = 0;
            return;
        }
        str++;
    }
}
void replace_args(GString* string, GSList* args){
    char* str = string->str;
    char c = 0;
    while((c=*str) != 0){
        if(c=='\\'){
            char* endptr;
            int index = strtol(str+1,&endptr,10);
            if(endptr == str+1) break;
            if(index > g_slist_length(args)){
                fprintf(stderr,"invalid number of args passed to macro: %s\n", string->str);
                exit(1);
            }
            char* replace = g_slist_nth_data(args,index-1);
            strip_newlines(replace);
            g_string_erase(string, str-string->str,endptr-str);
            g_string_insert(string, str-string->str,replace);

        }
        str++;
    }

}

GSList* extract_args(char** str){
    (*str)++; //remove space
    char* linend = strchr(*str,'\n');
    char* copy = calloc(sizeof(char),linend-*str+1);
    strncpy(copy,*str,linend-*str);
    char* arg = strtok(copy," ,");
    GSList* list= NULL;
    int len = 1;
    while(arg != NULL){
        list = g_slist_append(list,arg);
        len += strlen(arg)-1;
        arg = strtok(NULL," ,");
    }
    *str += len;
    return list;
}
void print_args(GSList* args){
    printf("Args: ");
    while(args != NULL){
        printf("%s ",args->data);
        args = args->next;
    }
    printf("\n");
}
void replace_macros(GString* string) {
    if (string == NULL)
        return;
    char* str = string->str;
    char  c = 0;
    while ((c = *str) != 0) {
        if (c == '`') {
            char* strstart = ++str;
            while (*str && (isalnum(*str) || *str == '_'))
                str++;
            char* macname = calloc(sizeof(char), str - strstart + 1);
            strncpy(macname, strstart, str - strstart);
            //printf("Macro instance name: %s\n", macname);
            char* macbody = g_hash_table_lookup(macro_table, macname);
            if (macbody == NULL) {
                fprintf(stderr, "Undefined macro name: %s\n", macname);
                exit(1);
            }
            char* strtmp = str;
            GSList* args = extract_args(&strtmp);
            //print_args(args);
            GString* body = g_string_new(macbody);
            extract_body(body);
            replace_args(body,args);
            //puts(body->str);
            strstart -= 1; // include backtick
            g_string_erase(string, strstart - string->str, strtmp - strstart);
            g_string_insert(string, strstart - string->str, body->str);
            /*str = strtmp;*/
        }
        str++;
    }
}

GString* read_replace_macros(FILE* input) {
    fseek(input, 0, SEEK_END);
    size_t bufsize = ftell(input);
    fseek(input, 0, SEEK_SET);
    if (bufsize == -1) {
        return NULL;
    }
    char*  buffer = malloc(sizeof(char) * (bufsize + 1));
    size_t newlen = fread(buffer, sizeof(char), bufsize, input);
    if (ferror(input) != 0) {
        fprintf(stderr, "Error reading file\n");
        exit(1);
    } else {
        buffer[newlen++] = '\0';
    }
    GString* string = g_string_new(buffer);
    macro_table = g_hash_table_new(g_str_hash, g_str_equal);
    free(buffer);
    fclose(input);
    build_macro_table(string);
    replace_macros(string);
    g_string_append(string,"\n");
    /*puts(string->str);*/
    return string;
}
