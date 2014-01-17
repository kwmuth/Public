; dac.asm: uses a R-2R ladder DAC to generate a ramp 
$MODDE2 
org 0000H 

 ljmp myprogram 
 
; 100 micro-second delay subroutine 
delay100us: 
 mov R1, #10 
M0: mov R0, #111 
M1: djnz R0, M1 ; 111*30ns*3=10us 
 djnz R1, M0 ; 10*10us=100us, approximately 
 ret 
 
SuccessiveApproximation:
	mov P3, #0
	anl P2, #00FH
	setb P3.7
	lcall delay100us
	jnb P2.0, L1
	clr P3.7
L1:	setb P3.6
	lcall delay100us
	jnb P2.0, L2
	clr P3.6
L2:	setb P3.5
	lcall delay100us
	jnb P2.0, L3
	clr P3.5
L3:	setb P3.4
	lcall delay100us
	jnb P2.0, L4
	clr P3.4
L4:	setb P3.3
	lcall delay100us
	jnb P2.0, L5
	clr P3.3
L5:	setb P3.2
	lcall delay100us
	jnb P2.0, L6
	clr P3.2
L6:	setb P3.1
	lcall delay100us
	jnb P2.0, L7
	clr P3.1
L7: setb P3.0
	lcall delay100us
	jnb P2.0, L8
	clr P3.0
L8:	ret


myprogram: 
 mov SP, #7FH ; Set the stack pointer 
 mov LEDRA, #0 ; Turn off all LEDs 
 mov LEDRB, #0 
 mov LEDRC, #0 
 mov LEDG, #0 
 mov P3MOD, #11111111B ; Configure P3.0 to P3.7 as outputs 
 mov P2MOD, #00000000B
 mov R3, #0 ; Initialize counter to zero 
Loop: 
 lcall SuccessiveApproximation
;mov P3, R3 
 lcall delay100us
; inc R3 
 lcall delay100us 
 sjmp Loop 
 END