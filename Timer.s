#include <xc.inc>

global	Timer_Setup, TMR0_INT
psect	External_timer, class = CODE

;Timer_int_hi:
;	btfss	INTCON, 2   ;check this is a timer 0 interrupt, bit 5 = TMR0IF
;	retfie	f	    ;if not then return
;	btfss	PORTA, 4    ;check if bit 4 is set (skips next instruction if set)
;	bra	Turn_on
;	bra	Turn_off
;	
;Turn_off:
;	bcf	PORTA, 4
;	bcf	INTCON, 2
;	retfie	f
;
;Turn_on:
;	bsf	PORTA, 4
;	bcf	INTCON, 2
;	retfie	f
TMR0_INT:
	INCF	Time_Counter, 1
	MOVFF	Time_Counter, PORTH
	bcf     TMR0IF
	retfie	f

Timer_Setup:	
	movlw   10000110B	; Fcyc/128 = 125 KHz
	movwf   T0CON, A
	bsf	GIE	    ;enable all interrupts 7=GIE
	bsf	INTCON, 6
	bsf     INTCON, 5 ;TMR0IE
	return
