;
; Timer1.asm
;
; Created: 25/06/2022 00:45:07
; Author : Aleksandar Bogdanovic
;


.include "m328pdef.inc"
.org 0x00

timer1:
    LDI   R16, 0b00010000 ; toggle PB4 (D132)
    LDI   R17, 0b00000000
    ;---------------------------------------------
    SBI   DDRB, 4         ; set PB4 for output
    OUT   PORTB, R17      ; PB4 = 0
    ;---------------------------------------------
L1: RCALL timer1_delay    ; 0.5 sec delay via timer1
    ;---------------------------------------------
    EOR   R17, R16        ; R17 = R17 XOR R16
    OUT   PORTB, R17      ; toggle PB4
    LDI   R18, 61         ; re-set loop counter
    RJMP  L1              ; go back & repeat toggle
;===============================================================
timer1_delay:             ;0.5 sec delay via timer1
    ;-------------------------------------------------------
	.EQU value = 57724    ;value to give 0.5 sec delay / 57724(0.5 sec), 49911(1 sec), 34286(2 sec) and 3036(4 sec)
    LDI   R20, high(value)
    STS   TCNT1H, R20
    LDI   R20, low(value)
    STS   TCNT1L, R20     ;initialize counter TCNT1 = value
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1A, R20
    LDI   R20, 0b00000101
    STS   TCCR1B, R20     ;normal mode, prescaler = 1024
    ;-------------------------------------------------------
l2: IN    R20, TIFR1      ;get TIFR1 byte & check
    SBRS  R20, TOV1       ;if TOV1=1, skip next instruction
    RJMP  l2              ;else, loop back & check TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 1<<TOV1
    OUT   TIFR1, R20      ;clear TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1B, R20     ;stop timer0
    RET