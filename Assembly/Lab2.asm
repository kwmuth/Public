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
	setb P2.0
	mov a, #0
		
	setb P3.7
	orl a, #10000000B
	lcall delay100us
	jnb P2.0, N1
	clr P3.7
	anl a, #01111111B
N1:	setb P3.6
	mov a, #01000000B
	lcall delay100us
	jnb P2.0, N2
	clr P3.6
	anl a, #10111111B
N2:	setb P3.5
	mov a, #00100000B
	lcall delay100us
	jnb P2.0, N3
	clr P3.5
	anl a, #11011111B
N3:	setb P3.4
	orl a, #00010000B
	lcall delay100us
	jnb P2.0, N4
	clr P3.4
	anl a, #11101111B
N4:	setb P3.3
	orl a, #00001000B
	lcall delay100us
	jnb P2.0, N5
	clr P3.3
	anl a, #11110111B
N5:	setb P3.2
	orl a, #00000100B
	lcall delay100us
	jnb P2.0, N6
	clr P3.2
	anl a, #11111011B
N6:	setb P3.1
	orl a, #00000010B
	lcall delay100us
	jnb P2.0, N7
	clr P3.1
	anl a, #11111101B
N7: setb P3.0
	orl a, #00000001B
	lcall delay100us
	jnb P2.0, N8
	clr P3.0
	anl a, #11111110B
N8:	mov LEDRA, a
	ret

SuccessiveApproximation2:
	mov P3, #0
	setb P2.1
	mov b, #0
		
	setb P3.7
	orl b, #10000000B
	lcall delay100us
	jnb P2.1, L1
	clr P3.7
	anl b, #10000000B
L1:	setb P3.6
	orl b, #01000000B
	lcall delay100us
	jnb P2.1, L2
	clr P3.6
	anl b, #01000000B
L2:	setb P3.5
	orl b, #00100000B
	lcall delay100us
	jnb P2.1, L3
	clr P3.5
	anl b, #11011111B
L3:	setb P3.4
	orl b, #00010000B
	lcall delay100us
	jnb P2.1, L4
	clr P3.4
	anl b, #11101111B
L4:	setb P3.3
	orl b, #00001000B
	lcall delay100us
	jnb P2.1, L5
	clr P3.3
	anl b, #11110111B
L5:	setb P3.2
	orl b, #00000100B
	lcall delay100us
	jnb P2.1, L6
	clr P3.2
	anl b, #11111011B
L6:	setb P3.1
	orl b, #00000010B
	lcall delay100us
	jnb P2.1, L7
	clr P3.1
	anl b, #11111101B
L7: setb P3.0
	orl b, #00000001B
	lcall delay100us
	jnb P2.1, L8
	clr P3.0
	anl b, #11111110B
L8:	mov LEDG, b
	ret

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
 ;lcall SuccessiveApproximation2
 ;mov P3, R3 
 lcall delay100us
 ;inc R3 
 lcall delay100us 
 sjmp Loop 
 END