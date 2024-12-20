#include "symbol_table.h"
#include <stdlib.h>
#include <string.h>
#include "types.h"

#define MAX_SYMBOLS 100

static Symbol symbol_table[MAX_SYMBOLS];
static int symbol_count = 0;

bool insert_symbol(const char *name, int type, int size) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return false; // Duplicate symbol
        }
    }
    Symbol new_symbol = {.name = strdup(name), .value = {.type = type}, .is_constant = false, .array_size = size};
    symbol_table[symbol_count++] = new_symbol;
    return true;
}

bool insert_constant(const char *name, int type, Value value) {
    if (!insert_symbol(name, type, 0)) return false;
    symbol_table[symbol_count - 1].value = value;
    symbol_table[symbol_count - 1].is_constant = true;
    return true;
}

Symbol *lookup_symbol(const char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return &symbol_table[i];
        }
    }
    return NULL; // Not found
}

bool check_type(int expected, Value actual) {
    return expected == actual.type;
}

