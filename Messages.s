#include <xc.inc>
    
global	Input_Angle, Sine_Msg, Cosine_Msg
extrn	inputangle, sine, cosine
    
psect Messages, class = CODE
 
Input_Angle: 
	movlw	inputangle
	movwf	FSR0	; points to start of message
	
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
	
	movlw	' '
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
	
	movlw	':'
	movwf	INDF0
	
	return 
	
Cosine_Msg:
    movlw   cosine
    movwf   FSR0
    
    movlw   'C'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'o'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   's'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'i'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'n'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'e'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   ':'
    movwf   INDF0
    
    return 
    
Sine_Msg:
    movlw   sine
    movwf   FSR0
    
    movlw   'S'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'i'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'n'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   'e'
    movwf   INDF0
    incf    FSR0, F
    
    movlw   ':'
    movwf   INDF0
    
    return 

