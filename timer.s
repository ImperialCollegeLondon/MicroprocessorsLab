#include <xc.inc>
    
global measure_modify_table
extrn modify_table, timer_low, timer_high

psect	timer_code,class=CODE
measure_modify_table:
	; Step 1: Reset Timer1
	clrf    TMR1H, A     ; Clear Timer1 High Byte
	clrf    TMR1L, A     ; Clear Timer1 Low Byte

	; Step 2: Configure Timer1
	movlw   0b00000001   ; Configure Timer1: Enable, No Prescaler, Fosc/4
	movwf   T1CON, A     ; Enable Timer1

	; Step 3: Call modify_table
	call    modify_table  ; Execute the function being measured

	; Step 4: Stop Timer1
	bcf     T1CON, 0, A     ; Disable Timer1 to freeze count

	; Step 5: Read Timer1 value and store it
	movf    TMR1L, W, A   ; Read low byte of Timer1
	movwf   timer_low, A  ; Store in timer_low
	movf    TMR1H, W, A   ; Read high byte of Timer1
	movwf   timer_high, A ; Store in timer_high

	return
