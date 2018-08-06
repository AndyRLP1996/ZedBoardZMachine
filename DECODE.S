.global decode

decode:
push {r14}

BLNE crashmode ;@executes if no matching instruction is found
pop {r15}

;@ R0 is operand 1
;@ R1 is operand 2
;@ tempop offsets 0, 2, 4, 6, 8, 10, 12, 14 store operands if it is variable operand type
;@ tempop (from 0 onwards) also stores the encoded string that comes after one instruction (PRINT)
;@ R2 will store the extra byte required in some instructions (ADD, SUB, MUL, DIV, CALL_2S, PULL, MOD, NOT)
;@ R2 will also store branch byte 1, if it is a branch instruction (JE, JL, JG, TEST_ATTR)
;@ R8 will store branch byte 2 if it's a long branch (JE, JL, JG, TEST_ATTR)
;@ R12 will be the number of operands

verify: ;@ - NO OPERANDS - 0xD
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}

add: ;@ - TWO OPERANDS - 0x14
	PUSH {R9, R10, R11, R14}
	ADD R9, R0, R1

	MOV R0, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
sub: ;@ - TWO OPERANDS - 0x15
	PUSH {R9, R10, R11, R14}
	SUB R9, R0, R1

	MOV R0, R9 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
mul: ;@ - TWO OPERANDS - 0x16
	PUSH {R9, R10, R11, R14}
	BL multiply
	
	MOV R0, R0 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
div: ;@ - TWO OPERANDS - 0x17
	PUSH {R9, R10, R11, R14}
	BL divide
	
	MOV R0, R0 ;@ for memorywrite function, R0 is what is being written
	LDR R1,=zreg ;@ for memorywrite function, R1 is the memory type
	MOV R2, R2 ;@ for memorywrite function, R2 is the memory offset
	BL memorywrite
	POP {R9, R10, R11, R15}
	
print_num: ;@ - VARIABLE OPERAND COUNT - 0x06
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
je: ;@ - TWO OPERANDS - 0x01
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
jl: ;@ - TWO OPERANDS - 0x02
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
jg: ;@ - TWO OPERANDS - 0x03
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
ret_popped: ;@ - NO OPERANDS - 0x08
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
ret: ;@ - ONE OPERAND - 0x0B
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
call_2s: ;@ - TWO OPERANDS - 0x19
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
call_2n: ;@ - TWO OPERANDS - 0x1A
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
push: ;@ - VARIABLE OPERAND COUNT - 0x08
	PUSH {R9, R10, R11, R14}
	LDR R9,=tempop ;@ Fetch first variable operand
	LDR R10, [R9]
	STR R10, [R5]
	ADD R5, R5, #1
	POP {R9, R10, R11, R15}
	
pull: ;@ - VARIABLE OPERAND COUNT - 0x09
	PUSH {R9, R10, R11, R14}
	LDR R5, [R2]
	SUB R5, R5, #1
	POP {R9, R10, R11, R15}
	
print: ;@ - NO OPERANDS - 0x02
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
test_attr: ;@ - TWO OPERANDS - 0x0A
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
set_attr: ;@ - TWO OPERANDS - 0x0B
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
clear_attr: ;@  - TWO OPERANDS - 0x0C
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
inc: ;@ - ONE OPERAND - 0x05
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
dec: ;@ - ONE OPERAND - 0x06
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
call_1n: ;@ - ONE OPERAND - 0x0F
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
mod: ;@ - TWO OPERANDS - 0x18
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
not: ;@ - VARIABLE OPERAND COUNT - 0x18
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}
	
print_char: ;@ VARIABLE OPERAND COUNT - 0x05
	PUSH {R9, R10, R11, R14}
	
	POP {R9, R10, R11, R15}

;@ ZPROCEDURES PROGRAMMING BEGIN

;@ 20th, 22nd, 24th, and 28th Zregisters are used for ZProcedure bookkeeping

call_zprocedure:
	ADD R6, R6, #1
	;@ "zero out the set of Zregisters that you have been given"
	;@ etc, unfinished

return_zprocedure:
	
	
;@ BRANCH EXCECUTION

branch:
	;@ R2 is the branch byte, R8 is the second branch byte (not used if it turns out it's a short branch)
