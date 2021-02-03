#include <xc.inc>

extrn	DAC_Setup, DAC_Int_Hi

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DAC_Int_Hi
	
start:	call	DAC_Setup
	goto	$	; Sit in infinite loop

	end	rst
