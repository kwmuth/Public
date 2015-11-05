library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.all;

----------------------------------------------------------------------
--
--  This is the top level template for Lab 2.  Use the schematic on Page 3
--  of the lab handout to guide you in creating this structural description.
--  The combinational blocks have already been designed in previous tasks,
--  and the spinwheel block is given to you.  Your task is to combine these
--  blocks, as well as add the various registers shown on the schemetic, and
--  wire them up properly.  The result will be a roulette game you can play
--  on your DE2.
--
-----------------------------------------------------------------------

entity roulette is
	port(   clock_27 : in std_logic; -- the fast clock for spinning wheel
		KEY : in std_logic_vector(3 downto 0);  -- reset = (1), slow_clock = (0)
		SW : in std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(3 downto 0);  
		hex7 : out std_logic_vector(6 downto 0);  
		hex6 : out std_logic_vector(6 downto 0);  
		hex5 : out std_logic_vector(6 downto 0);  
		hex4 : out std_logic_vector(6 downto 0); 
		hex3 : out std_logic_vector(6 downto 0);  
		hex2 : out std_logic_vector(6 downto 0);  
		hex1 : out std_logic_vector(6 downto 0); 
		hex0 : out std_logic_vector(6 downto 0)  
	);
end roulette;


architecture structural of roulette is
	component digit7seg is
		port(
			digit : in unsigned(3 downto 0);  
			seg7 : out std_logic_vector(6 downto 0)
		);  
	end component;
	
	component spinwheel is
		port(
			fast_clock : in  std_logic;
			resetb : in  std_logic;    
			spin_result : out unsigned(5 downto 0)); 
	end component;
	
	component new_balance is
	  port(money : in unsigned(11 downto 0);  -- Current balance before this spin
			 value1 : in unsigned(2 downto 0); 
			 value2 : in unsigned(2 downto 0); 
			 value3 : in unsigned(2 downto 0); 
			 bet1_wins : in std_logic; 
			 bet2_wins : in std_logic; 
			 bet3_wins : in std_logic;  
			 new_money : out unsigned(11 downto 0));
	end component;
	
	component win is 
	  port(spin_result_latched : 	in unsigned(5 downto 0);  -- result of the spin (the winning number)
					 bet1_value : 			in unsigned(5 downto 0); -- value for bet 1
					 bet2_colour : 		in std_logic;  -- colour for bet 2
					 bet3_dozen : 			in unsigned(1 downto 0);  -- dozen for bet 3
					 bet1_wins : 			out std_logic;  -- whether bet 1 is a winner
					 bet2_wins : 			out std_logic;  -- whether bet 2 is a winner
					 bet3_wins : 			out std_logic); -- whether bet 3 is a winner
	end component;
	
	component twoDigitHexToBCD is
		port(   val_hex : in unsigned(7 downto 0);
				  val_bcd : out unsigned(11 downto 0)
		);
	end component;
	
	component threeDigitHexToBCD is
		port(   val_hex : in unsigned(11 downto 0);
				  val_bcd : out unsigned(15 downto 0)
		);
	end component;

	signal slow_clock, resetb : std_logic;
	
	signal spin_result, spin_result_latched : unsigned(5 downto 0) := "000000";
	signal spin_result_display : unsigned(11 downto 0);
	
	signal bet1_value : unsigned(5 downto 0);
	signal bet2_colour : std_logic;
	signal bet3_dozen : unsigned(1 downto 0);
	signal bet1_wins, bet2_wins, bet3_wins : std_logic;
	
	signal bet1_amt : unsigned(2 downto 0);
	signal bet2_amt : unsigned(2 downto 0);
	signal bet3_amt : unsigned(2 downto 0);
	
	signal money, new_money : unsigned(11 downto 0);
	signal new_money_display : unsigned(15 downto 0);
	
	signal not_in_reset : std_logic := '0';
	
begin
	resetb <= KEY(1);
	slow_clock <= KEY(0);
	
	LEDG(2 downto 0) <= bet3_wins & bet2_wins & (bet1_wins and not_in_reset);
	
	wheel_block : spinwheel port map(fast_clock => clock_27, resetb => resetb, spin_result => spin_result);
	
	win_block: win port map(spin_result_latched => spin_result_latched, 
									bet1_value => bet1_value, bet2_colour => bet2_colour, bet3_dozen => bet3_dozen,
									bet1_wins => bet1_wins, bet2_wins => bet2_wins, bet3_wins => bet3_wins);

	new_money_block : new_balance port map(money => money, new_money => new_money,
														value1 => bet1_amt, value2 => bet2_amt, value3 => bet3_amt, 
														bet1_wins => bet1_wins, bet2_wins => bet2_wins, bet3_wins => bet3_wins);
	
	hex_conv_srl : twoDigitHexToBCD port map(val_hex => ("00" & spin_result_latched), val_bcd => spin_result_display);
	disp_srl0 : digit7seg port map(digit => spin_result_display(3 downto 0), seg7 => hex6);
	disp_srl1 : digit7seg port map(digit => ("00" & spin_result_display(5 downto 4)), seg7 => hex7);

	hex_conv_mon : threeDigitHexToBCD port map(val_hex => new_money, val_bcd => new_money_display);
	disp_mon0 : digit7seg port map(digit => new_money_display(3 downto 0), seg7 => hex0);
	disp_mon1 : digit7seg port map(digit => new_money_display(7 downto 4), seg7 => hex1);
	disp_mon2 : digit7seg port map(digit => new_money_display(11 downto 8), seg7 => hex2);
	disp_mon3 : digit7seg port map(digit => new_money_display(15 downto 12), seg7 => hex3);

	-- disable hex4, hex5
	hex4 <= "1111111";
	hex5 <= "1111111";
	
	regs: process(slow_clock, resetb)
	begin
		if (resetb = '0') then
			spin_result_latched <= "000000";
			
			bet1_value <= "000000";
			bet2_colour <= '0';
			bet3_dozen <= "00";
			
			bet1_amt <= "000";
			bet2_amt <= "000";
			bet3_amt <= "000";
			
			money <= x"020";
			
			not_in_reset <= '0';
		elsif rising_edge(slow_clock) then
			spin_result_latched <= spin_result;
			
			bet1_value <= unsigned(SW(8 downto 3));
			bet2_colour <= SW(12);
			bet3_dozen <= unsigned(SW(17 downto 16));
			
			bet1_amt <= unsigned(SW(2 downto 0));
			bet2_amt <= unsigned(SW(11 downto 9));
			bet3_amt <= unsigned(SW(15 downto 13));
			
			money <= new_money;
			
			not_in_reset <= '1';
		end if;
	end process;
	
end;
