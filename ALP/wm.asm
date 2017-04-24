.model tiny
.data
    STARTING_IP DW ?   
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
    ;---STORE THE ISR ADDRESS OF THE NMI(STOP) IN THE IVT
    ;MOV DX,OFFSET STOP_BUTTON
    ;MOV AX,2502H
    ;INT 21H
    
    
    
    
    LEA SP, TOP_STACK        
    MOV AL,10010000B        ;programming the 8255
    OUT CREG_8255,AL
    POLL_START:
    CALL STORE_IP           ;this will store the IP address of the next instruction in STARTING_IP
    MOV AL,00H
    OUT PORTB,AL            ;initially no output device in PORT B(agitator,buzzer) should be ON
    ;CALL INITIALIZE_INT     ;--remove this line
    ;INT 50H
    
    
    START:                  ;polling the START button
        IN AL, PORTA
        CMP AL, 11111110B
    JNZ START  
    CALL DEBOUNCE_DELAY     ;after start button comes up then only proceed
    MOV AL,00000000B
    OUT PORTC,AL      
    
    LOAD:                   ;polling the LOAD button and DOOR_LOCK switch 
        IN AL, PORTA
        CMP AL, 11101111B   ;if DOOR is locked(means mode of operation has been selected)
        JZ LOADEXIT
        CMP AL, 11111011B   
        JNZ LOAD
        INC BYTE PTR MODENO ;if LOAD button is pressed increase the MODE number
        CALL DEBOUNCE_DELAY ;one press of LOAD button should only raise MODE number by 1
    JMP LOAD
    LOADEXIT:
    ;Storing the MODE in AH
    MOV AH, MODENO
    MOV BL, 00H
    MOV MODENO, BL
    CMP AH, 00H             ;checking if mode is selected before closing of door
    JZ LOAD                 
    CMP AH, 03H             ;checking if mode number selected is valid
    JG LOAD                 
    MOV MODENO, AH
    OUT1: 
    CMP AH, 01H             ;displaying on the 7 segment display
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
    LIGHT:                  ;LIGHT MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,2
        X1:CALL DELAY_1m    ;rinse cycle runs for 2 minutes
        LOOP X1
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
        
        MOV AL,01H          ;wash cycle
        OUT PORTB,AL
        MOV CX,3
        X2:CALL DELAY_1m    ;wash cycle runs for 3 minutes
        LOOP X2
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY  
        
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,2
        X3:CALL DELAY_1m    ;rinse cycle runs for 2 minutes
        LOOP X3
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,02H          ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,2
        X4:CALL DELAY_1m    ;dry cycle runs for 2 minutes
        LOOP X4
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
        
    MEDIUM:                 ;MEDIUM MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X5:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X5
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
        
        MOV AL,01H          ;wash cycle
        OUT PORTB,AL
        MOV CX,5
        X6:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X6
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY  
        
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X7:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X7
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,02H          ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,4
        X8:CALL DELAY_1m    ;dry cycle runs for 4 minutes
        LOOP X8
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
    HEAVY:                  ;HEAVY MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X9:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X9
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
        
        MOV AL,01H          ;wash cycle
        OUT PORTB,AL
        MOV CX,5
        X10:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X10
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY
        
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X11:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X11
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
        
        MOV AL,01H          ;wash cycle
        OUT PORTB,AL
        MOV CX,5
        X12:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X12
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY
        
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,01H          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X13:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X13
        MOV AL,00H
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,02H          ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,4
        X14:CALL DELAY_1m   ;dry cycle runs for 4 minutes
        LOOP X14
        MOV AL,00H
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
                
    DONE_WASHING:
        JMP POLL_START
    
    ;INF:
    ;JMP INF
.exit

STORE_IP PROC NEAR          ;this procedure will store the IP address
    MOV BP,SP               ;of the label POLL_START
    MOV AX,[BP]
    MOV STARTING_IP,AX
    RET
STORE_IP ENDP



