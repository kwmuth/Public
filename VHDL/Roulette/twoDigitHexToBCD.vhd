library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.all;

-- can I add a define to make this generalized?
entity twoDigitHexToBCD is
	port(   val_hex : in unsigned(7 downto 0);
			  val_bcd : out unsigned(11 downto 0) 
	);
end twoDigitHexToBCD;

-- implements double dabble algorithm to convert from hex to bcd
-- https://en.wikipedia.org/wiki/Double_dabble
architecture behavourial of twoDigitHexToBCD is
begin	

	bcd_conv : process(val_hex)
		variable tmp : unsigned(val_hex'LEFT downto val_hex'RIGHT);
		variable bcd : unsigned(val_bcd'LEFT downto val_bcd'RIGHT);
	begin
		bcd := (others => '0');
		tmp := val_hex;
	
		for i in val_hex'RIGHT to val_hex'LEFT loop 
			
			if bcd(3 downto 0) > 4 then
				bcd(3 downto 0) := bcd(3 downto 0) + 3;
			end if;
			
			if bcd(7 downto 4) > 4 then
				bcd(7 downto 4) := bcd(7 downto 4) + 3;
			end if;
			
			if bcd(11 downto 8) > 4 then
				bcd(11 downto 8) := bcd(11 downto 8) + 3;
			end if;

			bcd := bcd(bcd'LEFT-1 downto bcd'RIGHT) & tmp(tmp'LEFT);
			tmp := tmp(tmp'LEFT-1 downto tmp'RIGHT) & '0';
			
		end loop;

		val_bcd <= bcd;
		
	end process;
	
end;