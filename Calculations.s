#include <xc.inc>
    
global	Find_Max_Heart_Rate, Divide_By_20, Load_HRZ_Table
    
; this includes subroutines for calculations: e.g. max heart rate calculation, boundary calculations
psect	udata_acs
myDenominator_low:ds    1
myNumerator:ds	    1
myQuotient:ds	    1
myRemainder:ds	    1
myDiff:ds	    1
STATUS_CHECK:ds	    1
HR_max:ds	    1
  

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
    
