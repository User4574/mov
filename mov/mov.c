#include <stdlib.h>
#include <stdio.h>

#define MEM_MAX 0xFF
#define OP_SEG 0xF0
#define WORD unsigned char

typedef struct {
  WORD *memory;
  WORD a;
  WORD b;
  WORD pc;
} MACHINE;

void *read_prog(WORD* memory, char *filename) {
  FILE *progfile;
  long len;

  progfile = fopen(filename, "r");
  fseek(progfile, 0, SEEK_END);
  len = ftell(progfile);
  if (len > OP_SEG)
    exit(1);

  fseek(progfile, 0, SEEK_SET);
  fread(memory, sizeof(WORD), len, progfile);
  fclose(progfile);
}

WORD get(MACHINE *machine, WORD index) {
  if (index < OP_SEG)
    return (machine->memory)[index];

  switch (index) {
    case 0xF0:
      return (machine->a);
    case 0xF1:
      return (machine->b);
    case 0xF2:
      return ~(machine->a);
    case 0xF3:
      return (machine->a) | (machine->b);
    case 0xF4:
      return (machine->a) & (machine->b);
    case 0xF5:
      return (machine->a) ^ (machine->b);
    case 0xF6:
      return (machine->a) + (machine->b);
    case 0xF7:
      return (machine->a) - (machine->b);
    case 0xF8:
      return (machine->a) << (machine->b);
    case 0xF9:
      return (machine->a) >> (machine->b);
    case 0xFB:
      return (WORD)getchar();
    case 0xFC:
    case 0xFD:
      return (machine->pc);
    case 0xFA:
    case 0xFE:
      return 0;
    case 0xFF:
      return 0xFF;
  }

  return 0;
}

void put(MACHINE *machine, WORD index, WORD value) {
  if (index < OP_SEG)
    (machine->memory)[index] = value;

  if (index == 0xF0)
    machine->a = value;
  if (index == 0xF1)
    machine->b = value;

  if (index == 0xFB)
    putchar((int)value);
  if (index == 0xFC && machine->a == 0)
    machine->pc = value;
  if (index == 0xFD)
    machine->pc = value;
}

void execute(MACHINE *machine) {
  WORD dst = machine->memory[(int)(machine->pc)++];
  WORD src = machine->memory[(int)(machine->pc)++];
  WORD val = get(machine, src);
  put(machine, dst, val);
}

void dump(MACHINE *machine) {
  int i;
  for(i = 0; i < OP_SEG; i += 8) {
    printf("%02x: %02x %02x %02x %02x    %02x %02x %02x %02x\n",
        i,
        get(machine, i+0), get(machine, i+1),
        get(machine, i+2), get(machine, i+3),
        get(machine, i+4), get(machine, i+5),
        get(machine, i+6), get(machine, i+7));
  }
  printf("f0: %02x %02x %02x %02x    %02x %02x %02x %02x\nf8: 00 00 00 00    %02x %02x %02x %02x\n",
      get(machine, 0xF0), get(machine, 0xF1),
      get(machine, 0xF2), get(machine, 0xF3),
      get(machine, 0xF4), get(machine, 0xF5),
      get(machine, 0xF6), get(machine, 0xF7),
      get(machine, 0xFC), get(machine, 0xFD),
      get(machine, 0xFE), get(machine, 0xFF));
}

MACHINE *setup(char* filename) {
  MACHINE *machine = calloc(1, sizeof(MACHINE));

  machine->memory = calloc(OP_SEG, sizeof(WORD));
  machine->a = 0;
  machine->b = 0;
  machine->pc = 0;

  read_prog(machine->memory, filename);

  return machine;
}

void teardown(MACHINE *machine) {
  free(machine->memory);
  free(machine);
}

int main(int argc, char **argv) {
  MACHINE *machine;

  if (argc != 2)
    return 1;

  machine = setup(argv[1]);
  while (machine->pc < OP_SEG)
    execute(machine);

  /*dump(machine);*/
  teardown(machine);
  return 0;
}
