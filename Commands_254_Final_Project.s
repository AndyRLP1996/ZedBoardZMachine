;@ NO OPERANDS:

;@ RET_POPPED - NO OPERANDS - 0x8 - (Looks to be a Pop from the ZStack, as refered to in Section 12.3)
;@ Pop the Zstack. Return from the current Zprocedure
;@ with the result that was popped.
;@ The detailed instructions on how to perform
;@ a Zprocedure return are in the main project manual.

;@ PRINT - NO OPERANDS - 0x2
;@ This instruction is followed by an encoded string.
;@ Send the given string, after decoding, to the
;@ UART.

;@ ONE OPERAND:

;@ INC - ONE OPERAND - 0x5 (Increment. Pretty simple)
;@ Perform the fetch of the operand. This will always
;@ be a byte.
;@ Read from the Zregister that would be indicated
;@ by the operand. (If the operand is 0x00,
;@ pop the stack. If it is 0x05, read the local Zregister
;@ number 4, etc...)
;@ Add one to the number you obtained in the
;@ previous step.
;@ Write that number back into the Zregister
;@ you got it from.

;@ DEC - ONE OPERAND - 0x6 (Decrement. Pretty simple)
;@ Perform the fetch of the operand. This will always
;@ be a byte.
;@ Read from the Zregister that would be indicated
;@ by the operand. (If the operand is 0x00,
;@ pop the stack. If it is 0x05, read the local Zregister
;@ number 4, etc...)
;@ Subtract one from the number you obtained
;@ in the previous step.
;@ Write that number back into the Zregister
;@ you got it from.

;@ CALL_1N - ONE OPERAND - 0xF ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operand.
;@ Call the Zprocedure that is given in the
;@ operand.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.
;@ Upon return from this call, you will throw
;@ away the result of the Zprocedure.

;@ RET - ONE OPERAND - 0xB
;@ Perform the fetch of the operand.
;@ Return from the current Zprocedure with the
;@ operand becoming the return result.
;@ The detailed instructions on how to perform
;@ a Zprocedure return are in the main project manual.

;@ VERIFY - NO OPERANDS - 0xD
;@ This is a branch instruction. Fetch one or two
;@ bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Optional support, though highly recommended.
;@ If you don’t want to support this instruction,
;@ treat it as an unconditional branch.
;@ If you are aiming for the VERIFY basic
;@ points, you need to support this instruction. Add
;@ up all the program bytes that followed the header,
;@ AND the sum with 0xffff and compare the result
;@ of the AND with the 16-bit number in the header
;@ at offset 28 (decimal). Branch on a match. Crash
;@ on a mismatch.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ TWO OPERANDS:

;@ ADD - TWO OPERANDS - 0x14
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the addition of the input operands
;@ and store the result, as indicated in the destination
;@ byte.

;@ SUB - TWO OPERANDS - 0x15
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the subtraction of the input
;@ operands and store the result, as indicated in the
;@ destination byte.
;@ (Result = Operand1 - Operand2)

;@ MUL - TWO OPERANDS - 0x16
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the multiplication of the input
;@ operands and store the result, as indicated in the
;@ destination byte.

;@ DIV - TWO OPERANDS - 0x17
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the division of the input operands
;@ and store the result, as indicated in the destination
;@ byte.
;@ (Result = Operand1 / Operand2)

;@ MOD - TWO OPERANDS - 0x18
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the modulus operation on the input
;@ operands and store the result, as indicated in the
;@ destination byte.
;@ (Result = Operand1 % Operand2)

;@ JE - TWO OPERANDS - 0x01
;@ This is a horrible Zinstruction. Despite being
;@ placed in the ”two operands” section, it can gladly
;@ appear in variable operand form and it can take
;@ up to four operands. Most of the time it only
;@ appears in simpler forms and takes only two
;@ operands, thankfully.
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand and any of the
;@ subsequent operands are equal.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project manual.

;@ JL - TWO OPERANDS - 0x02
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand is smaller than the
;@ second operand.
;@ Keep in mind, you have to use 16-bit arithmetic
;@ to find this out. 0xffff is smaller than
;@ 0x0000. Operating on raw ARM registers won’t
;@ get you the correct answer, unless you make sure
;@ to sign-extend your values to the full ARM register.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ JG - TWO OPERANDS - 0x03
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand is larger than the
;@ second operand.
;@ Keep in mind, you have to use 16-bit arithmetic
;@ to find this out. 0xffff is smaller than
;@ 0x0000. Operating on raw ARM registers won’t
;@ get you the correct answer, unless you make sure
;@ to sign-extend your values to the full ARM register.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ CALL_2S - TWO OPERANDS - 0x19 ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operands.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Call the Zprocedure that is the first operand.
;@ Give the Zprocedure the second operand as the
;@ input. Store the result into the designated destination.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.

