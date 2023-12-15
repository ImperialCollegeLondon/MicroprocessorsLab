#include <xc.inc>
    
global	Heart_Rate_Zone_Msg, Heart_Rate_Msg, Welcome_Msg

extrn	hr_msg, hrz_msg, welcome_msg
    
psect	Messages, class = CODE

Heart_Rate_Msg:
	movlw   hr_msg
	movwf   FSR0

	movlw   'H'
	movwf   INDF0
	incf    FSR0
	movlw   'e'
	movwf   INDF0
	incf    FSR0
	movlw   'a'
	movwf   INDF0
	incf    FSR0
	movlw   'r'
	movwf   INDF0
	incf    FSR0
	movlw   't'
	movwf   INDF0
	incf    FSR0
	movlw   ' '
	movwf   INDF0
	incf    FSR0
	movlw   'R'
	movwf   INDF0
	incf    FSR0
	movlw   'a'
	movwf   INDF0
	incf    FSR0
	movlw   't'
	movwf   INDF0
	incf    FSR0
	movlw   'e'
	movwf   INDF0
	incf    FSR0
	movlw   ':'
	movwf   INDF0
	incf    FSR0
	return
	
Heart_Rate_Zone_Msg:
	movlw   hrz_msg
	movwf   FSR0

	movlw   'Z'
	movwf   INDF0
	incf    FSR0
	movlw   'o'
	movwf   INDF0
	incf    FSR0
	movlw   'n'
	movwf   INDF0
	incf    FSR0
	movlw   'e'
	movwf   INDF0
	incf    FSR0
	movlw   ':'
	movwf   INDF0
	incf    FSR0
	return

Welcome_Msg:
	movlw   welcome_msg
	movwf   FSR0

	movlw   'I'
	movwf   INDF0
	incf    FSR0
	movlw   'n'
	movwf   INDF0
	incf    FSR0
	movlw   'p'
	movwf   INDF0
	incf    FSR0
	movlw   'u'
	movwf   INDF0
	incf    FSR0
	movlw   't'
	movwf   INDF0
	incf    FSR0
	movlw   ' '
	movwf   INDF0
	incf    FSR0
	movlw   'A'
	movwf   INDF0
	incf    FSR0
	movlw   'g'
	movwf   INDF0
	incf    FSR0
	movlw   'e'
	movwf   INDF0
	incf    FSR0
	movlw   ':'
	movwf   INDF0
	incf    FSR0
	return


