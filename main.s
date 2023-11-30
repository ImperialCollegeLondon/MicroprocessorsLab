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
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	20, 18, 17, 15, 13, 11
	myTable_l   EQU	6	; length of data
	;align	2
    
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
	
; The following code creates a table that contain the upper boundary value for HRZs.
; Initialize loop counter
	MOVLW	0
	MOVWF	LOOP_COUNTER

LOOP: ; Loop through the table
    
	MOVLW	myTable
	ADDWF	LOOP_COUNTER, W		; Calculate the address of the current table element
	MOVWF	TBLPTRH
	MOVLW	0
	MOVWF	TBLPTRL

	TBLRD*				; Read the current table element
	MOVF	TABLAT, W ; Use the value in WREG as needed
	MOVFF	TABLAT, PORTD

; Your processing code goes here
; Example: Increment the value and write it back to the table
	;INCF	WREG, 0
	;MOVWF	TABLAT
	;MOVWF	PORTD
	;TBLWT*
	
	MOVFF	LOOP_COUNTER, 0x10
	INCF	LOOP_COUNTER, 1		; Increment loop counter

    ; Check if we've reached the end of the table
	MOVLW	myTable_l
	MOVWF	TABLE_INDEX_DIFF	; set variable to be equal to the size of the table
	SUBFWB	LOOP_COUNTER, 0		; Store difference in WREG
	MOVWF	STATUS_CHECK
	
	MOVLW	0
	CPFSEQ	STATUS_CHECK		; If f=W=0, end loop
	GOTO	LOOP			; Repeat the loop
	GOTO	END_LOOP

END_LOOP:
	MOVLW	0xFF
	MOVWF	PORTE
    ; Your code continues...
	nop				; move on with the rest of the code
	nop
	
	goto	$

	end	rst
	
