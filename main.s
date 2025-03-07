
#include <xc.inc>

extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
    
psect	udata_acs   ; reserve data space in access ram
counter_pt:	ds 1    ; counter for printing the initial data
counter_ec:	ds 1	; encoding counter
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:    ds 0x80 ; reserve 128 bytes for message data
CiphertextArray:    ds 0x80 ; reserve 128 bytes for modified message data

    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
PlaintextTable:
	db	'P','l','a','i','n','t','e','x','t'
					
	TableLength   EQU	9	
	align	2
	
psect	code, abs
rst:	org 0x0
	goto setup
	
	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	movlw	0x00
	movwf	TRISH, A
	movlw	0x00
	movwf	PORTH, A
	goto	start

start:
	
	call	print_plaintext		; print the plaintext
	movlw   0xC0        ; Move the cursor to the second line (or wherever needed)
	call    LCD_Send_Byte_I

	movlw	0xFF	    ; allow time for cursor to move
	call	LCD_delay_ms
	
	call modify_table        ; Modify the ciphertext array
	call print_ciphertext    ; Print the modified data to the LCD
	
	movlw	0xFF
	call	LCD_delay_ms
	movlw	0xFF
	call	LCD_delay_ms
	movlw	0xFF
	call	LCD_delay_ms
	movlw	0xFF
	call	LCD_delay_ms
	
	goto	ending

modify_table:
    movlw   LOW(PlaintextArray)  ; Load low byte of PlaintextArray address
    movwf   FSR1L, A
    movlw   HIGH(PlaintextArray) ; Load high byte of PlaintextArray address
    movwf   FSR1H, A

    movlw   LOW(CiphertextArray) ; Load low byte of CiphertextArray address
    movwf   FSR0L, A
    movlw   HIGH(CiphertextArray); Load high byte of CiphertextArray address
    movwf   FSR0H, A

    movlw   TableLength          ; Load the number of characters to process
    movwf   counter_ec, A        ; Store in counter_ec

    goto    modify_loop          ; Start modification

modify_loop:
    movf    counter_ec, W, A     ; Check if counter is zero
    bz      modify_done          ; If zero, we are done

    movf    INDF1, W, A          ; Read character from PlaintextArray
    movwf   INDF0, A             ; Write character to CiphertextArray

    incf    FSR1L, A             ; Increment FSR1 (next character in PlaintextArray)
    incf    FSR0L, A             ; Increment FSR0 (next character in CiphertextArray)

    decfsz  counter_ec, A        ; Decrement counter and check if done
    bra     modify_loop          ; Loop again if not finished

modify_done:
    return
    
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
    bz      print_done      ; If counter is zero, we're done

    movf    INDF0, W, A    ; Read a character from PlaintextArray
    call    LCD_Send_Byte_D ; Send it to the LCD

    incf    FSR0L, A       ; Move to the next character in PlaintextArray
    decfsz  counter_pt, A  
    bra     print_loop      ; Loop until all characters are printed
    goto    print_done

print_done:
    return

ending:
    nop
    
    end rst
    
	
