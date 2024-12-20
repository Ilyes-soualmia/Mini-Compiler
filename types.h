#ifndef TYPES_H
#define TYPES_H

#include <stdbool.h>

#define TYPE_INT 0
#define TYPE_FLOAT 1
#define TYPE_CHAR 2

typedef struct {
    int type; // TYPE_INT, TYPE_FLOAT, or TYPE_CHAR
    union {
        int int_value;
        float float_value;
	char char_value;
    } value;
} Value;

typedef struct {
    char name[64];
    Value value;
} Operand;

typedef struct {
    char *name;
    Value value;
    int type;
    bool is_constant;
    int array_size;
} Symbol;

#endif // TYPES_H

