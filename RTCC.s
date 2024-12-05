#include <xc.inc>
    
global  RTCC_Setup, RTCC_Get_Seconds, RTCC_seconds
psect	udata_acs   ; reserve data space in access ram
RTCC_seconds: ds    1	    ; reserve 1 byte for variable UART_counter

psect	rtcc_code,class=CODE
    
START_SOSC:
    bsf	    OSCCON2,3
    
WAIT_SOSC_STABLE:
    btfss   OSCCON2,6
    goto    WAIT_SOSC_STABLE
    
    
RTCC_Setup:
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bcf	    RTSECSEL1	; RTSECSELx bits determine output on RTCC pin
    bsf	    RTSECSEL0	; 10 outputs the source clock, 01 outputs second count
    bsf	    RTCCFG,7
    bsf	    RTCCFG, 2
    movlw   0x84	; Enable RTCC, turn on RTCC output pin      
    movwf   RTCCFG, B
 
    
    movlb   0		; reset BSR to 0
    return

RTCC_Get_Seconds:	; Reads and stores seconds value in RTCC_Seconds
			; Also returns the value in W register
    banksel RTCCFG	; RTCC SFRs are not in access ram
    bcf	    RTCPTR1	; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf	    RTCPTR0
    movf    RTCVALL, W, B   ; Read seconds from RTCVALL
    movwf   RTCC_seconds, A ; Store value in RTCC_Seconds valriable space
    movlb   0		; reset BSR to 0
    return



