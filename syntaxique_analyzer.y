%{
#include "symbol_table.h"
#include <stdio.h>
#include "types.h"
#include <stdlib.h>
#include "intermediate_code.h"

#define __USE_C99_MATH

// Declare functions used in this file
void semantic_analysis(const char *identifier, int type, float value, int is_constant);
void analyze_assignment(const char *identifier, int type, float value);

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
int yylex();
%}

%union {
    int intval;
    float floatval;
    char *sval;
    int type_val;
    int condition; // Replaced bool with int for 0/1 values
    Value value;
    Operand operand;
}

%token <sval> IDENTIFIER STRING_LITERAL
%token <intval> INTEGER_CONSTANT
%token <floatval> FLOAT_CONSTANT
%token VAR_GLOBAL DECLARATION INSTRUCTION CONST
%token <type_val> INTEGER FLOAT CHAR
%token IF ELSE FOR READ WRITE
%token AND OR NOT EQUAL NOT_EQUAL LESS_EQUAL GREATER_EQUAL
%token PLUS MINUS MULTIPLY DIVIDE GREATER LESS
%token ASSIGN LEFT_BRACE RIGHT_BRACE LEFT_PAREN RIGHT_PAREN SEMICOLON
%token INCREMENT DECREMENT

%right ASSIGN
%left OR AND
%left EQUAL NOT_EQUAL
%left LESS LESS_EQUAL GREATER GREATER_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE
%right NOT
%right INCREMENT DECREMENT

%type <type_val> type
%type <value> expression
%type <value> term
%type <value> factor
%type <value> constant
%type <sval> declaration
%type <condition> condition

%%

// Program structure
program:
    VAR_GLOBAL declarations INSTRUCTION instructions
    {
        printf("Program parsed successfully.\n");
    }
;

// Declarations
declarations:
    declaration SEMICOLON declarations
    | /* empty */
;

declaration:
    type IDENTIFIER
    {
        semantic_analysis($2, $1, 0.0, 0);
    }
    | CONST type IDENTIFIER ASSIGN constant
    {
        semantic_analysis($3, $2, $5.value.float_value, 1);
    }
    | type IDENTIFIER '[' INTEGER_CONSTANT ']'
    {
        if (!insert_symbol($2, $1, $4)) {
            yyerror("Duplicate table declaration.");
        }
    }
;

// Type
type:
    INTEGER { $$ = TYPE_INT; }
    | FLOAT { $$ = TYPE_FLOAT; }
    | CHAR { $$ = TYPE_CHAR; }
;

// Instructions
instructions:
    instruction SEMICOLON instructions
    | /* empty */
;

instruction:
    IDENTIFIER ASSIGN expression
    {
        analyze_assignment($1, $3.type, $3.value.float_value);
    }
    | READ LEFT_PAREN IDENTIFIER RIGHT_PAREN
    {
        Symbol *sym = lookup_symbol($3);
        if (!sym) {
            yyerror("Undeclared variable.");
        } else {
            generate_io("READ", $3);
        }
    }
    | WRITE LEFT_PAREN write_args RIGHT_PAREN
    {
        printf("WRITE handled.\n");
    }
    | IF condition LEFT_BRACE instructions RIGHT_BRACE
    {
        printf("IF condition handled.\n");
    }
    | IF condition LEFT_BRACE instructions RIGHT_BRACE ELSE LEFT_BRACE instructions RIGHT_BRACE
    {
        printf("IF-ELSE condition handled.\n");
    }
;

write_args:
    STRING_LITERAL { printf("WRITE: %s\n", $1); }
    | STRING_LITERAL ',' IDENTIFIER { printf("WRITE: %s, %s\n", $1, $3); }
    | STRING_LITERAL ',' IDENTIFIER ',' STRING_LITERAL { printf("WRITE: %s, %s, %s\n", $1, $3, $5); }
;

// Condition
condition:
    expression LESS expression { $$ = ($1.value.float_value < $3.value.float_value); }
    | expression LESS_EQUAL expression { $$ = ($1.value.float_value <= $3.value.float_value); }
    | expression GREATER expression { $$ = ($1.value.float_value > $3.value.float_value); }
    | expression GREATER_EQUAL expression { $$ = ($1.value.float_value >= $3.value.float_value); }
    | expression EQUAL expression { $$ = ($1.value.float_value == $3.value.float_value); }
    | expression NOT_EQUAL expression { $$ = ($1.value.float_value != $3.value.float_value); }
;

// Expression
expression:
    expression PLUS term { Value result;
                           result.type = TYPE_FLOAT;
                           result.value.float_value = $1.value.float_value + $3.value.float_value;
                           $$ = result;
                         }
    | expression MINUS term { Value result;
                              result.type = TYPE_FLOAT;
                              result.value.float_value = $1.value.float_value - $3.value.float_value;
                              $$ = result;
 }
    | term { $$ = $1; }
;

// Term
term:
    term MULTIPLY factor { Value result;
                           result.type = TYPE_FLOAT;
                           result.value.float_value = $1.value.float_value * $3.value.float_value;
                           $$ = result;
                         }
    | term DIVIDE factor { Value result;
                           result.type = TYPE_FLOAT;
                           result.value.float_value = $1.value.float_value / $3.value.float_value;
                           $$ = result;
                         }
    | factor { $$ = $1; }
;

// Factor
factor:
    INTEGER_CONSTANT { Value result;                     
                       result.type = TYPE_INT;
                       result.value.int_value = $1; 
                       $$ = result; }
    | FLOAT_CONSTANT { Value result;
                       result.type = TYPE_FLOAT;
                       result.value.float_value = $1;
                       $$ = result; }
    | IDENTIFIER
    {
        Symbol *sym = lookup_symbol($1);
        if (!sym) {
            yyerror("Undeclared variable.");
        } else {
            $$ = sym->value;
        }
    }
    | LEFT_PAREN expression RIGHT_PAREN { $$ = $2; }
;

// Constant
constant:
    INTEGER_CONSTANT { Value result;
                       result.type = TYPE_INT;
                       result.value.int_value = $1;
                       $$ = result; }
    | FLOAT_CONSTANT { Value result;
                       result.type = TYPE_FLOAT;
                       result.value.float_value = $1;
                       $$ = result; }
;

%%

