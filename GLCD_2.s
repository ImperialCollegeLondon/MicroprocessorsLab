RS	EQU PORTB, 2 ;port B is control line
RW	EQU PORTB, 3
EN	EQU PORTB, 4
CS1	EQU PORTB, 0
CS2	EQU PORTB, 1
RST	EQU PORTB, 5

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

send_command: ;RS and R/W are both 0 when sending command
	bcf	PORTB, RS ;clear
	bcf	PORTB, RW ; clear RW
	movwf	PORTD ;store command in w, move command to port D where port D is data line
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	return
	
send_data: ;when writing/sending data, RS pin is set to 1
	bsf	PORTB, RS
	bcf	PORTB, RW
	movwf	PORTD ;place data on port D
	bsf	PORTB, EN; set Enable pin to 1
	call	delay
	bcf	PORTB, EN
	return


	
 
	
	


