#include <stdio.h> 
#include <at89lp51rd2.h> 
#define CLK 22118400L 
#define BAUD 115200L 
#define TIMER_2_RELOAD (0x10000L-(CLK/(32L*BAUD))) 
#define	F P1_0 
#define	G P1_1 
#define	E P1_2 
#define	D P1_3 
#define	DP P1_4
#define	C P1_5 
#define	B P1_6 
#define A P1_7 

void Display_BPM(  int digit );
void display_val( int digit1, int digit2, int digit3 );
void ClearHEX(void);
void wait (void);
unsigned char _c51_external_startup(void) 
{ 
 // Configure ports as a bidirectional with internal pull-ups. 
 P0M0=0; P0M1=0; 
 P1M0=0; P1M1=0; 
 P2M0=0; P2M1=0; 
 P3M0=0; P3M1=0; 
 AUXR=0B_0001_0001; // 1152 bytes of internal XDATA, P4.4 is GP I/O 
 P4M0=0; P4M1=0; 
 setbaud_timer2(TIMER_2_RELOAD); // Initialize serial port using timer 2 
 return 0; 
} 
 
volatile unsigned char ofcnt;
int BPM_1 = 0;
int BPM_2 = 0;
int BPM_3 = 0;
void OverflowIrqHandler (void) interrupt 1 {
 ofcnt++;
}
 
void main (void) 
{ 	 
 	float period;
 	int BPM = 0;
	int BPM_1 = 0;
	int BPM_2 = 0;
	int BPM_3 = 0;

	TR0=0; // Disable timer/counter 0

	TMOD=0B_00000001; // Set timer/counter 0 as 16-bit timer
	P3_2=1; // Pin used as input
	ET0=1; // enable timer 0 interrupt
	EA=1;

	display_val( BPM_1, BPM_2, BPM_3 );
	while(1)
	{
		TL0=0; TH0=0; ofcnt=0; // Reset the timer and overflow
		while(P2_7!=1) // Wait for the signal to be zero
		{
			display_val( BPM_1, BPM_2, BPM_3 );
		}
		while(P2_7!=0) // Wait for the signal to be one
		{
			display_val( BPM_1, BPM_2, BPM_3 );
		}
		TR0=1; // Start the timer
		while(P2_7!=1) // Wait for the signal to be zero
		{
			display_val( BPM_1, BPM_2, BPM_3 );
		}
		while(P2_7!=0) // Wait for the signal to be one
		{
			display_val( BPM_1, BPM_2, BPM_3 );
		}
		TR0=0; // Stop timer 0, ofcnt-TH0-TL0 has the period!
		period =(ofcnt*65536.0+TH0*256.0+TL0)*(12.0/22.1184e6);
		// Send the period to the serial port
		BPM = 60.0/period;
		BPM_1 = BPM/100;
		BPM_2 = (BPM%100)/10;
		BPM_3 = BPM%10; 
		
		display_val( BPM_1, BPM_2, BPM_3 );
		printf( "\rBPM=%d, period = %f\r\n" , BPM, period);
	}
} 


void wait (void)
{
_asm
;For a 22.1184MHz crystal one machine cycle 
;takes 12/22.1184MHz=0.5425347us
mov R2, #1
L3: mov R1, #10
L2: mov R0, #184
L1: djnz R0, L1 ; 2 machine cycles-> 2*0.5425347us*184=200us
djnz R1, L2 ; 200us*10=0.002s
djnz R2, L3 ; 0.002s*1=1s
ret
_endasm;
}

void display_val( int digit1, int digit2, int digit3 )
{
	P2_0 = 0;
	Display_BPM(digit1 );
	wait();
	P2_0 = 1;
	ClearHEX();
	P2_1 = 0;
	Display_BPM( digit2 );
	wait();
	P2_1 = 1;
	ClearHEX();
	P2_2 = 0;
	Display_BPM( digit3 );
	wait();
	P2_2 = 1;
	ClearHEX();
}


void ClearHEX(void)
{
	A = 1;
	B = 1;
	C = 1;
	D = 1;
	E = 1;
	F = 1;
}

void Display_BPM(  int digit )
{	
	if( digit == 0 )
	{		
		A = 0;
		B = 0;
		C = 0;
		D = 0;
		E = 0;
		F = 0;
		G = 1;
	}
	if( digit == 1 )
	{
		A = 1;
		B = 0;
		C = 0;
		D = 1;
		E = 1;
		F = 1;
		G = 1;
	}
	if( digit == 2 )
	{
		A = 0;
		B = 0;
		C = 1;
		D = 0;
		E = 0;
		F = 1;
		G = 0;
	}
	if( digit == 3 )
	{
		A = 0;
		B = 0;
		C = 0;
		D = 0;
		E = 1;
		F = 1;
		G = 0;
	}
	if( digit == 4 )
	{
		A = 1;
		B = 0;
		C = 0;
		D = 1;
		E = 1;
		F = 0;
		G = 0;
	}
	if( digit == 5 )
	{
		A = 0;
		B = 1;
		C = 0;
		D = 0;
		E = 1;
		F = 0;
		G = 0;
	}
	if( digit == 6 )
	{
		A = 0;
		B = 1;
		C = 0;
		D = 0;
		E = 0;
		F = 0;
		G = 0;
	}
	if( digit == 7 )
	{
		A = 0;
		B = 0;
		C = 0;
		D = 1;
		E = 1;
		F = 1;
		G = 1;
	}
	if( digit == 8 )
	{
		A = 0; 
		B = 0;
		C = 0;
		D = 0;
		E = 0;
		F = 0;
		G = 0;
	}
	if( digit == 9 )
	{
		A = 0;
		B = 0;
		C = 0;
		D = 0;
		E = 1;
		F = 0;
		G = 0;
	}
}

