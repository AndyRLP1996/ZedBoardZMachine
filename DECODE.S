.global decode

decode:
push {r14}

BLNE crashmode ;@executes if no matching instruction is found
pop {r15}
