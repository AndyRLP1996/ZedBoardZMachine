;@ final project assembly code

.global asm_main
.global zeroout
.global upload
.global checksum
.global memoryread
.global delay50th
.global sendtoUART
.global setupUART

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

uploadmode:
push {r14}
	;@ the following code zeroes all memory
	;@ zeroes zstack
	LDR R12,=1000000
	LDR R8, =zstack
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed
	;@zeroes the tempop
	LDR R12,=256
	LDR R8, =tempop
	;@zeroes the dumping ground
	LDR R12,=500000
	LDR R8, =dumpingground
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed
	;@zeroes the game memory
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed
	LDR R12,=2000000
	MOV R8, R7
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed
	LDR R12,=1000000
	LDR R8, =zreg
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed

	CMP R2, #128

	BLEQ upload
	CMP R2, #128
	BLEQ checksum
	CMP R0, #1 ;@checks that checksum returns true (file is valid)
	CMP R2, #128
	MOV R0, R7
	MOV R1, #28
	BLEQ memoryread ;@should return 0x942d in r0
	LDR R1,=0x942d
	CMP R0, R1 ;@checks that checksum works
pop {r15}

debugmode:
push {r14}

pop {r15}

headermode:
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
	MOV R4, R9;@initialize zpc
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
	Atype:
		LDR R1,=0b00110000
		AND R2, R0, R1 ;@bits 5 and 4 extracted
		SUBS R1,R1,R2
		;@R12 is holding the opcount
		MOV R12,#1
		MOVEQ R12,#0
		;@read operand type
		;@check 00, two byte constant
		LDR R1,=0b00110000;@edit
		ANDS R1, R1, R0
		BEQ fetchop;@branch to code for part 9

		;@check 01, one byte constant
		LDR R1,=0b00010000
		ANDS R1, R1, R0
		BNE fetchop;@branch to code for part 9

		;@check 10, one byte register indicator
		LDR R1,=0b00100000
		ANDS R1, R1, R0
		BNE	fetchop;@branch to code for part 9
		;@R1 contains the opcode for all 3 scenarios of atype
		BL crashmode;@should only branch if none of the decode branches work

	Btype:
		MOV R12,#2;@opcount
		;@extract bit 6
		MOV R1,R0
		LDR R2,=0b00100000
		ANDS R1,R2,R1
		;@zero for one byte constant, 1 for one byte register indicator
		;@extract bit 5
		MOV R1,R0
		LDR R2,=0b00010000
		ANDS R1,R2,R1
		;@zero for one byte constant, 1 for one byte register indicator
		;@extract bits 4-0
		MOV R1,R0
		LDR R2,=0b00011111
		AND R1,R2,R1
		;@R1 now contains opcode for instruction
		BL fetchop
		;@BL crashmode

	Ctype:
		;@extract bit 5 of byte
		MOV R1,R0
		LDR R2,=0b00010000
		ANDS R1, R1, R2
		;@check if 0 or 1. if 0, opcount is 2, otherwise is variable
		MOVEQ R12,#2
		MOVNE R12,#3 ;@3 indicates variable opcount
		;@extract instruction indicator
		MOV R1,R0
		LDR R2,=0b00011111
		AND R1,R2,R1
		;@R1 now contains instruction indicator, R12 contains opcount
		BL fetchop
		;@BL crashmode

	Xtype: ;@fill in later if time



	;@insert crash mode here
	;@BNE crashmode
	exitgamemode:
pop {r15}

fetchop:
push {r14}

pop {r15}

crashmode:
push {r14}
	;@send to UART the entire instruction and its location in memory (as an offset)
	;@ first load into dumpingground the contents of the instruction, then send them 1 by 1 to UART

pop {r15}
