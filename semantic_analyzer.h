#ifndef SEMANTIC_ANALYZER_H
#define SEMANTIC_ANALYZER_H

#include "symbol_table.h"

// Function to handle type checking during assignment
int check_type(int variable_type, Value expression_value);

// Function to evaluate conditions (used for if and loop statements)
int evaluate_condition(Value left, int comparison_type, Value right);

// Function to generate assignment code (used during semantic checks and intermediate code generation)
void generate_assignment(const char *identifier, Value value);

// Helper function to handle semantic errors
void semantic_error(const char *message);

// Utility to initialize the semantic analyzer (if needed)
void initialize_semantic_analyzer();

#endif /* SEMANTIC_ANALYZER_H */

