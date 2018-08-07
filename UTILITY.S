.global delay50th
.global sendtoUART
.global setupUART
.global memoryread
.global memoryreadbyte

delay50th:
push {R0,R14}
	LDR R0, =150000 ;@use 150,000 for roughly a 50th of a second delay (0.02ms)
	loop2:
		SUB R0, R0, #1
		ADD R0,R0,#1
		SUB R0, R0, #1
		CMP R0,#0
		BNE loop2
pop {R0,R15}

sendtoUART: ;@treats r0 as input register
push {r1,r14} ;@assumes UART is set
	LDR R1, =0xE0001030 ;@UART itself
	STR R0, [R1]
pop {r1,r15} ;@NOT DONE

setupUART:
push {R1,R2,R3,R8,R9,R10,R12,r14}
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
pop {R1,R2,R3,R8,R9,R10,R12,r15}

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

memoryreadbyte:
	;@r0 and r1 are the inputs
	;@r0 should be a pointer
	;@r1 should be an offset
	;@r0 is also the return register
push {r2,r3,r8,r14}
	LDR R0, [R0,R1] ;@loads most significant bits
	;@junk instruction:
	MOV R0, R0
pop {r2,r3,r8,r15}

memorywrite:
push {R3,R10,R11,R14}
	;@takes r0, r1, and r2 as input
	;@r0 is a 16 bit value and r1 is the destination memory location
	;@r2 is the offset
	LDR R3,=0x00ff
	AND R11, R0, R3 ;@R11 now holds the LSBs
	LDR R3,=0xff00
	AND R10,R0,R3
	MOV R10, R10 LSR #8
	STR R10, [R1,R2] ;@writes MSBs to desired address
	ADD R2, R2, #1
	STR R11, [R1,R2] ;@writes LSBs to next byte
pop {R3,R10,R11,R15}
