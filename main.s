#include <xc.inc>

extrn	Phase_Setup, Timer_Setup, Lookup_Setup, DDS_Int_Hi

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	Start

Int_Hi:	org	0x0008	; high vector, no low vector
	goto	DDS_Int_Hi
	
Start:	call	Phase_Setup
	call	Timer_Setup
	call	Lookup_Setup
	goto	$	; Sit in infinite loop

    end	    rst
