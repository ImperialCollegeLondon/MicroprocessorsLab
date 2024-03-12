#include <xc.inc>

global	inputangle    

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D, LCD_Clear
extrn	Keypad_Setup, Keypad_Read
extrn	Input_Angle
	
psect	udata_acs   ; reserve data space in access ram
counter:	ds 1    ; reserve one byte for a counter variable
delay_count:	ds 1    ; reserve one byte for counter in the delay routine
delay_count2:	ds 1
delay_count3:	ds 1
inputangle	EQU 0xA0

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	Keypad_Setup
	
	call	Input_Angle  ; load message
	
	
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	call	LCD_Clear
	movlw	inputangle
	movwf	FSR2
	movlw	12
	call	LCD_Write_Message
	goto	$

User_Input:
	call	Keypad_Read	; finds button pressed and stores in WREG
	call	LCD_Send_Byte_D	; writes what is stored in W to LCD
	call	delay_set		
	goto	start		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay_set:
	movlw	0xFF
	movwf	delay_count
	bra	delay	
	return

delay:
	movlw	0xFF
	movwf	delay_count2
	call	delay_loop
	decfsz	delay_count
	bra	delay
	return
	
delay_loop:
	movlw	0xFF
	movwf	delay_count3
	call	delay_2
	decfsz	delay_count2
	bra	delay_loop
	return

delay_2:
	decfsz	delay_count3
	call	delay_2
	return 
	

	end	rst