#include p18f87k22.inc
	
	global	DAC_Setup, LED_display
	
acs0	udata_acs
block	res 1
light	res 1
dir	res 1

	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	
	incf	LATD		; increment PORTD
	
	call	LED_display
	call	LED_Update
	
	bcf	INTCON,TMR0IF	; clear interrupt flag
	retfie	FAST		; fast return from interrupt
	
DAC	code
	
DAC_Setup
	;INPUTS/OUTPUTS
	clrf	TRISH
	clrf	LATH
	
	clrf	TRISD	
	clrf	LATD
	
	clrf	TRISE		; Set PORTD as all outputs
	clrf	LATE		; Clear PORTD outputs
	
	
	;INITIAL STATE
	;starts on B1:L1
	;direction UP (1)
	movlw	.1
	movwf	block
	
	movlw	b'00000001'
	movwf	light
	
	movlw	1
	movwf	dir

	;TIMING
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	return

	
LED_Update
	;START BY CHECKING DIR
	movlw 0 ;check if down
	CPFSEQ dir ;skip if down
	goto UP
	goto DOWN
	return
UP
	;check light position and move light
	movlw b'10000000'
	CPFSEQ light
	goto MOVE_UP ;if not at top, then just iterate as normal
	movlw .1
	CPFSEQ block
	goto BOUNCE_down ;if at top of second block, change direction and update
	goto INCREMENT_BLOCK ;top of first block, increment block and reset light to 0
	return
DOWN
	;check light position and move light
	movlw .1
	CPFSEQ light
	goto MOVE_DOWN ;if not at top, then just iterate as normal
	movlw .2
	CPFSEQ block
	goto BOUNCE_up ;if at top of second block, change direction and update
	goto DECREMENT_BLOCK ;top of first block, increment block and reset light to 0
	return
BOUNCE_up
	movlw 1	    ;1 = UP
	movwf dir
	goto MOVE_UP
	return
BOUNCE_down
	movlw 0	    ;0 = down
	movwf dir
	goto MOVE_DOWN
	return
INCREMENT_BLOCK
	incf block, 1
	movlw b'00000001'
	movwf light
	return
DECREMENT_BLOCK
	decf block, 1
	movlw b'10000000'
	movwf light
	return
MOVE_UP
	RLNCF light, 1 ;rotate left (increase index)
	return
MOVE_DOWN
	RRNCF light, 1 ;rotate left (decrease index)
	return
	

LED_display
	clrf LATE
	clrf LATH
	
	movlw	.2
	CPFSEQ	block
	goto B1
	goto B2
	return
B1
	movff	light, LATE
	return
B2
	movff	light, LATH
	return
	
;;CHECK WHICH BLOCK
;	movlw .1
;	CPFSEQ block
;	goto B2 
;	goto B1
;B1	;BLOCK 1
;	clrf LATE
;	clrf LATF
;	movff light, W
;	bsf LATE, W
;B2	;BLOCK 2
;	clrf LATE
;	clrf LATF
;	movff light, W
;	bsf LATF, W
	
end
