extern void asm_main();

int main()
{

	asm_main();

    return 0;
}

int divide(int R0, int R1)
{//update to read 16 bit signed arithmetic
    return R0/R1; //best choice would probably be short signed int
}