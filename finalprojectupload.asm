;@ final project assembly code

.global asm_main
.align 4
gamememory: .space 2000000
.align 4

asm_main:
	modecheck:
	LDR R0, =0x41220000;@switches
	LDR R1, [R0]
	AND R2, R1, #128
	CMP R2, #128
	BLEQ upload


upload:
;@PUSH{,R14}
	setup:
		LDR R1, =0xE0001030 ;@UART itself
		LDR R2, =0xE0001004 ;@UART mode register (write 0x20)
		LDR R3, =0xE0001018 ;@UART baud rate generator (write 0d62)
		LDR R8, =0xE0001034 ;@UART baud rate divider (write 0d6)
		LDR R9, =0xE0001000 ;@UART control register (write 0x117 to reset)
		LDR R7, =gamememory
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