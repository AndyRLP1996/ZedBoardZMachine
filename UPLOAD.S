.global asm_main
.global zeroout
.global upload
.global checksum
.global memoryread

zeroout:
PUSH {R8,R11,R14}
	MOV R11, #0
	zeromemory:
		STR R11, [R8,R12]
		SUB R12, R12, #1
		CMP R12, #0
		BNE zeromemory
POP {R8,R11,R15}

upload:
PUSH {r1,r2,r3,r8,r9,r10,r12,R14}
	setup:
		LDR R1, =0xE0001030 ;@UART itself
		LDR R2, =0xE0001004 ;@UART mode register (write 0x20)
		LDR R3, =0xE0001018 ;@UART baud rate generator (write 0d62)
		LDR R8, =0xE0001034 ;@UART baud rate divider (write 0d6)
		LDR R9, =0xE0001000 ;@UART control register (write 0x117 to reset)
		LDR R12, =0xE000102C ;@UART Fill register (check for 8)
	initializeUART:
		MOV R10, #0x20
		STR R10, [R2]
		MOV R10, #62
		STR R10, [R3]
		MOV R10, #6
		STR R10, [R8]
		MOV R10, #0x117
		STR R10, [R9]
	waittillfileissent:
		MOV R10, #2
		waittillfilereadable:
			LDR R8, [R12]
			AND R8, R8, R10
			CMP R8, R10
			BEQ waittillfilereadable
		MOV R3, #0
	fileintakeloop:
		LDR R10, [R1]
		STR R10, [R7,R3]
		ADD R3, R3, #1
		checknolongerrecieving:
			MOV R10, #8
			LDR R8, [R12]
			AND R8, R8, R10
			CMP R8, R10
			BNE fileintakeloop
POP {r1,r2,r3,r8,r9,r10,r12,R15}

checksum:
;@R0 is return register
;@returns 0 if not valid, 1 if valid
push {R1,R2,R3,R8,R14}
	LDR R1,=0x40
	LDR R2,=256000
	LDR R0,=0xffff
	MOV R8,#0
	checksumloop1:
		STR R3,[R7,R1]
		ADD R8,R8,R3
		ADD R1,R1,#1
		SUB R2,R2,#1
		CMP R2,#0
		BNE checksumloop1
	AND R8, R8, R0
	LDR R0,=0x942d
	CMP R8, R0
	MOV R0, #0
	MOVEQ R0, #1
pop {R1,R2,R3,R8,R15}

memoryread:
;@r0 and r1 are the inputs
;@r0 should be a pointer
;@r1 should be an offset
;@r0 is also the return register
push {r2,r3,r8,r14}
	LDR R2, [R0,R1] ;@loads most significant bits
	ADD R1, R1, #1
	LDR R3, [R0,R1] ;@loads least significant bits
	LDR R8,= 256
	MUL R2, R2, R8
	ADD R0, R2, R3
	;@junk instruction:
	MOV R0, R0
pop {r2,r3,r8,r15}




