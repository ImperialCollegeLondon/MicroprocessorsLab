#include <xc.inc>

global  keypad_setup, keypad_start   
    
psect	keypad_code,class=CODE
	
main:
	org	0x0
	goto	keypad_setup
	org	0x100		    ; Main code starts here at address 0x100

keypad_setup:
	setf	TRISE	
	banksel	PADCFG1		; set the pull-ups to on for PORTE (not access)

	clrf	LATE
	movlb	0x00
	movlw	0x4
	movwf	0x30
	movwf	0x31
	movlw   0x20		    ; setting size of delay
	movwf   0x40, A		    ; Set the locaitons for the delay counter
	movff   0x40, 0x41	    ; sub delay file
	movff   0x40, 0x140	    ; reset coutner storage
	movff   0x40, 0x43
	movff   0x40, 0x44
	row_value   EQU	    0x0
	column_value	EQU	0x0
	call keypad_start
	return
	
myTable: 
    db    1, 2, 3, 'F', 4, 5, 6, 'E', 7, 8, 9, 'D', 'A', 0, 'B', 'C' 
    myKeypad EQU 0x400    ; Address in RAM for data
    counter EQU 0x8    ; Address of counter variable	

keypad_start:
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	call row
	call column
	
	movlw	0x00
	movwf	PORTE, A
	
	movlw	1
	subwf	0x35
	call	get_position
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	
	lfsr     1, myKeypad    ; Load FSR0 with address in RAM
	movlw    low highword(myTable)    ; address of data in PM
	movwf    TBLPTRU, A    ; load upper bits to TBLPTRU
	movlw    high(myTable)    ; address of data in PM
	movwf    TBLPTRH, A    ; load high byte to TBLPTRH
	movlw    low(myTable)    ; address of data in PM
	movwf    TBLPTRL, A    ; load low byte to TBLPTRL
	movf	 0x33, W        ; 22 bytes to read
	movwf     counter, A    ; our counter register
	call loop
	
	movlw	0x00
	movwf	TRISH, A
	movff   TABLAT, PORTH
	
	return
	
loop:
    tblrd*+			 ; move one byte from PM to TABLAT, increment TBLPRT
    movff   TABLAT,  POSTINC1    ; move read data from TABLAT to (FSR0), increment FSR0
    decfsz    counter, A    ; count down to zero
    bra    loop        ; keep going until finished
    return
	

get_position:
	movlw	4
	mulwf	0x35, A
	movff	PRODL, 0x33
	movf	0x33, W
	addwf	0x36
	movff	0x36, 0x33
	
	return    
    
row:
	movlw	0x0F
	movwf	TRISE, A
	movlw	0xF0	    
	movff   0x140, 0x40			; reset delay counter
	call    Delay				; call delay function
	movwf	PORTE, A
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	subwf	PORTE, W, A
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	movwf	0x20, A	    ; holds the row key
	
	goto	row_test1
	
row1:
	movlw	0x00
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	return
    

row_test1:
	movlw	1
	cpfseq	0x20, A
	goto	row_test2
	movlw	4
	movff   0x140, 0x40			; reset delay counter
	call    Delay
	movwf	0x35
	bra row1
	
row_test2:
	movlw	2
	cpfseq	0x20, A
	goto	row_test3
	movlw	3
	movff   0x140, 0x40			; reset delay counter
	call    Delay
	movwf	0x35
	bra row1
	
row_test3:
	movlw	4
	cpfseq	0x20, A
	goto	row_test4
	movlw	2
	movff   0x140, 0x40			; reset delay counter
	call    Delay
	movwf	0x35
	bra row1
	
row_test4:
	movlw	1
	movff   0x140, 0x40			; reset delay counter
	call    Delay
	movwf	0x35
	bra row1
	
	
column:
	movlw	0xF0
	movwf	TRISE, A
	movlw	0x0F
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	movwf	PORTE, A
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	subwf	PORTE, W, A
	movff   0x140, 0x40			; reset delay counter
	call    Delay	
	movwf	0x21, A	    ; holds the column key
	
	goto	column_test1
	
column1:
	movlw	0x00
	movff   0x42, 0x40			; reset delay counter
	call    Delay	
	return
    

column_test1:
	movlw	16
	cpfseq	0x21, A
	goto	column_test2
	movlw	4
	movwf	0x36
	bra column1
	
column_test2:
	movlw	32
	cpfseq	0x21, A
	goto	column_test3
	movlw	3
	movwf	0x36
	bra column1
	
column_test3:
	movlw	64
	cpfseq	0x21, A
	goto	column_test4
	movlw	2
	movwf	0x36
	bra column1
	
column_test4:
	movlw	1
	movwf	0x36
	bra column1


Delay: 
    movff   0x140, 0x41
    call    Delay2
    decfsz  0x40, A
    bra     Delay
    return
    
Delay2: 
    movff   0x140, 0x43
    call Delay3
    decfsz  0x41, A
    bra     Delay2
    return
    
Delay3: 
    movff   0x140, 0x44
    call    Delay4
    decfsz  0x43, A
    bra     Delay3
    return
    
Delay4: 
    decfsz  0x44, A
    bra     Delay4
    return
    