;@ CALL_2N - TWO OPERANDS - 0x1A ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operands.
;@ Call the Zprocedure that is the first operand.
;@ Give the Zprocedure the second operand as the
;@ input.
;@ Upon return from this call, you will throw
;@ away the result of the Zprocedure.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.

;@ TEST_ATTR - TWO OPERANDS - 0x0A
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Check the bit indicated by the second operand. If
;@ that bit is set, branch.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ SET_ATTR - TWO OPERANDS - 0x0B
;@ Perform the fetch of the operands. Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Set the bit indicated by the second operand.

;@ CLEAR_ATTR - TWO OPERANDS - 0x0C
;@ Perform the fetch of the operands.
;@ Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Clear the bit indicated by the second operand.

;@ VARIABLE OPERAND COUNT:

;@ NOT - VARIABLE OPERAND COUNT - 0x18
;@ Perform the variable operand fetch.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Perform the logical not of the input operands
;@ and store them, as indicated in the destination
;@ byte.

;@ PRINT_CHAR - VARIABLE OPERAND COUNT - 0x5
;@ Perform the variable operand fetch.
;@ The first operand is an ASCII character, not
;@ encoded in any way. Throw it into the UART.

;@ PRINT_NUM - VARIABLE OPERAND COUNT - 0x6
;@ Perform the variable operand fetch.
;@ The first operand is going to be interpreted
;@ as a 16-bit signed number. Print that number
;@ through the UART. This is a pretty good candidate
;@ for delegating to C, see sprintf.

;@ PUSH - VARIABLE OPERAND COUNT - 0x08
;@ Perform the variable operand fetch.
;@ This instruction takes its first operand and
;@ pushes it onto the Zstack.

;@ PULL - VARIABLE OPERAND COUNT - 0x09
;@ Perform the variable operand fetch.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Pop the Zstack and store the value popped to
;@ the destination

#####################################################
#####################################################
#####################################################
#####################################################
#####################################################
#####################################################
DIFFERENT SORT METHOD AFTER THIS POINT
#####################################################
#####################################################
#####################################################
#####################################################
#####################################################
#####################################################

;@ VERIFICATION

;@ VERIFY - NO OPERANDS - 0xD
;@ This is a branch instruction. Fetch one or two
;@ bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Optional support, though highly recommended.
;@ If you don’t want to support this instruction,
;@ treat it as an unconditional branch.
;@ If you are aiming for the VERIFY basic
;@ points, you need to support this instruction. Add
;@ up all the program bytes that followed the header,
;@ AND the sum with 0xffff and compare the result
;@ of the AND with the 16-bit number in the header
;@ at offset 28 (decimal). Branch on a match. Crash
;@ on a mismatch.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ ARITHMETIC TEST SUITE

;@ ADD - TWO OPERANDS - 0x14
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the addition of the input operands
;@ and store the result, as indicated in the destination
;@ byte.

;@ SUB - TWO OPERANDS - 0x15
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the subtraction of the input
;@ operands and store the result, as indicated in the
;@ destination byte.
;@ (Result = Operand1 - Operand2)

;@ MUL - TWO OPERANDS - 0x16
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the multiplication of the input
;@ operands and store the result, as indicated in the
;@ destination byte.

;@ DIV - TWO OPERANDS - 0x17
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the division of the input operands
;@ and store the result, as indicated in the destination
;@ byte.
;@ (Result = Operand1 / Operand2)

;@ PRINT_NUM - VARIABLE OPERAND COUNT - 0x6
;@ Perform the variable operand fetch.
;@ The first operand is going to be interpreted
;@ as a 16-bit signed number. Print that number
;@ through the UART. This is a pretty good candidate
;@ for delegating to C, see sprintf.

;@ JUMP TEST SUITE

;@ JE - TWO OPERANDS - 0x01
;@ This is a horrible Zinstruction. Despite being
;@ placed in the ”two operands” section, it can gladly
;@ appear in variable operand form and it can take
;@ up to four operands. Most of the time it only
;@ appears in simpler forms and takes only two
;@ operands, thankfully.
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand and any of the
;@ subsequent operands are equal.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project manual.

;@ JL - TWO OPERANDS - 0x02
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand is smaller than the
;@ second operand.
;@ Keep in mind, you have to use 16-bit arithmetic
;@ to find this out. 0xffff is smaller than
;@ 0x0000. Operating on raw ARM registers won’t
;@ get you the correct answer, unless you make sure
;@ to sign-extend your values to the full ARM register.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ JG - TWO OPERANDS - 0x03
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Branch if the first operand is larger than the
;@ second operand.
;@ Keep in mind, you have to use 16-bit arithmetic
;@ to find this out. 0xffff is smaller than
;@ 0x0000. Operating on raw ARM registers won’t
;@ get you the correct answer, unless you make sure
;@ to sign-extend your values to the full ARM register.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ FUNCTION CALL TEST SUITE

