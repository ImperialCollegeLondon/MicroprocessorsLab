#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D
extrn	Keypad_INIT, Keypad_READ
extrn	Find_Max_Heart_Rate
extrn	Decode_First_Digit, Decode_Second_Digit
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
pressed:    ds  1
kb_pressed: ds	1   ; check if keypad pressed
digit_input_counter: ds	1   ; counter for checking how many digits of the age has been inputted
age_first: ds	1   ; first digit of age input
age_second: ds	1   ; second digit of age input
age: ds	1	    ; age, after combining the two digits
maximum_heart_rate: ds	1   ; value for maximum heart rate is stored here
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	call	Keypad_INIT	; setup keypad
	call	LCD_Setup	; setup UART
	
	movlw	0x00
	movwf	TRISD
	
	movlw	0x00
	movwf	TRISJ
	
	movlw	0
	movwf	kb_pressed, A	; initialise this as 0, to indicate o key has been pressed
	
	movlw	2
	movwf	digit_input_counter	; initialise digit counter to 2, as our upper limit of age is 99
	
	goto	start
	
	; ******* Main programme ****************************************

Age_Read_1: 	
	movlw	0xB7		; this is just for a test
	movwf	PORTE		; also for test
	
	call	Keypad_READ	; keypad read subroutine, value stored in W
	call	Decode_First_Digit  ; decode first digit, return with 10s value in WREG
	movwf	age_first	    ; save value in variable age_first
	movwf	PORTD		; output to PORTD to visualise the number just inputted
	
	movlw	0xFF		; value of error message
	cpfslt	age_first	; if no valid input, branch to Age_Read_1 to read from Keypad again; 
	bra	Age_Read_1
	decf	digit_input_counter ; if there has been a valid input, decrement the digit counter and return
	return

Age_Read_2: 	
	movlw	0xB7		; this is just for a test
	movwf	PORTE		; also for test
	
	call	Keypad_READ	; keypad read subroutine, value stored in W
	call	Decode_Second_Digit  ; decode first digit, return with 10s value in WREG
	movwf	age_second	    ; save value in variable age_first
	movwf	PORTD		; output to PORTD to visualise the number just inputted
	
	movlw	0xFF		; value of error message
	cpfslt	age_second	; if no valid input, branch to Age_Read_1 to read from Keypad again; 
	bra	Age_Read_2
	decf	digit_input_counter ; if there has been a valid input, decrement the digit counter and return
	return
		

start: 	
	
	; read in age input from keypad
	movff	digit_input_counter, PORTJ  ; output digit counter to PORTJ to visualise how many digits are left to be inputted
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
	
	movff	age, PORTD		    ; output to PORTD to visualise age
	
	; find maximum heart rate
	movff	age, WREG		    ; put age in WREG for use in subroutine
	call	Find_Max_Heart_Rate
	movwf	maximum_heart_rate	    ; move value for maximum heart rate into variable

	nop				; move on to the rest of the code
	nop

	end	rst
	
