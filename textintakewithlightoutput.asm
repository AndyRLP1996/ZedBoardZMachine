textintake:
setup:
	LDR R0, =0x41210000;@lights
	LDR R1, =0xE0001030 ;@UART itself
	LDR R2, =0xE0001004 ;@UART mode register (write 0x20)
	LDR R3, =0xE0001018 ;@UART baud rate generator (write 0d62)
	LDR R4, =0xE0001034 ;@UART baud rate divider (write 0d6)
	LDR R5, =0xE0001000 ;@UART control register (write 0x117 to reset)
	LDR R6, =gamememory
	LDR R12, =0xE000102C ;@UART Fill register (check for 8)
initializeUART:
	MOV R7, #0x20
	STR R7, [R2]
	MOV R7, #62
	STR R7, [R3]
	MOV R7, #6
	STR R7, [R4]
	MOV R7, #0x117
	STR R7, [R5]
textintakeloop:
	MOV R7, #8
	waittillreadable:
		LDR R4, [R12]
		AND R4, R4, R7
		CMP R4, R7
		BNE waittillreadable
	LDR R7, [R1];@loads uart into register 7
	STR R7, [R0];@writes uart into lights
	bl delay50th
	B textintakeloop

delay50th:
	push {R4,R14}
	LDR R4, =150000 ;@use 150,000 for roughly a 50th of a second delay (0.02ms)
	loop2:
		SUB R4, R4, #1
		ADD R4,R4,#1
		SUB R4, R4, #1
		CMP R4,#0
		BNE loop2
	pop {R4,R15}
