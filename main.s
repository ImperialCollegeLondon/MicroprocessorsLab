#include <xc.inc>

extrn	init_phase_accum, init_timer, update_phase, output_waveform, phase_jump
	
;===================================MAIN====================================
psect	code, abs
org 0x0000
    goto main      ; Ensure proper startup handling

org 0x0008
    goto int_service   ; Define interrupt vector

main:
    call    init_phase_accum
    call    init_timer
    bsf     INTCON, 7,	A   ; Bit 7 in INTCON is GIE
    goto    $
;===================================ISR====================================
int_service:
    btfsc  PIR1, 0, A	    ; Bit 0 of PIR1 is TMR1IF
    goto   handle_timer1
    retfie		    ; Return if it wasn?t Timer1

handle_timer1:
    bcf    PIR1, 0, A	    ; Clear Timer1 interrupt flag
    call   update_phase
    call   output_waveform
    retfie

    end main