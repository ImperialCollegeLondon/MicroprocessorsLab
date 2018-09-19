#include p18f87k22.inc

    global  UART_Setup, UART_Transmit_Message

acs0    udata_acs	    ; named variables in access ram
UART_counter res 1	    ; reserve 1 byte for variable UART_counter

UART    code
    
UART_Setup
    bsf	    RCSTA1, SPEN    ; enable
    bcf	    TXSTA1, SYNC    ; synchronous
    bcf	    TXSTA1, BRGH    ; slow speed
    bsf	    TXSTA1, TXEN    ; enable transmit
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only
    movlw   .103	    ; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1
    bsf	    TRISC, TX1	    ; TX1 pin as output
    return

UART_Transmit_Message	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter
UART_Loop_message
    movf    POSTINC2, W
    call    UART_Transmit_Byte
    decfsz  UART_counter
    bra	    UART_Loop_message
    return

UART_Transmit_Byte	    ; Transmits byte stored in W
    btfss   PIR1,TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1
    return

    end


