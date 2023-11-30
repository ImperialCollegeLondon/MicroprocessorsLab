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
HR_max: ds	1   ; the maximum heart rate calculated froma ge
HR_max_20: ds	1   ; the quotient of HR_max divided by 20
LOOP_COUNTER:ds	1   ; loop counter for HRZ boundary value calculations
TABLE_INDEX_DIFF:ds 1	; variable used to check end of loop condition
STATUS_CHECK:ds	1   ; use this in loop to check if the end of loop as been reached
    TABLE_START_ADDRESS EQU 0xA0    ; table start address for HRZ boundary values
    TABLE_SIZE EQU 8		    ; this value needs to be n+1, where n is how many times you want to read/write the table
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	HRZ_data    
ORG 0x1000 
	; ******* myTable, data in programme memory, and its length *****
Database:
	DB  20, 18, 17, 15, 13, 11
	CurrentIndex EQU 0x30
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
	movlw	201			; for testing
	movwf	HR_max			; for testing
	
	;call	Read_Age_Input_Find_HR_Max  ; return with W = HRmax
	;movwf	HR_max
	
	movff	HR_max, WREG		; move HR_max into WREG for use with function
	call	Divide_By_20		; return with HR_max/20 in WREG
	movwf	HR_max_20		; save quotient of divison (integer) in variable HR_max_20
	
	; Set up the table read pointer
	MOVLW	high(Database)
	MOVWF	TBLPTRH
	MOVLW	low(Database)
	MOVWF	TBLPTRL

    ; Initialize the index
	;MOVLW	0
	;MOVWF	CurrentIndex
	;MOVFF	CurrentIndex, PORTC
	
    ; Main loop to access the database
AccessLoop:
    ; Calculate the address of the current record
	;MOVLW	0
	;ADDWF	CurrentIndex, W
	;MOVWF	TBLPTRU

    ; Read the data from the database
	TBLRD*+
	MOVF	TABLAT, W ; Move the read data to WREG or other register
	MOVFF	TABLAT, PORTD
	
	;INCF	CurrentIndex, 1
		
	;MOVFF	CurrentIndex, WREG
	MOVFF	TBLPTRL, PORTC
	MOVFF	TBLPTRL, WREG
	
	SUBLW	6
	MOVWF	STATUS_CHECK	; difference between length of database and current index
	MOVFF	STATUS_CHECK, PORTB
	
	MOVLW	0
	CPFSEQ	STATUS_CHECK	; If difference is zero, skip to end of the loop
	GOTO	AccessLoop
	GOTO	EndAccessLoop
EndAccessLoop:
	GOTO	$



	
	goto	$

	end	rst
	
