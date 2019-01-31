	#include p18f87k22.inc

	extern	DAC_Setup
	
rst	code	0x0000	; reset vector
	goto	start

main	code
start	call	DAC_Setup
	goto	$		; Sit in infinite loop

	end
