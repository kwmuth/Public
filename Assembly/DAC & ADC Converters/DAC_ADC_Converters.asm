 
$MODDE2 
org 0000H 
	ljmp myprogram
	$include(LUT.asm)

DSEG at 30H
bcd: ds 3
x: ds 2
y: ds 2

CSEG
        myLUT:      ;Look-up table for 7-seg displays
        DB 0C0H, 0F9H, 0A4H, 0B0H, 099H                ; 0 TO 4
        DB 092H, 082H, 0F8H, 080H, 090H                ; 4 TO 9
        DB 088H, 083H, 0C6H, 0A1H, 086H, 0FFH ; A TO F

; 100 micro-second delay subroutine 
delay100us: 
	mov R1, #10 
	M0: mov R0, #111 
	M1: djnz R0, M1 ; 111*30ns*3=10us 
	djnz R1, M0 ; 10*10us=100us, approximately 
	ret

 
DisplayBin:
    mov dptr, #myLUT
	; Display Digit 0
	mov A, R0
	anl a, #0fh
    movc A, @A+dptr
    mov HEX0, A
    ; Display Digit 1
    mov A, R0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov HEX1, A
    ; Display Digit 2
    mov A, R1
    anl a, #0fh
    movc A, @A+dptr
    mov HEX2, A
    ret

ReadNumber:
	jnb SWA.0, H1
	mov x+0, R6
	sjmp H2
H1:	mov x+0, R7                ; Reads SW0-7, sets x-low
H2: mov x+1, #0                        ; Sets x-high
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

WriteGreen:
	lcall ClearScreen
	mov a, #'V'	
	lcall LCD_put
	mov a, #'A'	
	lcall LCD_put
	mov a, #'L'	
	lcall LCD_put
   	mov a, #'U'	
	lcall LCD_put
   	mov a, #'E'	
	lcall LCD_put
	mov a, #' '	
	lcall LCD_put
	mov a, #'O'	
	lcall LCD_put
	mov a, #'F'	
	lcall LCD_put
	mov a, #' '	
	lcall LCD_put
	mov a, #'G'	
	lcall LCD_put
	mov a, #'R'	
	lcall LCD_put
	mov a, #'E'	
	lcall LCD_put
	mov a, #'E'	
	lcall LCD_put
	mov a, #'N'	
	lcall LCD_put
	ret
	
WriteRed:
	lcall ClearScreen
	mov a, #'V'	
	lcall LCD_put
	mov a, #'A'	
	lcall LCD_put
	mov a, #'L'	
	lcall LCD_put
   	mov a, #'U'	
	lcall LCD_put
   	mov a, #'E'	
	lcall LCD_put
	mov a, #' '	
	lcall LCD_put
	mov a, #'O'	
	lcall LCD_put
	mov a, #'F'	
	lcall LCD_put
	mov a, #' '	
	lcall LCD_put
	mov a, #'R'	
	lcall LCD_put
	mov a, #'E'	
	lcall LCD_put
	mov a, #'D'
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


Clr_loop:
	lcall Wait40us
	lcall Wait40us
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


bin2bcd8:
	mov b, #100
	div ab
	mov r1, a
	mov a, b
	mov b, #10
	div ab
	swap a
	orl a, b
	mov r0, a
	ret

SuccessiveApproximation:
	mov P3, #0
	setb P2.0
		
	setb P3.7
	lcall delay100us
	jnb P2.0, N1
	clr P3.7
N1:	setb P3.6
	lcall delay100us
	jnb P2.0, N2
	clr P3.6
N2:	setb P3.5
	lcall delay100us
	jnb P2.0, N3
	clr P3.5
N3:	setb P3.4
	lcall delay100us
	jnb P2.0, N4
	clr P3.4
N4:	setb P3.3
	lcall delay100us
	jnb P2.0, N5
	clr P3.3
N5:	setb P3.2
	lcall delay100us
	jnb P2.0, N6
	clr P3.2
N6:	setb P3.1
	lcall delay100us
	jnb P2.0, N7
	clr P3.1
N7: setb P3.0
	lcall delay100us
	jnb P2.0, N8
	clr P3.0
N8:	mov LEDRA, P3
	mov R7, P3
	ret

SuccessiveApproximation2:
	mov P3, #0
	setb P2.2
	mov b, #0
		
	setb P3.7
	lcall delay100us
	jnb P2.2, L1
	clr P3.7
L1:	setb P3.6
	lcall delay100us
	jnb P2.2, L2
	clr P3.6
L2:	setb P3.5
	lcall delay100us
	jnb P2.2, L3
	clr P3.5
L3:	setb P3.4
	lcall delay100us
	jnb P2.2, L4
	clr P3.4
L4:	setb P3.3
	lcall delay100us
	jnb P2.2, L5
	clr P3.3
L5:	setb P3.2
	lcall delay100us
	jnb P2.2, L6
	clr P3.2
L6:	setb P3.1
	lcall delay100us
	jnb P2.2, L7
	clr P3.1
	lcall delay100us
L7: setb P3.0
	lcall delay100us
	jnb P2.2, L8
	clr P3.0
L8:	mov LEDG, P3
	mov R6, P3
	ret

CheckInputs:
	clr a
	jb SWA.0,SW0T
SW0F:
	mov a, R6
	lcall WriteRed
	sjmp Cont
SW0T:
	mov a, R7
	lcall WriteGreen
Cont:
	lcall ReadNumber
	lcall VoltageVal
	lcall hex2bcd
	lcall display
	ret

myprogram: 
 	mov SP, #7FH ; Set the stack pointer 
 	mov LEDRA, #0 ; Turn off all LEDs 
 	mov LEDRB, #0 
 	mov LEDRC, #0 
 	mov LEDG, #0 
 	mov P3MOD, #11111111B ; Configure P3.0 to P3.7 as outputs 
 	mov P2MOD, #00000000B
 
 	setb LCD_ON
    clr LCD_EN  							;Default state of enable must be zero
    lcall Wait40us
    
    mov LCD_MOD, #0xff 						;Use LCD_DATA as output port
    clr LCD_RW 								;Only writing to the LCD in this code.
	
	mov a, #0ch 							;Display on command
	lcall LCD_command
	mov a, #38H 							;8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
  
Loop: 
 lcall SuccessiveApproximation 
 lcall SuccessiveApproximation2
 lcall delay100us
 lcall CheckInputs
 sjmp Loop 
 END