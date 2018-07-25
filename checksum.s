checksum:
;@R0 is 
push {R14}
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
	LDR R0,=0x0942
	CMP R8, R0
	MOV R0, #0
	MOVEQ R0, #1
pop{R15}