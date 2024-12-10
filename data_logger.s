#include <xc.inc>

global data_logger

psect	udata_acs
data  ds  1

psect	data_logger,class=CODE
data_logger:
            movlw  0xFF      
            movwf  EEADR, A                # register low byte
            ;movlw  high(data)
            ;movwf  EEAPRH, A              # register high byte
            movlw  data              
            movwf  EEDATA, A               # EEPROM data register
            
program_memory:
            bcf    EECON1, 7, A            # EEPGD, access data EEPROM memory
            bcf    EECON1, 6, A            # CFGS, access data EEPROM
            bsf    EECON1, 2, A            # WREN, write cycles to EEPROM
            
            ;bcf   INTCON, GIE             # disable interrupts
            movlw  0x55                    # required sequence from the data sheet
            movwf  EECON2
            movlw  0xAA
            movwf  EECON2
            bsf    EECON1, 1, A            # WR, initiates a EEPROM write cycle
            btfsc  EECON1, 1, A
            ;bsf   INTCON, GIE             # re-enable interrupts
            bcf    EECON1, 2, A            # WREN, disable writes
            return









            

            
