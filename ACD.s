#include <xc.inc>

global  ADC_Setup, ADC_Read   
 
psect	udata_acs   ; reserve data space in access ram
D1:    ds 1    ; reserve one byte for digit 1 of result
D2:    ds 1    ; reserve one byte for digit 2
D3:    ds 1    ; reserve one byte for digit 3
D4:    ds 1    ; reserve one byte for digit 4
    
RES0:	ds 4
RES1:	ds 4
RES2:	ds 4
RES3:	ds 4

ARG1L:	ds 1
ARG1H:	ds 1
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

ADC_Convert:
	k	EQU   0x418A ; conversion factor k
	
	
end