#include <xc.inc>
   
global  RTCC_Setup, RTCC_Get_Seconds, RTCC_seconds, RTCC_minutes, RTCC_secondsL, RTCC_secondsH, ascii_low, ascii_high

psect udata_acs   ; reserve data space in access ram
RTCC_seconds: ds    1    ; reserve 1 byte for seconds
RTCC_minutes: ds    1    ; reserve 1 byte for minutes
RTCC_hours: ds    1    ; reserve 1 byte for hours
RTCC_secondsL:ds    1
RTCC_secondsH: ds   1
temp: ds    1
ascii_low: ds	1
ascii_high: ds	1
    
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
    movf    RTCVALH, W, B       ; Read Minutes
    call    DecodeBCD        ; Decode high and low nibbles into ASCII

    ;movf    RTCVALL, W, B       ; Read Seconds
    ;call    DecodeBCD        ; Decode high and low nibbles into ASCII
    movlb   0 ; reset BSR to 0
    return
    
DecodeBCD:
    movwf temp         ; Store BCD value
    swapf temp, W      ; Swap nibbles
    andlw 0x0F         ; Extract high nibble
    addlw 0x30         ; Convert to ASCII
    movwf ascii_high   ; Store high nibble ASCII
   
    movf temp, W       ; Get original BCD
    andlw 0x0F         ; Extract low nibble
    addlw 0x30         ; Convert to ASCII
    movwf ascii_low    ; Store low nibble ASCII
    return
    



