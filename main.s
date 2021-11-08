	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0		    ; starts code at this address
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0		    ;sets W directory to 00 value
	movwf	TRISC, A	    ; Port C all outputs
	movlw	0xff		    ; sets W to all 1s
	movwf	TRISD, A	    ; sets TRISD to akk 1s from W directory
	bra 	test		    ; branches to test
loop:
	movff 	0x06, PORTC
	movlw	0xff		    ; moves value to w register	(in this case just largest possible - 255)
	movwf	0x20, A		    ; moves value in w register to f
	call	delay		    ; calls delay subroutine
	incf 	0x06, W, A	    ; increments value in W register by 1 (0x06)
	 
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movf	PORTD, W, A ;modifies program so that it changes no times loop is run depending on which switch button is pushed
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

delay:	DECFSZ 0x20, F, A	    
	bra delay
	RETURN 0	
	
	end	main
	

