.model tiny
.data   
    PORTA EQU 00H
    PORTB EQU 02H
    PORTC EQU 04H  
    CREG_8255 EQU 06H
    CNT0 EQU 08H
    CNT1 EQU 0AH
    CNT2 EQU 0CH
    CREG_8253 EQU 0EH
    CREG0_8259 EQU 10H
    CREG1_8259 EQU 12H
    MODENO DB 00H   
.code
.startup        
    MOV AL,10010000B
    OUT CREG_8255,AL
    
    START:
        IN AL, PORTA
        CMP AL, 11101110B
    JNZ START  
          
    MOV AL,00001111B
    OUT CREG_8255,AL      
          
    LOAD:
        IN AL, PORTA
        CMP AL, 11101111B
        JZ LOADEXIT
        CMP AL, 11111011B
        JNZ LOAD
        INC BYTE PTR MODENO
    JMP LOAD
    LOADEXIT:
    MOV AL, 09H
    OUT PORTC, AL
    ;MOV AH, MODENO
    ;MOV BL, 00H
    ;MOV MODENO, BL
    ;CMP AH, 00H
    ;JZ LOAD
    ;CMP AH, 03H
    ;JG LOAD
    ;MOV MODENO, AH        
    
    OUT1: 
    CMP AH, 01H
    JNE OUT2
    MOV AL, 01H
    OUT PORTC, AL
    JMP LIGHT
    OUT2:
    LIGHT:        
    
    INF:
    JMP INF
.exit
end