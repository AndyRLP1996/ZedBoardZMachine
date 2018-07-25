.global asm_main
.global delay50th
.global sendtoUART

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
