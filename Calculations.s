#include <xc.inc>
    
global	Find_Max_Heart_Rate, Divide_By_20
    
; this includes subroutines for calculations: e.g. max heart rate calculation, boundary calculations
psect	udata_acs
myDenominator:ds    1
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
    MOVWF   myNumerator
    MOVLW   20
    MOVWF   myDenominator   ; divide by 20
    
    MOVLW   0		    ; Move 0 into WREG to check if denominator is zero
    CPFSEQ  myDenominator
    GOTO    Clear	    ; Check the MSB of myDenominator
    GOTO    DivisionError    ; If zero, handle division by zero
Clear:	; Perform division algorithm	
    CLRF    myQuotient       ; Clear the quotient register
    CLRF    myRemainder      ; Clear the remainder register

DivideLoop:
    MOVFF   myNumerator, WREG
    ; rather than doing subtraction, just do a comparison
    CPFSGT  myDenominator	    ; myNumerator(WREG) < myDenominator, skip to finish   
    GOTO    Incr
    GOTO    DivisionDone     ; Done if myNumerator < myDenominator
Incr:
    INCF    myQuotient, 1    ; Increment quotient
    MOVFF   myDenominator, WREG
    SUBWF   myNumerator, 1 ; myNumerator -= myDenominator
    GOTO    DivideLoop       ; Repeat the loop

DivisionDone:
    ; Quotient is in myQuotient, remainder is in myRemainder
    MOVFF   myQuotient, PORTC
    MOVFF   myQuotient, WREG
    RETURN

DivisionError:
    ; Handle division by zero or other error
    ; Your code here
    RETURN
