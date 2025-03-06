CONFIG  XINST = OFF           ; Extended Instruction Set (Disabled)
#include <xc.inc>

extrn LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Send_Byte_I, LCD_delay_ms, LCD_Send_Byte_D
    
psect	udata_acs   ; reserve data space in access ram
counter_pt:	ds 1    ; counter for printing the initial data
counter_ec:	ds 1	; encoding counter
next_address:    ds 1	; store the nex adrdress to write to
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
PlaintextArray:    ds 0x80 ; reserve 128 bytes for message data
CiphertextArray:    ds 0x80 ; reserve 128 bytes for modified message data

    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
PlaintextTable:
	db	'P','l','a','i','n','t','e','x','t'
					
	TableLength   EQU	9	
	align	2
    
CiphertextTable:
	db	'a','a','a', 'a','a','a','a','a','a'
	align	2
	
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
	call	setup_plaintext		; our counter register
	call	print_message
	
	movlw	0x4F
	call	LCD_delay_ms
	
	call    modify_table     
	call	setup_ciphertext
    	call	print_message
	
	movlw	0x4F
	call	LCD_delay_ms
	
	goto	ending
	
setup_plaintext:
	lfsr	0, PlaintextArray	; Load FSR0 with address in RAM	
	movlw	low highword(PlaintextTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(PlaintextTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(PlaintextTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_pt, A
	return
	
setup_ciphertext:
	lfsr	0, CiphertextArray	; Load FSR0 with address in RAM	
	movlw	low highword(CiphertextTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(CiphertextTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(CiphertextTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	TableLength	; bytes to read
	movwf 	counter_pt, A
	return
		
print_message: 	
    	movlw	0x01
	movwf	PORTH, A
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	movf	TABLAT, W, A

	call	LCD_Send_Byte_D
	movlw	0x00
	movwf	PORTH, A
	decfsz	counter_pt, A		; count down to zero
	bra	print_message	; keep going until finished
	
	movlw	0xC0
	call LCD_Send_Byte_I
	return
	
;modify_table:
;	movf CiphertextArray, W, A
;	movwf next_address, A
;	call setup_plaintext
;	
;	goto modify_loop
   
;modify_loop:
;	
;	tblrd*+			    ; one byte from PM to TABLAT, increment TBLPRT
;	movff	TABLAT, POSTINC0    ; move data from TABLAT to (FSR0), inc FSR0	
;	movf	TABLAT, W, A
;	movwf	next_address, A
;	incf	next_address, A
;	decfsz	counter_pt, A
;	bra modify_loop
;	
;	return
	
modify_table:
    call setup_ciphertext

modify_loop:
    tblrd*+              
    movff   TABLAT, POSTINC0
    movf    POSTINC0, W    
    movwf   TABLAT         
    tblwt*+                
    decfsz counter_ec, f   ; Decrement modification counter
    bra modify_loop         ; Continue loop if not done

    return


ending:
    nop
end
    
	
