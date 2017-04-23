#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=0500h#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0500h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0500h#	; same as loading segment
#ES=0500h#	; same as loading segment

; set stack
#SS=0500h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

.model small
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
    STACK DW 100 DUP(?)
    TOP_STACK LABEL WORD   
.code
.startup
    LEA SP, TOP_STACK        
    MOV AL,10010000B
    OUT CREG_8255,AL  
    CALL INITIALIZE_INT 
    ;int 3
    ;INT 50H
    
    
    START:
        IN AL, PORTA
        CMP AL, 11111110B
    JNZ START  
    CALL DEBOUNCE_DELAY
    ;MOV AL,00001111B
    ;OUT CREG_8255,AL      
    
    LOAD:
        IN AL, PORTA
        CMP AL, 11101111B
        JZ LOADEXIT
        CMP AL, 11111011B
        JNZ LOAD
        INC BYTE PTR MODENO
        CALL DEBOUNCE_DELAY
    JMP LOAD
    LOADEXIT:
    MOV AH, MODENO
    MOV BL, 00H
    MOV MODENO, BL
    CMP AH, 00H
    JZ LOAD
    CMP AH, 03H
    JG LOAD
    MOV MODENO, AH        
    
    OUT1: 
    CMP AH, 01H
    JNE OUT2
    MOV AL, 01H
    OUT PORTC, AL
    JMP LIGHT
    OUT2:
    CMP AH, 02H
    JNE OUT3
    MOV AL, 02H
    OUT PORTC, AL
    JMP MEDIUM
    OUT3:
    MOV AL, 03H
    OUT PORTC, AL
    JMP HEAVY
    LIGHT:
    MEDIUM:
    HEAVY:        
    
    INF:
    JMP INF
.exit

PROC DEBOUNCE_DELAY NEAR
    DEBOUNCE:       
        IN AL,PORTA
        CMP AL,11111111B
        JNZ DEBOUNCE
    RET
DEBOUNCE_DELAY ENDP

PROC INITIALIZE_INT NEAR
    MOV AX, 0
    MOV ES, AX
    CLI
    MOV WORD PTR ES:[320], OFFSET INT50H
    MOV WORD PTR ES:[322], CS
    STI  
    MOV AX, 0
    RET
INITIALIZE_INT ENDP 

INT50H PROC FAR
    ;int 3
    MOV AL, 08H
    OUT PORTC, AL
    IRET
INT50H ENDP
           
end



HLT           ; halt!


