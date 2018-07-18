;@ final project assembly code

.global asm_main
.global zeroout
.global upload

.align 4
gamememory: .space 2000000
.align 4

asm_main:
	LDR R7, =gamememory
	B zeroout
	modecheck:
	LDR R0, =0x41220000;@switches
	LDR R1, [R0]
	AND R2, R1, #128
	CMP R2, #128
	BLEQ zeroout
	CMP R2, #128
	BLEQ upload
	;@BLEQ sumcheck
	B modecheck

sumcheck:
