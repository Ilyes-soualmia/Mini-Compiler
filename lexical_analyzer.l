%{
#include "syntaxique_analyzer.tab.h"
#include "symbol_table.h"
#include "types.h"
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
%}

%%

"VAR_GLOBAL"          { return VAR_GLOBAL; }
"DECLARATION"         { return DECLARATION; }
"INSTRUCTION"         { return INSTRUCTION; }
"CONST"               { return CONST; }
"INTEGER"             { return INTEGER; }
"FLOAT"               { return FLOAT; }
"CHAR"                { return CHAR; }
"IF"                  { return IF; }
"ELSE"                { return ELSE; }
"FOR"                 { return FOR; }
"READ"                { return READ; }
"WRITE"               { return WRITE; }
"&&"                  { return AND; }
"||"                  { return OR; }
"!"                   { return NOT; }
"=="                  { return EQUAL; }
"!="                  { return NOT_EQUAL; }
"<="                  { return LESS_EQUAL; }
">="                  { return GREATER_EQUAL; }
"+"                   { return PLUS; }
"-"                   { return MINUS; }
"*"                   { return MULTIPLY; }
"/"                   { return DIVIDE; }
">"                   { return GREATER; }
"<"                   { return LESS; }
"++"                  { return INCREMENT; }
"--"                  { return DECREMENT; }
[0-9]+                { yylval.intval = atoi(yytext); return INTEGER_CONSTANT; }
[0-9]*"."[0-9]+       { yylval.floatval = atof(yytext); return FLOAT_CONSTANT; }
[A-Z][a-z0-9]{0,7}    { yylval.sval = strdup(yytext); return IDENTIFIER; }
"\""[^\"]*"\""        { yylval.sval = strdup(yytext); return STRING_LITERAL; } // Strings for WRITE
"%%"[^\\n]*           ; // Single line comment

"="                   { return ASSIGN; }
"{"                   { return LEFT_BRACE; }
"}"                   { return RIGHT_BRACE; }
"("                   { return LEFT_PAREN; }
")"                   { return RIGHT_PAREN; }
";"                   { return SEMICOLON; }

[ \t\n]+              ;//
.                     { printf("Unexpected character: '%s'\n", yytext); }

%%

int yywrap() { return 1; }

