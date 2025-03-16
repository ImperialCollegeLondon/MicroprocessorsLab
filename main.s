#include <xc.inc>

extrn	Phase_Setup, Timer_Setup, Lookup_Setup, DDS_Int_Hi

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	DDS_Int_Hi
	
start:	call	Phase_Setup
	call	Timer_Setup
	call	Lookup_Setup
	goto	$	; Sit in infinite loop

	end	rst
