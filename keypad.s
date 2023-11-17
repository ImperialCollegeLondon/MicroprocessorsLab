#include <xc.inc>
  
global  keypad_Setup, keypad_Read

psect	udata_acs   ; reserve data space in access ram
keypad_counter: ds    1	    ; reserve 1 byte for variable UART_counter

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
keyval:    ds 0x80 ; reserve 128 bytes for message data
        
psect	keypad_code,class=CODE
    
keypad_Setup:

    movlb   15	; pad configure 1 is in 15?
    bsf	    REPU    ; set pull-ups to on for PORTE
    movlb   0
    movlw   0x0F
    clrf    LATE    ; write 0s to the lat e register

    return

    
keypad_Read:
   
    call    bigdelay   ; can add a delay here to prevent need for status checks
    movff   PORTE, 0xD ; num is low bits
    movlw   0xF0    
    movwf   TRISE   ; set TRISE to 0x0F
    movf    PORTE, W ;  read PORTE to determine the logic levels on PORTE 0-3      
    iorwf   0xE0, 0, 1   ; num is low bits
    movwf   keyval
    call    bigdelay 
    goto    keypad_Read


delay:	decfsz	0xFF, A	; decrement until zero
	bra	delay
	return

bigdelay:
	call delay
	call delay
	call delay
	call delay 
	call delay
	call delay
	call delay
	call delay
	call delay 
	call delay
	return





