#include <xc.inc>
    
global	Input_Angle
extrn	inputangle
    
psect Messages, class = CODE
 
Input_Angle: 
	movlw	inputangle
	movwf	FSR0
	
	movlw	'I'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'n'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'p'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'u'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	't'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	''
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'A'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'n'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'g'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'l'
	movwf	INDF0
	incf	FSR0, F
	
	movlw	'e'
	movwf	INDF0
	incf	FSR0, F
	
	return 

