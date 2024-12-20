// semantic_analyzer.c
#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void semantic_analysis(const char *identifier, int type, float value, int is_constant) {
    Symbol *existing_symbol = lookup_symbol(identifier);

    if (existing_symbol != NULL) {
        if (is_constant && !existing_symbol->is_constant) {
            fprintf(stderr, "Error: Redefinition of constant '%s' as variable.\n", identifier);
            exit(EXIT_FAILURE);
        }
        if (!is_constant && existing_symbol->is_constant) {
            fprintf(stderr, "Error: Redefinition of variable '%s' as constant.\n", identifier);
            exit(EXIT_FAILURE);
        }
        fprintf(stderr, "Error: Redefinition of symbol '%s'.\n", identifier);
        exit(EXIT_FAILURE);
    }

    if (is_constant) {
        if (!insert_constant(identifier, type, value)) {
            fprintf(stderr, "Error: Failed to insert constant '%s'.\n", identifier);
            exit(EXIT_FAILURE);
        }
    } else {
        if (!insert_symbol(identifier, type, 0)) {
            fprintf(stderr, "Error: Failed to insert symbol '%s'.\n", identifier);
            exit(EXIT_FAILURE);
        }
    }
}

void analyze_assignment(const char *identifier, int type, float value) {
    Symbol *existing_symbol = lookup_symbol(identifier);

    if (existing_symbol == NULL) {
        fprintf(stderr, "Error: Assignment to undeclared variable '%s'.\n", identifier);
        exit(EXIT_FAILURE);
    }

    if (existing_symbol->is_constant) {
        fprintf(stderr, "Error: Cannot assign to constant '%s'.\n", identifier);
        exit(EXIT_FAILURE);
    }

    if (existing_symbol->type != type) {
        fprintf(stderr, "Error: Type mismatch in assignment to '%s'.\n", identifier);
        exit(EXIT_FAILURE);
    }

    if (type == TYPE_INT) {
        existing_symbol->value.int_value = (int)value;
    } else if (type == TYPE_FLOAT) {
        existing_symbol->value.float_value = value;
    }
}

