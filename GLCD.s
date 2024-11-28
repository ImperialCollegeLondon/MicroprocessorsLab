#include <xc.inc>    

; Define global variables
;AN0RES      res     2       ; Variable to store ADC result (16-bit)
;Temperature res     2       ; Temperature result in float (approximate in integer)
;Voltage     res     2       ; Voltage result in float (approximate in integer)
psect	udata_acs
GLCD_cnt_ms:	    ds 1
GLCD_tmp:	    ds 1
    
; GLCD Control Pins (Assuming connected to PORTB or PORTD)
; You can configure these depending on your wiring
GLCD_RS     EQU	    0x01    ; RS pin for GLCD (example RD0)
GLCD_RW     equ     0x02    ; RW pin for GLCD (example RD1)
GLCD_EN     equ	    0x04    ; EN pin for GLCD (example RD2)
GLCD_CS1    equ     0x08    ; Chip Select 1 for GLCD (example RD3)
GLCD_CS2    equ     0x10    ; Chip Select 2 for GLCD (example RD4)
GLCD_RST    equ     0x20    ; Reset pin for GLCD (example RD5)

; LCD Command for GLCD
GLCD_CMD    equ     0x00    ; GLCD Command register address (use 8-bit commands)

; Initialize the microcontroller: set TRIS registers for input/output
INIT:
    ; Initialize GPIO (PORTD or PORTB for GLCD)
;    bcf     STATUS, RP0           ; Select Bank 0 (access GPIO registers)
;    movlw   0x00                  ; Set RD0-RD7 (or RB0-RB7) as output for GLCD control and data pins
;    tris    PORTD

    ; Initialize ADC
    ;call    ADC_Init              ; Initialize ADC for LM35
    call    GLCD_Init             ; Initialize GLCD
    return

; GLCD Initialization Routine
GLCD_Init:
    ; Initialize the GLCD (assuming 128x64 GLCD and control via 8-bit data lines)
    ; Reset GLCD
    ;bcf	    PORTD, GLCD_RST, A	  ; Set GLCD reset pin high
    ;call    Delay_ms          ; Wait for 10ms
    ;bsf     PORTD, GLCD_RST, A       ; Set GLCD reset pin low
    ;call    Delay_ms          ; Wait for 10ms
    
    clrf    LATD, A
    ;bcf	    LATD, GLCD_CS1, A
    ;bcf	    LATD, GLCD_CS2, A
    
    ; Send initialization commands to the GLCD
    
    ;call    Delay_ms
    movlw   00111110B
    call    GLCD_SendCommand	    ; Display OFF
    ;call    Delay_ms		    ; Delay
    movlw   11000000B		    ; Display start line
    call    GLCD_SendCommand
    ;call    Delay_ms
    movlw   10111000B
    call    GLCD_SendCommand	    ; Set x address to 0
    ;call    Delay_ms
    movlw   01000000B
    call    GLCD_SendCommand	    ; Set y address to 0
    ;call    Delay_ms
    movlw   00011111B
    call    GLCD_SendCommand	    ;Display ON 
    
    return

; GLCD Command Sending Routine
GLCD_SendCommand:
    bcf	    LATD, GLCD_RS, A
    call    GLCD_Enable
    
	return
    

; GLCD Data Sending Routine
;GLCD_SendData:
    ;movf    GLCD_CMD, w
    ;bcf     STATUS, RP0            ; Select Bank 0
    ;bsf     GLCD_RS                ; RS = 1 (Data mode)
    ;bcf     GLCD_RW                ; RW = 0 (Write mode)
    ;bsf     GLCD_EN                ; Enable GLCD
    ;movwf   PORTD                  ; Send data to GLCD
    ;bcf     GLCD_EN                ; Disable GLCD
    ;return

; Delay Function (in ms)
Delay_ms:
    movlw   250                    ; Load delay value
DelayLoop:
    decfsz  WREG, A
    goto    DelayLoop
    return

GLCD_Enable:
    	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATD, GLCD_EN, A	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATD, GLCD_EN, A	    ; Writes data to LCD
	return

; ADC Initialization Routine
;ADC_Init:
    ; Set up ADCON0 and ADCON1 for PIC18F87K22
    ; Configure the ADC to read from AN0 (Channel 0)
    ;bcf     STATUS, RP0            ; Select Bank 0 (for ADC registers)
    ;movlw   0x01                   ; ADCON0: 0x01 (Enable ADC, AN0 selected)
    ;movwf   ADCON0
    ;movlw   0x80                   ; ADCON1: 0x80 (right justify result)
    ;movwf   ADCON1
    ;return

; ADC Read Routine
;ADC_Read:
    ; Clear the ADC channel select bits
    ;movf    ANC, w
    ;movwf   temp1
    ;bcf     ADCON0, 3              ; Clear channel select bit
    ;bcf     ADCON0, 2
    ;bcf     ADCON0, 1
    ;bcf     ADCON0, 0
    ; Set the channel number
    ;movlw   temp1
    ;addwf   ADCON0, f             ; Set ADC channel
    ; Wait for conversion to complete
    ;bsf     ADCON0, GO_DONE       ; Start conversion
    ;wait_adc_done:
        ;btfsc   ADCON0, GO_DONE    ; Wait until conversion is done
        ;goto    wait_adc_done
    ; Return ADC result (10-bit)
    ;movf    ADRESH, w
    ;movwf   temp1                  ; Store high byte of result
    ;movf    ADRESL, w
    ;movwf   temp1                  ; Store low byte of result
    ;return

; Main Loop
;MainLoop:
    ; Read ADC value from Channel 0 (AN0)
    ;call    ADC_Read               ; Read ADC value from channel 0 (AN0)
    ; Calculate the Voltage and Temperature (simplified for assembly)
    ; Voltage = ADC_Value * (5.0 / 1024) ~ approximated as ADC_Value * 5 / 1024

    ; Convert Voltage to Temperature (Assuming 10mV per degree for LM35)
    ; Example: Temperature = (ADC_Value * 5 / 1024) / 0.01

    ; Display the Temperature on GLCD
    ; You can draw temperature as pixels, or display it in text form.
    ; Here we will assume a function to draw text or numbers.

    ; Display on GLCD (e.g., print the temperature value)
    ;call    GLCD_DrawText, "Temp: 25C"   ; Assuming a simplified routine for displaying text
    
    ;goto    MainLoop                  ; Loop forever

; Example routine to draw text on GLCD
;GLCD_DrawText:
    ; You would write your logic here to draw characters on the GLCD.
    ; This can involve sending the pixel data for each character.
    ;return


