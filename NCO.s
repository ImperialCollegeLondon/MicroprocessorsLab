#include <xc.inc>
	
global	Phase_Setup, Timer_Setup, Lookup_Setup, DDS_Int_Hi  ; global routines
global	Phase_Jump, Phase_Accum
extrn	Lookup_Table	; global data

psect	udata_acs   ; reserve data space in access ram
Phase_Jump:	ds  2
Phase_Accum:	ds  2
Lookup_Ptr:	ds  3

psect	dac_code, class=CODE

Phase_Setup:
	clrf	Phase_Accum + 2,    A
	clrf	Phase_Accum + 1,    A
	clrf	Phase_Accum,	    A
	clrf	Phase_Jump + 1,	    A
	clrf	Phase_Jump,	    A
	movlw	0x01
	movwf	Phase_Jump,	    A
	return

Timer_Setup:
	clrf	TRISJ,	A	; Set PORTD as all outputs
	clrf	LATJ,	A	; Clear PORTD outputs
	movlw	10001000B	; Set timer0 to 16-bit, Fosc/4
	movwf	T0CON,	A	; = 16MHz clock rate, approx 4ms rollover
	bsf	TMR0IE		; Enable timer0 interrupt
	bsf	GIE		; Enable all interrupts
	return

Lookup_Setup:
	bcf	CFGS			; point to Flash program memory  
	bsf	EEPGD			; access Flash program memory
Lookup_Init:
	movlw	low highword(Lookup_Table)	; address of data in PM
	movwf	Lookup_Ptr + 2,    A		; load upper bits to TBLPTRU
	movlw	high(Lookup_Table)		; address of data in PM
	movwf	Lookup_Ptr + 1,    A		; load high byte to TBLPTRH
	movlw	low(Lookup_Table)		; address of data in PM
	movwf	Lookup_Ptr,	   A		; load low byte to TBLPTRL
	return

DDS_Int_Hi:	
	btfss	TMR0IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
Pointer_Ld:
	movf	Lookup_Ptr + 2, W, A
	movwf	TBLPTRU,	   A
	movf	Lookup_Ptr + 1, W, A
	movwf	TBLPTRH,	   A
	movf	Lookup_Ptr,	W, A
	movwf	TBLPTRL,	   A
Phase_Amp:
	tblrd*
	movff	TABLAT, LATJ
Phase_Inc:
	incf	Lookup_Ptr, A
	bcf	TMR0IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

	end
