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
BCD_count:		ds 3
NewTime_count: 	ds 3
AlarmCount: 	ds 3
Cnt_10ms:  		ds 1

BSEG 
Meridiem:		dbit 1
MeridiemAlarm: 	dbit 1


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
	
	mov NewTime_count+0,#0					;Set NewTime_count to 12:00:00 to set the time
	mov NewTime_count+1,#0
	mov NewTime_count+2,#12H
	
	cjne a, #100, do_nothing1
	
	jb SWA.0, M1							;CHeck if SWA.0 is set
	jnb SWA.0, Continue
	
M1: lcall ClearDisplay						;Clear display and set the time
	lcall SetTime2	
		
Continue:									;Increment seconds
	mov Cnt_10ms, #0
	mov a, BCD_count+0
	add a, #1
	da a
	mov BCD_count+0, a
	cjne A, #60H, checkAlarmCount
	
	
Min:										;Increment minutes
	mov BCD_count+0, #00H					
	mov a, BCD_count+1
	add a, #1
	da a
	mov BCD_count+1, a
;	cjne A, 30H, M17
;	lcall setLED
M17:cjne A, #60H, checkAlarmCount			;If minutes is not at 60, display value of minutes

	
Hour:										;Increment hours
	mov BCD_count+1,#00H
	mov a, BCD_count+2
	add a, #1
	da a
	mov BCD_count+2, a
	cjne A, #12H, M8						;If hours is not at 12, display value of hours
CPLMeridiem:
	cpl meridiem
	jnb meridiem, AM
	jb meridiem, PM
AM: mov HEX0, #08H
	ljmp checkAlarmCount
PM: mov HEX0, #0CH
M8:	cjne A,#13H, checkAlarmCount
	mov BCD_count+2, #1H
	ljmp checkAlarmCount
	
do_nothing1:
	ljmp do_nothing

SetLED:
	mov LEDRB, #1H 
	ret

checkAlarmCount:
	mov a, AlarmCount+1
	mov R1, BCD_count+1
	subb a, R1
	mov BCD_count+1, R1
	jz SetLED
	
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
	mov HEX6, A
;Display digit 6
	mov A, BCD_count+2
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX7, A
	
do_nothing:
	pop dph
	pop dpl
	pop acc
	pop psw	
	reti

SetAlarm2:
	mov AlarmCount+0, #0H
	mov AlarmCount+1, #0H
	mov AlarmCount+2, #12H
	lcall SetAlarm
	ret
SetAlarm:
	jb SWA.5, SetAlarmMin
	jb SWA.6, SetAlarmHour
	jb SWA.4, SetAlarm
	ret
SetAlarmMin:
	jnb SWA.4, SetAlarm
	jnb SWA.5, SetAlarmMin
	mov a, AlarmCount+1
	add a, #1
	da a
	cjne a, #60H, M9
	clr a
M9:	mov AlarmCount+1, a
	lcall DisplaySetTime2
	jb SWA.5, WaitSW5
WaitSW5:
	jb SWA.5, WaitSW5
	sjmp SetAlarm
SetAlarmHour:
	jnb SWA.4, SetAlarm
	jnb SWA.6, SetAlarmHour
	mov a, AlarmCount+2
	add a, #1
	da a
	cjne a, #13H, M14
	mov a, #1H
	da a
M14:mov AlarmCount+2, a
	lcall DisplaySetTime2
	lcall AMPM2
	jb SWA.6, WaitSW6
WaitSW6:
	jb SWA.6, WaitSW6
	sjmp SetAlarm
AMPM2:
	mov a, AlarmCount+2
	cjne a, #12H, return2
	cpl MeridiemAlarm 
	jnb MeridiemAlarm, ChangeToAM2
	jb MeridiemAlarm, ChangeToPM2
ChangeToAM2:
	mov HEX0, #08H
	sjmp return2
ChangeToPM2:
	mov HEX0, #0CH
return2:
	ret	
	
ISR_timer0:
	jb SWA.4, M11
	jnb SWA.4, Cont
M11:setb LEDG.1
	lcall ClearDisplay
	lcall SetAlarm2
Cont:
	clr LEDG.1
	cpl P0.0
M15:mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
 	reti
 
SoundAlarm:
	cpl P0.1
	jnb SWA.6, SoundAlarm
	ret

DisplaySetTime2:
	mov dptr, #myLUT	
; Display Digit 1
	mov A, AlarmCount+0
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A   
; Display Digit 2
    mov A, AlarmCount+0
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A	 
; Display digit 3
	mov A, AlarmCount+1
	anl A, #0FH
	movc A, @A+dptr
	mov HEX4, A	
