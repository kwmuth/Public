LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a skeleton you can use for the win subblock.  This block determines
--  whether each of the 3 bets is a winner.  As described in the lab
--  handout, the first bet is a "straight-up" bet, the second bet is 
--  a colour bet, and the third bet is a "dozen" bet.
--
--  This should be a purely combinational block.  There is no clock.
--  Remember the rules associated with Pattern 1 in the lectures.
--
---------------------------------------------------------------

ENTITY win IS
	PORT(spin_result_latched : 	in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : 			in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : 		in std_logic;  -- colour for bet 2
             bet3_dozen : 			in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : 			out std_logic;  -- whether bet 1 is a winner
             bet2_wins : 			out std_logic;  -- whether bet 2 is a winner
             bet3_wins : 			out std_logic); -- whether bet 3 is a winner
END win;


ARCHITECTURE behavioural OF win IS

BEGIN
-- Win Detector Logic
process(all)
  variable colour : std_logic;
  variable my_int : integer;
  variable dozen : unsigned(1 downto 0);
begin

	if( spin_result_latched = bet1_value ) then
		bet1_wins <= '1';
	else
		bet1_wins <= '0';
	end if;
	
	my_int := to_integer(spin_result_latched);
	
	case my_int is
		when 1|3|5|7|9|12|14|16|18|19|21|23|25|27|30|32|34|36 => colour := '1';
		when 2|4|6|8|10|11|13|15|17|20|22|24|26|28|29|31|33|35 => colour := '0'; 
		when others => colour := '0';
	end case;
	
	if( my_int = 0 ) then
		bet2_wins <= '0';
	elsif( colour = bet2_colour ) then
		bet2_wins <= '1';
	else
		bet2_wins <= '0';
	end if;
	
	case my_int is
		when 1 to 12 => dozen := "00";
		when 13 to 24 => dozen := "01";
		when 25 to 36 => dozen := "10";
		when others => dozen := "11";
	end case;
	
	if( dozen = bet3_dozen ) then
		bet3_wins <= '1';
	else
		bet3_wins <= '0';
	end if;
		

end process;

end architecture;
