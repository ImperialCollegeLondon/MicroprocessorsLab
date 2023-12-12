#include <xc.inc>

;extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, Clear_LCD, LCD_Send_Byte_HR, LCD_Send_Byte_HRZ, LCD_Write_Message, LCD_Write_Hex
extrn	Keypad_INIT, Keypad_READ, delay_ms
extrn	Decode_First_Digit, Decode_Second_Digit, Read_Age_Input_Find_HR_Max
extrn	Find_Max_Heart_Rate, Divide_By_20, Divide_By_Ten, Load_HRZ_Table, Determine_HRZ, IIR_Filter
extrn	Timer_Setup
extrn	no_overflow, overflow, Sixteen_Division
  
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds	1    ; reserve one byte for a counter variable
delay_count:ds	1    ; reserve one byte for counter in the delay routine
Measured_Zone:ds	1
Time_Counter:ds	1
OverflowCounter_1:ds	1
OverflowCounter_2:ds	1
Count:ds	1
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

psect	data    
HRMessage:
	db	'H','R','=',0x0a
					; message, plus carriage return
	myTable_l   EQU	4	; length of data
	align	2

psect	code, abs	
rst: 	org 0x0
 	goto	setup

Timer_Interrupt:org  0x0008
	btfss   TMR0IF
	retfie	f
	goto	Increase_Interrupt
	bcf     TMR0IF
	movlw   10000100B	; Fcyc/128 = 125 KHz
	movwf   T0CON, A
	retfie	f
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	;call	Keypad_INIT	; setup keypad

	movlw	0x00
	movwf	Time_Counter	; Initialise Time_Counter
	call	Timer_Setup
	call	LCD_Setup
	
	
	;bsf	INTCON, 4
;	bsf	PIE4, 2
;	bsf	ODCON2, 2
;	clrf	TMR1H
;	clrf	TMR1L

	movlw	0x00
	movwf	TRISH

	movlw	0x00
	movwf	TRISF
	
	movlw	0x00
	movwf	TRISC
	
	movlw	0xFF
	movwf	TRISD
	
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
	
	; call	overflow
	; heart rate measurement here
	
	
	
	; call	Sixteen_Division
	
	; IIR Filter: subroutine is entered with most recent measurement in WREG, outputs the averaged value

	; MOVLW	0x64		;Fictitious HR = 100
	; call	IIR_Filter	; Output_HR = average of past 3 measurements

	; sift through HRZ_Table and find the relevant heart rate zone, with measured HR in WREG
	; call	Determine_HRZ	; return with zone number in WREG
	; MOVWF	PORTB

	
	movlw	0x00
	movwf	PORTJ, A		; clear checking port
Detection_Loop:
	movlw	0x00
	CPFSGT	PORTD		; skip if pulse signal is high
	bra	Update_and_Branch
	CPFSGT	PORTJ		; skip if previous pulse was also high
	call	Signal_Detected
	bra	Update_and_Branch
Update_and_Branch:
	MOVFF	PORTD, PORTJ	; update LATJ with current value
	MOVLW	0x00
	MOVWF	PORTH
	bra	Detection_Loop
Signal_Detected:
	MOVFF	PORTD, PORTJ	; update LATJ with current value	
	MOVLW	0xFF
	MOVWF	PORTH
 	MOVFF	OverflowCounter_2, Count	; move timer count to WREG, OverflowCounter increments 1 every 4.08ms
 	CLRF	OverflowCounter_2, A		; reset time_counter
	MOVLW	1
	MULWF	Count				; this multiplication stores the count in PRODH:PRODL
	call	Sixteen_Division

	movlw	100
	cpfslt	Count	;if less skip
	call	Hundred
	movff	Count, WREG
	call	Divide_By_Ten
	call	Ten
	movff	Count, WREG
	addlw	'0'
	call	LCD_Send_Byte_HR


	bra	Detection_Loop
	
	;goto	$

Write_HR_LCD:
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(HRMessage)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(HRMessage)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(HRMessage)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished

	movlw	myTable_l	; output message to LCD
	addlw	0xff		; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message

Increase_Interrupt:
	INCF	OverflowCounter_1, 1
	;MOVFF	OverflowCounter_1, WREG
	BC	Increment_OFC2		; Branch if carry
	return
Increment_OFC2:
	INCF	OverflowCounter_2, 1
	;MOVFF	OverflowCounter_2, WREG
	return
    
Find_HR_from_Overflow:
	MOVFF	Count, WREG	; move count to W for multiplication
	MULLW	8		; multiply counter with period of timer0, result stored in PRODH:PRODL
	call	Sixteen_Division; denominator stored in PRODH, PRODL
	return
	
TMR0_INT:
	INCF	Time_Counter, 1
	;MOVFF	Time_Counter, PORTH
	bcf     TMR0IF
	
	movlw   10000100B	; Fcyc/128 = 125 KHz
	movwf   T0CON, A
	retfie	f

Hundred:
	movlw	1
	addlw	'0'
	call	LCD_Send_Byte_HR
	movlw	100
	subwf	Count, 1
	return
Ten:
	addlw	'0'
	call	LCD_Send_Byte_HR
	mullw	10
	movff	PRODL, WREG
	subwf	Count, 1
	return
	
	end	rst
	