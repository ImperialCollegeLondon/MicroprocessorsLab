#include <xc.inc>

extrn CiphertextArray, PlaintextArray, TableLength, counter_pt, LCD_Send_Byte_D
global print_plaintext, print_ciphertext, send_characters, copy_plaintext, PlaintextTable
    
psect	print_code,class=CODE

print_ciphertext:
    ; Load the start address of CiphertextArray into FSR0
    movlw   LOW(CiphertextArray)  
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray) 
    movwf   FSR0H, A

    movlw   TableLength    ; Load the number of characters
    movwf   counter_pt, A  ; Store in counter
    goto print_loop
    
print_plaintext:
    ; Load the start address of PlaintextArray into FSR0
    movlw   LOW(PlaintextArray)  
    movwf   FSR0L, A
    movlw   HIGH(PlaintextArray) 
    movwf   FSR0H, A

    movlw   TableLength    ; Load the number of characters to print
    movwf   counter_pt, A  ; Store in counter
    goto    print_loop 
   
print_loop:
    movf    counter_pt, W, A  

    movf    INDF0, W, A    ; Read a character from PlaintextArray
    call    LCD_Send_Byte_D ; Send it to the LCD

    incf    FSR0L, A       ; Move to the next character in PlaintextArray
    decfsz  counter_pt, A  
    bra     print_loop      ; Loop until all characters are printed
    return   

send_characters:
    movlw    LOW(PlaintextArray)  
    movwf    FSR0L, A
    movlw    HIGH(PlaintextArray) 
    movwf    FSR0H, A
    movlw    TableLength    ; Load the number of characters
    movwf    counter_pt, A  ; Store in counter
    
send_loop:
    movf    counter_pt, W, A  

    movf    INDF0, W, A    ; Read a character from PlaintextArray
    movwf   PORTD ; Send it to the LCD

    incf    FSR0L, A       ; Move to the next character in PlaintextArray
    decfsz  counter_pt, A  
    bra     send_loop      ; Loop until all characters are printed
    return

copy_plaintext:
	lfsr	0, PlaintextArray	; Load FSR0 with address in RAM	
	movlw	low highword(PlaintextTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(PlaintextTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(PlaintextTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_pt, A
	goto setup_loop
	
setup_loop:
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A
	decfsz	counter_pt, A		; count down to zero
	bra	setup_loop	; keep going until finished
	return

