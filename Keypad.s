#include <xc.inc>

global	Keypad_Setup, Keypad_Read
    
psect	udata_acs   ; reserve data space in access ram
Keypad_counter: ds    1	    ; reserve 1 byte for variable Keypad_counter
row: ds	    1
col: ds	    1
button: ds	1
cnt_ms:	ds 1   ; reserve 1 byte for ms counter
cnt_l:	ds 1   ; reserve 1 byte for variable cnt_l
cnt_h:	ds 1   ; reserve 1 byte for variable cnt_h


psect	keypad_code,class=CODE
    
Keypad_Setup:
    banksel PADCFG1
    bsf	    REPU
    clrf    LATE, A
    banksel 0
    
    movlw   0x0F
    movwf   TRISE, A 
    call    delay_ms
    
    return 
    
Keypad_Read: 
    ;reading column
    movlw   0x0F 
    movwf   TRISE, A
    call    delay_ms
    movff   PORTE, col, A
   
    ;reading row
    movlw   0xF0 
    movwf   TRISE, A
    call    delay_ms
    movff   PORTE, row, A
    
    ;finding button
    movff   row, WREG
    addwf   col, W, A
    movwf   button, A
    call    Error_Check
    return
    
Error_Check:
    movlw   0x00 ;ascii code for null 
    cpfseq  button, A
    bra	    Decode_0
    retlw   0x00

Decode_0:
    movlw   0xBE
    cpfseq  button, A
    bra	    Decode_1
    retlw   '0'
    
Decode_1:
    movlw   0x77
    cpfseq  button, A
    bra	    Decode_2
    retlw   '1'
    
Decode_2:
    movlw   0xB7
    cpfseq  button, A
    bra	    Decode_3
    retlw   '2'
    
Decode_3:
    movlw   0xD7
    cpfseq  button, A
    bra	    Decode_4
    retlw   '3'
    
Decode_4:
    movlw   0x7B
    cpfseq  button, A
    bra	    Decode_5
    retlw   '4'
    
Decode_5:
    movlw   0xBB
    cpfseq  button, A
    bra	    Decode_6
    retlw   '5'
    
Decode_6:
    movlw   0xDB
    cpfseq  button, A
    bra	    Decode_7
    retlw   '6'
    
Decode_7:
    movlw   0x7D
    cpfseq  button, A
    bra	    Decode_8
    retlw   '7'
    
Decode_8:
    movlw   0xBD
    cpfseq  button, A
    bra	    Decode_9
    retlw   '8'

Decode_9:
    movlw   0xDD
    cpfseq  button, A
    bra	    Decode_A
    retlw   '9'
    
Decode_A:
    movlw   0x7E
    cpfseq  button, A
    bra	    Decode_B
    retlw   'A'
    
Decode_B:
    movlw   0xDE
    cpfseq  button, A
    bra	    Decode_C
    retlw   'B'
    
Decode_C:
    movlw   0xEE
    cpfseq  button, A
    bra	    Decode_D
    retlw   'C'

Decode_D:
    movlw   0xED
    cpfseq  button, A
    bra	    Decode_E
    retlw   'D'
    
Decode_E:
    movlw   0xEB
    cpfseq  button, A
    bra	    Decode_F
    retlw   'E'
    
Decode_F:
    movlw   0xE7
    cpfseq  button, A
    retlw   0xFF
    retlw   'F'
    
;Delay Routines
delay_ms:		    ; delay given in ms in W
	movwf	cnt_ms, A
lp2:	movlw	250	    ; 1 ms delay
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


    end
    