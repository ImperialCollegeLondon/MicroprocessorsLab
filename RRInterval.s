#include <xc.inc>

global	RR_int, RR_Setup, no_overflow, overflow, Sixteen_Division
    
psect	udata_acs
	
prevtimeH: ds 1
prevtimeL: ds 1
    
maxH:ds	1
maxL:ds 1
Num_H:ds	1
Num_L:ds	1
Den_H:ds	1
Den_L:ds	1
Heart_Rate:ds	1
    
periodH:	ds 1
periodL:	ds 1
Numerator:	ds 1  ;for working out bpm 60/RR interval
    
psect	External_timer, class = CODE
 
RR_Setup:
	;movlw	60
	;movwf	Numerator    ;for working out bpm 60/RR interval
	bsf	CCP5CON, 1
	bsf	CCP5CON, 2 ; sets up CCP5 as capture on every rising edge (00000110)
	movlw	0x00
	movwf	CCPTMRS1    ;sets CCP5 to use timer1 for capture
	movlw	10110111    ;enables Timer1 to synchronise with external clock at RA5 and perform read/write in 1 16bit operation
	movwf	T1CON
	bsf	PIE4, 2	    ;enables CCP5 interrupt
	bsf	PIE1, 0	    ;enables timer1 overflow interrupt
	bsf	IPR4, 2
	bsf	ODCON2, 2
	movlw	0x00 
	movwf	TRISF
	return
	
RR_int:
	;bsf	PIR4, 2
	nop
	nop
	btfss	PIR4, 2	    ;Checks to see if CCP5 interrupt flag
	retfie	f
	btfss	PIR1, 0	    ;Checks to see if timer1 overflowed
	bra	no_overflow
	bra	overflow
	
no_overflow:
	;subtract values stored in prevtimeH and prevtimeL from CCPR5H and CCPR5L store result in period
	;period returned in units of 1.024 ms
	;Do subtraction
	MOVFF	prevtimeL, WREG
	CPFSLT	CCPR5L
	bra	Subtract_no
	bra	Borrow_no
Borrow_no:
	DECF	CCPR5H, 1
Subtract_no:
	MOVFF	prevtimeL, WREG
	SUBWF	CCPR5L, 0	    ; subtract prevtimeL from CCPR5L, store result in WREG
	MOVWF	periodL		    ; move value into periodL
	MOVFF	prevtimeH, WREG
	SUBWF	CCPR5H, 0	    ; subtract prevtimeH from CCPR5H, store result in WREG
	MOVWF	periodH
	;store value in periodH and periodL
	
	
	movff	CCPR5H, WREG	   ;update previous time
	movwf	prevtimeH
	movff	CCPR5L, WREG
	movwf	prevtimeL
	bcf	PIR4, 2	    ;clear CCP interrupt flag
	movff	periodL, PORTF
	retfie	f
	
overflow:
	;subtract prevtimeH and prevtimeL from 11111111B as this will be max value
	;add this result to values stored in CCPR5H and CCPR5L to calculate period
	;period returned in units of 1.024 ms (as this is the period of external clock)
	;Do subtraction
	MOVLW	0xFF
	MOVWF	maxL
	MOVWF	maxH
	
	CPFSEQ	prevtimeL	    ; prevtimeL = 0xFF, need to borrow
	bra	Subtract_o
	bra	Borrow_o
Borrow_o:
	DECF	maxH, 1
Subtract_o:
	MOVFF	prevtimeL, WREG
	SUBWF	maxL, 0	    ; subtract prevtimeL from CCPR5L, store result in WREG
	MOVWF	periodL		    ; move value into periodL
	MOVFF	prevtimeH, WREG
	SUBWF	maxH, 0	    ; subtract prevtimeH from CCPR5H, store result in WREG
	MOVWF	periodH
	
	;Addition periodL/H + CCPR5L/H
Addition:
	
	MOVFF	CCPR5L, WREG
	ADDWF	periodL, 1	    ; place value back into periodL
	MOVFF	periodL, WREG
	
	MOVFF	CCPR5H, WREG
	ADDWFC	periodH, 1
	MOVFF	periodH, WREG

	;store final value in periodH and periodL
	
	movff	CCPR5H, WREG	   ;update previous time
	movwf	prevtimeH
	movff	CCPR5L, WREG
	movwf	prevtimeL
	bcf	PIR4, 2	    ;clear CCP interrupt flag
	bcf	PIR1, 2
	movff	periodL, PORTF
	retfie	f
	
Sixteen_Division:
	MOVLW	0xEA
	MOVWF	Num_H
	MOVLW	0x60
	MOVWF	Num_L		; initiate numerator to 60000 ms
	MOVLW	0x02
	MOVWF	Den_H
	MOVLW	0x58
	MOVWF	Den_L

	MOVLW	0
	MOVWF	Heart_Rate		; initialise quotient
High_byte_check:
	MOVFF	Den_H, WREG
	CPFSGT	Num_H
	bra	End_Sixteen_Division	; when high byte of denominator is greater than numerator
	bra	Low_byte_check		
Low_byte_check:
	MOVFF	Den_L, WREG
	CPFSGT	Num_L
	bra	Sixteen_Borrow	
	bra	Sixteen_Subtraction
Sixteen_Subtraction:
	MOVFF	Den_L, WREG
	SUBWF	Num_L, 1
	MOVFF	Den_H, WREG
	SUBWF	Num_H, 1
	INCF	Heart_Rate, 1
	MOVFF	Heart_Rate, PORTB
	bra	High_byte_check
Sixteen_Borrow:
	DECF	Num_H, 1		; borrow from Num_H
	MOVFF	Den_H, WREG
	CPFSGT	Num_H
	bra	End_Sixteen_Division
	bra	Sixteen_Subtraction
End_Sixteen_Division:	
	MOVFF	Heart_Rate, PORTC
	MOVFF	Heart_Rate, WREG
	; move results into results register pair
	return	    ; return with Heart Rate in 