;@ RET_POPPED - NO OPERANDS - 0x8 - (Looks to be a Pop from the ZStack, as refered to in Section 12.3)
;@ Pop the Zstack. Return from the current Zprocedure
;@ with the result that was popped.
;@ The detailed instructions on how to perform
;@ a Zprocedure return are in the main project manual.

;@ RET - ONE OPERAND - 0xB
;@ Perform the fetch of the operand.
;@ Return from the current Zprocedure with the
;@ operand becoming the return result.
;@ The detailed instructions on how to perform
;@ a Zprocedure return are in the main project manual.

;@ CALL_2S - TWO OPERANDS - 0x19 ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operands.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Call the Zprocedure that is the first operand.
;@ Give the Zprocedure the second operand as the
;@ input. Store the result into the designated destination.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.

;@ CALL_2N - TWO OPERANDS - 0x1A ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operands.
;@ Call the Zprocedure that is the first operand.
;@ Give the Zprocedure the second operand as the
;@ input.
;@ Upon return from this call, you will throw
;@ away the result of the Zprocedure.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.

;@ PUSH - VARIABLE OPERAND COUNT - 0x08
;@ Perform the variable operand fetch.
;@ This instruction takes its first operand and
;@ pushes it onto the Zstack.

;@ PULL - VARIABLE OPERAND COUNT - 0x09
;@ Perform the variable operand fetch.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Pop the Zstack and store the value popped to
;@ the destination

;@ OBJECT ATTRIBUTE TEST SUITE

;@ PRINT - NO OPERANDS - 0x2
;@ This instruction is followed by an encoded string.
;@ Send the given string, after decoding, to the
;@ UART.

;@ TEST_ATTR - TWO OPERANDS - 0x0A
;@ Perform the fetch of the operands.
;@ This is a branch instruction. Fetch one or
;@ two bytes though the ZPC, incrementing the ZPC
;@ each time.
;@ Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Check the bit indicated by the second operand. If
;@ that bit is set, branch.
;@ The detailed instructions on how to decode
;@ and perform a branch are in the main project
;@ manual.

;@ SET_ATTR - TWO OPERANDS - 0x0B
;@ Perform the fetch of the operands. Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Set the bit indicated by the second operand.

;@ CLEAR_ATTR - TWO OPERANDS - 0x0C
;@ Perform the fetch of the operands.
;@ Use the first operand as the index into your
;@ items table. (Multiply the operand by 14 to get the
;@ offset into the items table.) Retrieve the six bytes
;@ which correspond to the attribute set of an object.
;@ Clear the bit indicated by the second operand.

;@ THE REST OF THE NECESSARY INSTRUCTIONS

;@ INC - ONE OPERAND - 0x5 (Increment. Pretty simple)
;@ Perform the fetch of the operand. This will always
;@ be a byte.
;@ Read from the Zregister that would be indicated
;@ by the operand. (If the operand is 0x00,
;@ pop the stack. If it is 0x05, read the local Zregister
;@ number 4, etc...)
;@ Add one to the number you obtained in the
;@ previous step.
;@ Write that number back into the Zregister
;@ you got it from.

;@ DEC - ONE OPERAND - 0x6 (Decrement. Pretty simple)
;@ Perform the fetch of the operand. This will always
;@ be a byte.
;@ Read from the Zregister that would be indicated
;@ by the operand. (If the operand is 0x00,
;@ pop the stack. If it is 0x05, read the local Zregister
;@ number 4, etc...)
;@ Subtract one from the number you obtained
;@ in the previous step.
;@ Write that number back into the Zregister
;@ you got it from.

;@ CALL_1N - ONE OPERAND - 0xF ('Branch' (but not an actual branch) to a named 'function', called a Zprocedure)
;@ Perform the fetch of the operand.
;@ Call the Zprocedure that is given in the
;@ operand.
;@ The detailed instructions on how to perform
;@ a Zprocedure call are in the main project manual.
;@ Upon return from this call, you will throw
;@ away the result of the Zprocedure.

;@ MOD - TWO OPERANDS - 0x18
;@ Perform the fetch of the operands.
;@ This Zinstruction is followed by a byte that
;@ designates the destination Zregister. Fetch it and
;@ advance the ZPC by one.
;@ Perform the modulus operation on the input
;@ operands and store the result, as indicated in the
;@ destination byte.
;@ (Result = Operand1 % Operand2)

;@ NOT - VARIABLE OPERAND COUNT - 0x18
;@ Perform the variable operand fetch.
;@ This instruction is followed by a byte that
;@ designates the destination Zregister.
;@ Perform the logical not of the input operands
;@ and store them, as indicated in the destination
;@ byte.

;@ PRINT_CHAR - VARIABLE OPERAND COUNT - 0x5
;@ Perform the variable operand fetch.
;@ The first operand is an ASCII character, not
;@ encoded in any way. Throw it into the UART.
