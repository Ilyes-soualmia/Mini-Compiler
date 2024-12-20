#include "intermediate_code.h"
#include <stdio.h>
#include "types.h"

void generate_assignment(const char *name, Value value) {
    printf("ASSIGN %s ", name);
    if (value.type == TYPE_INT) {
        printf("%d\n", value.value.int_value);
    } else if (value.type == TYPE_FLOAT) {
        printf("%f\n", value.value.float_value);
    }
}

void generate_io(const char *type, const char *name) {
    printf("%s %s\n", type, name);
}

void generate_arithmetic(const char *op, Value left, Value right) {
    printf("ARITHMETIC %s %s ", op, left.type == TYPE_INT ? "INT" : "FLOAT");
}

