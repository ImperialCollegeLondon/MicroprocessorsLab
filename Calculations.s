#include <xc.inc>
    
global	Find_Max_Heart_Rate, Divide_By_20
    
; this includes subroutines for calculations: e.g. max heart rate calculation, boundary calculations
psect	udata_acs
myDenominator_low:ds    1
myNumerator:ds	    1
myQuotient:ds	    1
myRemainder:ds	    1
myDiff:ds	    1
  

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
    
