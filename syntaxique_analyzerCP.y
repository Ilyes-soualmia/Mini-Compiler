%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"
#include "semantic_analyzer.h"
#include "intermediate_code.h"
extern int yylex();
void yyerror(const char *s);
%}

%union {
    char* str;
    int val;
}

/* Token declarations */
%token <str> ID TYPE
%token <val> NUMBER
%token WRITE READ IF ELSE CONST AND OR NOT EQ NEQ GEQ LEQ
%token VAR_GLOBAL DECLARATION INSTRUCTION

%type <str> declaration var_list write_arg
%type <val> expression

%left AND OR
%left '<' '>' LEQ GEQ EQ NEQ
%left '+' '-'
%left '*' '/'
%right NOT

%%
program:
    declarations instructions {
        printf("Parsing program complete.\n");
    }
    ;

declarations:
    VAR_GLOBAL '{' '}' declaration_block {
        printf("Global declarations block processed.\n");
    }
    ;

declaration_block:
    DECLARATION '{' declaration_list '}' {
        printf("Declaration block processed.\n");
    }
    ;

declaration_list:
    declaration_list declaration {
        printf("Declaration added.\n");
    }
    | declaration {
        printf("Single declaration processed.\n");
    }
    ;

declaration:
    TYPE var_list ';' {
        printf("Variables of type %s declared.\n", $1);
    }
    | CONST TYPE ID '=' NUMBER ';' {
        insert_symbol($3, $2, 1, 1, $5);
        printf("Constant %s of type %s initialized with value %d.\n", $3, $2, $5);
    }
    | TYPE ID '[' NUMBER ']' ';' {
        insert_symbol($2, $1, $4, 0, 0);
        printf("Array %s of type %s with size %d declared.\n", $2, $1, $4);
    }
    ;

var_list:
    var_list ',' ID {
        insert_symbol($3, "", 1, 0, 0);
        printf("Variable %s added to the list.\n", $3);
    }
    | ID {
        insert_symbol($1, "", 1, 0, 0);
        printf("Variable %s declared.\n", $1);
    }
    ;

instructions:
    INSTRUCTION '{' instruction_list '}' {
        printf("Instructions block processed.\n");
    }
    ;

instruction_list:
    instruction_list instruction {
        printf("Instruction added to list.\n");
    }
    | instruction {
        printf("Single instruction processed.\n");
    }
    ;

instruction:
    WRITE '(' write_args ')' ';' {
        printf("WRITE instruction executed.\n");
    }
    | READ '(' ID ')' {
        if (is_declared($3) == -1) {
            yyerror("Variable not declared.");
        } else {
            printf("READ instruction executed for variable %s.\n", $3);
        }
    } ';'
    | IF '(' expression ')' '{' instruction_list '}' else_clause {
        printf("IF statement processed.\n");
    }
    | ID '=' expression ';' {
        if (is_declared($1) == -1) {
            yyerror("Variable not declared.");
        } else {
            check_constant_modification($1);
            printf("Assignment: %s updated.\n", $1);
        }
    }
    ;

else_clause:
    ELSE '{' instruction_list '}' {
        printf("ELSE clause executed.\n");
    }
    | /* empty */ {
        printf("No ELSE clause.\n");
    }
    ;

write_args:
    write_args ',' write_arg {
        printf("Additional argument in WRITE.\n");
    }
    | write_arg {
        printf("WRITE argument processed.\n");
    }
    ;

write_arg:
    '"' ID '"' {
        printf("String %s printed.\n", $2);
    }
    | ID {
        printf("Variable %s printed.\n", $1);
    }
    | NUMBER {
        printf("Number %d printed.\n", $1);
    }
    ;

expression:
    expression AND expression {
        printf("AND operation.\n");
        $$ = $1 && $3;
    }
    | expression OR expression {
        printf("OR operation.\n");
        $$ = $1 || $3;
    }
    | expression '<' expression {
        printf("Less-than comparison.\n");
        $$ = $1 < $3;
    }
    | expression '>' expression {
        printf("Greater-than comparison.\n");
        $$ = $1 > $3;
    }
    | expression EQ expression {
        printf("Equality comparison.\n");
        $$ = $1 == $3;
    }
    | expression NEQ expression {
        printf("Not-equal comparison.\n");
        $$ = $1 != $3;
    }
    | expression GEQ expression {
        printf("Greater-or-equal comparison.\n");
        $$ = $1 >= $3;
    }
    | expression LEQ expression {
        printf("Less-or-equal comparison.\n");
        $$ = $1 <= $3;
    }
    | expression '+' expression {
        printf("Addition operation.\n");
        $$ = $1 + $3;
    }
    | expression '-' expression {
        printf("Subtraction operation.\n");
        $$ = $1 - $3;
    }
    | expression '*' expression {
        printf("Multiplication operation.\n");
        $$ = $1 * $3;
    }
    | expression '/' expression {
        printf("Division operation.\n");
        if ($3 == 0) yyerror("Division by zero");
        else $$ = $1 / $3;
    }
    | NOT expression {
        printf("Logical NOT operation.\n");
        $$ = !$2;
    }
    | '(' expression ')' {
        $$ = $2;
    }
    | ID {
        if (is_declared($1) == -1) {
            yyerror("Variable not declared.");
        } else {
            printf("Variable %s used in expression.\n", $1);
            $$ = 0; // Dummy value
        }
    }
    | NUMBER {
        $$ = $1;
    }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Start parsing...\n");
    yyparse();
    printf("Parsing complete!\n");
    display_symbol_table();
    return 0;
}

