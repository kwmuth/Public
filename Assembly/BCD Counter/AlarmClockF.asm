$MODDE2

CLK EQU 33333333
FREQ_0 EQU 2000
FREQ_2 EQU 100
TIMER0_RELOAD EQU 65536-(CLK/(12*2*FREQ_0))
TIMER2_RELOAD EQU 65536-(CLK/(12*FREQ_2))

org 0000H
	ljmp Startup
        
org 000BH
	ljmp ISR_timer0	  						;Timer1 ISR
	
org 002BH
	ljmp ISR_timer2   						;Timer2 ISR
        
DSEG at 30H
count10ms:	ds 1
seconds:	ds 1
minutes:	ds 1
hours:		ds 1
AlarmCount:	ds 3

BSEG
meridiem:	dbit 1
meridiemAlarm: dbit 1
alarmSet: 	dbit 1

CSEG

myLUT:										;Look-up table for 7-segment displays
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
    DB 0FFH 								;All segments off

ISR_Timer0:
	cpl P0.0 								;Compliments the bit of P0.0
	mov TH0, #high(TIMER0_RELOAD)
	mov TL0, #low(TIMER0_RELOAD)
	reti

ISR_Timer2:
	push psw
    push acc
    push dph
    push dpl
    
    clr TF2
	cpl P0.1
    
    jb SWA.2, Alarm							;if SWA.2 is flipped, alarm is set, check if alarm should go off
    jnb SWA.2, NoAlarm						;if SWA.2 is off, no alarm is set 
Alarm:
    lcall CheckAlarm
    sjmp Continue
NoAlarm:	
	lcall WriteClock						;Display clock on LCD screen
	clr LEDG.3			
	clr ET0									;Clear Timer 0 ISR
Continue:
    jb SWA.0, ISR_Timer2_L0 				;Setting up time, does not increment anything
    
    ;Increment the counter and check if a second has passed
    inc count10ms
    mov a, count10ms
    cjne A, #100, ISR_Timer2_L0
    mov count10ms, #0
    
    ;increment seconds
    mov a, seconds
    add a, #1
    da a
    mov seconds, a
    cjne A, #60H, ISR_Timer2_L0
    mov seconds, #0

	;increment minutes
    mov a, minutes
    add a, #1
    da a
    mov minutes, a
    cjne A, #60H, ISR_Timer2_L0
    mov minutes, #0

	;increment hours
    mov a, hours
    add a, #1
    da a
    mov hours, a
    
    cjne A, #12H, SkipMeridiem
CPLMeridiem:								;if the clock is at 12 hours, change AM/PM
	cpl meridiem
	jnb meridiem, AM
	jb meridiem, PM
AM:	mov HEX0, #08H
	ljmp ISR_Timer2_L0
PM: mov HEX0, #0CH
SkipMeridiem:								;if clock is at 13 hours, move 1 to hours
	cjne A, #13H, ISR_Timer2_L0
    mov hours, #1
    
ISR_Timer2_L0:
	jb SWA.1, Do_Nothing					;if SWA.1 is up, increment clock, do not display
	mov dptr, #myLUT

	jnb meridiem, InitMeridiemAM			;Display AM/PM
	jb meridiem, InitMeridiemPM
InitMeridiemAM:
	mov HEX0, #08H
 	ljmp M15
InitMeridiemPM:
	mov HEX0, #0CH

M15:
	mov a, seconds							;Display seconds
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	mov a, seconds
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a

 	mov a, minutes							;Display minutes
	anl a, #0fH	
	movc a, @a+dptr
	mov HEX4, a
	mov a, minutes
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, hours							;Display hours
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	mov a, hours
	jb acc.4, ISR_Timer2_L1					;If hour between 1-9, nothing displayed on HEX7
	mov a, #0A0H
ISR_Timer2_L1:
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX7, a

Do_Nothing:
	pop dpl
	pop dph
	pop acc
	pop psw    
	reti

;Checks if clock time matches alarm time and sounds buzzer
CheckAlarm:								
	jb ET0, M20								;if interrupt 0 is enabled, write "wake up" to LCD
	lcall WriteAlarm						;otherwise write "alarm"
	sjmp M21
M20:lcall WriteWakeUp
M21:jb meridiem, M22
	jnb meridiemAlarm, CheckHour
	sjmp ReturnISR							;check if AM/PM matches