;Display digit 4
	mov A, AlarmCount+1
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX5, A	
;Display digit 5
	mov A, AlarmCount+2
	anl A, #0FH
	movc A, @A+dptr
	mov HEX6, A
;Display digit 6
	mov A, AlarmCount+2
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX7, A
	ret

 
SetTime2:
	mov NewTime_count+0,#0
	mov NewTime_count+1,#0
	mov NewTime_count+2,#12H
	clr meridiem
	lcall SetTime
	ret
	
SetTime:
	jb SWA.1, SetTimeSec
	jb SWA.2, SetTimeMin
	jb SWA.3, SetTimeHour
	jb SWA.0, SetTime
	lcall MoveToBCD											                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	ret

SetTimeSec:
	jnb SWA.0, SetTime
	jnb SWA.1, SetTimeSec
	mov a, NewTime_count+0
	add a, #1
	da a
	cjne a, #60H, M5
	clr a
M5:	mov NewTime_count+0, a
	lcall DisplaySetTime
	jb SWA.1, WaitSW1
WaitSW1:
	jb SWA.1, WaitSW1
	sjmp SetTime
	
SetTimeMin:
	jnb SWA.0, SetTime
	jnb SWA.2, SetTimeMin
	mov a, NewTime_count+1
	add a, #1
	da a
	cjne a, #60H, M20
	clr a
M20:mov NewTime_count+1, a
	lcall DisplaySetTime
	jb SWA.2, WaitSW2
WaitSW2:
	jb SWA.2, WaitSW2
	sjmp SetTime
	
SetTimeHour:
	jnb SWA.0, SetTime
	jnb SWA.3, SetTimeHour
	mov a, NewTime_count+2
	add a, #1
	da a
	cjne a, #13H, M7
M6:	mov a, #1H
	da a
M7:	mov NewTime_count+2, a
	lcall DisplaySetTime
	lcall AMPM
	jb SWA.3, WaitSW3
WaitSW3:
	jb SWA.3, WaitSW3
	sjmp SetTime

AMPM:
	mov a, NewTime_count+2
	cjne a, #12H, return
	cpl meridiem 
	jnb meridiem, ChangeToAM
	jb meridiem, ChangeToPM
ChangeToAM:
	mov HEX0, #08H
	sjmp return
ChangeToPM:
	mov HEX0, #0CH
return:
	ret	

MoveToBCD:
	mov BCD_count+0, NewTime_count+0
	mov BCD_count+1, NewTime_count+1
	mov BCD_count+2, NewTime_count+2
	ret
	
	
DisplaySetTime:
	mov dptr, #myLUT
	
; Display Digit 1
	mov A, NewTime_count+0
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A
    
; Display Digit 2
    mov A, NewTime_count+0
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A	
    
; Display digit 3
	mov A, NewTime_count+1
	anl A, #0FH
	movc A, @A+dptr
	mov HEX4, A
	
;Display digit 4
	mov A, NewTime_count+1
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX5, A
	
;Display digit 5
	mov A, NewTime_count+2
	anl A, #0FH
	movc A, @A+dptr
	mov HEX6, A

;Display digit 6
	mov A, NewTime_count+2
	swap A
	anl A, #0FH
	movc A, @A+dptr
	mov HEX7, A
	ret

ClearDisplay:
	mov HEX0, #08H
    mov HEX2, #40H
    mov HEX3, #40H
    mov HEX4, #40H
    mov HEX5, #40H
    mov HEX6, #0A4H
    mov HEX7, #0F9H
    ret
    
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
	mov P0MOD, #00000011B				;P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2!
	setb P0.0

    mov TMOD,  #00000001B 				;GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 							;Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 							;Enable timer 0
    setb ET0 							;Enable timer 0 interrupt
    
        
    mov T2CON, #00H 					;Autoreload is enabled, work as a timer
    clr TR2
    clr TF2
    									; Set up timer 2 to interrupt every 10ms
    mov RCAP2H,#high(TIMER2_RELOAD)
    mov RCAP2L,#low(TIMER2_RELOAD)
    setb TR2
    setb ET2
    mov HEX0, #08H
    lcall ClearDisplay
    
    mov a, #12H
    da a
    
    mov BCD_count+0, #0					;Set initial value 12:00:00 for BCD_count
    mov BCD_count+1, #0
    mov BCD_count+2, a
    
    mov AlarmCount+0, #0				;Set initial value 12:00:00 for AlarmCount
    mov AlarmCount+1, #0
    mov AlarmCount+2, a
    
    clr meridiem						;Set AM
    clr MeridiemAlarm
    mov Cnt_10ms, #0
    
    setb EA  							; Enable all interrupts

M0:
	cpl LEDRA.0
	lcall WaitHalfSec
	sjmp M0
END