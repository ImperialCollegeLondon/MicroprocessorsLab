#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_clear
extrn   keypad_setup, keypad_start
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
    db   'j', 'j', 'l' , 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '!'  
    myword EQU 0x200    ; Address in RAM for data
    counter_hi EQU 0x8     ; Address of counter variable
    cipherkey EQU 0x9   ; value of a cipher key 
    zorkey    EQU 0x10
    
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call    keypad_setup
	call    keypad_start
	movff   LATH, cipherkey
	;.call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	goto	start
	
	; ******* Main programme ****************************************
start: 	    
	
	
	;movlw     7
	;movwf     cipherkey
	;ovff     LATH, cipherkey
	movlw     206
	movwf     zorkey
	lfsr     0, myword    ; Load FSR0 with address in RAM
	movlw    low highword(myTable)    ; address of data in PM
	movwf    TBLPTRU, A    ; load upper bits to TBLPTRU
	movlw    high(myTable)    ; address of data in PM
	movwf    TBLPTRH, A    ; load high byte to TBLPTRH
	movlw    low(myTable)    ; address of data in PM
	movwf    TBLPTRL, A    ; load low byte to TBLPTRL
	movlw    12
	movwf    counter_hi, A		; our counter register
loop: 	
	tblrd*+			 ; move one byte from PM to TABLAT, increment TBLPRT
	movf     cipherkey, W 
	addwf    TABLAT, W		 ; add the cipher key to original letters
	xorwf    zorkey, W		 ; add zorkey to cipher encrypt
;	xorwf    zorkey, W		 ; decrypt string
;	movwf   0x99			 ; decrypt string  
;	movf    cipherkey,W		 ; decrypt string
;	subwf    0x99, W
	movwf    POSTINC0		 ;  move read data from TABLAT to (FSR0), increment FSR0
	decfsz    counter, A    ; count down to zero
	bra    loop 
		
	;movlw	myTable_l	; output message to UART
	;lfsr	2, myArray
	;all	UART_Transmit_Message
	
	movlw    12
	lfsr     0  , 0x200
	call	LCD_Write_Message   ; goto current line in code
	;call    LCD_clear	    ;

			
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst