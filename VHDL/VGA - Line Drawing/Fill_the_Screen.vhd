library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fill_the_Screen is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
		 
end Fill_the_Screen;

architecture RTL of Fill_the_Screen is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;

begin

  -- includes the vga adapter, which should be in your project 

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);
	


	process(all)
	begin	
	
		if(KEY(3) = '0') then
			x <= "00000000"; 	-- if asynchronous reset is pressed, set everything to zero and wait for rising edge of clock
			y <= "0000000";
			colour <= "000";
			plot <= '0';
		
		elsif(rising_edge(CLOCK_50)) then

			if( x < "10011111" ) then	-- check to see if x is less than 159
				if( y < "1110111" ) then	-- check to see if y is less than 119
					y <= std_logic_vector(unsigned(y) + 1);
				else								
					y <= "0000000";			-- if y > 119, set y back to 0
					x <= std_logic_vector(unsigned(x) + 1);	-- increment x to next column since we went through all rows with y
					
					if( colour < "111" ) then						
						colour <= std_logic_vector(unsigned(colour) + 1);	-- change the colour since we are in new column
					else
						colour <= "000";
					end if;
				end if;
			
			elsif( x = "10011111" ) then
				if( y < "1110111" ) then 
					y <= std_logic_vector(unsigned(y) + 1);
				else
					y <= "0000000";
					x <= "00000000"; 
					colour <= "000";
				end if;
			end if;
		
		plot <= '1';
		
		end if;
	end process;				
end RTL;


