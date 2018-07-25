;@ final project assembly code

.global asm_main
.global zeroout
.global upload
.global checksum
.global memoryread
.global delay50th
.global sendtoUART

.align 4
gamememory: .space 2000000
.align 4
gamestack: .space 1000000
.align 4
tempop: .space 256
.align 4
dumpingground: .space 500000 ;@for use in case run out of registers
.align 4
gamereg: .space 1000000
.align 4

asm_main:
	LDR R7, =gamememory
	MOV R4, #0 ;@zpc
	MOV R5, #0 ;@zsp
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
			LDR R1, [R0] ;@ask TAs
			AND R2, R1, #64
			CMP R2, #64
		BLEQ headermode
		BLNE noheadermode ;@ask TAs about placement
		BL gamemode ;@header vs no header check
	B modecheck

uploadmode:
push {r14}
	;@ the following code zeroes all memory
	;@ zeroes gamestack
	LDR R12,=1000000
	LDR R8, =gamestack
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
	LDR R8, =gamereg
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
push {r14}

pop {r15}

noheadermode:
push {r14}

pop {r15}

gamemode:
push {r14}
	;@popeq {r15}
pop {r15}

crashmode:
push {r14}

pop {r15}
