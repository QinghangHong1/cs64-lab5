#ifndef DECODE_CODE_H
#define DECODE_CODE_H

typedef struct _mipsinstruction{
	int funct;  	// unsigned function code
	int immediate;	// signed immediate field
	int rd;		// unsigned rd field
	int rt;		// unsigned rt field
	int rs;		// unsigned rs field
	int opcode; 	// unsigned opcode
} mipsinstruction;

mipsinstruction decode(int);

#endif
