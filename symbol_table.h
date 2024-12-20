#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "types.h"
#include <stdbool.h>

bool insert_symbol(const char *name, int type, int size);
bool insert_constant(const char *name, int type, Value value);
Symbol *lookup_symbol(const char *name);
bool check_type(int expected, Value actual);

#endif // SYMBOL_TABLE_H

