/* 
    File for ultrasonic sensor modules
*/
#include <xc.inc>
    
global ULTRA_Setup, ULTRA_Pulse, ULTRA_Measure, ULTRA_Convert, ULTRA_delay_ms, High_ISR
global t1L, t1H, t2L, t2H, tstatL, tstatH 
    
psect	udata_acs	    ; named variables in access ram
ULTRA_cnt_l:	ds 1	    ; reserve 1 byte for variable ULTRA_cnt_l
ULTRA_cnt_h:	ds 1	    ; reserve 1 byte for variable ULTRA_cnt_h
ULTRA_cnt_ms:	ds 1	
t1L:		ds 1
t1H:		ds 1
t2L:		ds 1
t2H:		ds 1
tstatH:		ds 1
tstatL:		ds 1
    
psect	ultra_code,class=CODE    
ULTRA_Setup:
    movlw   01000000B
    movwf   TRISD, A	; set portc i/o
    ;movlw   00000100B
    ;movwf   PORTD, A	; set Vcc (5V)
    movlw   0xFF
    movwf   TRISE, A	    ;  -> in order to configure CCP6 pin to input
    return
	
High_ISR:
    btfss   CCP6IF, A    ; skip next instruction if timer register capture occurred
    goto    OtherISR
    ; check which edge was detected
    movf    CCP6CON, W, A
    andlw   0x0F	    ; keep relevant bits only
    xorlw   0101B	    ; compare to 0101B for rising edge mode
    btfsc   STATUS, 2, A    ; skip next instruction if comparison yielded false
    goto    ISR_CCP6_Rise   
    goto    ISR_CCP6_Fall
    
ISR_CCP6_Rise:
    clrf    TMR1H, A	    ; clear timer bytes
    clrf    TMR1L, A
    bcf	    CCP6IF, A		    ; clear interrupt flag
    movlw   0000100B		    ; falling edge mode
    movwf   CCP6CON, A
    goto    OtherISR
    
ISR_CCP6_Fall:
    movf    CCPR6L, W, A	    ; save timer value L
    movwf   t2L, A
    movf    CCPR6H, W, A	    ; save timer value H
    movwf   t2H, A
    bcf	    CCP6IF, A		    ; clear interrupt flag
    goto    OtherISR
    
OtherISR:
    ; clear other interrupts if there are any
    ; none at the moment
    retfie  f

ULTRA_Pulse:
    movlw   00010000B
    movwf   PORTD, A	    ; signal on
    movlw   2
    call    ULTRA_delay_ms  ; delay for 2 ms
    movlw   00000000B
    movwf   PORTD, A	    ; signal off - device will now send 8 cycle sonic burst
    return

ULTRA_Measure:
    ; rising edge capture
    clrf    CCP6CON, A	    ; reset CCP6
    movlw   00000101B	    ; capture every rising edge
    movwf   CCP6CON, A 
    movlw   00110001B	    ; prescaler 1:8 for timer1, use internal clock, enable timer1
    movwf   T1CON, A
    clrf    TMR1H, A	    ; clear timer bytes
    clrf    TMR1L, A
    bsf	    CCP6IE, A	    ; enable CCP interrupt
    bsf	    CCP6IP, A	    ; set priority of CCP6 to high
    bsf	    PEIE, A	    ; enable peripheral interrupts
    bcf	    CCP6IF, A	    ; clear interrupt flag to be safe
    bsf	    GIE, A	    ; enable global interrupt
    ; wait for echo
    movlw   100
    call    ULTRA_delay_ms  ; delay for 100 ms
    
    ; read time between send and receive:
    ; interrupt on rising edge of echo
    ; reset timer
    ; interrupt on falling edge of echo
    ; save time value
    
    ; convert to distance using speed of sound
    
    
    ; output measured distance in hex
    return
    
ULTRA_Convert:
    ; take the timer values stored in t2H and t2L and multiply by 0x56
    ; divide by 0xA three times
    ; output hex result somehow
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

