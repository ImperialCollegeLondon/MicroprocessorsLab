#include <xc.inc>
    
global	Find_Max_Heart_Rate, Divide_By_20, Divide_By_Ten, Load_HRZ_Table, Determine_HRZ, IIR_Filter
    
; this includes subroutines for calculations: e.g. max heart rate calculation, boundary calculations
psect	udata_acs
myDenominator_low:ds    1
myNumerator:ds	    1
myQuotient:ds	    1
myRemainder:ds	    1
myDiff:ds	    1
STATUS_CHECK:ds	    1
HR_max:ds	    1
Zone_Value:ds	    1
HR_Measured:ds	    1   ; reserve one byte for measured HR value from sensor

x1:ds		1
x2:ds		1
x3:ds		1
x1x2H:ds	1
x1x2L:ds	1
x1x2x3H:ds	1
x1x2x3L:ds	1
myDen_low:ds	1
myQuo:ds	1
myRem:ds	1
  

psect	calculations_code,class=CODE
    
Find_Max_Heart_Rate:
    sublw	220	; subtract age from 220 to find the maximum heart rate, store in WREG
    return	
    
Divide_By_20:	    ; divide the number stored in WREG by 20
    ; Ensure myDenominator is not zero
    ;	MOVWF   myNumerator
    
    MOVLW   19			; Think this needs to be n - 1, where n is the denominator??
    MOVWF   myDenominator_low   ; divide by 20
    
    MOVLW   0		    ; Move 0 into WREG to check if denominator is zero
    CPFSEQ  myDenominator_low
    GOTO    Clear	    ; Check the MSB of myDenominator
    GOTO    DivisionError    ; If zero, handle division by zero
Clear:	; Perform division algorithm	
    CLRF    myQuotient       ; Clear the quotient register
    CLRF    myRemainder      ; Clear the remainder register

Division_Loop:
    MOVFF   myDenominator_low, WREG
    CPFSLT  PRODL	    ; if lower byte is smaller than denominator: need to borrow
    bra	    Subtract
    bra	    Borrow_or_Done
Borrow_or_Done:
    MOVLW   0
    CPFSGT  PRODH		; Check if done, i.e. if the upper byte is zero.
    bra	    Division_Done
    DECF    PRODH, 1		; Borrow from higher byte
    MOVFF   PRODH, PORTB
Subtract:
    INCF    myQuotient, 1	; Increment quotient
    MOVFF   myQuotient, PORTD
    MOVFF   myDenominator_low, WREG
    SUBWFB  PRODL, 1		; myNumerator -= myDenominator
    MOVFF   PRODL, PORTC
    bra	    Division_Loop
Division_Done:
    ;MOVFF   myQuotient, PORTC
    MOVFF   myQuotient, WREG	; return with the quotient in the WREG
    RETURN
DivisionError:
    RETURN
    

Load_HRZ_Table: ; call with HR_max in WREG
	MOVWF	HR_max
	
	CLRF	EEADR		; start at address 0
	BCF	EECON1, 6	; set for memory, bit 6 = CFGS
	BCF	EECON1, 7	; set for data EEPROM, bit 7 = EEPGD
	BSF	EECON1, 2	; write enable, bit 2 = WREN
	
Loop:
	MOVFF	EEADR, PORTB
	BSF	EECON1, 0	; read current address, bit 0 = RD
	nop			; need to have delay after read instruction for reading to complete
	MOVFF	EEDATA, WREG	; W = multiplier
	MOVFF	EEDATA, PORTC
	MULWF	HR_max

	CALL	Divide_By_20	; (HR_max*multiplier)/20, return with quotient in WREG
	
	MOVWF	EEDATA		; move data to EE
	
	BCF	INTCON, 7	; disable interrupts, bit 7 = GIE

	MOVLW	0x55
	MOVWF	EECON2		
	MOVLW	0xAA
	MOVWF	EECON2
	
	BSF	EECON1, 1	; to write data, bit 1  = WR
	BTFSC	EECON1, 1
	bra	$-2		; wait for write to complete
	INCF	EEADR, 1	; Increment address and save back to EEADR
	
	MOVFF	EEADR, WREG	; Routine to check if the end has been reached
	SUBLW	6
	MOVWF	STATUS_CHECK	
	MOVLW	0
	CPFSEQ	STATUS_CHECK	; comparison to see if the end of the table has been reached
	bra	Loop
	bra	End_Write
End_Write:
	; Continue on with the rest of the code
	BCF	EECON1, 2	; disenable writing function
	MOVLW	0xFF
	MOVWF	PORTD
	RETURN

Determine_HRZ: ; enter with measured HR stored in WREG
	movwf	HR_Measured
	
	MOVLW	6
	MOVWF	Zone_Value	; initialise at 6, highest possible zone value is 5
	
	CLRF	EEADR		; start at address 0
	BCF	EECON1, 6	; set for memory, bit 6 = CFGS
	BCF	EECON1, 7	; set for data EEPROM, bit 7 = EEPGD
	BCF	EECON1, 2	; write enable, bit 2 = WREN	
