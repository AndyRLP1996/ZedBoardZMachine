fetchop:;@R10 is the input, correctly stored operands are the output
push {r8,r10,r14}
	;@ at this point R0 still contains the full encoded byte
	;@input determines which way to fetch operands.

	;@1 is A type 16 bit constant
		CMP R10,#1
		ADDEQ R1, R4, #1
		MOVEQ R0, R7
		BLEQ memoryread ;@R0 now contains the 16 bit constant
		POPEQ {R8,r10,R15}
	;@2 is A type 8 bit constant
		CMP R10,#2
		ADDEQ R1, R4, #1
		MOVEQ R0, R7
		BLEQ memoryreadbyte
		POPEQ {R8,r10,R15}
	;@3 is A type one register
		CMP R10,#3


	;@4 is a type no operands
		CMP R10, #4
		MOVEQ R12, #0
		POPEQ {R8,r10,R15}
	;@5 is b type first operand one byte constant
		CMP R10,#5
		ADDEQ R1, R4, #1
		MOVEQ R0, R7
		BLEQ memoryreadbyte
		POPEQ {R8,r10,R15}
	;@6 is b type first operand register
		CMP R10,#6
		

	;@7 is b type second operand 1 byte constant
		CMP R10,#7
		ADDEQ R1, R4, #2
		MOVEQ R0, R7
		BLEQ memoryreadbyte
		POPEQ {R8,r10,R15}
	;@8 is b type second operand register
		CMP R10,#8
		

	;@9 is c type 
		CMP R10,#9
		

pop {r8,r10,r15}