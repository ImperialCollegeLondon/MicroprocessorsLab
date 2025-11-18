#include <xc.inc>

global ADC_Setup, ADC_Read, ADC_Convert
global RES0, RES1, RES2, RES3
global DEC0, DEC1, DEC2, DEC3
 
psect	udata_acs   ; reserve data space in access ram
DEC0:    ds 1    ; reserve one byte for digit 1 of result (output goes as D0 D1 D2 D3)
DEC1:    ds 1    ; reserve one byte for digit 2 
DEC2:    ds 1    ; reserve one byte for digit 3
DEC3:    ds 1    ; reserve one byte for digit 4

    
RES0:	ds 4
RES1:	ds 4
RES2:	ds 4
RES3:	ds 4

ARG1L:	ds 1
ARG1H:	ds 1
ARG1M:	ds 1
ARG2L:	ds 1
ARG2H:	ds 1 

psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

ADC_Convert:	; requires ADC_Read to be called first
	; k is 0x418A - conversion factor k
	movlw	0x41
	movwf	ARG2H, A
	movlw	0x8A
	movwf	ARG2L, A
	movff	ADRESH, ARG1H, A
	movff	ADRESL, ARG1L, A
	
	; begin conversion via 16 x 16 unsigned multiply routine, see datasheet
	movf	ARG1L, W
	mulwf	ARG2L	
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1H, W
	mulwf	ARG2H
	
	movff	PRODH, RES3
	movff	PRODL, RES2
	
	movf	ARG1L, W
	mulwf	ARG2H
	
	movf	PRODL, W
	addwf	RES1, F
	movf	PRODH, W
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	movf	ARG1H, W
	mulwf	ARG2L
	
	movf	PRODL, W
	addwf	RES1, F
	movf	PRODH, W
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	; setup for second multiplication
	movff	RES3, DEC0, A ; save result of step 1 to first digit 
	
	movff	RES0, ARG1L, A ; save other results to be used in further multiplications
	movff	RES1, ARG1M, A
	movff	RES2, ARG1H, A
	
	movlw	0x0A	; mini_k constant for finding less significant bits
	movwf	ARG2L, A
	clrf	ARG2H
	
	; commence second multiplication
	
	movf	ARG1L, W, A
	mulwf	ARG2L
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1H, W, A
	mulwf	ARG2L

	movff	PRODH, RES3
	movff	PRODL, RES2
	
	movf	ARG1M, W, A
	mulwf	ARG2L
	
	movf	PRODL, W
	addwf	RES1, F
	movf	PRODH, W
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	movff	RES3, DEC1, A ; save useful result
	
	; setup for third multiplication
	movff	RES0, ARG1L, A ; save other results to be used in further multiplications
	movff	RES1, ARG1M, A
	movff	RES2, ARG1H, A
	
	; commence third multiplication
	movf	ARG1L, W, A
	mulwf	ARG2L
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1H, W, A
	mulwf	ARG2L

	movff	PRODH, RES3
	movff	PRODL, RES2
	
	movf	ARG1M, W, A
	mulwf	ARG2L
	
	movf	PRODL, W
	addwf	RES1, F
	movf	PRODH, W
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	movff	RES3, DEC2, A ; save useful result
	
	; setup for fourth multiplication
	movff	RES0, ARG1L, A ; save other results to be used in further multiplications
	movff	RES1, ARG1M, A
	movff	RES2, ARG1H, A
	
	; commence fourth multiplication
	movf	ARG1L, W, A
	mulwf	ARG2L
	
	movff	PRODH, RES1
	movff	PRODL, RES0
	
	movf	ARG1H, W, A
	mulwf	ARG2L

	movff	PRODH, RES3
	movff	PRODL, RES2
	
	movf	ARG1M, W, A
	mulwf	ARG2L
	
	movf	PRODL, W
	addwf	RES1, F
	movf	PRODH, W
	addwfc	RES2, F
	clrf	WREG
	addwfc	RES3, F
	
	movff	RES3, DEC3, A ; save useful result
	
	
	
end