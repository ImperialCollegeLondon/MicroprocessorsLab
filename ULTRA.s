/* 
    File for ultrasonic sensor modules
*/
#include <xc.inc>
    
global ULTRA_Setup, ULTRA_Pulse, ULTRA_Measure, ULTRA_Convert, ULTRA_delay_ms	
    
psect	udata_acs   ; named variables in access ram
ULTRA_cnt_l:	ds 1	; reserve 1 byte for variable ULTRA_cnt_l
ULTRA_cnt_h:	ds 1	; reserve 1 byte for variable ULTRA_cnt_h
ULTRA_cnt_ms:	ds 1	
    
psect	ultra_code,class=CODE    
ULTRA_Setup:
    movlw   01000000B
    movwf   TRISD, A	; set portc i/o
    ;movlw   00000100B
    ;movwf   PORTD, A	; set Vcc (5V)
    return
    
    
ULTRA_Pulse:
    movlw   00010000B
    movwf   PORTD, A ; signal on
    movlw   2
    call    ULTRA_delay_ms ; delay for 2 ms
    movlw   00000000B
    movwf   PORTD, A ; signal off - device will now send 8 cycle sonic burst
    return

ULTRA_Measure:
    movlw   100
    call    ULTRA_delay_ms ; delay for 100 ms
    ; read time between send and receive:
    ; interrupt on rising edge of echo
    ; count
    ; interrupt on falling edge of echo
   
    ; convert to distance using speed of sound
    ; output measured distance in hex
    return
    
ULTRA_Convert:
    return
    
    
ULTRA_delay_ms:		    ; delay given in ms in W
	movwf	ULTRA_cnt_ms, A
ultralp2:	movlw	250	    ; 1 ms delay
	call	ULTRA_delay_x4us	
	decfsz	ULTRA_cnt_ms, A
	bra	ultralp2
	return
    
ULTRA_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	ULTRA_cnt_l, A	; now need to multiply by 16
	swapf   ULTRA_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	ULTRA_cnt_l, W, A ; move low nibble to W
	movwf	ULTRA_cnt_h, A	; then to ULTRA_cnt_h
	movlw	0xf0	    
	andwf	ULTRA_cnt_l, F, A ; keep high nibble in ULTRA_cnt_l
	call	ULTRA_delay
	return
    
ULTRA_delay:			; delay routine	4 instruction loops == 250ns	    
	movlw 	0x00		; W=0
ultralp1:	decf 	ULTRA_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	ULTRA_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	ultralp1		; carry, then loop again
	return			; carry reset so return

