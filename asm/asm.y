%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define WORD unsigned char

extern int yylex();
extern void yyerror(char *err);
extern FILE *yyin;

WORD *program = NULL;
size_t ploc = 0, psize = 0;
void optimise();
void mov(WORD dst, WORD src);
void dat(WORD data);
%}

%token tMOV tJMP tJNZ tHLT tNOP tINP tOUT
%token tNOT tIOR tAND tXOR tADD tSUB tLSH tRSH
%token tRGA tRGB tPRC tHEX tOCT tDEC tBIN tZRO tONS
%token tNXT tCMA tORG tDAT

%%

prog: 
    | dir
    | dir tNXT prog
    | tNXT prog
    ;

dir: istr
   | tORG number  { ploc = $2; }
   | tDAT number  { dat($2); }
   ;

istr: tMOV darg tCMA sarg            { mov($2, $4); }
    | tJMP sarg                      { mov(0xFD, $2); }
    | tJNZ sarg tCMA sarg            { mov(0xF0, $4); mov(0xFC, $2); }
    | tHLT                           { mov(0xFD, 0xFF); }
    | tNOP                           { mov(0, 0); }
    | tINP darg                      { mov($2, 0xFB); }
    | tOUT darg                      { mov(0xFB, $2); }
    | tNOT darg tCMA sarg            { mov(0xF0, $4); mov($2, 0xF2); }
    | tIOR darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF3); }
    | tAND darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF4); }
    | tXOR darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF5); }
    | tADD darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF6); }
    | tSUB darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF7); }
    | tLSH darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF8); }
    | tRSH darg tCMA sarg tCMA sarg  { mov(0xF0, $4); mov(0xF1, $6); mov($2, 0xF9); }
    ;

darg: register
    | number
    ;

sarg: darg
    | result
    | constant
    ;

constant: tZRO  { $$ = 0xFE; }
        | tONS  { $$ = 0xFF; }

result: tNOT  { $$ = 0xF2; }
      | tIOR  { $$ = 0xF3; }
      | tAND  { $$ = 0xF4; }
      | tXOR  { $$ = 0xF5; }
      | tADD  { $$ = 0xF6; }
      | tSUB  { $$ = 0xF7; }
      | tLSH  { $$ = 0xF8; }
      | tRSH  { $$ = 0xF9; }

register: tRGA { $$ = 0xF0; }
        | tRGB { $$ = 0xF1; }
        | tPRC { $$ = 0xFD; }
        ;

number: tHEX { $$ = yylval; }
      | tOCT { $$ = yylval; }
      | tDEC { $$ = yylval; }
      | tBIN { $$ = yylval; }
      ;

%%

void optimise() {}

void dat(WORD data) {
  while (ploc >= psize) {
    size_t newpsize = psize + (256 * sizeof(WORD));
    program = realloc(program, newpsize);
    memset(program + psize, 0, 256 * sizeof(WORD));
    psize = newpsize;
  }
  program[ploc++] = data;
}

void mov(WORD dst, WORD src) {
  dat(dst);
  dat(src);
}

void dump() {
  fwrite(program, sizeof(WORD), ploc, stdout);
  fflush(stdout);
}

int main(int argc, char **argv) {
  if (argc != 2)
    return 1;
  if(strncmp(argv[1], "-", 1))
    yyin = fopen(argv[1], "r");
  yyparse();
  optimise();
  dump();
  free(program);
  return 0;
}

void yyerror(char *err) {
  fprintf(stderr, "EE: %s\n", err);
}
