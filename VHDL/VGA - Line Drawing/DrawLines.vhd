library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DrawLines is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
		 
end DrawLines;

architecture RTL of DrawLines is

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

	type STATE is (CLEAR_SCREEN, INIT_NEW_LINE, DRAW_LINES, FINISHED, CLOCK_DIV);
	signal current_state : STATE := CLOCK_DIV; -- start here because vga outputs take extra time to appear on screen initially

	signal screen_cleared : std_logic := '0';
	signal clear_screen_request : std_logic := '0';
	signal done_line : std_logic := '0';
	signal initialize_new_line : std_logic := '0';	
	signal start_timer : std_logic := '0';
	signal timer_done : std_logic := '0';

	signal x_clear : unsigned(7 downto 0) := "00000000";
	signal y_clear : unsigned(6 downto 0) := "0000000";

	signal X0_line : signed(7 downto 0) := "00000000";
	signal Y0_line : signed(6 downto 0) := "0000000";

	signal x      : std_logic_vector(7 downto 0);
	signal y      : std_logic_vector(6 downto 0);
	signal colour : std_logic_vector(2 downto 0);
	signal plot   : std_logic;

	signal inital_wait : std_logic := '1';

	signal line_num : unsigned(3 downto 0) := "0001";

	TYPE stv_array IS ARRAY (0 to 7) OF std_logic_vector(2 downto 0);
	signal gray_code_array : stv_array := (("000"), ("001"), ("011"), ("010"), ("110"), ("111"), ("101"), ("100"));   

	signal rst_n : std_logic;

begin

	rst_n <= KEY(3);

	vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => rst_n,
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
				 
	screen_clearing: process(rst_n, CLOCK_50)
	begin
		if (rst_n = '0') THEN 
			screen_cleared <= '0'; 
			y_clear <= "0000000";
			x_clear <= "00000000"; 
		elsif (rising_edge(CLOCK_50)) then
			if(clear_screen_request = '1') then
				screen_cleared <= '0';
				
				if( x_clear < "10011111" ) then	-- check to see if x is less than 159
					if( y_clear < "1110111" ) then	-- check to see if y is less than 119
						y_clear <= y_clear + 1;
					else								
						y_clear <= "0000000";			-- if y > 119, set y back to 0
						x_clear <= x_clear + 1;	-- increment x to next column since we went through all rows with y
					end if;
				
				elsif( x_clear = "10011111" ) then
					if( y_clear < "1110111" ) then 
						y_clear <= y_clear + 1;
					else
						y_clear <= "0000000";
						x_clear <= "00000000"; 
						screen_cleared <= '1';
					end if;
				end if;	
				
			else
				screen_cleared <= '0';
			end if;
		end if;
	end process;
					 
	line_drawing : process(rst_n, CLOCK_50)
		variable X0, X1, dx : signed(8 downto 0);
		variable Y0, Y1, dy : signed(8 downto 0);
		variable sx, sy: signed(8 downto 0);
		variable err : signed(8 downto 0);
		variable e2: signed(17 downto 0);
	begin
		if (rst_n = '0') THEN 
			done_line <= '0';
		elsif( rising_edge(CLOCK_50)) then	
			
			if (initialize_new_line = '1' ) then
				done_line <= '0';

				X0 := to_signed(0, X0'length);
				Y0 := to_signed(to_integer(line_num)*8, Y0'length);
				X1 := to_signed(159, X1'length);
				Y1 := to_signed(120 - (to_integer(line_num)*8), Y1'length);
				
				if (X1 > X0) then
					dx := X1 - X0;
				else
					dx := X0 - X1;
				end if;
				
				if (Y1 > Y0) then
					dy := Y1 - Y0;
				else
					dy := Y0 - Y1;
				end if;
				
				if (X0 < X1) then 
					sx := "000000001";
				else 
					sx := to_signed(-1, sx'LENGTH);
				end if;
				
				if (Y0 < Y1)then 
					sy := "000000001";
				else 
					sy := to_signed(-1, sy'LENGTH);
				end if;
				 
				err := dx - dy;
				
			else
			
				if (X0 = X1 and Y0 = Y1) then
					done_line <= '1';
				else
			
				   e2 := 2 * err;
				  
					if (e2 > (0 - dy)) then
						err := err - dy;
						X0 := X0 + sx;
					end if;
			
					if (e2 < dx) then
						err := err + dx;
						Y0 := Y0 + sy;
					end if;
					
				end if;
			end if; --initialize_new_line

			X0_line <= X0(7 downto 0);
			Y0_line <= Y0(6 downto 0);
			
		end if; -- rising_edge
	end process;
	
	clk_div : process(all)
		variable count : unsigned(31 downto 0) := x"00000000";
	begin
		if (rst_n = '0') then
			count := x"00000000";
			timer_done <= '0';
		elsif(rising_edge(CLOCK_50)) then
			if (start_timer = '1') then 
			
				count := count + 1;
				
				if (inital_wait = '1') then
					if(count(27) = '1') then -- extra time so first vga outputs will appear on screen
						count := x"00000000";
						timer_done <= '1';
						inital_wait <= '0'; -- this signal is intentionally not reset
					end if;
					
				elsif (count(26) = '1') then -- roughly 1 second
					count := x"00000000";
					timer_done <= '1';
				end if;
				
			else
				timer_done <= '0';
			end if;
		end if;
	end process;
	
	
	fsm : process( rst_n, CLOCK_50 )  
	begin 
		if (rst_n = '0') then
			current_state <= CLEAR_SCREEN;
			initialize_new_line <= '0';
			line_num <= "0001";
			
		elsif( rising_edge(CLOCK_50) ) then 		
			initialize_new_line <= '0';
			start_timer <= '0';
			clear_screen_request <= '0';
			
			case current_state is
				when CLEAR_SCREEN =>
					clear_screen_request <= '1';
					x <= std_logic_vector(x_clear);
					y <= std_logic_vector(y_clear);
					colour <= "000"; --black
					plot <= '1';
					
					if( screen_cleared = '1' ) then
						current_state <= INIT_NEW_LINE;						
						plot <= '0';
					end if;
				
				when INIT_NEW_LINE =>
					initialize_new_line <= '1';
			
					if(done_line = '0') then
						current_state <= DRAW_LINES;
						x <= std_logic_vector(X0_line);
						y <= std_logic_vector(Y0_line);
						colour <= gray_code_array(to_integer(line_num) mod 8);
						plot <= '1';
					end if;
					
				when DRAW_LINES =>
					x <= std_logic_vector(X0_line);
					y <= std_logic_vector(Y0_line);
					colour <= gray_code_array(to_integer(line_num) mod 8);
					plot <= '1';
					
					if( done_line = '1' ) then
						current_state <= FINISHED;
					end if;

				when FINISHED =>
					plot <= '0';
					current_state <= CLOCK_DIV;
					
					if (line_num < 15) then
						line_num <= line_num + 1;
					else
						line_num <= "0001";
					end if;
					
				when CLOCK_DIV =>
					start_timer <= '1';
					
					if (timer_done = '1') then
						current_state <= CLEAR_SCREEN;
					end if;
			end case;
		end if;
	end process;

end RTL;