    #include <xc.inc>

psect	udata_acs		; reserve space in access ram
phase_jump:	ds  1
phase_accum:	ds  2

psect	data			; reserve space
sine:
   db		0x40, 0x6c, 0x7f, 0x6c, 0x40, 0x13, 0x0, 0x13
   sine_length	EQU 0x08
   align	2

clock_setup:
    movlw	10000111B	; Set timer0 to 16-bit, Fosc/4/256
    movwf	T0CON, A	; = 62.5KHz clock rate, approx 1sec rollover
    bsf		TMR0IE		; Enable timer0 interrupt
    return

