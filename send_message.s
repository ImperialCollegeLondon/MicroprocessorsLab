#include <xc.inc>
    
global send_characters, send_loop
extrn PlaintextArray, TableLength, counter_pt
    
    
psect send_code,class=CODE
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


