#include <xc.inc>
    
global	Find_Max_Heart_Rate
    
; this includes subroutines for calculations: e.g. max heart rate calculation, boundary calculations

Find_Max_Heart_Rate:
    sublw	220	; subtract age from 220 to find the maximum heart rate, store in WREG
    return	
