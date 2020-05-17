#define __SFR_OFFSET 0
#include <avr/io.h>


;define length r18   ; stores length of morse
;define sequence r19 ; stores morse sequence
;define index r20    ; stores current character index
;define delay r24    ; defined in delay_cs.S


;;; Constants
DOT = 1                                 ; 100ms
DASH = 3 * DOT                          ; 300ms
SIGNAL_GAP = DOT                        ; 100ms
LETTER_GAP = 6 * DOT                    ; 600ms

	.section .text
	.global main
main:
    ldi r16, _BV(5)
    out DDRB, r16            ; set bit 5 (pin 13) of PORTB as output
    ldi ZL, lo8(message)     ; make Z point to the table with the message
    ldi ZH, hi8(message)
    rcall message_loop
    rjmp main
message_loop:
    lpm r20, Z               ; load index into r20
    cpi r20, 46            ; check if end of message has been reached
    breq end_message_loop    ; if it has then end the loop
    subi r20, 65
    rcall send_signal
    
    adiw ZL, 1               ; increment Z pointer
    rjmp message_loop        ; jmp back to the message_loop top

end_message_loop:
    clr r24                  ; clr timer register
    ret

send_signal:
    push ZL                  ; save previous state of table
    push ZH                  ; save previous state of table

    ldi ZL, lo8(dictionary)  ; load dictionary table
    ldi ZH, hi8(dictionary)
    
    add ZL, r20         ; add the index we were at
    brcc 1f
    inc ZH

1:  lpm r18, Z          ; load the length of the letter
    adiw ZL, 26         ; point Z to row 2
    lpm r19, Z          ; load the morse code found in row 2

signal_loop:
    sbi PORTB, 5        ; turn on bit 5 of portB

    sbrs r19, 0         ;check if current bit is 1
    rcall dot           ; if it isn't, it is a dot

    rcall dash          ;if it is, it is a dash

    lsr r19             ; shift bits in r19 to the right
    dec r18             ; decrement the counter

    rcall delay

    cbi PORTB, 5        ; turn off bit 5 of PORTB

    ldi r24, SIGNAL_GAP ;load delay register with the signal gap time
    rcall delay
    clr r24
    tst r18             ; do we have any more signals to output
    breq end_signal_loop; if we don't, end the loop
    rjmp signal_loop    ; loop through again

end_signal_loop:
    ldi r24, LETTER_GAP  
    rcall delay
    pop ZH               ; restore pointer to message table
    pop ZL               ; restore pointer to message table
    ret

dot:
    ldi r24, DOT         ; load delay register with the dot time
    ret                  ; return to where we called dot

dash:
    tst r24              ; check if time hasn't been initialised
    breq 1f              ; if it hasnt, load he dash time
    ret                  ; return to where we called dash
1:
    ldi r24, DASH        ; load delay register with the dash time
    ret                  ; return to where we called dash

;Message table
;Must always end with a period
message:
    .string "HELLO."

;;; Dictionary table: 
;;; First row stores the letter length
;;; Second row stores the morse value
dictionary:
    .byte 0x2, 0x4, 0x4, 0x3, 0x1, 0x4, 0x3, 0x4, 0x2, 0x4, 0x3, 0x4, 0x2, 0x2, 0x3, 0x4, 0x4, 0x3, 0x3, 0x1, 0x3, 0x4, 0x3, 0x4, 0x4,0x4
    .byte 0x2, 0x1, 0x5, 0x1, 0x0, 0x4, 0x3, 0x0, 0x0, 0xE, 0x5, 0x2, 0x3, 0x1, 0x7, 0x6, 0xB, 0x2, 0x0, 0x1, 0x4, 0x8, 0x6, 0x9, 0xD, 0x3
    ;      A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R    S    T    U    V    W    X    Y    Z
