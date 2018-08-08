.global decode

decode:
push {r14}
	;@takes r3 in as instruction indicator
	;@takes r0 and r1 as operand types
	;@takes r12 as the count of the number of operands to fetch
	;@will likely also take r10 as an indicator of what type of instruction and possibly 1 other thing
	;@insert comparison of indicators here, with each case having its own call to fetchop
	CMP R3,#0x0d
	;@perform any necessary changes to input vars for fetchop here
	BLEQ fetchop
	BLEQ verify

	CMP R3,#0x14
	;@perform any necessary changes to input vars for fetchop here
	BLEQ fetchop
	BLEQ add

	BLNE crashmode ;@executes if no matching instruction is found
pop {r15}

fetchop:;@instruction indicator will be in R3, R12 holds the opcount
push {r8,r14}
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
		

pop {r8,r15}

ctypevar:
push {r14}
	;@

pop {r15}

zregfetch: ;@takes the address of the z register to fetch as input, and returns its contents
push {r14} ;@r10 is the input
	;@add 1 to R5 (z stack pointer) when pushing onto stack and subtract 1 when popping

pop {r15}

zregstore: ;@takes the address of the zregister and the contents you wish to store and stores the contents to the given z register
push {r14} ;r10 and r11 are the inputs. 
	;@

pop {r15}


;@ R0 is operand 1
;@ R1 is operand 2
;@ tempop offsets 0, 2, 4, 6, 8, 10, 12, 14 store operands if it is variable operand type
;@ tempop (from 0 onwards) also stores the encoded string that comes after one instruction (PRINT)
;@ R2 will store the extra byte required in some instructions (ADD, SUB, MUL, DIV, CALL_2S, PULL, MOD, NOT)
;@ R2 will also store branch byte 1, if it is a branch instruction (JE, JL, JG, TEST_ATTR, VERIFY)
;@ R8 will store branch byte 2 if it's a long branch (JE, JL, JG, TEST_ATTR, VERIFY)
;@ R12 will be the number of operands

verify: ;@ - NO OPERANDS - 0xD OPCODE|BRANCHBYTE1|(SOMETIMES BRANCHBYTE2) ;@ Branching not done yet
	PUSH {R9, R10, R11, R14}

	BL checksum
	CMP R0, #1 ;@checks that checksum returns true (file is valid)
	BNE crashmode
	;@ second checksum
	MOV R0, R7
	MOV R1, #28
	BLEQ memoryread ;@should return 0x942d in r0
	LDR R1,=0x942d
	CMP R0, R1 ;@checks that checksum works
	BNE crashmode
	POP {R9, R10, R11, R15}

add: ;@ - TWO OPERANDS - 0x14 - (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	ADD R9, R0, R1

	MOV R0, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
sub: ;@ - TWO OPERANDS - 0x15 - (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	SUB R9, R0, R1

	MOV R0, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
mul: ;@ - TWO OPERANDS - 0x16 - (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	BL multiply
	
	MOV R0, R0 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
div: ;@ - TWO OPERANDS - 0x17 - (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	BL divide
	
	MOV R0, R0 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
print_num: ;@ - VARIABLE OPERAND COUNT - 0x06 (C) ?
	PUSH {R9, R10, R11, R14}
	LDR R9,=tempop
	LDR R0, [R9]
	BL hextoascii
	BL sendtoUART
	POP {R9, R10, R11, R15}
	
je: ;@ - TWO OPERANDS - 0x01 (B) OPCODE|SCREWED_UP_PSEUDO_C_TYPE
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
jl: ;@ - TWO OPERANDS - 0x02 (B) OPCODE|OPERAND1|OPERAND2|BRANCHBYTE1|(SOMETIMES BRANCHBYTE2) (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
jg: ;@ - TWO OPERANDS - 0x03 (B) OPCODE|OPERAND1|OPERAND2|BRANCHBYTE1|(SOMETIMES BRANCHBYTE2) (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
ret_popped: ;@ - NO OPERANDS - 0x08 (A) OPCODE
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
ret: ;@ - ONE OPERAND - 0x0B (A) OPCODE
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
call_2s: ;@ - TWO OPERANDS - 0x19 (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
call_2n: ;@ - TWO OPERANDS - 0x1A (B) OPCODE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
push: ;@ - VARIABLE OPERAND COUNT - 0x08 (C) ?
	PUSH {R9, R10, R11, R14}
	LDR R9,=tempop ;@ Fetch first variable operand
	LDR R10, [R9]
	STR R10, [R5]
	ADD R5, R5, #1
	POP {R9, R10, R11, R15}
	
pull: ;@ - VARIABLE OPERAND COUNT - 0x09 (C) ?
	PUSH {R9, R10, R11, R14}
	LDR R5, [R2]
	SUB R5, R5, #1
	POP {R9, R10, R11, R15}
	
print: ;@ - NO OPERANDS - 0x02 (A) OPCODE|ENCODED_STRING ;@ TODO
	PUSH {R9, R10, R11, R14}
	LDR R9,=tempop
	printwhile1:
		LDR R10, [R9]
		AND R10, R10, #0b1000000
		CMP R10, #0b1000000
		LDR R10, [R9]
		LDR R11, [R9, #1]
		MULL R10, R0, R10, #256
		ADD R0, R10, R11
		BL hextoascii3 ;@ convert three characters of 5 bits each to characters stopbit|5|5|5
		BL sendtoUART
		ADD, R9, R9, #2
		BNE printwhile1
	endprintwhile1:
	POP {R9, R10, R11, R15}
	
test_attr: ;@ - TWO OPERANDS - 0x0A OPCODE|OPERAND1|OPERAND2|BRANCHBYTE1|(SOMETIMES BRANCHBYTE2) (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
set_attr: ;@ - TWO OPERANDS - 0x0B (B) OPCODE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
clear_attr: ;@  - TWO OPERANDS - 0x0C (B) OPCODE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
inc: ;@ - ONE OPERAND - 0x05 (A) OPCODE|OPERAND1
	PUSH {R9, R10, R11, R14}
	MOV R1, R0
	LDR R0,=zreg
	BL memoryread
	ADD R9, R0, #1
	MOV R9, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R0 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
dec: ;@ - ONE OPERAND - 0x06 (A) OPCODE|OPERAND1
	PUSH {R9, R10, R11, R14}
	MOV R1, R0
	LDR R0,=zreg
	BL memoryread
	SUB R9, R0, #1
	MOV R9, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R0 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
call_1n: ;@ - ONE OPERAND - 0x0F  (A) OPCODE|OPERAND1
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
mod: ;@ - TWO OPERANDS - 0x18 (B) OPCODE|EXTRABYTE|OPERAND1|OPERAND2 (C) ?
	PUSH {R9, R10, R11, R14}
	BL modulus
	MOV R0, R0 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
not: ;@ - VARIABLE OPERAND COUNT - 0x18 (C) ?
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
print_char: ;@ VARIABLE OPERAND COUNT - 0x05 (C) ?
	PUSH {R9, R10, R11, R14}
	LDR R9,=tempop
	LDR R0, [R9]
	BL sendtoUART
	POP {R9, R10, R11, R15}

;@ ZPROCEDURES PROGRAMMING BEGIN

;@ 20th, 22nd, 24th, and 28th Zregisters are used for ZProcedure bookkeeping

call_zprocedure:
	ADD R6, R6, #1
	;@ "zero out the set of Zregisters that you have been given"
	;@ etc, unfinished

return_zprocedure:
	
	
;@ BRANCH EXCECUTION

branch:
	;@ R2 is the branch byte, R8 is the second branch byte (not used if it turns out it's a short branch)
