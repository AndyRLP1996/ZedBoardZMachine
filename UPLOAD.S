.global uploadmode

uploadmode:
push {r14}
	;@ the following code zeroes all memory
	;@ zeroes zstack
	LDRB R12,=1000000
	LDRB R8, =zstack
	BL zeroout ;@takes R12 as input. input is size of memory to be zeroed
	;@zeroes the tempop
	LDRB R12,=256
	LDRB R8, =tempop
	BL zeroout
	;@zeroes the dumping ground
	LDRB R12,=500000
	LDRB R8, =dumpingground
	BL zeroout ;@takes R12 as input. input is size of memory to be zeroed
	;@zeroes the game memory
	LDRB R12,=2000000
	MOV R8, R7;@zmemory
	;@zeroes the zregisters
	BLEQ zeroout ;@takes R12 as input. input is size of memory to be zeroed
	LDRB R12,=1000000
	LDRB R8, =zreg
	BL zeroout ;@takes R12 as input. input is size of memory to be zeroed

	CMP R2, #128
	BLEQ upload
	CMP R2, #128
	BL verify
	;@BLEQ checksum
	;@CMP R0, #1 ;@checks that checksum returns true (file is valid)
	;@CMP R2, #128
	;@ second checksum

pop {r15}

zeroout:
PUSH {R8,R11,R14}
	MOV R11, #0
	zeromemory:
		STRB R11, [R8,R12]
		SUB R12, R12, #1
		CMP R12, #0
		BNE zeromemory
POP {R8,R11,R15}

upload:
PUSH {r1,r2,r3,r8,r9,r10,r12,R14}
	setup:
		LDRB R1, =0xE0001030 ;@UART itself
		LDRB R2, =0xE0001004 ;@UART mode register (write 0x20)
		LDRB R3, =0xE0001018 ;@UART baud rate generator (write 0d62)
		LDRB R8, =0xE0001034 ;@UART baud rate divider (write 0d6)
		LDRB R9, =0xE0001000 ;@UART control register (write 0x117 to reset)
		LDRB R12, =0xE000102C ;@UART Fill register (check for 8)
	initializeUART:
		MOV R10, #0x20
		STRB R10, [R2]
		MOV R10, #62
		STRB R10, [R3]
		MOV R10, #6
		STRB R10, [R8]
		MOV R10, #0x117
		STRB R10, [R9]
	waittillfileissent:
		MOV R10, #2
		waittillfilereadable:
			LDRB R8, [R12]
			AND R8, R8, R10
			CMP R8, R10
			BEQ waittillfilereadable
		MOV R3, #0
	fileintakeloop:
		LDRB R10, [R1]
		STRB R10, [R7,R3]
		ADD R3, R3, #1
		checknolongerrecieving:
			MOV R10, #8
			LDRB R8, [R12]
			AND R8, R8, R10
			CMP R8, R10
			BNE fileintakeloop
POP {r1,r2,r3,r8,r9,r10,r12,R15}

checksum: ;@need to remove now that verify has been added
	;@R0 is return register
push {R1,R2,R3,R8,R14}
	LDRB R1,=0x40
	LDRB R2,=256000
	SUB R2, R2, R1
	LDRB R0,=0xffff
	MOV R8,#0
	checksumloop1:
		STRB R3,[R7,R1]
		ADD R8,R8,R3
		ADD R1,R1,#1
		SUB R2,R2,#1
		CMP R2,#0
		BNE checksumloop1
	AND R8, R8, R0
	;@LDRB R0,=0x942d
	;@CMP R8, R0
	MOV R0, R8
	;@MOVEQ R0, #1
pop {R1,R2,R3,R8,R15}
