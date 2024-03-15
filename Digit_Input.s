#include <xc.inc>
    
global	User_Input_Setup
extrn	Keypad_Read
extrn	LCD_Write_Message, LCD_Clear, Second_Line, Shift_Left
extrn	LCD_Send_Byte_D
extrn	input_address_1, input_address_2, delay_ms
    
psect	udata_acs		    ; reserve data space in access ram
digit_counter:	ds 1
d1:		ds 1
d2:		ds 1
input_1:	ds 1
input_2:	ds 1
before_dec:	ds 1
    
    
psect	udata_bank4		    ; reserve data anywhere in RAM
myArray:    ds 0x80
    
psect input_code, class=CODE
    
User_Input_Setup:
	Input_1:
	call	User_Input_1
	
	Input_2:
	call	User_Input_2
	
Add_Input:
	movff	input_1, WREG	    ; adding together the two digits to
				    ; create one 8 bit number
	addwf	input_2, W
	movwf	before_dec

	call	delay_ms
	call	delay_ms
	call	delay_ms

	return
	
User_Input_1:
	movlw	input_address_1	    ; address to store first digit
	movwf	FSR0
    
	call	Keypad_Read	    ; finds button pressed and stores in WREG
	call	Decode_Input_1	    ; Decodes digit
	movwf	input_1
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF
	cpfslt	input_1		    ; Checks for valid input
	bra	User_Input_1	    ; repeat if valid button not pressed
	
	call	Second_Line	    ; Writes digit to second line of LCD 
	movlw	input_address_1
	movwf	FSR2
	movlw	1
	call	LCD_Write_Message 
	
	return
	
User_Input_2:
	movlw	input_address_2	    ; address to store second digit
	movwf	FSR0
    
	call	Keypad_Read	    ; finds button pressed and stores in WREG
	call	Decode_Input_2	    ; Decodes digit 
	movwf	input_2
	
	movlw	0xFF
	call	delay_ms
	
	movlw	0xFF
	cpfslt	input_2		    ; Checks for valid input 
	bra	User_Input_2	    ; repeat if valid button not pressed
	
	movlw	input_address_2
	movwf	FSR2
	movlw	1
	call	LCD_Write_Message 
	
	return 

Decode_Input_1:
    movwf   d1, A
Error_Check_1:
    movlw   0xFF		    
    cpfseq  d1, A
    bra	    Decode_0_1
    retlw   0xFF

Decode_0_1:
    movlw   0x7D
    cpfseq  d1, A
    bra	    Decode_1_1
    movlw   '0'	    
    movwf   INDF0
    incf    FSR0
    retlw   0
    
Decode_1_1:
    movlw   0xEE
    cpfseq  d1, A
    bra	    Decode_2_1
    movlw   '1'
    movwf   INDF0
    incf    FSR0
    retlw   10			   ; stores first digit as tens 
    
Decode_2_1:
    movlw   0xED
    cpfseq  d1, A
    bra	    Decode_3_1
    movlw   '2'
    movwf   INDF0
    incf    FSR0
    retlw   20
    
Decode_3_1:
    movlw   0xEB
    cpfseq  d1, A
    bra	    Decode_4_1
    movlw   '3'
    movwf   INDF0
    incf    FSR0
    retlw   30
    
Decode_4_1:
    movlw   0xDE
    cpfseq  d1, A
    bra	    Decode_5_1
    movlw   '4'
    movwf   INDF0
    incf    FSR0
    retlw   40
    
Decode_5_1:
    movlw   0xDD
    cpfseq  d1, A
    bra	    Decode_6_1
    movlw   '5'
    movwf   INDF0
    incf    FSR0
    retlw   50
    
Decode_6_1:
    movlw   0xDB
    cpfseq  d1, A
    bra	    Decode_7_1
    movlw   '6'
    movwf   INDF0
    incf    FSR0
    retlw   60
    
Decode_7_1:
    movlw   0xBE
    cpfseq  d1, A
    bra	    Decode_8_1
    movlw   '7'
    movwf   INDF0
    incf    FSR0
    retlw   70
    
Decode_8_1:
    movlw   0xBD
    cpfseq  d1, A
    bra	    Decode_9_1
    movlw   '8'
    movwf   INDF0
    incf    FSR0
    retlw   80

Decode_9_1:
    movlw   0xBB
    cpfseq  d1, A
    retlw   0xFF
    movlw   '9'
    movwf   INDF0
    incf    FSR0
    retlw   90
     
Decode_Input_2:
    movwf   d2, A
Error_Check_2:
    movlw   0xFF  
    cpfseq  d2, A
    bra	    Decode_0_2
    retlw   0xFF

Decode_0_2:
    movlw   0x7D
    cpfseq  d2, A
    bra	    Decode_1_2
    movlw   '0'
    movwf   INDF0
    incf    FSR0
    retlw   0
    
Decode_1_2:
    movlw   0xEE
    cpfseq  d2, A
    bra	    Decode_2_2
    movlw   '1'
    movwf   INDF0
    incf    FSR0
    retlw   1				; stores second digit as units 			
    
Decode_2_2:
    movlw   0xED
    cpfseq  d2, A
    bra	    Decode_3_2
    movlw   '2'
    movwf   INDF0
    incf    FSR0
    retlw   2
    
Decode_3_2:
    movlw   0xEB
    cpfseq  d2, A
    bra	    Decode_4_2
    movlw   '3'
    movwf   INDF0
    incf    FSR0
    retlw   3
    
Decode_4_2:
    movlw   0xDE
    cpfseq  d2, A
    bra	    Decode_5_2
    movlw   '4'
    movwf   INDF0
    incf    FSR0
    retlw   4
    
Decode_5_2:
    movlw   0xDD
    cpfseq  d2, A
    bra	    Decode_6_2
    movlw   '5'
    movwf   INDF0
    incf    FSR0
    retlw   5
    
Decode_6_2:
    movlw   0xDB
    cpfseq  d2, A
    bra	    Decode_7_2
    movlw   '6'
    movwf   INDF0
    incf    FSR0
    retlw   6
    
Decode_7_2:
    movlw   0xBE
    cpfseq  d2, A
    bra	    Decode_8_2
    movlw   '7'
    movwf   INDF0
    incf    FSR0
    retlw   7
    
Decode_8_2:
    movlw   0xBD
    cpfseq  d2, A
    bra	    Decode_B_2
    movlw   '8'
    movwf   INDF0
    incf    FSR0
    retlw   8
    
Decode_B_2:
    movlw   0x7B
    cpfseq  d2, A
    bra	    Decode_9_2
    call    Shift_Left			; backspace = shift cursor left and 
					; print a space 
    movlw   ' '
    movwf   FSR2
    movlw   1
    call   LCD_Write_Message
    bra    Input_1
    
Decode_9_2:
    movlw   0xBB
    cpfseq  d2, A
    retlw   0xFF
    movlw   '9'
    movwf   INDF0
    incf    FSR0
    retlw   9

  