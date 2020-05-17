; includes all character definitions for the 7 segment display
#include "7segment.S"
; includes all morse code definitions
#include "morsecode_definitions.S"


    .global get_morse_code

get_morse_code:
	; Uncomment for standby mode
	; cpi r29, 0x0 ;check if there are no letters being inputted
	; breq standby ;go to standby mode

    cpi r29, 0x1 ;check if the letter is 1 signal long
    breq one

    cpi r29, 0x2 ;check if the letter is 2 signals long
    breq two

    cpi r29, 0x3 ;check if the letter is 3 signals long
    breq three

    cpi r29, 0x4 ;check if the letter is 4 signals long
    breq four

	rjmp error ;if the counter is greater or less than than 4, then throw an error

standby:
	rjmp final ;jmp to final

one:
	ldi r30, CHAR_E	
	cpi r28, M_E	; compare the morse code value in r28 with the morse code value of E
	breq buff1

	ldi r30, CHAR_T 
	cpi r28, M_T	; compare the morse code value in r28 with the morse code value of T
	breq buff1			

	rjmp error  ; if the signal is not identifiable as a letter
                ; throw an error

buff1:
	rjmp final ; The buffer is needed as the branch (+- 64 ) instruction cannot jump as far as a rjmp (+- 2k words) / jmp (anywhere within the program memory)

two:
	ldi r30, CHAR_I
	cpi r28, M_I	; compare the morse code value in r28 with the morse code value of I
	breq buff2

	ldi r30, CHAR_A 
	cpi r28, M_A	; compare the morse code value in r28 with the morse code value of A
	breq buff2

    ldi r30, CHAR_N	
	cpi r28, M_N	; compare the morse code value in r28 with the morse code value of N
	breq buff2

	ldi r30, CHAR_M
	cpi r28, M_M	; compare the morse code value in r28 with the morse code value of M 
	breq buff2

	rjmp error  ; if the signal is not identifiable as a letter
                ; throw an error

buff2:
	rjmp final ; The buffer is needed as the branch (+- 64 ) instruction cannot jump as far as a rjmp (+- 2k words) / jmp (anywhere within the program memory)

three:
	ldi r30, CHAR_D 
	cpi r28, M_D	; compare the morse code value in r28 with the morse code value of D
	breq buff3

	ldi r30, CHAR_G 
	cpi r28, M_G	; compare the morse code value in r28 with the morse code value of G 
	breq buff3

    ldi r30, CHAR_K	
	cpi r28, M_K	; compare the morse code value in r28 with the morse code value of K
	breq buff3

	ldi r30, CHAR_O 
	cpi r28, M_O	; compare the morse code value in r28 with the morse code value of O
	breq buff3	

    ldi r30, CHAR_R 
	cpi r28, M_R	; compare the morse code value in r28 with the morse code value of R
	breq buff3

	ldi r30, CHAR_S 
	cpi r28, M_S	; compare the morse code value in r28 with the morse code value of S 
	breq buff3

    ldi r30, CHAR_U 
	cpi r28, M_U	; compare the morse code value in r28 with the morse code value of U
	breq buff3

	ldi r30, CHAR_W 
	cpi r28, M_W	; compare the morse code value in r28 with the morse code value of W 
	breq buff3

	rjmp error  ; if the signal is not identifiable as a letter
                ; throw an error	

buff3:
	rjmp final ; The buffer is needed as the branch (+- 64 ) instruction cannot jump as far as a rjmp (+- 2k words) / jmp (anywhere within the program memory)

four:
	ldi r30, CHAR_B 
	cpi r28, M_B	; compare the morse code value in r28 with the morse code value of B
	breq final

	ldi r30, CHAR_C 
	cpi r28, M_C	; compare the morse code value in r28 with the morse code value of C 
	breq final			

    ldi r30, CHAR_F 
	cpi r28, M_F	; compare the morse code value in r28 with the morse code value of F
	breq final

	ldi r30, CHAR_H 
	cpi r28, M_H	; compare the morse code value in r28 with the morse code value of H 
	breq final	

    ldi r30, CHAR_J 
	cpi r28, M_J	; compare the morse code value in r28 with the morse code value of J
	breq final

	ldi r30, CHAR_L 
	cpi r28, M_L	; compare the morse code value in r28 with the morse code value of L 
	breq final	

    ldi r30, CHAR_P	
	cpi r28, M_P	; compare the morse code value in r28 with the morse code value of P
	breq final

	ldi r30, CHAR_Q 
	cpi r28, M_Q	; compare the morse code value in r28 with the morse code value of Q
	breq final	

    ldi r30, CHAR_V 
	cpi r28, M_V	; compare the morse code value in r28 with the morse code value of V
	breq final

	ldi r30, CHAR_X 
	cpi r28, M_X	; compare the morse code value in r28 with the morse code value of X 
	breq final	

    ldi r30, CHAR_Y	
	cpi r28, M_Y	; compare the morse code value in r28 with the morse code value of Y
	breq final
	
	ldi r30, CHAR_Z 
	cpi r28, M_Z	; compare the morse code value in r28 with the morse code value of Z
	breq final	

	rjmp error  ; if the signal is not identifiable as a letter
                ; throw an error	

final:
    clr r29 ; clear the morse code length 
    clr r28 ; clear the morse code letter
    ret     ; return to where we relative called get_morse_code
    .global error
error:
	ldi r30, CHAR_ERROR ; output the ERROR character
	rjmp final

