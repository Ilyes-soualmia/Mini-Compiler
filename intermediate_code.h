#ifndef INTERMEDIATE_CODE_H
#define INTERMEDIATE_CODE_H

#include "types.h"

void generate_assignment(const char *name, Value value);
void generate_io(const char *type, const char *name);
void generate_arithmetic(const char *op, Value left, Value right);

#endif // INTERMEDIATE_CODE_H

