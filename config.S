; PIC18F87K22 Configuration Bit Settings

; Assembly source line config statements

#include <xc.inc>

; CONFIG1L
  CONFIG  RETEN = ON            ; VREG Sleep Enable bit (Enabled)
  CONFIG  INTOSCSEL = HIGH      ; LF-INTOSC Low-power Enable bit (LF-INTOSC in High-power mode during Sleep)
  CONFIG  SOSCSEL = DIG         ; SOSC Power Selection and mode Configuration bits (Digital IO selected)
  CONFIG  XINST = OFF           ; Extended Instruction Set (Disabled)

; CONFIG1H
  CONFIG  FOSC = HS1            ; Oscillator (HS oscillator (Medium power, 4 MHz - 16 MHz))
  CONFIG  PLLCFG = ON           ; PLL x4 Enable bit (Enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor (Disabled)
  CONFIG  IESO = OFF            ; Internal External Oscillator Switch Over Mode (Disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power Up Timer (Disabled)
  CONFIG  BOREN = SBORDIS       ; Brown Out Detect (Enabled in hardware, SBOREN disabled)
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (1.8V)
  CONFIG  BORPWR = ZPBORMV      ; BORMV Power level (ZPBORMV instead of BORMV is selected)

; CONFIG2H
  CONFIG  WDTEN = OFF	        ; Watchdog Timer (WDT enabled in hardware; SWDTEN bit disabled)
  CONFIG  WDTPS = 1048576       ; Watchdog Postscaler (1:1048576)

; CONFIG3L
  CONFIG  RTCOSC = SOSCREF      ; RTCC Clock Select (RTCC uses SOSC)
  CONFIG  EASHFT = ON           ; External Address Shift bit (Address Shifting enabled)
  CONFIG  ABW = MM              ; Address Bus Width Select bits (8-bit address bus)
  CONFIG  BW = 16               ; Data Bus Width (16-bit external bus mode)
  CONFIG  WAIT = OFF            ; External Bus Wait (Disabled)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 Mux (RC1)
  CONFIG  ECCPMX = PORTE        ; ECCP Mux (Enhanced CCP1/3 [P1B/P1C/P3B/P3C] muxed with RE6/RE5/RE4/RE3)
  CONFIG  MSSPMSK = 0        ; MSSP address masking (7 Bit address masking mode)
  CONFIG  MCLRE = ON            ; Master Clear Enable (MCLR Enabled, RG5 Disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Overflow Reset (Enabled)
  CONFIG  BBSIZ = BB2K          ; Boot Block Size (2K word Boot Block size)

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protect 00800-03FFF (Disabled)
  CONFIG  CP1 = OFF             ; Code Protect 04000-07FFF (Disabled)
  CONFIG  CP2 = OFF             ; Code Protect 08000-0BFFF (Disabled)
  CONFIG  CP3 = OFF             ; Code Protect 0C000-0FFFF (Disabled)
  CONFIG  CP4 = OFF             ; Code Protect 10000-13FFF (Disabled)
  CONFIG  CP5 = OFF             ; Code Protect 14000-17FFF (Disabled)
  CONFIG  CP6 = OFF             ; Code Protect 18000-1BFFF (Disabled)
  CONFIG  CP7 = OFF             ; Code Protect 1C000-1FFFF (Disabled)

; CONFIG5H
  CONFIG  CPB = OFF             ; Code Protect Boot (Disabled)
  CONFIG  CPD = OFF             ; Data EE Read Protect (Disabled)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Table Write Protect 00800-03FFF (Disabled)
  CONFIG  WRT1 = OFF            ; Table Write Protect 04000-07FFF (Disabled)
  CONFIG  WRT2 = OFF            ; Table Write Protect 08000-0BFFF (Disabled)
  CONFIG  WRT3 = OFF            ; Table Write Protect 0C000-0FFFF (Disabled)
  CONFIG  WRT4 = OFF            ; Table Write Protect 10000-13FFF (Disabled)
  CONFIG  WRT5 = OFF            ; Table Write Protect 14000-17FFF (Disabled)
  CONFIG  WRT6 = OFF            ; Table Write Protect 18000-1BFFF (Disabled)
  CONFIG  WRT7 = OFF            ; Table Write Protect 1C000-1FFFF (Disabled)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Config. Write Protect (Disabled)
  CONFIG  WRTB = OFF            ; Table Write Protect Boot (Disabled)
  CONFIG  WRTD = OFF            ; Data EE Write Protect (Disabled)

; CONFIG7L
  CONFIG  EBRT0 = OFF           ; Table Read Protect 00800-03FFF (Disabled)
  CONFIG  EBRT1 = OFF           ; Table Read Protect 04000-07FFF (Disabled)
  CONFIG  EBRT2 = OFF           ; Table Read Protect 08000-0BFFF (Disabled)
  CONFIG  EBRT3 = OFF           ; Table Read Protect 0C000-0FFFF (Disabled)
  CONFIG  EBRT4 = OFF           ; Table Read Protect 10000-13FFF (Disabled)
  CONFIG  EBRT5 = OFF           ; Table Read Protect 14000-17FFF (Disabled)
  CONFIG  EBRT6 = OFF           ; Table Read Protect 18000-1BFFF (Disabled)
  CONFIG  EBRT7 = OFF           ; Table Read Protect 1C000-1FFFF (Disabled)

; CONFIG7H
  CONFIG  EBRTB = OFF           ; Table Read Protect Boot (Disabled)

  end
