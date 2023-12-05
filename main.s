#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D, Write_Welcome, SetTwoLines
extrn	Keypad_INIT, Keypad_READ, delay_ms
extrn	Decode_First_Digit, Decode_Second_Digit, Read_Age_Input_Find_HR_Max
extrn	Find_Max_Heart_Rate, Divide_By_20, Load_HRZ_Table, Determine_HRZ
extrn	Timer_Setup, Timer_int_hi  
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds	1    ; reserve one byte for a counter variable
delay_count:ds	1    ; reserve one byte for counter in the delay routine
Measured_Zone:ds	1
HR_Measured:ds	1   ; reserve one byte for measured HR value from sensor
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

timer_interrupt_low:	org  0x0008
	goto	Timer_int_hi

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
	;call	Write_Welcome
	;bra	SetTwoLines
	;call	Read_Age_Input_Find_HR_Max  ; return with W = HRmax
	;movwf	HR_max

	movlw	10		; FICTITOUS HR MAX FOR TESTING
	call	Load_HRZ_Table
	
	; heart rate measurement here
	movlw	7		; FICTITOUS HR VALUE FOR TESTING
	
	call	Determine_HRZ	; Zone value stored in WREG
	MOVWF	Measured_Zone
	
    
	
	; sift through HRZ_Table and find the relevant heart rate zone
	
	goto	$

	end	rst
	
