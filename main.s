#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D
extrn	Keypad_INIT, Keypad_READ
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
pressed:    ds  1
kb_pressed: ds	1   ; check if keypad pressed
digit_input_counter: ds	1   ; counter for checking how many digits of the age has been inputted
    
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
	movwf	digit_input_counter
	
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	movff	digit_input_counter, PORTJ
	movlw	0
	cpfseq	digit_input_counter	; check if there are any digits left to input, skip if =
	call	Age_Read
	nop				; move on to the rest of the code
	nop
	movlw	0xFF
	movwf	PORTJ

	
Age_Read: 	
	call	Keypad_READ
	movwf	PORTD
	movwf	pressed
	
	movlw	0xFF
	cpfslt	pressed	    ; do not output anything to LCD if there is no/invalid input
	bra	Age_Read

	lfsr	2, pressed
	movlw	1
	call	LCD_Write_Message
	decf	digit_input_counter
	bra	start		
	
	end	rst
	
