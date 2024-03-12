#include <xc.inc>

global	inputangle    

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D, LCD_Clear
extrn	Keypad_Setup, Keypad_Read, delay_ms
extrn	Input_Angle
	
psect	udata_acs   ; reserve data space in access ram
counter:	ds 1    ; reserve one byte for a counter variable
delay_count:	ds 1    ; reserve one byte for counter in the delay routine
input:		ds 1
input_address	EQU 0xB0

    inputangle	EQU 0xA0
	
psect	udata_bank4 ; reserve data anywhere in RAM
myArray:    ds 0x80

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
	movlw	11
	call	LCD_Write_Message
	movlw	0xFF
	call	delay_ms
	goto	User_Input

User_Input:
	movlw	input_address
	movwf	FSR0
    
	call	Keypad_Read ; finds button pressed and stores in WREG
	movwf	input
	movwf	PORTD
	
	movlw	0xFF
	call	delay_ms

	movlw	0x00
	cpfslt	input
	bra	User_Input
	
	movlw	input
	call	LCD_Send_Byte_D ; writes what is stored in W to LCD
	goto	$

	end	rst
	