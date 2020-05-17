;;; You may note the lack of labels used when dealing with a short press.
;;; This is because we do not need to set a bit, due to a dot being represented by a zero, 
;;; thus allowing us to get away with not checking the counter size
    .global short_press
short_press:
    inc r29   ; Increment character counter
    rjmp final 

    .global long_press
long_press:
    inc r29       ; Increment character counter
    cpi r29, 0x01 ; if the counter is 1
    breq long1    ; then jump to long1

    cpi r29, 0x02 ; if the counter is 2
    breq long2    ; then jump to long2

    cpi r29, 0x03 ; if the counter is 3
    breq long3    ; then jump to long3

    cpi r29, 0x04 ; if the counter is 4
    breq long4    ; then jump to long4

    rjmp final

;;; r28 will hold the morse code that we have inputted
long1:
    ori r28, 0x01 ; OR r28 with 0001
    rjmp final

long2:
    ori r28, 0x02 ; OR r28 with 0010
    rjmp final

long3:
    ori r28, 0x04 ; OR r28 with 0100
    rjmp final
    
long4:
    ori r28, 0x08 ; OR r28 with 1000
    rjmp final

final:
    pop r16       ; restore the value held in r16 (I think r16 holds whether we were waiting for a button release or a button press)
    clr r19       ; clear the timer overflow flag/register
    ret           ; return back to where we relative called released

