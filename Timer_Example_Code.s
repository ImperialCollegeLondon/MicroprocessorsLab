; Define your oscillator frequency
#define _XTAL_FREQ 4000000  ; Replace with your actual oscillator frequency

; Variable declarations
PREVIOUS_CAPTURE equ 0x20  ; Store the previous capture value

; Reset vector
ORG 0x00
GOTO Main

; High-Priority Interrupt Vectors
ORG 0x08
GOTO Timer1_ISR

; Main program
Main:
    ; Initialize
    BSF STATUS, RP0      ; Bank 1
    CLRF T1CON           ; Clear Timer1 control register
    CLRF TMR1H           ; Clear Timer1 high register
    CLRF TMR1L           ; Clear Timer1 low register
    CLRF PREVIOUS_CAPTURE ; Clear previous capture value
    BCF STATUS, RP0      ; Bank 0

    ; Configure Timer1 for capture mode
    BSF CCP1CON, CCP1M0  ; Set capture mode on rising edge, bit 0 = CCP1M0
    BSF CCP1CON, CCP1M1  ; Set capture mode on falling edge, bit 1 = CCP1M1
    BSF PIE3, 1		 ; Enable CCP1 interrupt, bit 1 = CCP1IE
    BSF PIR1, 1     ; Clear CCP1 interrupt flag, bit 1 = CCP1IF

    ; Configure interrupts
    BSF INTCON, 7      ; Enable global interrupts, bit 7 = GIE
    BSF INTCON, 6     ; Enable peripheral interrupts, bit 6 = PEIE

    ; Configure T1CKI pin as input (replace with the actual pin configuration)
    BCF TRISC, 0         ; Make T1CKI an input

    ; Configure Timer1 prescaler (adjust as needed)
    BSF T1CON, T1CKPS0   ; Set prescaler to 1:1, bit 5-4 = T1CKPS (customise for specific prescale value)

    ; Enable Timer1
    BSF T1CON, TMR1ON	; bit 0 = TMR1ON, set as 1 to enable Timer 1

    ; Main loop
MainLoop:
    ; Your main code goes here

    GOTO MainLoop

; Timer1 CCP1 interrupt service routine
Timer1_ISR:
    ; Read the captured time
    MOVF CCPR1H, W
    MOVWF PREVIOUS_CAPTURE + 1
    MOVF CCPR1L, W
    MOVWF PREVIOUS_CAPTURE

    ; Your ISR code goes here

    ; Clear CCP1 interrupt flag
    BCF PIR1, CCP1IF

    RETFIE


