#include <xc.inc>

psect	code, abs

psect	udata_
myNumerator:ds	1
myDenominator:ds    1
myQuotient:ds    1
myRemainder:ds    1
myDiff:ds   1
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	bra 	test
loop:
	movff 	0x06, PORTC
	incf 	0x06, W, A
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0x01
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	;goto 	0x0		    ; Re-run program from start

; PIC18 Assembly division example

; Inputs:
;   Numerator in WREG
;   Denominator in a register (e.g., myDenominator)

    ; Initialize variables
    MOVLW   11             ; Numerator
    MOVWF   myNumerator

    MOVLW   3              ; Denominator
    MOVWF   myDenominator

    ; Perform division
    CALL    Divide

    ; Result is now in WREG

    ; Your code here

Divide:
    ; Ensure myDenominator is not zero
    MOVLW   0
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
    RETURN

DivisionError:
    ; Handle division by zero or other error
    ; Your code here
    RETURN
    
	end	main

