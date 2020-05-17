;;; The timer prescaler is set to 1024, ie one timer tick
;;; is 1024 CPU clock ticks. Then we only look at the high byte of the
;;; 16 bit timer1, which is the basis for all timing. One tick at the
;;; high byte is 1024*256 CPU clock ticks. With a CPU clock of 16MHz,
;;; ie 16,000,000 CPU clock ticks per second, this means one tick in
;;; the high byte of timer1 corresponds to 256*1024 / 16.000.000 Hz =
;;; 16ms. So 16ms is the basis of all our timings, about 61 ticks per second

	CPU_FREQ = 16000000 						; frequency of cpu in hertz
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024) 	; number of ticks in a second

	LIMIT = (1 * TICKS_PER_SEC ) / 10 		   	; 100ms This is the limit that we will use to identify if the signal is a dot or a dash
	CHARACTER_LIMIT = (3 * TICKS_PER_SEC) / 10 	; 300ms this the limit that we will use to identify the end of a letter

;;; Button is connected to PIN 8, PORTB, Bit 0, because that doubles as the ICP1 for timer1.
;;; ICP1 (Input Capture Pin) is used as an edgetriggered event pin that will 
;;; allow the timer to capture the counter value stored in TCNT1 
	BUTTON = 0
	
;;; Timer1 capture interrupt is used to record the length of button
;;; presses and button releases. 
;;;
;;; Global register use:
;;; r19: used as a flag that indicates whether the timer has overrun its
;;; max value while a button has been held pressed.
	
;;; include all port definitions
#define __SFR_OFFSET 0
#include <avr/io.h>
; includes all character definitions for the 7 segment display	
#include "7segment.S"

;;; this is the entry point to the user code, called from init.S. We
;;; do the setup of ports, timer and interrupts, then we go to an
;;; eternal loop because all the work is done in the interrupt service
;;; routines. 

	.section .text
	.global main
main:	
	;; make these pins output:
	ldi r30, ALL_SEGS ; Load the 7 seg into r30
	out DDRD, r30     ;Make r30 output to port D
	
	;; setup for the button, DDRB0 is automatically an input.
	sbi PORTB, BUTTON 	; switch on the pull-up. Released
						; button is 1, depressed button read as 0.

	;; set up the timer

	clr r16				; make sure r16 has no value
	sts TCCR1A, r16 	; setting timer output mode: no output
						; pin used, normal counting up. 

	;; enable input capture interrupt (to time button presses),
	;; timer overflow interrupt (the time-out that results in the end of a letter)
	;; and output compare A match interrupt
	ldi r16, _BV(ICIE1) | _BV(TOIE1) | _BV(OCIE1A)
	sts TIMSK1, r16

	ldi r16, CHARACTER_LIMIT ; load the character limit into r16
	sts OCR1AH, r16			 ; store directly into the data space where 16-register OCR1AH resides

	ldi r16, 0
	sts OCR1AL, r16			 ; store directly into the data space where 16-register OCR1AL resides
	
	;; enable noise canceller, set prescaler to 1024, and start
	;; timer in Clear Timer on Compare (CTC) Mode
	;; When the timer/counter (TCNT1) reaches the max value (CHARACTER_LIMIT)
	;; it will clear itself
	ldi r16,  _BV(ICNC1) | _BV(CS12) | _BV(CS10) | _BV(WGM12)
	sts TCCR1B, r16

	clr r19		; reset overflow flag to defined state
	sei			; enable interrupts globally.

waitforinterrupt:
	rjmp waitforinterrupt ;just wait for an interrupt
						  ;; end of setup

;;; This interrupt service routine is currently called whenever timer1 has
;;; an overflow, ie when more than 4s have elapses since the last button release. 
	
	.global timer1_compa_isr  ; export symbol to overwrite weak
							  ; definition in init.S

;;; This is the start of the interrupt service routine:
timer1_compa_isr:			

	push r16	
	in r16, SREG		; save the status register.
	push r16

	;; check whether we are waiting for a button press or release:
	lds r16, TCCR1B
	sbrs r16, ICES1 	; skip if waiting for positive edge (ie for button release)
	rjmp awaiting_press

awaiting_release:
	;;  make sure also an overly long press is always recognised
	;;  as a long press, irrespective of a timer overrun:

	ser r19 	; using r19 as a flag to indicate a
				; timer overflow has occured.
	rjmp 1f

awaiting_press:	
	;; if we waited for more than 400ms then
	;; this signifies the end of the letter

	rcall get_morse_code	; translate the morse code stored in r27
	out PORTD, r30 			; output the character stored in r30
	
1:	pop r16
	out SREG, r16 			; restore status register
	pop r16
	
	reti


;;; This interrupt service routine times the duration of button
;;; presses. It is also involved in timing button releases as it
;;; always resets timer1 when called.
;;; It is called whenever the signal at ICP1 (PORTB0) changes in a
;;; certain direction. If we are called for a negative edge (button
;;; has just been depressed), we go on waiting for a positive edge
;;; (button will be released) and vice-versa.
	
	.global timer1_cpt_isr

timer1_cpt_isr:

	push r8

	in r8, SREG 		; save the status register.
	push r8

	lds r8, ICR1L		; get the timer count when the capture event happened.
	lds r8, ICR1H       ; we discard the low part, only
						; interested in the high part, but
						; reading low byte is necessary to get
						; a correct high byte in ICR1H, see
						; documentation [ATmega328p] Section 15.11.7 p131 
	push r17				

	;; debounce button:

	mov r17,r19		;  If there is no timer-overflow (ie a
					;  very long button press and
	or r17,r8		;  ICR1H is still zero, then 
					;  less than 16ms have elapsed since
					;  last release or press
	breq debounce	;  and we do nothing

	clr r17
	sts TCNT1H, r17 	; reset timer, first writing the high byte to the latch
	sts TCNT1L, r17		; then the low byte -- Section 16.3 of [328] again.

	;; check whether we were looking for a positive or a negative edge:
	lds r17, TCCR1B
	sbrs  r17, ICES1	; skip next instruction if positive edge dedection.
	
	rjmp pressed		; we have a negative edge ie button
						; has been pressed

	;; positive edge, button has been released
	rcall released

	andi r17, ~(_BV(ICES1)) ; we have had positive edge, so next
							; time looking for negative edge
	rjmp end_isr

	
pressed:
	ori r17, _BV(ICES1)	; next time detect positive edge, ie a
						; button release.

end_isr:
	sts TCCR1B, r17 	; write r17 to TCCR1B to activate the
						; change in edge detection.
	
debounce:
	pop r17
	pop r8
	out SREG, r8		; restore status register
	pop r8

	reti

;;; This subroutine handles the detection of a button release (ie the
;;; end of a button press)
;;; It expects the durations of button presses in 16ms ticks in r8

released:
	push r16

	tst r19 	; Did we have a timer overflow (tst - test if register is zero or minus (minus is only true if the (S)ign flag has been set))

	brne long	; if there has been an overflow, we will go to the long label

	;; is the signal longer than LIMIT?
	ldi r16, LIMIT
	cp r8,r16		 ; if r16 > r8, then the carry flag is set
	brcs short		 ; if it is shorter, jump to label short (brcs (branch if carry flag set) can also be interchanged with brlo (branch if less than))

	
short:
	rjmp short_press ; relative jump to short_press label in count_character.S

long:
	rjmp long_press  ; relative jump to long_press label in count_character.S
		
