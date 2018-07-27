.global asm_main
.global delay50th
.global sendtoUART
.global setupUART

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
	pop {r1,r15}

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