M22:jb meridiem, CheckHour
	sjmp ReturnISR
CheckHour:
	mov a, hours							;check if hours match
	mov b, AlarmCount+2
	clr c
 	subb a,b
	jz CheckMin
	sjmp ReturnISR
CheckMin:									;check if minutes match
	mov a, minutes
	mov b, AlarmCount+1
	clr c
	subb a, b
	jz CheckSec
	sjmp ReturnISR
CheckSec:									;check if seconds match
	mov a, seconds
	mov b, AlarmCount+0
	clr c
	subb a,b 
	jz SoundAlarm
	sjmp ReturnISR
SoundAlarm:									;if time matches, enable timer 0 interrupt, return to timer 2 ISR
	setb LEDG.3
	setb ET0
ReturnISR:
	ret

;Displays time we are setting alarm to on HEX display
DisplayAlarmVal:	
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
	jb acc.4, I0
	mov a, #0A0H
I0:	swap A
 	anl A, #0FH
 	movc A, @A+dptr
	mov HEX7, A
	ret
	
SetAlarm:
	lcall DisplayAlarmVal					;initially displays 12:00:00 AM on screen
	jb KEY.1, M6							;if KEY.1 is not pressed, check KEY.2
 	jnb KEY.1, $							;wait for key to be released
	mov a, AlarmCount+0						;increment seconds, and display
    add a, #1
    da a
    mov AlarmCount+0, a
    cjne A, #60H, DisplayAlarmVal
    mov AlarmCount+0, #0
    ljmp DisplayAlarmVal
M6:	jb KEY.2, M7							;if KEY.2 is not pressed, check KEY.3
    jnb KEY.2, $							;wait for key to be released
    mov a, AlarmCount+1						;increment minutes and display
	add a, #1
	da a
	mov AlarmCount+1, a
    cjne A, #60H, DisplayAlarmVal
    mov AlarmCount+1, #0
    ljmp DisplayAlarmVal
M7: jb KEY.3, M9							;if KEY.3 is not pressed, check if SWA.1 is flipped
	jnb KEY.3, $							;wait for key to be released
	mov a, AlarmCount+2						;increment hours and display
	add a, #1
	da a
	mov AlarmCount+2, a
	lcall AlarmAMPM							;change AM/PM values every 12 hours
    cjne A, #13H, DisplayAlarmVal
    mov AlarmCount+2, #1H
    ljmp DisplayAlarmVal
M9:	jb SWA.1, SetAlarm						;if SWA.1 is still flipped, jump back to beginning of function			
	ljmp M4									;if SWA.1 is not flipped, back to forever loop

;checks value stored in AlarmCount+2 and changes AM/PM accordingly
AlarmAMPM:									
	mov a, AlarmCount+2
	cjne a, #12H, returnAlarm				;if not 12:00:00, AM/PM does not need to be changed
	cpl meridiemAlarm						;if equal to 12, complement bit
	jnb meridiemAlarm, ChangeToAMAlarm		;if bit = 0, change to AM
	jb meridiemAlarm, ChangeToPMAlarm		;if bit = 1, change to PM
ChangeToAMAlarm:
	mov HEX0, #08H
	sjmp returnAlarm
ChangeToPMAlarm:
	mov HEX0, #0CH
returnAlarm:								;return to set alarm function
	ret
        
ChangeMeridiem:
	mov a, hours
 	cjne a, #12H, ReturnMeridiem			;if not 12:00:00, AM/PM does not need to be changed
	cpl meridiem							;if equal to 12, complement bit
CM:	jnb meridiem, ChangeToAM				;if bit = 0, change to AM
	jb meridiem, ChangeToPM					;if bit = 1, change to PM
ChangeToAM:
	mov HEX0, #08H
	sjmp ReturnMeridiem
ChangeToPM:
	mov HEX0, #0CH
ReturnMeridiem:								;return to set time function
	ret

;checks if SWA.0 or SWA.1 is flipped
;sets time 
SetTime:
	jb SWA.1, SetAlarm						;if SWA.1 is up, set alarm
	jnb SWA.0, M4							;if SWA.0 is down, cannot set time, clock continues to increment
	jb KEY.3, M1
    jnb KEY.3, $							;if KEY.3 is pressed, increment hours
    mov a, hours
	add a, #1
	da a
	mov hours, a
	lcall ChangeMeridiem					;change AM/PM accordingly
    cjne A, #13H, M1
    mov hours, #1
