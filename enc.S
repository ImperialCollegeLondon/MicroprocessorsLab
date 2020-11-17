#include <xc.inc>
    
global  encrypt_me, decrypt_me    
extrn    Storage_read    



psect	enc_code,class=CODE
    
main:     
    org	0x0
    org	0x100	    
 
encrypt_me:
    call     Storage_read	 ; call the storage module 
    movf     0x50, W 
    addwf    0x52, W		 ; add the cipher key to original letters
    xorwf    0x51, W		 ; add xorkey to cipher encrypt
    movwf    0x53
    return
        
decrypt_me:
    call     Storage_read	; call the storage module 
    movf     0X53, W
    xorwf    0x51, W		 ; decrypt string
    movwf    0x99		 ; decrypt string  
    movf     0x50 ,W		 ; decrypt string
    subwf    0x99, W
    movwf    0x53
    return