DEBOUNCE_DELAY PROC NEAR    ;this procedure checks all the buttons and
    DEBOUNCE:               ;returns only of all the buttons are up
        IN AL,PORTA
        OR AL,11110000B
        CMP AL,11111111B
        JNZ DEBOUNCE
    RET
DEBOUNCE_DELAY ENDP

INITIALIZE_INT PROC NEAR
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

;DELAY_1m PROC NEAR
;    ;PUSHA 
;    MOV AL,MODENO 
;    ;SETTING PC4 = 1
;    OUT PORTC,AL 
;    ;Programming counter 0
;    MOV AL,00110001B
;    OUT CREG_8253,AL
;   MOV AL,99H
;    OUT CNT0,AL
;    MOV AL,99H
;    OUT CNT0,AL
      
    
;GET_COUNT:    
;    MOV AL,00000001B
;    OUT CREG_8253,AL
;    IN AL,CNT0
;    MOV BL,AL 
;    IN AL,CNT0
;    MOV BH,AL  
;    ; BX now contains the count value
;    CMP BX,00H 
;JNE GET_COUNT 
    ;POPA 
;    RET   
;DELAY_1m ENDP

DELAY_1m PROC NEAR          ;this procedure is used to generate a delay of 1 minute
    PUSH CX                 ;for simulation purpose 1 minute(virtual) = 10 seconds(real)
    MOV BX,000FH
    L2:MOV CX,0FFFFH
    L1:NOP
        LOOP L1
        DEC BX
        JNZ L2
    POP CX
        RET
DELAY_1m ENDP






WATER_MAX PROC NEAR         ;this procedure checks if water level is max
                            ;water level is max when the pressure sensitive switch(WATER_MAX) is pressed
    CHECK1:
        IN AL,PORTA
        CMP AL,11001111B
    JNE CHECK1
    MOV AL,06H
    OUT PORTC,AL 
    RET
WATER_MAX ENDP 

WATER_MIN PROC NEAR         ;this procedure checks if water level is min
                            ;water level is min when the pressure sensitive switch(WATER_MIN) is pressed
    CHECK2:
        IN AL,PORTA
        CMP AL,10101111B
    JNE CHECK2
    MOV AL,07H
    OUT PORTC,AL 
    RET
WATER_MIN ENDP

BUZZER_RINSE PROC NEAR      ;this procedure activates a buzzer after rinse cycle in complete
    MOV AL,10H
    OUT PORTB,AL
    MOV AL,08H
    OUT PORTC,AL
    CALL DELAY_1m
    MOV AL,00H
    OUT PORTB,AL
    RET
BUZZER_RINSE ENDP

BUZZER_WASH PROC NEAR       ;this procedure activates a buzzer after wash cycle in complete
    MOV AL,08H
    OUT PORTB,AL
    CALL DELAY_1m
    MOV AL,00H
    OUT PORTB,AL
    RET
BUZZER_WASH ENDP 

BUZZER_DRY PROC NEAR        ;this procedure activates a buzzer after dry cycle in complete
    MOV AL,04H
    OUT PORTB,AL
    CALL DELAY_1m
    MOV AL,00H
    OUT PORTB,AL
    RET
BUZZER_DRY ENDP
                            
CHECK_RESUME PROC NEAR      ;this procedure checks if resume button is pressed or not
    
    CHECKR:
        IN AL,PORTA
        OR AL,11100111B
        CMP AL,11100111B
        JNE CHECKR
        MOV AL,08H
    OUT PORTC,AL
        
    RET
CHECK_RESUME ENDP

STOP_BUTTON PROC NEAR              ;this procedure is an ISR for NMI(STOP button)
    MOV BP,SP
    MOV AL,00H
    OUT PORTB,AL
    OUT PORTC,AL
    MOV AX,STARTING_IP ;this will put in stack the IP address of the starting line of program
    MOV [BP],AX
    IRET               ;now the IP address popped will be of the starting line of program 
STOP_BUTTON ENDP



end


