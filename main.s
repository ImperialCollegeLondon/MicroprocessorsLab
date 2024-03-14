#include <xc.inc>

global	inputangle, delay_ms, input_address_1, input_address_2  

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Clear, Second_Line
extrn	Keypad_Setup, Keypad_Read
extrn	Input_Angle
extrn	User_Input_Setup
	
psect	udata_acs   ; reserve data space in access ram
counter:	ds 1    ; reserve one byte for a counter variable
cnt_ms:	ds 1   ; reserve 1 byte for ms counter
cnt_l:	ds 1   ; reserve 1 byte for variable cnt_l
cnt_h:	ds 1   ; reserve 1 byte for variable cnt_h
    
    input_address_1	EQU 0xB0
    input_address_2	EQU 0xC0
    inputangle		EQU 0xA0
	
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
	movlw	inputangle  ; Writes 'input angle' messge 
	movwf	FSR2
	movlw	12
	call	LCD_Write_Message  
	call	delay_ms
	call	delay_ms
	call	delay_ms
	
	call	User_Input_Setup    ; Waits for user input (8-bit/2-digits)
	goto	$

	
;Delay Routines
delay_ms:		    ; delay given in ms in W
	movwf	cnt_ms, A
lp2:	movlw	0xFF 
	call	delay_x4us	
	decfsz	cnt_ms, A
	bra	lp2
	return
	
delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	cnt_l, A	; now need to multiply by 16
	swapf   cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	cnt_l, W, A ; move low nibble to W
	movwf	cnt_h, A	; then to cnt_h
	movlw	0xf0	    
	andwf	cnt_l, F, A ; keep high nibble in cnt_l
	call	delay
	return

delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lp1:	decf 	cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lp1		; carry, then loop again
	return			; carry reset so return
	
	end	rst
