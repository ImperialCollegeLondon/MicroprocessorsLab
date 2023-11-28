#include <xc.inc>

; This includes the subroutine to decode the input from the keypad for the two-digit age input
    
global	Decode_First_Digit, Decode_Second_Digit

;psect	 data_section, global, class = DABS
;first_digit: ds	    1
;second_digit: ds    1

psect	udata   ; reserve data space in access ram
first_digit: ds	    1
second_digit: ds    1
    
Decode_First_Digit: ; Read input from keypad, interpret as the 10s value, return as literal
    movwf	first_digit, A
Test_none_1:	; no key pressed
    movlw	0xFF
    cpfseq	first_digit, A
    bra		Test_0_1	; this is the ?no? result
    retlw	0xFF		; this is the ?yes? result
Test_0_1:
    movlw	0xBE
    cpfseq	first_digit, A
    bra		Test_1_1	
    retlw	0	
Test_1_1:
    movlw	0x77
    cpfseq	first_digit, A
    bra		Test_2_1	
    retlw	10	
Test_2_1:
    movlw	0xB7
    cpfseq	first_digit, A
    bra		Test_3_1	
    retlw	20	
Test_3_1:
    movlw	0xD7
    cpfseq	first_digit, A
    bra		Test_4_1	
    retlw	30	
Test_4_1:
    movlw	0x7B
    cpfseq	first_digit, A
    bra		Test_5_1	
    retlw	40	
Test_5_1:
    movlw	0xBB
    cpfseq	first_digit, A
    bra		Test_6_1	
    retlw	50	
Test_6_1:
    movlw	0xDB
    cpfseq	first_digit, A
    bra		Test_7_1	
    retlw	60	
Test_7_1:
    movlw	0x7D
    cpfseq	first_digit, A  
    bra		Test_8_1	
    retlw	70	
Test_8_1:
    movlw	0xBD
    cpfseq	first_digit, A
    bra		Test_9_1	
    retlw	80	
Test_9_1:
    movlw	0xDD
    cpfseq	first_digit, A
    retlw	0xFF		; error message: when a letter or an invalid input has been detected
    retlw	90	

    
Decode_Second_Digit: ; Read input from keypad, interpret as the 10s value, return as literal
    movwf	second_digit, A
Test_none_2:	; no key pressed
    movlw	0xFF
    cpfseq	second_digit, A
    bra		Test_0_2	; this is the ?no? result
    retlw	0xFF		; this is the ?yes? result
Test_0_2:
    movlw	0xBE
    cpfseq	second_digit, A
    bra		Test_1_2	
    retlw	0	
Test_1_2:
    movlw	0x77
    cpfseq	second_digit, A
    bra		Test_2_2	
    retlw	1	
Test_2_2:
    movlw	0xB7
    cpfseq	second_digit, A
    bra		Test_3_2	
    retlw	2	
Test_3_2:
    movlw	0xD7
    cpfseq	second_digit, A
    bra		Test_4_2	
    retlw	3
Test_4_2:
    movlw	0x7B
    cpfseq	second_digit, A
    bra		Test_5_2	
    retlw	4	
Test_5_2:
    movlw	0xBB
    cpfseq	second_digit, A
    bra		Test_6_2	
    retlw	5	
Test_6_2:
    movlw	0xDB
    cpfseq	second_digit, A
    bra		Test_7_2	
    retlw	6	
Test_7_2:
    movlw	0x7D
    cpfseq	second_digit, A  
    bra		Test_8_2	
    retlw	7	
Test_8_2:
    movlw	0xBD
    cpfseq	second_digit, A
    bra		Test_9_2	
    retlw	8	
Test_9_2:
    movlw	0xDD
    cpfseq	second_digit, A
    retlw	0xFF		; error message: when a letter or an invalid input has been detected
    retlw	9	




