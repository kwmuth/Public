library ieee;
use ieee.std_logic_1164.all;

entity Lab1Challenge is
   port (KEY: in std_logic_vector(3 downto 0);  -- push-button switches
         SW : in std_logic_vector(17 downto 0);  -- slider switches
         CLOCK_50: in std_logic;                 -- 50MHz clock input
			CLOCK_27: in std_logic; 					 -- 27MHz clock input
			HEX0 : out std_logic_vector(6 downto 0); -- output to drive digit 0
			HEX1 : out std_logic_vector(6 downto 0) -- output to drive digit 1
   );     
end Lab1Challenge;

architecture structural of Lab1Challenge is
   component state_machine
      port (clk : in std_logic;   -- clock input
				resetb : in std_logic;   -- active-low reset input
				dir : in std_logic;      -- dir switch value
				hex0 : out std_logic_vector(6 downto 0)  -- drive digit 0
      );
   end component;

	component clock_divider
		port (clk_in : in std_logic;
				speed_sel : in std_logic_vector(7 downto 0);
			   clk_out : out std_logic
		);
	end component;
	
   signal slow_clock_50 : std_logic;
	signal slow_clock_27 : std_logic;
	
begin

	 cd_50 : clock_divider port map(clk_in => CLOCK_50, speed_sel => SW(9 downto 2), clk_out => slow_clock_50);
	 cd_27 : clock_divider port map(clk_in => CLOCK_27, speed_sel => SW(17 downto 10), clk_out => slow_clock_27);
	 
    sm_50 : state_machine port map(clk => slow_clock_50,
											  resetb => KEY(0),
											  dir => SW(0),
											  hex0 => HEX0);
										 
	 sm_27 : state_machine port map(clk => slow_clock_27,
											  resetb => KEY(0),
											  dir => SW(1),
											  hex0 => HEX1);

end structural;
