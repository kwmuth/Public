; Blinky_Int.asm: blinks LEDR0 of the DE2-8052 each second.
; Also generates a 2kHz signal at P0.0 using timer 0 interrupt.
; Also keeps a BCD counter using timer 2 interrupt.

$MODDE2

CLK EQU 33333333
FREQ_0 EQU 2000
FREQ_2 EQU 100
TIMER0_RELOAD EQU 65536-(CLK/(12*2*FREQ_0))
TIMER2_RELOAD EQU 65536-(CLK/(12*FREQ_2))

org 0000H
	ljmp myprogram
	
org 000BH
	ljmp ISR_timer0
	
org 002BH
	ljmp ISR_timer2

DSEG at 30H
BCD_count: ds 3
Cnt_10ms:  ds 1

BSEG 
Meridiem:	dbit 1


CSEG

; Look-up table for 7-segment displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H

ISR_timer2:
	push psw
	push acc
	push dpl
	push dph
	
	clr TF2
	cpl P0.1
	
	mov a, Cnt_10ms
	inc a
	mov Cnt_10ms, a
	
	cjne a, #100, do_nothing
	
	mov Cnt_10ms, #0
	mov a, BCD_count+0
	add a, #1
	da a
	mov BCD_count+0, a
	cjne A, #60H, L11
	ljmp min
L11:	ljmp Display
	
min:mov BCD_count+0, #00H
	mov a, BCD_count+1
	add a, #1
	da a
	mov BCD_count+1, a
	cjne A, #60H, L22
	ljmp hour
L22:	ljmp Display
	
hour:mov BCD_count+1,#00H
	mov a, BCD_count+2
	add a, #1
	da a
	mov BCD_count+2, a
	cjne A,#13H, L33
	mov BCD_count+2, #00H
	cpl meridiem
	jnb AM
	jb PM
AM: HEX0, #08H
	ljmp Display
PM: HEX0, #0CH

L33: ljmp Display

Display:
	mov dptr, #myLUT
; Display Digit 1
	mov A, BCD_count+0
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A
; Display Digit 2
    mov A, BCD_count+0
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A	
    
; Display digit 3
	mov A, BCD_count+1
	anl A, #0FH
	movc A, @A+dptr
	mov HEX4, A
	
;Display digit 4
	mov A, BCD_count+1
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX5, A
	
;Display digit 5
	mov A, BCD_count+2
	anl A, #0FH
	movc A, @A+dptr
	mov HEX5, A

;Display digit 6
	mov A, BCD_count+2
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX6, A
	

do_nothing:
	pop dph
	pop dpl
	pop acc
	pop psw
	
	reti

ISR_timer0:
	cpl P0.0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
	reti
	
;For a 33.33MHz clock, one cycle takes 30ns
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
	ret
	
myprogram:
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	mov P0MOD, #00000011B ; P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2!
	setb P0.0

    mov TMOD,  #00000001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 ; Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt
    
        
    mov T2CON, #00H ; Autoreload is enabled, work as a timer
    clr TR2
    clr TF2
    ; Set up timer 2 to interrupt every 10ms
    mov RCAP2H,#high(TIMER2_RELOAD)
    mov RCAP2L,#low(TIMER2_RELOAD)
    setb TR2
    setb ET2
    mov HEX0, #08H
    
    mov BCD_count+0, #0
    mov BCD_count+1, #0
    mov BCD_count+2, #0
    clr meridiem
    mov Cnt_10ms, #0
     
    setb EA  ; Enable all interrupts

M0:
	cpl LEDRA.0
	lcall WaitHalfSec
	sjmp M0
END
