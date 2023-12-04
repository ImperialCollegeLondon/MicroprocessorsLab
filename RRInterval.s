#include <xc.inc>


psect	External_timer, class = CODE
 
 
 
RR_Setup:
	bsf	CCP1CON, 0
	bsf	CCP1CON, 2 ; sets up ECCP1 as capture on every rising edge
	movlw	0x00
	movwf	CCPTMRS0    ;sets ECCP1 to use timer1 for capture
	movlw	10110011    ;enables Timer1 to synchronise with external clock at RA5 and perform read/write in 1 16bit operation
	movwf	T1CON