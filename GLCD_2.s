#include <xc.inc>

    
RS	EQU	2 ;port B is control line
R	EQU	3 ;RW
EN	EQU	4
CS1	EQU	0
CS2	EQU	1
RST	EQU	5

init_LCD:
	bsf	PORTB, RST ;reset
	call	delay
	bcf	PORTB, RST ;end reset
	bsf	PORTB, CS1 ;select left half
	bsf	PORTB, CS2 ;select right half
	movlw	0xB8 ;set to page 0 (x-address)
	call	send_command
	movlw	0x40 ;set to strip 0 in page (y-address)
	call	send_command
	movlw	0xC0 ;start line, start from row 0 (z-address)
	call	send_command
	movlw	0x3F ;display on
	call	send_command
	return

draw_pattern:
	movlw	0xAA
	call	send_data
	return
	
send_command: ;RS and R/W are both 0 when sending command
	bcf	PORTB, RS ;clear
	bcf	PORTB, R ; clear RW
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	return
	
send_data: ;when writing/sending data, RS pin is set to 1
	bsf	PORTB, RS
	bcf	PORTB, R
	movwf	PORTD ;place data on port D
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	return

delay:
	decfsz	0x20, F, A    ; Decrement until zero
	bra	delay
	return

	


