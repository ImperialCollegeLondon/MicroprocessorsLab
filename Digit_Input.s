#include <xc.inc>
    
global	User_Input_Setup, Press_Clear
extrn	Keypad_Read
extrn	LCD_Write_Message, LCD_Clear, Second_Line, Shift_Left
extrn	input_address_1, input_address_2, delay_ms, start
;extrn	cordic_loop
    
psect	udata_acs		    ; reserve data space in access ram
digit_counter:	ds 1
d1:		ds 1
d2:		ds 1
input_1:	ds 1
input_2:	ds 1
before_dec:	ds 1
enter:		ds 1
clear:		ds 1
    
    
psect	udata_bank4		    ; reserve data anywhere in RAM
myArray:    ds 0x80
    
psect input_code, class=CODE
    
User_Input_Setup:
	Input_1:
	    call	User_Input_1	; Input first digit
	
	Input_2:
	    call	User_Input_2	; Input second digit 
	
Add_Input:
    movff	input_1, WREG	    ; adding together the two digits to
				    ; create one 8 bit number
    addwf	input_2, W
    movwf	before_dec

    call	delay_ms
    call	delay_ms
    call	delay_ms

Press_Enter:			    ; Checks to see if E button pressed
    call	Keypad_Read
    call	Decode_Enter
    movwf	enter

    movlw	0xFF
    call	delay_ms

    movlw	0xFF
    cpfslt	enter
    bra		Press_Enter

    call	LCD_Clear	   ; Clear screen 
    ;call	cordic_loop	   ; Calculate cosine and sine values 

return
	
Press_Clear:			   ; Checks to see if C button pressed
    call    Keypad_Read
    call    Decode_Clear
    movwf   clear
    
    movlw   0xFF
    call    delay_ms
    
    movlw   0xFF
    cpfslt  clear
    bra	    Press_Clear
    
    call    LCD_Clear		    ; Clear Screen 
    
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
    bra		User_Input_1	    ; repeat if valid button not pressed

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

    movlw	0x7B
    cpfseq	input_2
    bra		No_Backspace
    goto	Backspace

    No_Backspace:
    movlw	0xFF
    cpfslt	input_2		    ; Checks for valid input 
    bra		User_Input_2	    ; repeat if valid button not pressed

    movlw	input_address_2
    movwf	FSR2
    movlw	1
    call	LCD_Write_Message 

    return 
	
Backspace:
    call    Shift_Left			; backspace = shift cursor left and 
					    ; print a space 
    movlw   'N'
    
    movwf   FSR2
    movlw   1
    call    LCD_Write_Message
    goto    Input_1

Decode_Input_1:
    movwf   d1, A
    
    Error_Check_1:
	movlw   0xFF		    
	cpfseq  d1, A
	bra	Decode_0_1
	retlw   0xFF

    Decode_0_1:
	movlw   0x7D
	cpfseq  d1, A
	bra	Decode_1_1
	movlw   '0'	    
	movwf   INDF0
	incf    FSR0
	retlw   0

    Decode_1_1:
	movlw   0xEE
	cpfseq  d1, A
	bra	Decode_2_1
	movlw   '1'
	movwf   INDF0
	incf    FSR0
	retlw   10			   ; stores first digit as tens 

    Decode_2_1:
	movlw   0xED
	cpfseq  d1, A
	bra	Decode_3_1
	movlw   '2'
	movwf   INDF0
	incf    FSR0
	retlw   20

    Decode_3_1:
	movlw   0xEB
	cpfseq  d1, A
	bra	Decode_4_1
	movlw   '3'
	movwf   INDF0
	incf    FSR0
	retlw   30

    Decode_4_1:
	movlw   0xDE
	cpfseq  d1, A
	bra	Decode_5_1
	movlw   '4'
	movwf   INDF0
	incf    FSR0
	retlw   40

    Decode_5_1:
	movlw   0xDD
	cpfseq  d1, A
	bra	Decode_6_1
	movlw   '5'
	movwf   INDF0
	incf    FSR0
	retlw   50

    Decode_6_1:
	movlw   0xDB
	cpfseq  d1, A
	bra	Decode_7_1
	movlw   '6'
	movwf   INDF0
	incf    FSR0
	retlw   60

    Decode_7_1:
	movlw   0xBE
	cpfseq  d1, A
	bra	Decode_8_1
	movlw   '7'
	movwf   INDF0
	incf    FSR0
	retlw   70

    Decode_8_1:
	movlw   0xBD
	cpfseq  d1, A
	bra	Decode_9_1
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
	bra	Decode_0_2
	retlw   0xFF

    Decode_0_2:
	movlw   0x7D
	cpfseq  d2, A
	bra	Decode_1_2
	movlw   '0'
	movwf   INDF0
	incf    FSR0
	retlw   0

    Decode_1_2:
	movlw   0xEE
	cpfseq  d2, A
	bra	Decode_2_2
	movlw   '1'
	movwf   INDF0
	incf    FSR0
	retlw   1				; stores second digit as units 			

    Decode_2_2:
	movlw   0xED
	cpfseq  d2, A
	bra	Decode_3_2
	movlw   '2'
	movwf   INDF0
	incf    FSR0
	retlw   2

    Decode_3_2:
	movlw   0xEB
	cpfseq  d2, A
	bra	Decode_4_2
	movlw   '3'
	movwf   INDF0
	incf    FSR0
	retlw   3

    Decode_4_2:
	movlw   0xDE
	cpfseq  d2, A
	bra	Decode_5_2
	movlw   '4'
	movwf   INDF0
	incf    FSR0
	retlw   4

    Decode_5_2:
	movlw   0xDD
	cpfseq  d2, A
	bra	Decode_6_2
	movlw   '5'
	movwf   INDF0
	incf    FSR0
	retlw   5

    Decode_6_2:
	movlw   0xDB
	cpfseq  d2, A
	bra	Decode_7_2
	movlw   '6'
	movwf   INDF0
	incf    FSR0
	retlw   6

    Decode_7_2:
	movlw   0xBE
	cpfseq  d2, A
	bra	Decode_8_2
	movlw   '7'
	movwf   INDF0
	incf    FSR0
	retlw   7

    Decode_8_2:
	movlw   0xBD
	cpfseq  d2, A
	bra	Decode_B_2
	movlw   '8'
	movwf   INDF0
	incf    FSR0
	retlw   8

    Decode_B_2:
	movlw   0x7B
	cpfseq  d2, A
	bra	Decode_9_2
	retlw	0x7B

    Decode_9_2:
	movlw   0xBB
	cpfseq  d2, A
	retlw   0xFF
	movlw   '9'
	movwf   INDF0
	incf    FSR0
	retlw   9
    
    
Decode_Enter:
    movwf   enter, A
    
    Error_Check_E:
	movlw   0xFF		    
	cpfseq  enter, A
	bra	Decode_E
	retlw   0xFF
  
    Decode_E:
	movlw   0xD7
	cpfseq  enter, A
	retlw	0xFF
	return 
	
Decode_Clear:
    movwf   clear, A
    
    Error_Check_C:
	movlw	0xFF
	cpfseq	clear, A
	bra	Decode_C
	retlw	0xFF

    Decode_C:
	movlw	0x77
	cpfseq	clear, A
	retlw	0xFF
	return