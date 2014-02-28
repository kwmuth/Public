
$MODELP51

CSEG at 0H
ljmp main
Wait_half_second:
;For a 22.1184MHz crystal one machine cycle
;takes 12/22.1184MHz=0.5425347us
mov R2, #10
L3: mov R1, #250
L2: mov R0, #184
L1: djnz R0, L1 ; 2 machine cycles-> 2*0.5425347us*184=200us
djnz R1, L2 ; 200us*250=0.05s
djnz R2, L3 ; 0.05s*10=0.5s
ret
main:
mov SP, #7FH
; Configure port 2 as a bidirectional port,
; just like the original 8051.
mov P2M0, #0
mov P2M1, #0
forever:
cpl P2.0
lcall Wait_half_second
sjmp forever
end