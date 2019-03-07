%{
#include <stdlib.h>
#include "asm.tab.h"
%}

%option caseless

%%
JMP           { return tJMP; }
JNZ           { return tJNZ; }
MOV           { return tMOV; }
HLT           { return tHLT; }
NOP           { return tNOP; }
IN            { return tINP; }
OUT           { return tOUT; }
NOT           { return tNOT; }
OR            { return tIOR; }
AND           { return tAND; }
XOR           { return tXOR; }
ADD           { return tADD; }
SUB           { return tSUB; }
SHL           { return tLSH; }
SHR           { return tRSH; }
&             { return tDAT; }
[;\n]         { return tNXT; }
,             { return tCMA; }
A             { return tRGA; }
B             { return tRGB; }
PC            { return tPRC; }
ZERO          { return tZRO; }
ONES          { return tONS; }
@             { return tORG; }
0x[0-9a-f]+   { yylval = strtol(yytext+2, NULL, 16); return tHEX; }
0[0-7]*       { yylval = strtol(yytext,   NULL,  8); return tOCT; }
[1-9][0-9]*   { yylval = strtol(yytext,   NULL, 10); return tDEC; }
0b[01]+       { yylval = strtol(yytext+2, NULL,  2); return tBIN; }
[ \t]         { }
.             { printf("_%s\n", yytext); }
%%
