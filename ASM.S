;@ final project assembly code

.global asm_main
.global zmemory
.global zstack
.global tempop
.global dumpingground
.global zreg

.align 4
zmemory: .space 2000000
.align 4
zstack: .space 1000000
.align 4
tempop: .space 256
.align 4
dumpingground: .space 500000 ;@for use in case run out of registers
.align 4
zreg: .space 1000000
.align 4

asm_main:
	LDR R7, =zmemory
	MOV R4, #0 ;@zpc
	MOV R5, #0 ;@zsp, reads as 00 in disassembly
	MOV R6, #0 ;@function call nesting depth
	modecheck:
		LDR R0, =0x41220000;@switches
			LDR R1, [R0]
			AND R2, R1, #32
			CMP R2, #32
		BLEQ debugmode
			LDR R1, [R0]
			AND R2, R1, #128
			CMP R2, #128
		BLEQ uploadmode
			LDR R1, [R0]
			AND R2, R1, #64
			CMP R2, #64
		BLEQ headermode ;@will get object table location in r11, dictionary in r10, instruction location in r9, and global registers in r8
		BLNE noheadermode ;@objects will be in same location as no header mode
		BL gamemode
	B modecheck

debugmode:
push {r14}

pop {r15}

headermode: ;@not quite done yet?
push {r12,r14}
	;@read in object table
	LDR R12,=0x0A
	LDR R11,[R7,R12] ;@r11 now contains location of object table
	;@read in dictionary
	LDR R12,=0x08
	LDR R10,[R7,R12] ;@r10 now contains location of dictionary
	;@read in location of first instruction
	LDR R12,=0x04
	LDR R9,[R7,R12]
	;@read in global register locations
	LDR R12,=0x0C
	LDR R8,[R7,R12]
	MOV R4, R8;@initialize zpc
pop {r12,r15}

noheadermode:
push {r12,r14}
	LDR R11,=0x1000 ;@obj table
	LDR R10,=0x2000 ;@dictionary
	LDR R9,=0x0000;@first instruction
	LDR R8,=0x4000;@global z registers
	MOV R4, R9;@initialize zpc
pop {r12,r15}

gamemode:
push {r14}
	mainloop:
		LDR R0,[R7,R4];@load opcode
		ADD R4,R4,#1;@advance ZPC
		;@extract bits 7 and 6
		LDR R1,=0b11000000
		AND R1,R0,R1
		;@check for A type
		LDR R2,=0b10000000
		CMP R2, R1
		BEQ Atype
		;@check for B type
		LDR R2,=0b00000000
		CMP R2, R1
		BEQ Btype
		;@check for C type
		LDR R2,=0b11000000
		CMP R2, R1
		BEQ Ctype
		;@ load switches to check that board is still in game mode
			LDR R12, =0x41220000;@switches
			LDR R1, [R12]
			AND R1, R1, #128
			CMP R1, #128
		BNE exitgamemode
		;@R0 still has opcode
	Atype:;@done
		LDR R1,=0b00110000
		MOV R3, R0
		AND R2, R0, R1 ;@bits 5 and 4 extracted
		SUBS R1,R1,R2
		;@R12 is holding the opcount
		MOV R12,#1
		MOVEQ R12,#0
		;@read operand type
			;@isolates instruction indicator
			LDR R2,=0b00001111
			AND R3,R2,R3 ;@R3 now contains isolated instruction indicator
		;@check 00, two byte constant
			LDR R1,=0b00110000;@edit
			ANDS R1, R1, R0
			MOVNE R10, #1
			BLEQ decode
		;@check 01, one byte constant
			LDR R1,=0b00010000
			ANDS R1, R1, R0
			MOVNE R10, #2
			BLNE decode
		;@check 10, one byte register indicator
			LDR R1,=0b00100000
			ANDS R1, R1, R0
			MOVNE R10, #3
			BLNE decode
		;@R1 contains the opcode for all 3 scenarios of atype
		;@check for 11, no operands
			LDR R1,=0b00110000
			AND R2, R1, R0
			CMP R2, R1
			MOVEQ R10, #4
			BLEQ decode
		BL crashmode;@should only branch if none of the decode branches work

	Btype:
		MOV R12,#2;@opcount
		MOV R3, R0
		;@extract bits 4-0
			LDR R2,=0b00011111
			AND R3,R2,R3
			;@R3 now contains instruction indicator

		;@extract bit 6
			MOV R1,R0
			LDR R2,=0b01000000
			ANDS R1,R2,R1
			;@zero for one byte constant, 1 for one byte register indicator
			;@MOVNE R10, #5
			;@MOVEQ R10, #6
			BL decode
		;@extract bit 5
			MOV R1,R3
			LDR R2,=0b00100000
			ANDS R1,R2,R1
			;@zero for one byte constant, 1 for one byte register indicator
			;@MOVNE R10, #7
			;@MOVEQ R10, #8
			BL decode
		BL crashmode

	Ctype:
		;@extract instruction indicator
			MOV R1,R0
			LDR R2,=0b00011111
			AND R1,R2,R1
			MOV R3, R1
			;@R3 now contains instruction indicator, R12 contains opcount
		;@extract bit 5 of byte
			MOV R1,R0
			LDR R2,=0b00100000
			ANDS R1, R1, R2 ;@checks if byte 5 is 0 or 1
			;@check if 0 or 1. if 0, opcount is 2, if 1, is variable
			MOVEQ R12,#2 ;@2 indicates opcount is 2
			BLNE ctypevar
			;@MOVNE R12,#3 ;@3 indicates variable opcount
			;@MOV R10,#9
			BL decode
		;@BL crashmode
	Xtype: ;@fill in later if time
	;@insert crash mode here
	;@BNE crashmode
	exitgamemode:
pop {r15}

ctypevar:
push {r14}
	
pop {r15}

fetchop:;@instruction indicator will be in R3, R12 holds the opcount
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

zregfetch: ;@takes the address of the z register to fetch as input, and returns its contents
push {r14} ;@r10 is the input
	;@add 1 to R5 (z stack pointer) when pushing onto stack and subtract 1 when popping

pop {r15}

zregstore: ;@takes the address of the zregister and the contents you wish to store and stores the contents to the given z register
push {r14} ;r10 and r11 are the inputs. 
	L

pop {r15}

crashmode:
push {r14}
	;@send to UART the entire instruction and its location in memory (as an offset)
	;@ first load into dumpingground the contents of the instruction, then send them 1 by 1 to UART

pop {r15}
