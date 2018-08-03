.global decode

decode:
push {r14}

BLNE crashmode ;@executes if no matching instruction is found
pop {r15}

;@ R2 will store the extra byte required in some instructions (ADD, SUB, MUL, DIV, CALL_2S, PULL, MOD, NOT)
;@ R2 will also store branch byte 1, if it is a branch instruction (JE, JL, JG, TEST_ATTR)
;@ R3 will sore branch byte 2 if it's a long branch (JE, JL, JG, TEST_ATTR)
;@ R12 will be the number of operands

verify: ;@ - NO OPERANDS - 0xD
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}

add: ;@ - TWO OPERANDS - 0x14
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
sub: ;@ - TWO OPERANDS - 0x15
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
mul: ;@ - TWO OPERANDS - 0x16
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
div: ;@ - TWO OPERANDS - 0x17
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
print_num: ;@ - VARIABLE OPERAND COUNT - 0x06
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
je: ;@ - TWO OPERANDS - 0x01
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
jl: ;@ - TWO OPERANDS - 0x02
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
jg: ;@ - TWO OPERANDS - 0x03
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
ret_popped: ;@ - NO OPERANDS - 0x08
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
ret: ;@ - ONE OPERAND - 0x0B
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
call_2s: ;@ - TWO OPERANDS - 0x19
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
call_2n: ;@ - TWO OPERANDS - 0x1A
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
push: ;@ - VARIABLE OPERAND COUNT - 0x08
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
pull: ;@ - VARIABLE OPERAND COUNT - 0x09
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
print: ;@ - NO OPERANDS - 0x02
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
test_attr: ;@ - TWO OPERANDS - 0x0A
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
set_attr: ;@ - TWO OPERANDS - 0x0B
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
clear_attr: ;@  - TWO OPERANDS - 0x0C
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
inc: ;@ - ONE OPERAND - 0x05
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
dec: ;@ - ONE OPERAND - 0x06
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
call_1n: ;@ - ONE OPERAND - 0x0F
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
mod: ;@ - TWO OPERANDS - 0x18
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
not: ;@ - VARIABLE OPERAND COUNT - 0x18
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
print_char: ;@ VARIABLE OPERAND COUNT - 0x05
	PUSH{R8, R9, R10, R11, R14}
	
	POP{R8, R9, R10, R11, R15}
	
