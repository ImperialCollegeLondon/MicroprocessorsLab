#include <xc.inc>

global	Timer_Setup, Timer_int_hi
psect	External_timer, class = CODE

Timer_int_hi:
	btfss	INTCON, 2   ;check this is a timer 0 interrupt, bit 5 = TMR0IF
	retfie	f	    ;if not then return
	btfss	PORTA, 4    ;check if bit 4 is set (skips next instruction if set)
	bra	Turn_on
	bra	Turn_off
	
Turn_off:
	bcf	PORTA, 4
	bcf	INTCON, 2
	retfie	f

Turn_on:
	bsf	PORTA, 4
	bcf	INTCON, 2
	retfie	f
 
Timer_Setup:	
	movlw	00100000B    ;set RA5 as input and rest of Port A as output
	movwf	TRISA, A
	movlw	11000111B    ;set Timer0 to 8-bit, Fosc/4/256
	movwf	T0CON, A    ;approximately  0.5ms rollover
	bsf	INTCON, 5   ;enable timer0 interrupt, bit 5 = TIME0IE
	bsf	INTCON, 7	    ;enable all interrupts 7=GIE
	bcf	INTCON2, 2
	return

