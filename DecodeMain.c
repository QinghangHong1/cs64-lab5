#include "stdio.h"
#include "stdlib.h"
#include "DecodeCode.h"

int main(int argc, char *argv[]) {
  char buf[256];
  int value;
  int result1;
  unsigned int result2;
  FILE *file;

  if (argc != 2) {
    printf("Proper usage: a.out filename.txt\n");
    printf("You need to create a file, and that file contains\n");
    printf("a list of numbers, with each number on a different line.\n");
    printf("This program will run all of the tests on each number.\n");
    exit(1);
  }

  file = fopen(argv[1],"r");
  if (file == NULL) {
    printf("Could not open file %s\n",argv[1]);
    exit(2);
  }

  // read in each line, convert to number, then do bitwise stuff
  fgets(buf,256,file);
  while (!feof(file)) {
    // convert the number from a character string to integer
    int value = atoi(buf);
    mipsinstruction inst;
    
    // print the number out as an integer and hex number
    printf("Original instruction value: hex: %x\n",value);
    
    inst = decode(value);
    
    printf("Decoded instruction:\n");
    printf("Opcode: %d, Funct: %d\n",inst.opcode,inst.funct);
    printf("rs: %d, rt: %d, rd: %d\n",inst.rs, inst.rt, inst.rd);
    printf("immediate: %d\n\n",inst.immediate);
    
    fgets(buf,256,file);
  }
}

