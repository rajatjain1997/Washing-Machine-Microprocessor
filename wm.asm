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
.code
.startup        
    MOV AL,10010000B
    OUT CREG_8255,AL
    MOV AL,00001111B
    OUT CREG_8255,AL
    INF:
    JMP INF
.exit
end