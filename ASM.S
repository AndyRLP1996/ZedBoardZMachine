;@ final project assembly code

.global asm_main
.global zmemory
.global zstack
.global tempop
.global dumpingground
.global zreg
.global crashmode
.global gamemode

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
	MOV R0, R6
	MOV R1, R6
	MOV R2, R6
	MOV R3, R6
	MOV R8, R6
	MOV R9, R6
	MOV R10, R6
	MOV R11, R6
	MOV R12, R6
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
		BLEQ headermode ;@will get object table location in r11, dictionary in r10, inSTRuction location in r9, and global registers in r8
		BLNE noheadermode ;@objects will be in same location as no header mode
		BL gamemode
	B modecheck

debugmode:
push {r14}
	BL crashmode
pop {r15}

headermode: ;@not quite done yet?
push {r12,r14}
	;@read in object table
	LDR R12,=0x0A
	LDR R11,[R7,R12] ;@r11 now contains location of object table
	;@read in dictionary
	LDR R12,=0x08
	LDR R10,[R7,R12] ;@r10 now contains location of dictionary
	;@read in location of first inSTRuction
	LDR R12,=0x04
	LDR R9,[R7,R12]
	;@read in global register locations
	LDR R12,=0x0C
	LDR R8,[R7,R12]
	MOV R4, R8;@initialize zpc
pop {r12,r15}

noheadermode: ;@not quite done yet?
push {r12,r14}
	LDR R11,=0x1000 ;@obj table
	LDR R10,=0x2000 ;@dictionary
	LDR R9,=0x0000;@first inSTRuction
	LDR R8,=0x4000;@global z registers
	MOV R4, R9;@initialize zpc
pop {r12,r15}

gamemode:
push {r14}
	mainloop:
		LDR R0,[R7,R4];@load opcode
		ADD R4,R4,#1;@advance ZPC
		LDR R8,=dumpingground
		STR R0,[R8] ;@for crashmode
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
			;@isolates inSTRuction indicator
			LDR R2,=0b00001111
			AND R3,R2,R3 ;@R3 now contains isolated inSTRuction indicator
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

	Btype: ;@done
		MOV R12,#2;@opcount
		MOV R3, R0
		;@extract bits 4-0
			LDR R2,=0b00011111
			AND R3,R2,R3
			;@R3 now contains inSTRuction indicator
		;@extract bit 6
			MOV R1,R0
			LDR R2,=0b01000000
			AND R8,R2,R1
		;@extract bit 5
			MOV R1,R3
			LDR R2,=0b00100000
			AND R1,R2,R1
			;@zero for one byte constant, 1 for one byte register indicator
			;@ 4 possible cases. 5 for both are constants. 6 for first is constant, second is register. 7 for first is register, second is constant. 8 for both are registers
			MOV R1, R1, LSL #1
			ADD R1, R8, R1
			CMP R1, #0
			MOVEQ R10, #5 ;@both are constants
			CMP R1, #1
			MOVEQ R10, #6 ;@second is register
			CMP R1, #2
			MOVEQ R10, #7
			CMP R1, #3
			MOVEQ R10, #8
			BL decode
		BL crashmode
	Ctype:
		;@extract inSTRuction indicator
			MOV R1,R0
			LDR R2,=0b00011111
			AND R1,R2,R1
			MOV R3, R1
			;@R3 now contains inSTRuction indicator, R12 will contain the opcount
		;@extract bit 5 of byte
			MOV R1,R0
			LDR R2,=0b00100000
			ANDS R1, R1, R2 ;@checks if byte 5 is 0 or 1
			;@check if 0 or 1. if 0, opcount is 2, if 1, is variable
			MOVEQ R12,#2 ;@2 indicates opcount is 2
			MOVEQ R10, #9 ;@is code for opcount=2
			MOVNE R10, #10 ;@indicates opcount is variable
			MOVNE R12,#3 ;@3 indicates variable opcount, will get readjusted at decode function
			BL decode
		BL crashmode
	Xtype: ;@fill in later if time
	;@insert crash mode here
	BL crashmode
	exitgamemode: ;@should only ever be branched to if deliberately exiting game mode, thus crash comes first.
pop {r15}

crashmode: ;@should be done
push {r14}
	;@send to UART the entire inSTRuction and its location in memory (as an offset)
	;@ first load into dumpingground the contents of the inSTRuction, then send them 1 by 1 to UART
		LDR R1,=dumpingground
		LDRB R8, [R1]
		MOV R3, R8
		MOV R2, #0
		LDR R0,=10
		STRB R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=13
		STRB R0,[R1,R2]
		ADD R2, R2, #1
	;@stores "CRASH!:" to the memory to read
		LDR R0,=67 ;@C
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=82;@R
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=65 ;@A
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=83 ;@S
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=72 ;@H
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=33 ;@!
		STR R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=58 ;@:
		STR R0,[R1,R2]
		ADD R2, R2, #1
	;@stores current memory address to memory as ASCII
		MOV R0, R4
		PUSH {R1,R2, R3}
		BL hextoascii
		POP {R1,R2, R3}
		STRB R0,[R1,R2]
		ADD R2, R2, #1
		LDR R0,=32
		STRB R0,[R1,R2]
		ADD R2, R2, #1
	;@load in the inSTRuction indicator
		MOV R9, #0
		crashloop1:
			MOV R0, R3
			LDR R11,=0b00000001
			MOV R11, R11, LSL R9
			ADD R9, R9, #1
			AND R0, R11, R0
			PUSH {R1,R2, R3}
			BL hextoascii
			POP {R1,R2, R3}
			STRB R0,[R1,R2]
			ADD R2, R2, #1
			CMP R9, #8
			BNE crashloop1
	;@load operand bytes
		;@R12 contains the opcount, R4 is ZPC
		MOV R8, R12
		MOV R10, #0
		crashloop3:
			MOV R9, #0
			ADD R10, R4, R7
			SUB R10, R10, R8
			LDRB R3, [R10]
			crashloop2:
				MOV R0, R3
				LDR R11,=0b00000001
				MOV R11, R11, LSL R9
				ADD R9, R9, #1
				AND R0, R11, R0
				PUSH {R1,R2, R3}
				BL hextoascii
				POP {R1,R2, R3}
				STRB R0,[R1,R2]
				ADD R2, R2, #1
				CMP R9, #8
				BNE crashloop2
			LDR R0,=10
			STRB R0,[R1,R2]
			ADD R2, R2, #1
			LDR R0,=13
			STRB R0,[R1,R2]
			ADD R2, R2, #1
			SUB R8, R8, #1
			CMP R8, #0
			BNE crashloop3
	;@write bytes to UART:
		MOV R0, R1
		MOV R1, R2
		;@ADD R1, R1, #9
		;@LDR R0,=dumpingground
		BL sendlotstoUART
	B HCF
pop {r15}
