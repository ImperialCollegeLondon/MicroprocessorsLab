#include <xc.inc>
   
global  RTCC_Setup, RTCC_Get_Seconds, RTCC_seconds, RTCC_minutes

psect udata_acs   ; reserve data space in access ram
RTCC_seconds: ds    1    ; reserve 1 byte for seconds
RTCC_minutes: ds    1    ; reserve 1 byte for minutes
RTCC_hours: ds    1    ; reserve 1 byte for hours
   
psect rtcc_code,class=CODE
RTCC_Setup:
    banksel RTCCFG ; RTCC SFRs are not in access ram
    bsf    RTSECSEL1 ; RTSECSELx bits determine output on RTCC pin
    bcf    RTSECSEL0 ; 10 outputs the source clock, 01 outputs second count
    movlw   0x84 ; Enable RTCC, turn on RTCC output pin      
    movwf   RTCCFG, B
    movlb   0 ; reset BSR to 0
    return

RTCC_Get_Seconds: ; Reads and stores seconds value in RTCC_Seconds
; Also returns the value in W register
    banksel RTCCFG ; RTCC SFRs are not in access ram
    ;read year (RTCPTR = 11)
    bcf    RTCPTR1 ; Clear RTCPTR1 and RTCPTR0 for seconds output
    bcf    RTCPTR0
    movf    RTCVALL, W, B   ; Read seconds from RTCVALL
    movwf   RTCC_seconds, A ; Store value in RTCC_Seconds variable space
    movf    RTCVALH, W, B   ; Read minutes from RTCVALH
    movwf   RTCC_minutes, A ; Store value in RTCC_Minutes variable space
    movlb   0 ; reset BSR to 0
    return


