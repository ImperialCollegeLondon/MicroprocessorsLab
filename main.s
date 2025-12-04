#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear, LCD_Write_Distance, LCD_Max_Message, LCD_Mode_Error ; external LCD subroutines
extrn	ADC_Setup, ADC_Read, ADC_Convert		   ; external ADC subroutines
extrn	ULTRA_Setup, ULTRA_Pulse, ULTRA_Measure, ULTRA_Dist_Convert, ULTRA_delay_ms, High_ISR, ULTRA_Hex_Time_to_Dist
extrn	DIST1, DIST2, DIST3, DIST4, DIST5, DIST6, DIST7
extrn	LED_Setup
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'M','a','x',' ','d','i','s','t','.','>', 0x0a
					; message, plus carriage return
	myTable_l   EQU	10	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup
	
int_hi:
    org 0x0008		    ; if high priority interrupt is triggered
    goto    High_ISR

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	; call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	;call	ADC_Setup	; setup ADC
	call	ULTRA_Setup
	
	; check for mode
	movlw	0x0F
	movwf	TRISJ ; set output from port J 0-3 and input from port J 4-7
	nop
	nop
	nop
	nop
	
	movf	PORTJ, W
	iorlw	11110000B	; mask off top bits being used as outputs
	xorlw   11110001B	; compare to 0101B for rising edge mode
	btfsc   STATUS, 2, A    ; skip next instruction if comparison yielded false
	goto	Distance_cont_mode_start
	
	movf	PORTJ, W
	iorlw	11110000B
	xorlw   11110010B	    ; compare to 0101B for rising edge mode
	btfsc   STATUS, 2, A    ; skip next instruction if comparison yielded false
	goto	Proximity_mode_start
	
	movf	PORTJ, W
	iorlw	11110000B
	xorlw   11110100B	    ; compare to 0101B for rising edge mode
	btfsc   STATUS, 2, A    ; skip next instruction if comparison yielded false
	goto	Motion_mode_start
	
	goto	Mode_not_found	    ; check if an invalid mode was selected
	
Mode_not_found:
    call LCD_Mode_Error		    ; display error message
    goto    $
	
Proximity_mode_start:
    call    LED_Setup
    goto    Proximity_mode_start
Motion_mode_start:
    goto    Motion_mode_start
    
Distance_cont_mode_start:	
	call	ULTRA_Pulse
	call	ULTRA_Measure
	call	ULTRA_Hex_Time_to_Dist
	call	ULTRA_Dist_Convert; use measured distance and convert to cm
	; output cm value to LCD
	call	LCD_Clear ; clear LCD to prepare for new value to be output
	; check for timer overflow
	btfsc	PIR1, 0
	call	LCD_Max_Message
	btfss	PIR1, 0
	call	LCD_Write_Distance
	
	movlw	0xFF
	call	ULTRA_delay_ms
	   
	
	
	
	goto Distance_cont_mode_start
	
	
	
/*
	; ******* Main programme ****************************************
start: 	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message

	movlw	myTable_l-1	; output message to LCD
				; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
	
measure_loop:
	call	ADC_Read
	call	ADC_Convert
	movf	ADRESH, W, A
	call	LCD_Write_Hex
	movf	ADRESL, W, A
	call	LCD_Write_Hex
	goto	measure_loop		; goto current line in code
*/
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst