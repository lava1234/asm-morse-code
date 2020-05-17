; includes all character definitions for the 7 segment display
#include "7segment.S"
; includes all morse code definitions
#include "morsecode_definitions.S"
;r22 store temp value of r30 as ZL is r30
;ZL = r30
;ZH = r31
;r24 Iterator
;r25 Offset
    .global get_morse_code

get_morse_code:
	cpi r29, 0	
	breq final

	mov r22, r30
	ldi r24, 26	  ; Start on the second row
loop:
	rcall reset_pointer ; resets the pointer
	mov r25, r24
	subi r25, -26 ; Due to the limitations of the architecture of the arduino, we do not have an ADDI instruction
				  ; So we have to make do with SUBI
				  ; We add 26 to the offset to allow us to read the third row
	add ZL, r24   ; Add iterator to offset
	brcc 1f	      ; if no overflow from Z low, continue at 1
	inc ZH	  	  ; else add overflow to Z high byte

1:
	lpm r23, Z	  ; load letter length from the table
	cp r23, r29   ; compare letter length
	brne increment

	rcall reset_pointer ; resets the pointer

	add ZL, r25
	brcc 1f
	inc ZH

1: 
	lpm r23, Z
	cp r23, r28 ; compare morse code
	brne increment

	rjmp output ; output the character

increment:
	cpi r24, 52			; check if we have reached the end of the alphabet
	brne 1f				; if we haven't, then continue
	rjmp error			; if we have, then output an error

1:  inc r24     		; increment r24 and then go through the loop again
    rjmp loop   		; relative jump to loop

output:
	rcall reset_pointer ; resets the pointer
	subi r24, 26		; read the first line
    add ZL, r24    		; add the offset
    brcc 1f	
    inc ZH
1:
	lpm r22, Z			; load the 7-seg representaiton into r22
	mov r30, r22		; move the representation into r30

final:
	clr r29 			; clear the morse code length 
    clr r28 			; clear the morse code letter
    ret     			; return to where we relative called get_morse_code

error:
	ldi r30, CHAR_ERROR	; output the error sybol
	rjmp final

reset_pointer:
	ldi ZL, lo8(dictionary)	;reset the ZL and ZH registers
	ldi ZH, hi8(dictionary)
	ret
;;; Dictionary table:
;;;	First row holds the 7 seg representaion
;;;	Second row holds the length of each letter in terms of their signal
;;;	Third row holds their morse code value
dictionary:
    .byte CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, CHAR_I, CHAR_J, CHAR_K, CHAR_L, CHAR_M, CHAR_N, CHAR_O, CHAR_P, CHAR_Q, CHAR_R, CHAR_S, CHAR_T, CHAR_U, CHAR_V, CHAR_W, CHAR_X, CHAR_Y, CHAR_Z
    .byte 0x2, 0x4, 0x4, 0x3, 0x1, 0x4, 0x3, 0x4, 0x2, 0x4, 0x3, 0x4, 0x2, 0x2, 0x3, 0x4, 0x4, 0x3, 0x3, 0x1, 0x3, 0x4, 0x3, 0x4, 0x4,0x4
    .byte M_A, M_B, M_C, M_D, M_E, M_F, M_G, M_H, M_I, M_J, M_K, M_L, M_M, M_N, M_O, M_P, M_Q, M_R, M_S, M_T, M_U, M_V, M_W, M_X, M_Y, M_Z