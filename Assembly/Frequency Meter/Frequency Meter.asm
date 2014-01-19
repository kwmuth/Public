$MODDE2

CSEG
org 0000H
   ljmp MyProgram

	;cseg		                                   ; Absolute CODE segements at fixed memory locations
    myLUT:                                         ; Look-up table for 7-seg displays
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H                ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H, 0FFH          ; 4 TO 9, OFF
 
;cseg
hex2bcd:
        push acc
        push psw
        push AR0
        
        clr a
        mov R3, a ; Initialize registers to 00-00-00 
        mov R4, a
        mov R5, a
        mov R6, a
        mov b, #24  ; Loop counter.

hex2bcd_L0:
        ; Shift binary left        
        mov a, R1
        mov c, acc.7 ; This way (R2-0)B remains unchanged!
        mov a, R0
        rlc a
        mov R0, a
        mov a, R1
        rlc a
        mov R1, a
        mov a, R2
        rlc a
        mov R2, a
        
    
        ; Perform bcd + bcd + carry using BCD arithmetic
        mov a, R3
        addc a, R3
        da a ;decimal adjust
        mov R3, a
        mov a, R4
        addc a, R4
        da a
        mov R4, a
        mov a, R5
        addc a, R5
        da a
        mov R5, a
        mov a, R6
        addc a, R6
        da a
        mov R6, a
      

        djnz b, hex2bcd_L0

        pop AR0
        pop psw
        pop acc
        ret
        
Display:
        mov dptr, #myLUT
        ; Display Digit 0
        mov A, R3
        anl a, #0fh
        movc A, @A+dptr
        mov HEX0, A
        ; Display Digit 1
        mov A, R3
        swap a
        anl a, #0fh
        movc A, @A+dptr
        mov HEX1, A
        ; Display Digit 2
        mov A, R4
        anl a, #0fh
        movc A, @A+dptr
        mov HEX2, A
        ; Display Digit 3
        mov A, R4
        swap a
        anl a, #0fh
        movc A, @A+dptr
        mov HEX3, A
        ; Display Digit 4
        mov A, R5
        anl a, #0fh
        movc A, @A+dptr
        mov HEX4, A
        ; Display Digit 5
        mov A, R5
        swap a
        anl a, #0fh
        movc A, @A+dptr
        mov HEX5, A
        ; Display Digit 6
        mov A, R6
        anl a, #0fh
        movc A, @A+dptr
        mov HEX6, A
        ; Display Digit 7
        mov A, R6
        swap a
        anl a, #0fh
        movc A, @A+dptr
        mov HEX7, A
        ret

correctBCDvalues:
        ;if high part of R6 is zero
        mov a,R6
        anl a,#0F0H
        swap a
        jnz correctBCDvalues_return
        ;turn off HEX7:
        mov a,R6
        anl a,#0FH
        orl a,#0A0H
        mov R6,a
        
        ;if low part of R6 is zero
        mov a,R6
        anl a,#0FH
        jnz correctBCDvalues_return ;if accumulator is not zero, jump to function
        ;turn off HEX6:
        mov a,R6
        anl a,#0F0H
        orl a,#0AH
        mov R6,a
        
        ;if high part of R5 is zero
        mov a,R5
        anl a,#0F0H
        swap a
        jnz correctBCDvalues_return
        ;turn off HEX5
        mov a,R5
        anl a,#0FH
        orl a,#0A0H
        mov R5,a
        
        ;if low part of R5 is zero
        mov a,R5
        anl a,#0FH
        jnz correctBCDvalues_return
        ;turn off HEX4
        mov a,R5
        anl a,#0F0H
        orl a,#0AH
        mov R5,a
        
        ;if high part of R4 is zero
        mov a,R4
        anl a,#0F0H
        swap a
        jnz correctBCDvalues_return
        ;turn off HEX3
        mov a,R4
        anl a,#0FH
        orl a,#0A0H
        mov R4,a
        
        ;if low part of R4 is zero
        mov a,R4
        anl a,#0FH
        jnz correctBCDvalues_return
        ;turn off HEX2
        mov a,R4
        anl a,#0F0H
        orl a,#0AH
        mov R4,a
        
        ;if high part of R3 is zero
        mov a,R3
        anl a,#0F0H
        swap a
        jnz correctBCDvalues_return
        ;turn off HEX1
        mov a,R3
        anl a,#0FH
        orl a,#0A0H
        mov R3,a
        
        ;if low part of R3 is zero
        mov a,R3
        anl a,#0FH
        jnz correctBCDvalues_return
        ;turn off HEX0
        mov a,R3
        anl a,#0F0H
        orl a,#0AH
        mov R3,a
        
        ret
        
        correctBCDvalues_return: 
        ret ;returns to forever function

add24:
        ;x=x+y R0 and R1 will hold : R7*65536
        mov a,R0
        add a,R3
        mov R0,a
        mov a,R1
        addc a,R4
        mov R1,a
        mov a,R2
        addc a,R5
        mov R2,a
        ret

multiply24:
        ;x=65536*R7
        mov R3,#0FFH
        mov R4,#0FFH
        mov R5,#0
        mov R0,#0
        mov R1,#0
        mov R2,#0
        mov a,R7
        mov R6,a ;move the number of overflows to R6
        jnz multiply24_L1 ;if accumulator does not equal zero jump to loop
        ret ;if number of overflows equal zero, return
        multiply24_L1:
        call add24 ;x=x+65536
        dec R6
        mov a,R6
        jnz multiply24_L1 ;if accumulator is not zero, repeat loop 
        ret ;if accumulator is zero, return
        

; On the DE2-8052, with a 33.33MHz clock, one cycle takes 30ns
Wait1s:
        mov R7,#0 ; will store the amount of overflows in 1 second
        mov R2, #176
        L3: mov R1, #250
        L2: mov R0, #250
        L1: djnz R0, L1 ;3 machine cycles -> 3*30ns*250=22.5us
        jnb TF0, continue
   
        clr TF0 ;clears overflow flag after it is set
        inc R7 ;increment R7
        
        continue:
        djnz R1, L2 ; 22.5us*250=5.625ms
        djnz R2, L3 ; 5.625ms*180=1s (approximately)
        ret


;Initializes timer/counter 0 as a 16-bit counter
InitTimer0:
        clr TR0 ; Stop timer 0
        mov a, #11110000B ; Clear the bits of timer 0
        anl a,TMOD
        orl a, #00000101B ; Set timer 0 as 16-bit counter
        mov TMOD, a
        ret

MyProgram:
    	mov SP, #7FH ; Set the stack pointer to the begining of idata
        mov LEDRA, #0
        mov LEDRB, #0
        mov LEDRC, #0
        mov LEDG, #0

Forever:        
        setb T0 ;configures T0 as an input 	
        lcall InitTimer0 ;1) Set up the counter to count pulses from T0
        clr TR0 ;stop counter 0
        mov TL0, #0 ; Reset counter low
        mov TH0, #0 ; Reset counter high
        setb TR0 ; Start counting
        lcall Wait1s ; Wait one second
        clr TR0 ; Stop counter 0
        
        ;Display values of counter registers, and the overflow register (R7)
        ;mov LEDRB,TH0
        ;mov LEDRA,TL0
        ;mov LEDG,R7
        
        call multiply24
        mov R3,TL0
        mov R4,TH0
        mov R5,#0
        call add24
        
        ;mov LEDRB,R2
        ;mov LEDRA,R1
        ;mov LEDG,R0
        
        call hex2bcd
        call correctBCDvalues
        call display
        
    	jmp Forever

END