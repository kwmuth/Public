library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
   port (clk_in  : in  std_logic;
			speed_sel : in std_logic_vector(7 downto 0);
         clk_out : out std_logic
   );     
end clock_divider;

architecture behavioural of clock_divider is	
   signal count : unsigned(35 downto 0) := (others => '0');
begin

	--slowest speed ~ 0.1hz 0
	--fastest speed ~ 4hz   255

    process(clk_in)	
    begin
        if rising_edge (clk_in) then 
            count <= count + 67 + (unsigned(speed_sel)*67);
        end if;
    end process;
	 
    clk_out <= count(35);
	 
end behavioural;