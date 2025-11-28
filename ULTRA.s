/* 
    File for ultrasonic sensor software modules
*/
#include <xc.inc>
    
global ULTRA_Setup, ULTRA_Pulse, ULTRA_Measure, ULTRA_Convert, ULTRA_delay_ms, High_ISR
global t2L, t2H, RES0, RES1, RES2
    
psect	udata_acs	    ; named variables in access ram
ULTRA_cnt_l:	ds 1	    ; reserve 1 byte for variable ULTRA_cnt_l
ULTRA_cnt_h:	ds 1	    ; reserve 1 byte for variable ULTRA_cnt_h
ULTRA_cnt_ms:	ds 1
    
t2L:		ds 1
t2H:		ds 1
    
ARG1L:		ds 1
ARG1H:		ds 1
ARG2:		ds 1
    
RES0x:		ds 1
RES1x:		ds 1
RES2x:		ds 1

SHIFTS:		ds 1	    ; number of shifts to execute in our binary to decimal converter

DRES0:		ds 1
DRES1:		ds 1
DRES2:		ds 1
DRES3:		ds 1
    
DIST1:		ds 1	; distance digits in decimal
DIST2:		ds 1
DIST3:		ds 1
DIST4:		ds 1
DIST5:		ds 1
DIST6:		ds 1
DIST7:		ds 1
DIST8:		ds 1	 ; adjust as needed
    
DDL:		ds 1
DDH:		ds 1
    
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
    
    return
    
ULTRA_Hex_Time_to_Dist:
	; take the timer values stored in t2H and t2L and multiply by 0x56
	; output hex result
	movff	t2L, ARG1L, A	; setup arguments
	movff	t2H, ARG1H, A
	movlw	0x56 ; = 86D = 344/4 m/s
	movwf	ARG2, A
    
	movf	ARG1L, W, A
	mulwf	ARG2
	
	movff	PRODH, RES1x
	movff	PRODL, RES0x
	
	movf	ARG1H, W, A
	mulwf	ARG2

	movff	PRODH, RES2x
	
	movf	PRODL, W	   ; directly process product, skip saving 
	addwfc	RES1x, F
	clrf	WREG
	addwfc	RES2x, F
	
	 return
	
Ultra_Dist_Convert:
	; Double dabble decimal conversion
	movlw	24D		    ; 24 shifts to execute in our BCD
	movf	SHIFTS
	
	clrf	DRES0
	clrf	DRES1
	clrf	DRES2
	clrf	DRES3
	bcf	STATUS, 0	    ; clear carry bit

Ultra_loop:
	; check low nibble > 4
	movf	DRES0, W
	andlw	0x0F	    ; only want bottom nibble
	sublw	4	    ; if w greater than or equal to 5, there is no carry
	movf	DRES0, W
	andlw	0x0F	    ; only want bottom nibble
	btfsc	STATUS, 0
	addlw	00000011B
	movwf	DDL

	swapf	DRES0, W
	andlw	0x0F	    ; only want top nibble
	sublw	4
	movf	DRES0, W
	andlw	0xF0	    ; only want top nibble
	btfsc	STATUS, 0
	addlw	00110000B   ; add 3 to top nibble
	iorwf	DDL, W	    ; combine low nibble from earlier with high nibble in W
	movwf	DRES0, A
	
	; WORK IN PROGRESS MODIFY ME PLEASE
	
	

	
	; shifting time!
	rlcf	RES0x
	rlcf	RES1x
	rlcf	RES2x
	rlcf	DRES0
	rlcf	DRES1
	rlcf	DRES2
	rlcf	DRES3
	
	
	
	
	
	
	
	; Finish conversion 
	btfss	SHIFTS		    ; check we've gone through all our shifts
	return			    ; return if counter is 0
	goto	Ultra_Dist_Convert  ; loop is counter is nonzero
   
    
    
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

