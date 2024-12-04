#include <xc.inc>

global  ADC_Setup, ADC_Read, multiplication, mul24and8, RES3,RES0, RES1, RES2, ARG2H, ARG2L, NRES0, NRES1, NRES2, NRES3 

psect	udata_acs   ; reserve data space in access ram
ARG2L:    ds 1    ; reserve 4 bytes 
ARG2H:	  ds 1    ; reserve 4 bytes 
RES0:     ds 1    ; reserve 4 bytes 
RES1:	  ds 1    ; reserve 4 bytes 
RES2:     ds 1    ; reserve 4 bytes 
RES3:	  ds 1    ; reserve 4 bytes 
NRES0:	  ds 1    ; reserve 4 bytes 
NRES1:	  ds 1    ; reserve 4 bytes 
NRES2:	  ds 1    ; reserve 4 bytes 
NRES3:	  ds 1    ; reserve 4 bytes 
    
psect	adc_code, class=CODE
    
ADC_Setup:
	bsf	TRISA, 3, A  ; pin RA0==AN0 input
	movlb	0x0f
	bsf	ANSEL3	    ; set AN0 to analog
	movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return
	
multiplication:
	movlw	0x418A
	andlw	0xFF
	movwf	ARG2L, A
	movlw   high(0x418A)
	movwf	ARG2H, A
	
	MOVF	ADRESL, W      ;Lower - 0xFF, Higher - 0xFF00
	MULWF	ARG2L ; ARG1L * ARG2L-> ; PRODH:PRODL 
	MOVFF	PRODH, RES1 ; 
	MOVFF	PRODL, RES0 ; 
	;
	MOVF	ADRESH, W 
	MULWF	ARG2H ; ARG1H * ARG2H-> ; PRODH:PRODL
	MOVFF	PRODH, RES3 ; 
	MOVFF	PRODL, RES2 ; 
	;
	MOVF	ADRESL, W 
	MULWF	ARG2H ; ARG1L * ARG2H-> 
		    ; PRODH:PRODL 
	MOVF	PRODL, W ; 
	ADDWFC	RES1,F; Add cross 
	MOVF	PRODH, W ; products 
	ADDWFC	RES2, F ; 
	CLRF	WREG ; 
	ADDWFC	RES3, F ; 
	; 
	MOVF	ADRESH, W ; 
	MULWF	ARG2L ; ARG1H * ARG2L-> 
		    ; PRODH:PRODL 
	MOVF	PRODL, W ; 
	ADDWFC	RES1, F ; Add cross 
	MOVF	PRODH, W ; products 
	ADDWFC	RES2, F ; 
	CLRF	WREG ; 
	ADDWFC	RES3, F ;
	return
	
mul24and8:
	MOVLW	0x0A
	MULWF	RES0; ARG1L * ARG2L-> ; PRODH:PRODL 
	MOVFF	PRODH, NRES1 ; 
	MOVFF	PRODL, NRES0 
	;
	MOVLW	0x0A
	MULWF	RES1; ARG1L * ARG2L-> ; PRODH:PRODL 
	MOVF	PRODL, W ;
	ADDWF	NRES1, F ; Add cross 
	MOVFF	PRODH, NRES2 ; 
	;
	MOVLW	0x0A
	MULWF	RES2 ; ARG1L * ARG2L-> ; PRODH:PRODL 
	MOVF	PRODL, W ;
	ADDWFC	NRES2, F
	MOVFF	PRODH, NRES3 ;
	CLRF	WREG ; 
	ADDWFC	NRES3, F ;
	;
	movff   NRES0, RES0
	movff   NRES1, RES1
	movff   NRES2, RES2
	movff   NRES3, RES3
	return
	
	
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

end