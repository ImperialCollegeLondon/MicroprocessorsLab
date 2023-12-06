#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D
extrn	Keypad_INIT, Keypad_READ, delay_ms
extrn	Decode_First_Digit, Decode_Second_Digit, Read_Age_Input_Find_HR_Max
extrn	Find_Max_Heart_Rate, Divide_By_20, Load_HRZ_Table, Determine_HRZ
extrn	Timer_Setup, Timer_int_hi
extrn	no_overflow, overflow
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds	1    ; reserve one byte for a counter variable
delay_count:ds	1    ; reserve one byte for counter in the delay routine
Measured_Zone:ds	1
Num_H:ds	1
Num_L:ds	1
Den_H:ds	1
Den_L:ds	1
Quotient:ds	1
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

	;movlw	10		; FICTITOUS HR MAX FOR TESTING
	;call	Load_HRZ_Table
	
	;call	Determine_HRZ	; Zone value stored in WREG
	;MOVWF	Measured_Zone
	
	;call	overflow
	
	; heart rate measurement here
	;movlw	5		; FICTITOUS HR VALUE FOR TESTING
	
	; sift through HRZ_Table and find the relevant heart rate zone, with measured HR in WREG
	;call	Determine_HRZ	; return with zone number in WREG
	;MOVWF	PORTB
	
	MOVLW	0x11
	MOVWF	Num_H
	MOVLW	0x22
	MOVWF	Num_L
	MOVLW	0x66
	MOVWF	Den_H
	MOVLW	0x66
	MOVWF	Den_L
	
	call	Sixteen_Division
	nop
	nop
	nop
	
Sixteen_Division:
	MOVLW	0
	MOVWF	Quotient		; initialise quotient
High_byte_check:
	MOVFF	Den_H, WREG
	CPFSGT	Num_H
	bra	End_Sixteen_Division	; when high byte of denominator is greater than numerator
	bra	Low_byte_check		
Low_byte_check:
	MOVFF	Den_L, WREG
	CPFSGT	Num_L
	bra	Sixteen_Borrow	
	bra	Sixteen_Subtraction
Sixteen_Subtraction:
	MOVFF	Den_L, WREG
	SUBWF	Num_L, 1
	MOVFF	Den_H, WREG
	SUBWF	Num_H, 1
	INCF	Quotient, 1
	MOVFF	Quotient, PORTB
	bra	High_byte_check
Sixteen_Borrow:
	DECF	Num_H, 1		; borrow from Num_H
	MOVFF	Den_H, WREG
	CPFSGT	Num_H
	bra	End_Sixteen_Division
	bra	Sixteen_Subtraction
End_Sixteen_Division:	
	MOVFF	Quotient, PORTC
	; move results into results register pair
	return
    
	
	
	
	goto	$

	end	rst
	