Table_Compare_Loop:
	MOVFF	EEADR, PORTB
	BSF	EECON1, 0	; read current address, bit 0 = RD
	nop			; need to have delay after read instruction for reading to complete
	MOVFF	EEDATA, WREG	; zone boundary
	CPFSLT	HR_Measured	; f < W
	bra	Output_Zone_Value
	DECF	Zone_Value, 1
	INCF	EEADR, 1
	bra	Table_Compare_Loop
Output_Zone_Value:
	MOVFF	Zone_Value, WREG
	return

IIR_Filter:
	MOVWF	x3		; newest measurement WREG -> x3
	
	MOVFF	x1, WREG
	ADDWF	x2, 0		; 200 + 256 = 456 = 1C8
	MOVWF	x1x2L
	
	MOVLW	0x00
	ADDWFC	x1x2H, 1		; carry to higher byte
	INCF	x1x2L, 1
	
	; give newest measurement a higher weighting, multiply it by 2
	MOVFF	x3, WREG	    ; newest measuremeng in WREG
	MULLW	2		    ; double the weighting than the other two measurements
	; results stored in PRODH:PRODL 2*HR_newest
	MOVFF	PRODH, WREG
	MOVFF	PRODL, WREG
	ADDWF	x1x2L, 0	    ; 456 + 200 = 656 = 290
	MOVWF	x1x2x3L		    ; contains lower byte of sum
	
	MOVFF	PRODH, WREG
	ADDWFC	x1x2H, 0
	MOVWF	x1x2x3H		    ; contains higher byte of sum
	
	; divide by 4
	
	MOVLW   3			; Think this needs to be n - 1, where n is the denominator??
	MOVWF   myDen_low		; divide by 4 to find the average
    
	MOVLW   0		    ; Move 0 into WREG to check if denominator is zero
	CPFSEQ  myDen_low
	GOTO    Clear_1	    ; Check the MSB of myDenominator
	GOTO    DivisionError_1    ; If zero, handle division by zero
Clear_1:	; Perform division algorithm	
	CLRF    myQuo      ; Clear the quotient register
	CLRF    myRem      ; Clear the remainder register

Divide_By_Ten:
    ; Ensure myDenominator is not zero
	MOVWF   myNumerator
; Think this needs to be n - 1, where n is the denominator??
	MOVLW	9
	MOVWF   myDenominator_low   ; divide by 20

	MOVLW	0
	CPFSEQ  myDenominator_low
	GOTO    Clear_Ten	    ; Check the MSB of myDenominator
	GOTO    DivisionError_Ten    ; If zero, handle division by zero
Clear_Ten:   ; Perform division algorithm??
	CLRF    myQuotient       ; Clear the quotient register
	CLRF    myRemainder      ; Clear the remainder register

Division_Loop_Ten:
	MOVFF   myDenominator_low, WREG
	CPFSLT  PRODL		; if lower byte is smaller than denominator: need to borrow
	BRA	Subtract_Ten
	BRA	Borrow_or_Done_Ten
Borrow_or_Done_Ten:
	MOVLW   0
	CPFSGT  PRODH		; Check if done, i.e. if the upper byte is zero.
	BRA	Division_Done_Ten
	DECF	PRODH, 1
	;MOVFF   PRODH, PORTB
Subtract_Ten:
	INCF	myQuotient, 1
	MOVFF   myQuotient, PORTD
	MOVFF	myDenominator_low, WREG
	SUBWFB	PRODL, 1
	;MOVFF	PRODL, PORTC
	BRA	Division_Loop_Ten
Division_Done_Ten:
    ;MOVFF   myQuotient, PORTC
	MOVFF   myQuotient, WREG    ; return with the quotient in the WREG
	RETURN
DivisionError_Ten:
	RETURN

	
Division_Loop_1:
	MOVFF   myDen_low, WREG
	CPFSLT  x1x2x3L	    ; if lower byte is smaller than denominator: need to borrow
	bra	Check_Equal
	bra	Borrow_or_Done_1
Borrow_or_Done_1:
	MOVLW   0
	CPFSGT  x1x2x3H		; Check if done, i.e. if the upper byte is zero.
	bra	Division_Done
	DECF    x1x2x3H, 1		; Borrow from higher byte
	;MOVFF   x1x2x3H, PORTB
	bra	Subtract_1
Check_Equal:
	MOVFF	myDen_low, WREG
	CPFSEQ	x1x2x3L
	bra	Subtract_1
	bra	Borrow_or_Done_1
Subtract_1:
	INCF    myQuo, 1	; Increment quotient
	MOVFF   myQuo, PORTD
	MOVFF   myDen_low, WREG
	SUBWFB  x1x2x3L, 1		; myNumerator -= myDenominator
	MOVFF   x1x2x3L, PORTC
	bra	Division_Loop_1
Division_Done_1:
	call	Update_Vals
	MOVFF   myQuo, WREG	; 656/4 = 164 ...
	RETURN
DivisionError_1:
	RETURN
Update_Vals:
	MOVFF	x2, WREG
	MOVWF	x1		; update x1 with value in x2
	MOVFF	myQuo, WREG
	MOVWF	x2		; update x2 with newest measurement
	return
	

	
	