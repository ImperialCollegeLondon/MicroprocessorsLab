#include <xc.inc>

; This includes the subroutine to decode the input from the keypad for the two-digit age input
    
global	Decode_First_Digit, Decode_Second_Digit, Read_Age_Input_Find_HR_Max
extrn	Keypad_READ
extrn	delay_ms
;extrn	Find_Max_Heart_Rate
extrn	LCD_Write_Message

psect	udata_acs   ; reserve data space in access ram
first_digit: ds	    1
second_digit: ds    1
digit_input_counter: ds	1   ; counter for checking how many digits of the age has been inputted
age_first: ds	1   ; first digit of age input
age_second: ds	1   ; second digit of age input
age: ds	1	    ; age, after combining the two digits
maximum_heart_rate: ds	1   ; value for maximum heart rate is stored here

psect	digit_reader_code,class=CODE

Age_Read_1: 	

	movff	digit_input_counter, PORTJ  ; output digit counter to PORTJ to visualise how many digits are left to be inputted
	
	call	Keypad_READ	; keypad read subroutine, value stored in W
	call	Decode_First_Digit  ; decode first digit, return with 10s value in WREG
	movwf	age_first	    ; save value in variable age_first
	movwf	PORTD		; output to PORTD to visualise the number just inputted
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF		; value of error message
	cpfslt	age_first	; if no valid input, branch to Age_Read_1 to read from Keypad again; 
	bra	Age_Read_1
	decf	digit_input_counter,1 ; if there has been a valid input, decrement the digit counter and return
	call	LCD_Write_Message   ; digit stored in POSTINC0
	
	return

Age_Read_2: 	
	movff	digit_input_counter, PORTJ  ; output digit counter to PORTJ to visualise how many digits are left to be inputted
	
	call	Keypad_READ	; keypad read subroutine, value stored in W
	call	Decode_Second_Digit  ; decode first digit, return with 10s value in WREG
	movwf	age_second	    ; save value in variable age_first
	movwf	PORTD		; output to PORTD to visualise the number just inputted
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF		; value of error message
	cpfslt	age_second	; if no valid input, branch to Age_Read_1 to read from Keypad again; 
	bra	Age_Read_2
	decf	digit_input_counter, 1 ; if there has been a valid input, decrement the digit counter and return
	call	LCD_Write_Message   ; digit stored in POSTINC0
	movff	digit_input_counter, PORTJ  ; output digit counter to PORTJ to visualise how many digits are left to be inputted
	
	return

Read_Age_Input_Find_HR_Max: 	
	; read in age input from keypad
	movlw	2
	movwf	digit_input_counter
	
	movlw	2			    ; set WREG to 2, to deduce value in digit coubnter
	cpfslt	digit_input_counter	    ; skip if smaller than two, otherwise read first digit
	call	Age_Read_1
	movlw	1
	cpfslt	digit_input_counter	    ; skip if smaller than 1, otherwise read second digit
	call	Age_Read_2
	
	; add the two digits of age together
	movff	age_first, WREG		    ; move first digit of age to WREG
	addwf	age_second, W		    ; add second digit to WRED (age_first) and store result in WREG
	movwf	age			    ; store age in memory
	movff	age, PORTD 
	
	movlw	0xFF
	movwf	PORTJ
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF
	call	delay_ms		    ; delay to see on board 
	
	; find maximum heart rate
	movff	age, WREG		    ; put age in WREG for use in subroutine
	
;	call	Find_Max_Heart_Rate
	movwf	maximum_heart_rate	    ; move value for maximum heart rate into variable
	movff	maximum_heart_rate, WREG
	
	return
    
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
    movlw	'0'
    movwf	POSTINC0
    retlw	0	
Test_1_1:
    movlw	0x77
    cpfseq	first_digit, A
    bra		Test_2_1
    movlw	'1'
    movwf	POSTINC0
    retlw	10	
Test_2_1:
    movlw	0xB7
    cpfseq	first_digit, A
    bra		Test_3_1
    movlw	'2'
    movwf	POSTINC0
    retlw	20	
Test_3_1:
    movlw	0xD7
    cpfseq	first_digit, A
    bra		Test_4_1
    movlw	'3'
    movwf	POSTINC0
    retlw	30	
Test_4_1:
    movlw	0x7B
    cpfseq	first_digit, A
    bra		Test_5_1
    movlw	'4'
    movwf	POSTINC0
    retlw	40	
Test_5_1:
    movlw	0xBB
    cpfseq	first_digit, A
    bra		Test_6_1
    movlw	'5'
    movwf	POSTINC0
    retlw	50	
Test_6_1:
    movlw	0xDB
    cpfseq	first_digit, A
    bra		Test_7_1
    movlw	'6'
    movwf	POSTINC0
    retlw	60	
Test_7_1:
    movlw	0x7D
    cpfseq	first_digit, A  
    bra		Test_8_1
    movlw	'7'
    movwf	POSTINC0
    retlw	70	
Test_8_1:
    movlw	0xBD
    cpfseq	first_digit, A
    bra		Test_9_1
    movlw	'8'
    movwf	POSTINC0
    retlw	80	
Test_9_1:
    movlw	0xDD
    cpfseq	first_digit, A
    retlw	0xFF		; error message: when a letter or an invalid input has been detected
    movlw	'9'
    movwf	POSTINC0
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
    movlw	'0'
    movwf	POSTINC0
    retlw	0	
Test_1_2:
    movlw	0x77
    cpfseq	second_digit, A
    bra		Test_2_2
    movlw	'1'
    movwf	POSTINC0
    retlw	1	
Test_2_2:
    movlw	0xB7
    cpfseq	second_digit, A
    bra		Test_3_2
    movlw	'2'
    movwf	POSTINC0
    retlw	2	
Test_3_2:
    movlw	0xD7
    cpfseq	second_digit, A
    bra		Test_4_2
    movlw	'3'
    movwf	POSTINC0
    retlw	3
Test_4_2:
    movlw	0x7B
    cpfseq	second_digit, A
    bra		Test_5_2
    movlw	'4'
    movwf	POSTINC0
    retlw	4	
Test_5_2:
    movlw	0xBB
    cpfseq	second_digit, A
    bra		Test_6_2
    movlw	'5'
    movwf	POSTINC0
    retlw	5	
Test_6_2:
    movlw	0xDB
    cpfseq	second_digit, A
    bra		Test_7_2
    movlw	'6'
    movwf	POSTINC0
    retlw	6	
Test_7_2:
    movlw	0x7D
    cpfseq	second_digit, A  
    bra		Test_8_2
    movlw	'7'
    movwf	POSTINC0
    retlw	7	
Test_8_2:
    movlw	0xBD
    cpfseq	second_digit, A
    bra		Test_9_2
    movlw	'8'
    movwf	POSTINC0
    retlw	8	
Test_9_2:
    movlw	0xDD
    cpfseq	second_digit, A
    retlw	0xFF		; error message: when a letter or an invalid input has been detected
    movlw	'9'
    movwf	POSTINC0
    retlw	9	





