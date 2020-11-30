#include <xc.inc>

global  Storage_setup, Storage_start, Storage_read
    
psect	storage_code,class=CODE
Storage_setup:
    setf    TRISD
    banksel PADCFG1 
    bsf     REPU
    movlb   0x00
    clrf    TRISC, A
    movlw   0XFF
    movwf   PORTC, A
    OE1     EQU    1	    ; LOcation for the output register 1
    CP1     EQU    3	    ; LOcation for the clock control 1
    OE2     EQU    2	    ; LOcation for the output register 1
    CP2     EQU    4	    ; LOcation for the clock control 1
    movlw   0x4		    ; setting size of delay
    movwf   0x40, A		    ; Set the locaitons for the delay counter
    movff   0x40, 0x41	    ; sub delay file
    movff   0x40, 0x140	    ; reset coutner storage
    movff   0x40, 0x43
    movff   0x40, 0x44
    movlw   0x0
    call    Storage_start
    return

Storage_start: 
    movf    0x09, W, A          ; store 1st value to be stored
    call    write
    movlw   0x0 
    movwf   0x09
    movf    0x10, W, A		; store 2nd value to be stored
    call    write2
    movlw   0x0 
    movwf   0x10
    return
    
write:
    clrf    TRISD, A
    movwf   PORTD, A
    BCF     PORTC, CP1, A     ;lower the bit for the control pulse
    movff   0x21, 0x22, A
    call    Delay
    BSF     PORTC, CP1, A     ; here vlaue is written to the memory
    return

write2:
    clrf    TRISD, A
    movwf   PORTD, A
    BCF     PORTC, CP2, A     ;lower the bit for the control pulse
    movff   0x21, 0x22, A
    call    Delay
    BSF     PORTC, CP2, A     ; here vlaue is written to the memory
    return
    
Storage_read:		; 29 CLOCK cycles , excluding delyas
    movlw   0x0
    setf    TRISD, A            ; CHange the port e to input
    BCF     PORTC, OE1, A
    movff   0x140, 0x40
    call    Delay
    movff   PORTD, 0x50
    movff   0x140, 0x40
    call    Delay
    BSF	    PORTC, OE1, A
   
    movlw   0x0
    setf    TRISD, A            ; CHange the popprt e to input
    BCF     PORTC, OE2, A
    movff   0x140, 0x40
    call    Delay
    movff   PORTD, 0x51
    movff   0x140, 0x40
    call    Delay
    BSF	    PORTC, OE2, A
    return
    
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
    
    
   


