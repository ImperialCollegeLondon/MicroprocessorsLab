#include <xc.inc>

extrn CiphertextArray, PlaintextArray, TableLength, counter_pt, LCD_Send_Byte_D
global print_plaintext, print_ciphertext
    
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
