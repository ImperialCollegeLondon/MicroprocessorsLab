#include <xc.inc>

global  

psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l

psect	lcd_code,class=CODE
    

INTER_Timer_Setup:  
	bcf	T1CON, TMR1ON	; timer off
	bcf	T1CON, TMR1CS	; Clock source = Fosc/4
	bcf	T1CON, T1SYNC	; Not synchronised
	bcf	T1CON, T1RD16	; 16-bit mode
	
INTER_RB7_Enable:
	bsf	INTCON, RBIE	; enable PORTB IOC
	bsf	INTCON, GIE	; enable global interrupts
    
    
    
end


