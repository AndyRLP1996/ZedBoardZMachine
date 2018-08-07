#include<stdio.h>
#include<stdlib.h>

extern void asm_main();

int main()
{

	asm_main();

    return 0;
}

int divide(int R0, int R1)
{//update to read 16 bit signed arithmetic
    return (R0/R1); //best choice would probably be short signed int
}

int multiply(int R0, int R1)
{//update to read 16 bit signed arithmetic
	return (R0*R1);
}

char hextoascii(int R0)//assuming it works as intended, it will return the ascii value of the given input
{
    char buffer[1];
    int x=sprintf(buffer,"%d",R0);
    return buffer[0];
}
