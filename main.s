#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D
extrn	Keypad_INIT, Keypad_READ, delay_ms
extrn	Decode_First_Digit, Decode_Second_Digit, Read_Age_Input_Find_HR_Max
extrn	Divide_By_20
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds	1    ; reserve one byte for a counter variable
delay_count:ds	1    ; reserve one byte for counter in the delay routine
pressed:ds	1
kb_pressed: ds	1   ; check if keypad pressed
denominator_high:ds	1
denominator_low:ds	1
HR_max: ds	1   ; the maximum heart rate calculated froma ge
HR_max_20: ds	1   ; the quotient of HR_max divided by 20
LOOP_COUNTER:ds	1   ; loop counter for HRZ boundary value calculations
TABLE_INDEX_DIFF:ds 1	; variable used to check end of loop condition
STATUS_CHECK:ds	1   ; use this in loop to check if the end of loop as been reached
    TABLE_START_ADDRESS EQU 0xA0    ; table start address for HRZ boundary values
    TABLE_SIZE EQU 8		    ; this value needs to be n+1, where n is how many times you want to read/write the table
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	edata	    ; store data in EEPROM, so can read and write
;ORG 0x1000 
	; ******* myTable, data in programme memory, and its length *****
Database:
	DB  20, 18, 17, 15, 13, 11
	align	2
	
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	call	Keypad_INIT	; setup keypad
	call	LCD_Setup	; setup UART
	
	movlw	0x00
	movwf	TRISD
	
	movlw	0x00
	movwf	TRISC
	
	movlw	0x00
	movwf	TRISB
	
	movlw	0x00
	movwf	TRISJ
	
	;movlw	0
	;movwf	kb_pressed, A	; initialise this as 0, to indicate o key has been pressed
		
	goto	start
	
	; ******* Main programme ****************************************

start: 	
	
	call	Read_Age_Input_Find_HR_Max  ; return with W = HRmax
	movwf	HR_max

	
    ; Main loop to access the database
	;MOVLW	3
	;MOVWF	HR_max
	
AccessLoop:
	CLRF	EEADR		; start at address 0
	BCF	EECON1, 6	; set for memory, bit 6 = CFGS
	BCF	EECON1, 7	; set for data EEPROM, bit 7 = EEPGD
	BCF	INTCON, 7	; disable interrupts, bit 7 = GIE
	BSF	EECON1, 2	; write enable, bit 2 = WREN
	
Loop:
	MOVFF	EEADR, PORTB
	BSF	EECON1, 0	; read current address, bit 0 = RD
	nop			; need to have delay after read instruction for reading to complete
	MOVFF	EEDATA, WREG	; W = eedata
	MOVFF	EEDATA, PORTC
	
	
	MULWF	HR_max
	
	CALL	Divide_By_20	
	MOVWF	PORTB
	MOVWF	EECON2		; move data from WREG to EECON2 waiting to be written
	BSF	EECON1, 1	; to write data, bit 1  = WR
	BTFSC	EECON1, 1
	bra	$-2		; wait for write to complete
	INCF	EEADR, 1	; Increment address and save back to EEADR
	
	MOVFF	EEADR, WREG	; Routine to check if the end has been reached
	SUBLW	6
	MOVWF	STATUS_CHECK	
	MOVLW	0
	CPFSEQ	STATUS_CHECK	; comparison to see if the end of the table has been reached
	bra	Loop
	bra	End_Write
End_Write:
	; Continue on with the rest of the code
	BCF	EECON1, 2	; disenable writing function
	MOVLW	0xFF
	MOVWF	PORTD
	goto	$  



	
	goto	$

	end	rst
	
