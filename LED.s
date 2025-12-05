#include <xc.inc>

global	LED_Setup, LED_Logic
global	deltat_L, deltat_H, LIM_L, LIM_H, CLO_L, CLO_H, FAR_L, FAR_H
extrn t2L, t2H


psect	udata_acs
deltat_L:    ds	1 ; detla_t should be leq 16383 in decimal (3FFF) so that FAR stays 16 bit
deltat_H:   ds  1
LIM_L:	    ds	1
LIM_H:	    ds	1
CLO_L:	    ds	1
CLO_H:	    ds	1
MID_L:	    ds	1
MID_H:	    ds	1
FAR_L:	    ds	1
FAR_H:	    ds	1
    
    
psect	led_code,class=CODE   
	
LED_Setup:
; setup pins 4-7 of port J as output in main
    ; set delta t
    movlw   0xFF
    movwf   deltat_L
    movlw   0x07
    movwf   deltat_H
    
    ;LIM
    movff   deltat_L, LIM_L
    movff   deltat_H, LIM_H
    
    ; CLO
    movlw   0x2
    mulwf   deltat_L
    
    movff	PRODH, CLO_H	; intermediate result
    movff	PRODL, CLO_L
    
    movlw   0x2
    mulwf   deltat_H
    
    movf	PRODL, W	   ; directly process product, skip saving 
    addwfc	CLO_H, F
    
    ; MID
    movlw   0x3
    mulwf   deltat_L
    
    movff	PRODH, MID_H	; intermediate result
    movff	PRODL, MID_L
    
    movlw   0x3
    mulwf   deltat_H
    
    movf	PRODL, W	   ; directly process product, skip saving 
    addwfc	MID_H, F
    
    ; FAR
    movlw   0x4
    mulwf   deltat_L
    
    movff	PRODH, FAR_H	; intermediate result
    movff	PRODL, FAR_L
    
    movlw   0x4
    mulwf   deltat_H
    
    movf	PRODL, W	   ; directly process product, skip saving 
    addwfc	FAR_H, F
    
    bcf	    LATJ, 7   ; clear LED pins
    bcf	    LATJ, 6
    bcf	    LATJ, 5
    bcf	    LATJ, 4

LED_Logic:
    ; light  up leds in sequence
FAR_Check:
    ; compare more significant bits first
    movf    t2H, W
    cpfseq  FAR_H  ; only need to check low bits if high bits are equal
    bra	    FAR_check_hi_res 
    
    movf    t2L, W
    cpfslt  FAR_L
    goto    FAR_LED    ; turn FAR led on
    bcf	    LATJ, 4
    bcf	    LATJ, 5
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return
    
FAR_check_hi_res:
    movf    t2H, W
    cpfslt  FAR_H
    goto    FAR_LED	; if high bit dist smaller than FAR threshold, light up FAR LED
    bcf	    LATJ, 4
    bcf	    LATJ, 5
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return

MID_Check:
    movf    t2H, W
    cpfseq  MID_H  
    bra	    MID_check_hi_res 
    
    movf    t2L, W
    cpfslt  MID_L
    goto    MID_LED    ; turn MID led on
    bcf	    LATJ, 5
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return
    
MID_check_hi_res:
    movf    t2H, W
    cpfslt  MID_H
    goto    MID_LED
    bcf	    LATJ, 5
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return
    
CLO_Check:
    movf    t2H, W
    cpfseq  CLO_H  
    bra	    CLO_check_hi_res 
    
    movf    t2L, W
    cpfslt  CLO_L
    goto    CLO_LED    ; turn CLO led on
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return
    
CLO_check_hi_res:
    movf    t2H, W
    cpfslt  CLO_H
    goto    CLO_LED
    bcf	    LATJ, 6
    bcf	    LATJ, 7
    return

LIM_Check:
    movf    t2H, W
    cpfseq  LIM_H  
    bra	    LIM_check_hi_res 
    
    movf    t2L, W
    cpfslt  LIM_L
    goto    LIM_LED	; turn LIM led on if distance less than LIM dist
    bcf	    LATJ, 7	; turn LIM LED off if distance greater than LIM dist
    return
    
LIM_check_hi_res:
    movf    t2H, W
    cpfslt  LIM_H
    goto    LIM_LED	; turn LIM led on if distance less than LIM dist
    bcf	    LATJ, 7	; turn LIM LED off if distance greater than LIM dist
    return    
    
FAR_LED:
    bsf	    LATJ, 4
    goto    MID_Check	; check next distance marker
    
MID_LED:
    bsf	    LATJ, 5
    goto    CLO_Check	; check next distance marker
    
CLO_LED:
    bsf	    LATJ, 6
    goto    LIM_Check	; check next distance marker
    
LIM_LED:
    bsf	    LATJ, 7
    bsf	    LATD, 0 ; buzzer on (?)
    return		; all LEDs on, return


