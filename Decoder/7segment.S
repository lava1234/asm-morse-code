
#include <avr/io.h> 				

	;; the segments are connected to these pins of PORTD:
	
	SEG_A = 7		; top
	SEG_B = 1 		; upper right
	SEG_C = 2		; lower right
	SEG_D = 3		; buttom
	SEG_E = 4		; lower left
	SEG_F = 5		; upper right
	SEG_G = 6		; middle

	;; a bit mask that contains all bits used:
	ALL_SEGS = _BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G) 

	;; The hexadecimal digits:
	;; Note that the seven segment follows INVERSE LOGIC. That
	;; means a 0 in the corresponding bit switches the segment on
	;; and a 1 switches the segment off. That is why the bit patterns
	;; below are inverted (~):

	CHAR_A = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_G) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_B = ~(_BV(SEG_F) | _BV(SEG_G) | _BV(SEG_E) | _BV(SEG_C) | _BV(SEG_D))
	CHAR_C = ~(_BV(SEG_A) | _BV(SEG_F) | _BV(SEG_E) | _BV(SEG_D))
	CHAR_D = ~(_BV(SEG_B) | _BV(SEG_G) | _BV(SEG_E) | _BV(SEG_C) | _BV(SEG_D))
	CHAR_E = ~(_BV(SEG_A) | _BV(SEG_F) | _BV(SEG_E) | _BV(SEG_D) | _BV(SEG_G))
	CHAR_F = ~(_BV(SEG_A) | _BV(SEG_F) | _BV(SEG_E) | _BV(SEG_G))
	CHAR_G = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_H = ~(_BV(SEG_E) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_I = ~(_BV(SEG_B) | _BV(SEG_C))
	CHAR_J = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) |  _BV(SEG_E))
	CHAR_K = ~(_BV(SEG_F) | _BV(SEG_G) | _BV(SEG_E) |  _BV(SEG_D))
	CHAR_L = ~(_BV(SEG_F) | _BV(SEG_E) | _BV(SEG_D))
	CHAR_M = ~(_BV(SEG_A) | _BV(SEG_E) | _BV(SEG_C))
	CHAR_N = ~(_BV(SEG_E) | _BV(SEG_G) | _BV(SEG_C))
	CHAR_O = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_P = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_G) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_Q = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_G) | _BV(SEG_C) | _BV(SEG_F))
	CHAR_R = ~(_BV(SEG_E) | _BV(SEG_G))
	CHAR_S = ~(_BV(SEG_A) | _BV(SEG_F) | _BV(SEG_G) | _BV(SEG_C) | _BV(SEG_D))
	CHAR_T = ~(_BV(SEG_B) | _BV(SEG_G) | _BV(SEG_C))
	CHAR_U = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_V = ~(_BV(SEG_E) | _BV(SEG_D) | _BV(SEG_C))
	CHAR_W = ~(_BV(SEG_F) | _BV(SEG_D) | _BV(SEG_B))
	CHAR_X = ~(_BV(SEG_A) | _BV(SEG_G) | _BV(SEG_D))
	CHAR_Y = ~(_BV(SEG_F) | _BV(SEG_B) | _BV(SEG_G) | _BV(SEG_C) | _BV(SEG_D))
	CHAR_Z = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_G) | _BV(SEG_E) | _BV(SEG_D))
	CHAR_ERROR = ~(_BV(SEG_G))