M1:        
	jb KEY.2, M2
    jnb KEY.2, $							;if KEY.2 is pressed, increment minutes
    mov a, minutes
	add a, #1
	da a
	mov minutes, a
	cjne A, #60H, M2
	mov minutes, #0
M2:        
	jb KEY.1, M3
	jnb KEY.1, $							;if KEY.1 is pressed, increment seconds
	mov a, seconds
	add a, #1
	da a
	mov seconds, a
	cjne A, #60H, M3
	mov seconds, #0
M3:        
	ljmp SetTime							;loop through function until SWA.0 is not flipped
M4:	
	ret

;Writes WAKE UP to LCD screen when buzzer is sounded
WriteWakeUp:
	lcall ClearScreen
	mov a, #'W'	
	lcall LCD_put
	mov a, #'A'	
	lcall LCD_put
	mov a, #'K'	
	lcall LCD_put
   	mov a, #'E'	
	lcall LCD_put
   	mov a, #' '	
	lcall LCD_put
	mov a, #'U'	
	lcall LCD_put
	mov a, #'P'	
	lcall LCD_put
	ret

;Writes ALARM to LCD screen when alarm is set
WriteAlarm:
	lcall ClearScreen
	mov a, #'A'	
	lcall LCD_put
	mov a, #'L'	
	lcall LCD_put
	mov a, #'A'	
	lcall LCD_put
   	mov a, #'R'	
	lcall LCD_put
   	mov a, #'M'	
	lcall LCD_put
	ret

;Writes clock to LCD screen when clock is incrementing
WriteClock:
	lcall ClearScreen
	mov a, #'C'	
	lcall LCD_put
	mov a, #'L'	
	lcall LCD_put
	mov a, #'O'	
	lcall LCD_put
   	mov a, #'C'	
	lcall LCD_put
   	mov a, #'K'	
	lcall LCD_put
	ret

;Clears screen
ClearScreen:
	mov a, #01H 
	lcall LCD_command	
	mov R1, #40
	lcall Clr_loop
	mov a, #80H
	lcall LCD_command
	ret

;
Clr_loop:
	lcall Wait40us
	djnz R1, Clr_loop
	ret	 
	
Wait40us:
	mov R0, #149
X1: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, X1 							;9 machine cycles-> 9*30ns*149=40us
    ret

LCD_command:
	mov	LCD_DATA, A
	clr	LCD_RS
	nop
	nop
	setb LCD_EN 							;Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us

LCD_put:
	mov	LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN 							;Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr	LCD_EN
	ljmp Wait40us   
	
Startup:
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	
	mov P0MOD, #00000011B 					;P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2!
	setb P0.0             					;Sets P0.0 to 1

	mov TMOD,  #00000001B 					;GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0               					;Disable timer 0
	clr TF0               					;Clear timer 0 flag
	mov TH0, #high(TIMER0_RELOAD) 			;Timer low 8-bits
	mov TL0, #low(TIMER0_RELOAD)  			;Timer high 8-bits
	setb TR0              					;Enable timer 0
	clr ET0              					;Disable timer 0 interrupt
	
	mov T2CON, #00H 						;Autoreload is enabled, work as a timer
    clr TR2
    clr TF2										
    mov RCAP2H,#high(TIMER2_RELOAD)			;Set up timer 2 to interrupt every 10ms
    mov RCAP2L,#low(TIMER2_RELOAD)
    setb TR2								;Enable timer 2
    setb ET2								;Enable timer 2 interrupt

    setb EA  								;Enable all interrupts
    
    setb LCD_ON
    clr LCD_EN  							;Default state of enable must be zero
    lcall Wait40us
    
    mov LCD_MOD, #0xff 						;Use LCD_DATA as output port
    clr LCD_RW 								;Only writing to the LCD in this code.
	
	mov a, #0ch 							;Display on command
	lcall LCD_command
	mov a, #38H 							;8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
	
	lcall WriteClock
   
    mov seconds, #00H
	mov minutes, #00H
	mov hours, #12H
        
	clr meridiem
	clr meridiemAlarm

    mov AlarmCount+0, #00H
	mov AlarmCount+1, #00H
	mov AlarmCount+2, #12H

Forever:
	lcall SetTime
	sjmp Forever
END