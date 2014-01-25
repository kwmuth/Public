$MODDE2 
org 0000H 
	ljmp Startup
	$include(LUT.asm)

DSEG at 30H
	bcd: ds 3
	x: ds 2
	y: ds 2

CSEG
	myLUT:	;Look-up table for 7-seg displays
	DB 0C0H, 0F9H, 0A4H, 0B0H, 099H			; 0 TO 4
	DB 092H, 082H, 0F8H, 080H, 090H			; 4 TO 9
	DB 088H, 083H, 0C6H, 0A1H, 086H, 0FFH	; A TO F
	
	myASCII:	;Look-up table for 7-seg displays
	DB 30H, 31H, 32H, 33H, 34H			; 0 TO 4
	DB 35H, 36H, 37H, 38H, 39H			; 4 TO 9
	DB 088H, 083H, 0C6H, 0A1H, 086H, 0FFH	; A TO F

delay100us: 	; 100 micro-second delay subroutine 
	mov R1, #10 
	M0: mov R0, #111 
	M1: djnz R0, M1 ; 111*30ns*3=10us 
	djnz R1, M0 ; 10*10us=100us, approximately 
	ret

VoltageVal:
	mov dptr, #myVoltTable
	mov y, #2                        ; Each row has two entries (DW is two bytes)
	lcall mul16                ; Multiplies by two
	mov y+1, dph                ; Sets high to the first 8-bits of y
	mov y+0, dpl                ; Sets low to the last 8-bits of y
	lcall add16                        ; 
	mov dph, x+1                ; Sets high to the first 8-bits of x
	mov dpl, x+0                ; Sets low to the last 8-bits of x
	
	clr a
	movc a, @a+dptr                ; Selects the first 8-bits to display
	mov x+1, a                        ; Sets the first 8-bits of the value
	inc dptr                        ; Increments dptr to select second bit
	clr a 
	movc a, @a+dptr                ; Selects the second 8-bits to display
	mov x+0, a                        ; Sets the second 8-bits of the value
	ret

Display:
	mov dptr, #myLUT
	; Display Digit 0
	mov A, bcd+0
	anl a, #0fh
	movc A, @A+dptr
	mov HEX0, A
	; Display Digit 1
	mov A, bcd+0
	swap a
	anl a, #0fh
	movc A, @A+dptr
	mov HEX1, A
	; Display Digit 2
	mov A, bcd+1
	anl a, #0fh
	movc A, @A+dptr
	mov HEX2, A
	; Display Digit 3
	mov A, bcd+1
	swap a
	anl a, #0fh
	movc A, @A+dptr
	mov HEX3, A
	ret

DisplayLCD:
	lcall WriteVoltage
	mov dptr, #myASCII
	; Display Digit 0
	mov A, bcd+1
	swap a
	anl a, #0fh
	movc A, @A+dptr
	lcall LCD_put	
	
	mov a, #'.'
	lcall LCD_put
	
	; Display Digit 1
	mov A, bcd+1
	anl a, #0fh
	movc A, @A+dptr
	lcall LCD_put
	; Display Digit 2
	mov A, bcd+0
	swap a
	anl a, #0fh
	movc A, @A+dptr
	lcall LCD_put
	; Display Digit 3
	mov A, bcd+0
	anl a, #0fh
	movc A, @A+dptr
	lcall LCD_put
	
	mov a, #'V'
	lcall LCD_put
	ret

WriteVoltage:
	mov a, #'V'
	lcall LCD_put
	mov a, #'O'
	lcall LCD_put
	mov a, #'L'
	lcall LCD_put
	mov a, #'T'
	lcall LCD_put
	mov a, #'A'
	lcall LCD_put
	mov a, #'G'
	lcall LCD_put
	mov a, #'E'
	lcall LCD_put
	mov a, #':'
	lcall LCD_put
	mov a, #' '
	lcall LCD_put
	ret

ClearScreen:		;Clears screen
	mov a, #01H 
	lcall LCD_command        
	mov R1, #40
	lcall Clr_loop
	ret

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
	djnz R0, X1	;9 machine cycles-> 9*30ns*149=40us
	ret

LCD_command:
	mov LCD_DATA, A
	clr LCD_RS
	nop
	nop
	setb LCD_EN	;Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr LCD_EN
	ljmp Wait40us

LCD_put:
	mov LCD_DATA, A
	setb LCD_RS
	nop
	nop
	setb LCD_EN	;Enable pulse should be at least 230 ns
	nop
	nop
	nop
	nop
	nop
	nop
	clr LCD_EN
	ljmp Wait40us   


CheckInputs_mac Mac
	mov a, %0
	lcall LCD_command
	mov x+0, %1
	mov x+1, #0
	clr a
	mov a, %1
	lcall VoltageVal
	lcall hex2bcd
	lcall DisplayLCD
endmac

SuccessiveApprox_mac Mac
	mov P3, #0
	setb %0
	setb P3.7
	lcall delay100us
	jnb %0, %1
	clr P3.7
%1:	setb P3.6
	lcall delay100us
	jnb %0, %2
	clr P3.6
%2:	setb P3.5
	lcall delay100us
	jnb %0, %3
	clr P3.5
%3:	setb P3.4
	lcall delay100us
	jnb %0, %4
	clr P3.4
%4:	setb P3.3
	lcall delay100us
	jnb %0, %5
	clr P3.3
%5:	setb P3.2
	lcall delay100us
	jnb %0, %6
	clr P3.2
%6:	setb P3.1
	lcall delay100us
	jnb %0, %7
	clr P3.1
%7:	setb P3.0
	lcall delay100us
	jnb %0, %8
	clr P3.0
%8:	mov %10, P3
	mov %9, P3 ; R7
endmac

StartUp: 
	mov SP, #7FH ;		Set the stack pointer 
	mov LEDRA, #0		; Turn off all LEDs 
	mov LEDRB, #0 
	mov LEDRC, #0 
	mov LEDG, #0 
	mov P3MOD, #11111111B ; Configure P3.0 to P3.7 as outputs 
	mov P2MOD, #00000000B

	setb LCD_ON
	clr LCD_EN		;Default state of enable must be zero
	lcall Wait40us

	mov LCD_MOD, #0xff	;Use LCD_DATA as output port
	clr LCD_RW			;Only writing to the LCD in this code.
	mov a, #0ch			;Display on command
	lcall LCD_command
	mov a, #38H			;8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
  
Loop:
	SuccessiveApprox_mac(P2.0, N1, N2, N3, N4, N5, N6, N7, N8, R7, LEDRA)
	lcall delay100us
	CheckInputs_mac(#80H, R7)
	SuccessiveApprox_mac(P2.2, O1, O2, O3, O4, O5, O6, O7, O8, R6, LEDG) 
	lcall delay100us
	CheckInputs_mac(#0C0H, R6)
	ljmp Loop 
END