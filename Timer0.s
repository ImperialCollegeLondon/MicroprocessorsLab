#include <xc.inc>

global	Timer_Setup, Timer_int_hi  

psect	External_timer, class = CODE

Timer_int_hi:
	btfss	INTCON, 2	    ;check this is a timer 0 interrupt, bit 2 = TMR0IF
	retfie	f	    ;if not then return
	btfss	PORTA, 4    ;check if bit 4 is set (skips next instruction if set)
	bra	Turn_off
	bra	Turn_on
	
Turn_off:
	bcf	PORTA, 4
	bcf	TMR0IF
	retfie	f

Turn_on:
	bsf	PORTA, 4
	bcf	TMR0IF
	retfie	f
 
Timer_Setup:	
	movlw	00100000    ;set RA5 as input and rest of Port A as output
	movwf	PORTA, A
	movlw	11000100    ;set Timer0 to 8-bit, Fosc/4/32
	movwf	T0CON, A    ;approximately  0.5ms rollover
	bsf	INTCON, 5	    ;enable timer0 interrupt, bit 5 = TMR0IE
	bsf	GIE	    ;enable all interrupts
	return


    



