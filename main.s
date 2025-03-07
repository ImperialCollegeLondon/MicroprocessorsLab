
#include <xc.inc>
global CiphertextArray, PlaintextArray, TableLength, counter_pt, counter_ec, timer_low, timer_high
extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
extrn print_plaintext, print_ciphertext   
extrn modify_table
extrn measure_modify_table
    
psect	udata_acs		; reserve data space in access ram
counter_pt:	ds 1		; counter for printing the initial data
counter_ec:	ds 1		; encoding counter
timer_low:  ds 1		; Store low byte of Timer1
timer_high: ds 1		; Store high byte of Timer1
    
psect	udata_bank4		; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:    ds 0x80	; reserve 128 bytes for message data
CiphertextArray:    ds 0x80	; reserve 128 bytes for modified message data

    
psect	data    
PlaintextTable:
	db	'H','e','l','l','o',' ', 'w','o','r','l', 'd'				
	TableLength   EQU	11	
	align	2

	
psect	code, abs
rst:	org 0x0
	goto setup
	
setup:	bcf	CFGS		; point to Flash program memory  
	bsf	EEPGD		; access Flash program memory
	call	LCD_Setup	; setup UART
	movlw	0x00
	movwf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	goto	start

start:
	call	copy_plaintext		; load code into RAM
	call	print_plaintext		; print the plaintext
	
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I
	movlw	0x01	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call measure_modify_table        ; Modify the ciphertext array and time it
	
	call print_ciphertext    ; Print the modified data to the LCD
	
	movlw ' '
	call LCD_Send_Byte_D 
	
	movf timer_high, W, A
	call LCD_Write_Hex
	
	movf timer_low, W, A
	call LCD_Write_Hex
	
	goto	$

copy_plaintext:
	lfsr	0, PlaintextArray	; Load FSR0 with address in RAM	
	movlw	low highword(PlaintextTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(PlaintextTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(PlaintextTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_pt, A
	goto setup_loop

setup_loop:
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A
	decfsz	counter_pt, A		; count down to zero
	bra	setup_loop	; keep going until finished
	return

ending:
    nop
    
    end rst
    
	