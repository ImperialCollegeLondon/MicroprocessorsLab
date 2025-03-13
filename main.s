	#include <xc.inc>

extrn	init_phase_accum, init_timer, int_service, phase_jump
	
;===================================MAIN====================================
psect	code, abs
main:
    org	0x0
    goto init

init:
    call    init_phase_accum
    call    init_timer
    call    main_loop

main_loop:
    goto    main_loop    ; Infinite loop, processing happens in ISR