#include <xc.inc>
    
global  Keypad_INIT, Keypad_READ

psect	udata_acs   ; reserve data space in access ram
Keypad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
row: ds	    1
col: ds	    1
keyval: ds	1
cnt_ms:	ds 1   ; reserve 1 byte for ms counter
cnt_l:	ds 1   ; reserve 1 byte for variable cnt_l
cnt_h:	ds 1   ; reserve 1 byte for variable cnt_h

psect	uart_code,class=CODE

Keypad_INIT:
    
    banksel PADCFG1
    bsf	    REPU    ;PADCFG1, REPU, 1 Pulling up resistors
    clrf    LATE, A
    banksel 0
    
    movlw   0x0F
    movwf   TRISE, A
    
    movlw   1
    call    delay_ms
    
    return

    
Keypad_READ:
    ; Drive output bits low all at once
    movlw   0x00
    movwf   PORTE, A
    
    movff   PORTE, col ; read in column values
    
    movlw   0xF0
    movwf   TRISE,  A ; changing TRI state
    
    movlw   1
    call    delay_ms	;delay
    
    ; Drive output bits low all at once
    movlw   0x00
    movwf   PORTE, A
 
    movff   PORTE, row	; read in row values
    movff   row, WREG
    
    iorwf   col, 0, 0	; inclusive or logic for row and column
    movwf   keyval	;
    
    movlw   0x0F
    movwf   TRISE, A
    
    movlw   1
    call    delay_ms
    
    movff   keyval, WREG    ; move keyvalue into WREG for decoder to work
    
    ;call    Test_none	; decode results, returns with result in working directory

    return
    
Test_none:	; no key pressed
	movlw	0xFF
	cpfseq	keyval, A
	bra	Test_0	; this is the ?no? result
	retlw	0xFF		; this is the ?yes? result
Test_0:
	movlw	0xBE
	cpfseq	keyval, A
	bra	Test_1	
	retlw	'0'	
Test_1:
	movlw	0x77
	cpfseq	keyval, A
	bra	Test_2	
	retlw	'1'	
Test_2:
	movlw	0xB7
	cpfseq	keyval, A
	bra	Test_3	
	retlw	'2'	
Test_3:
	movlw	0xD7
	cpfseq	keyval, A
	bra	Test_4	
	retlw	'3'	
Test_4:
	movlw	0x7B
	cpfseq	keyval, A
	bra	Test_5	
	retlw	'4'	
Test_5:
	movlw	0xBB
	cpfseq	keyval, A
	bra	Test_6	
	retlw	'5'	
Test_6:
	movlw	0xDB
	cpfseq	keyval, A
	bra	Test_7	
	retlw	'6'	
Test_7:
	movlw	0x7D
	cpfseq	keyval, A
	bra	Test_8	
	retlw	'7'	
Test_8:
	movlw	0xBD
	cpfseq	keyval, A
	bra	Test_9	
	retlw	'8'	
Test_9:
	movlw	0xDD
	cpfseq	keyval, A
	bra	Test_A	
	retlw	'9'	
Test_A:
	movlw	0x7E
	cpfseq	keyval, A
	bra	Test_B	
	retlw	'A'	
Test_B:
	movlw	0xDE
	cpfseq	keyval, A
	bra	Test_C	
	retlw	'B'	
Test_C:
	movlw	0xEE
	cpfseq	keyval, A
	bra	Test_D	
	retlw	'C'	
Test_D:
	movlw	0xED
	cpfseq	keyval, A
	bra	Test_E	
	retlw	'D'	
Test_E:
	movlw	0xEB
	cpfseq	keyval, A
	bra	Test_F	
	retlw	'E'	
Test_F:
	movlw	0xE7
	cpfseq	keyval, A
	retlw	0xFF		; error message	
	retlw	'F'	

    
delay_ms:		    ; delay given in ms in W
	movwf	cnt_ms, A
lp2:	movlw	250	    
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

	


