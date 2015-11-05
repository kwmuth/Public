library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.lab4_pkg.all; 


entity lab4 is
  port(CLOCK_50            : in  std_logic;  
	    SW						: in std_logic_vector(17 downto 0);
       KEY                 : in  std_logic_vector(3 downto 0);  
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0); 
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab4;


architecture rtl of lab4 is

  signal resetn : std_logic;
  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  signal draw   : point;
	
  signal rst_n : std_logic;
  
begin
  
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
 
 
  x <= std_logic_vector(draw.x(x'range));
  y <= std_logic_vector(draw.y(y'range));
  
  rst_n <= KEY(3);
 
  controller_state : process(CLOCK_50, rst_n)	 
    variable state : draw_state_type := START; 
	 variable paddle_x : unsigned(draw.x'range); -- left-most pixel of the paddle
	 
	 -- In this implementation, the puck velocity has two components: an x component
	 -- and a y component.  Each component is always +1 or -1.
    variable puck1 :fixed_point;
	 variable puck1_velocity : velocity;
	 
	 variable puck2 :fixed_point;
	 variable puck2_velocity : velocity;
	 
	 -- This will be used as a counter variable in the IDLE state
    variable clock_counter : natural := 0;	 	 
	 variable paddle_shrink_count : natural := 0;
	 variable paddle_shrink : natural;
	 
	 variable paddle_deflects : natural := 0;
	 variable paddle_speed : natural := 2;
	 
 begin

    if rst_n = '0' then
	     state := INIT;
    elsif rising_edge(CLOCK_50) then

      case state is
		
		  -- ============================================================
		  -- The INIT state sets the variables to their default values
		  -- ============================================================
		  
		  when INIT =>
 
           draw <= (x => to_unsigned(0, draw.x'length),
                 y => to_unsigned(0, draw.y'length));			  
           paddle_x := to_unsigned(PADDLE_X_START, paddle_x'length);
			  
			  puck1.x := to_unsigned(FACEOFF_X, puck1.x'length/2) & x"00";
			  puck1.y := to_unsigned(FACEOFF_Y, puck1.y'length/2) & x"00";
			  
			  -- 0.96,-0.25
			  --puck1_velocity.x := to_signed(x"FF08", puck1_velocity.x'length );
			  --puck1_velocity.y := to_signed(x"FF", puck1_velocity.y'length );
			  puck1_velocity.x := x"00F8";
			  puck1_velocity.y := x"FF40";
			  puck2.x := to_unsigned((FACEOFF_X - 20), puck2.x'length/2 ) & x"00";
			  puck2.y := to_unsigned(FACEOFF_Y, puck2.y'length/2 ) & x"00";
			  
			  -- -0.5,0.86
			  puck2_velocity.x := x"FF80";
			  puck2_velocity.y := x"00E0";
			  --puck2_velocity.x := to_signed(0, puck2_velocity.x'length );
			  --puck2_velocity.y := to_signed(0, puck2_velocity.y'length );
			  
           colour <= BLACK;
			  plot <= '1';
			  state := START;  

			  paddle_shrink := 0;
			  paddle_speed := 2;
		  -- ============================================================
        -- the START state is used to clear the screen.  We will spend many cycles
		  -- in this state, because only one pixel can be updated each cycle.  The  
		  -- counters in draw.x and draw.y will be used to keep track of which pixel 
		  -- we are erasing.  
		  -- ============================================================
		  
        when START =>	
		  
		    -- See if we are done erasing the screen		    
          if draw.x = SCREEN_WIDTH-1 then
            if draw.y = SCREEN_HEIGHT-1 then
				
				  -- We are done erasing the screen.  Set the next state 
				  -- to DRAW_TOP_ENTER

              state := DRAW_TOP_ENTER;	
		  
            else
				
				  -- In this cycle we will be erasing a pixel.  Update 
				  -- draw.y so that next time it will erase the next pixel
				  
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
   			  draw.x <= to_unsigned(0, draw.x'length);				  
            end if;
          else	
	
            -- Update draw.x so next time it will erase the next pixel    
			  	
            draw.x <= draw.x + to_unsigned(1, draw.x'length);

          end if;

		  -- ============================================================
        -- The DRAW_TOP_ENTER state draws the first pixel of the bar on
		  -- the top of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_TOP_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_TOP_ENTER =>				
			     draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
				  draw.y <= to_unsigned(TOP_LINE, draw.y'length);
				  colour <= GREEN;
				  state := DRAW_TOP_LOOP;
			  
		  -- ============================================================
        -- The DRAW_TOP_LOOP state is used to draw the rest of the bar on 
		  -- the top of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
        when DRAW_TOP_LOOP =>	
		  
           -- See if we have been in this state long enough to have completed the line
    		  if draw.x = RIGHT_LINE then
			     -- if so, the next state is DRAW_RIGHT_ENTER			  
              state := DRAW_RIGHT_ENTER; -- next state is DRAW_RIGHT
            else
				
				  -- Otherwise, update draw.x to point to the next pixel
              draw.y <= to_unsigned(TOP_LINE, draw.y'length);
              draw.x <= draw.x + to_unsigned(1, draw.x'length);
				  
				  -- Do not change the state, since we want to come back to this state
				  -- the next time we come through this process (at the next rising clock
				  -- edge) to finish drawing the line
				  
            end if;

		  -- ============================================================
        -- The DRAW_RIGHT_ENTER state draws the first pixel of the bar on
		  -- the right-side of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_RIGHT_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_RIGHT_ENTER =>				
			  draw.y <= to_unsigned(TOP_LINE, draw.x'length);
			  draw.x <= to_unsigned(RIGHT_LINE, draw.x'length);	
		     state := DRAW_RIGHT_LOOP;
   		  
		  -- ============================================================
        -- The DRAW_RIGHT_LOOP state is used to draw the rest of the bar on 
		  -- the right side of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
		  when DRAW_RIGHT_LOOP =>	

		  -- See if we have been in this state long enough to have completed the line
	   	  if draw.y = SCREEN_HEIGHT-1 then
		  
			     -- We are done, so the next state is DRAW_LEFT_ENTER	  
	 
              state := DRAW_LEFT_ENTER;	-- next state is DRAW_LEFT
            else

				  -- Otherwise, update draw.y to point to the next pixel				
              draw.x <= to_unsigned(RIGHT_LINE,draw.x'length);
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
            end if;	

		  -- ============================================================
        -- The DRAW_LEFT_ENTER state draws the first pixel of the bar on
		  -- the left-side of the screen.  The machine only stays here for
		  -- one cycle; the next cycle it is in DRAW_LEFT_LOOP to draw the
		  -- rest of the bar.
		  -- ============================================================
		  
		  when DRAW_LEFT_ENTER =>				
			  draw.y <= to_unsigned(TOP_LINE, draw.x'length);
			  draw.x <= to_unsigned(LEFT_LINE, draw.x'length);	
		     state := DRAW_LEFT_LOOP;
   		  
		  -- ============================================================
        -- The DRAW_LEFT_LOOP state is used to draw the rest of the bar on 
		  -- the left side of the screen.
        -- Since we can only update one pixel per cycle,
        -- this will take multiple cycles
		  -- ============================================================
		  
		  when DRAW_LEFT_LOOP =>

		  -- See if we have been in this state long enough to have completed the line		  
          if draw.y = SCREEN_HEIGHT-1 then

			     -- We are done, so get things set up for the IDLE state, which 
				  -- comes next.  
				  
              state := IDLE;  -- next state is IDLE
				  clock_counter := 0;  -- initialize counter we will use in IDLE  
				  
            else
				
				  -- Otherwise, update draw.y to point to the next pixel					
              draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
              draw.y <= draw.y + to_unsigned(1, draw.y'length);
            end if;	
				  
		  
		  -- ============================================================
        -- The IDLE state is basically a delay state.  If we didn't have this,
		  -- we'd be updating the puck location and paddle far too quickly for the
		  -- the user.  So, this state delays for 1/8 of a second.  Once the delay is
		  -- done, we can go to state ERASE_PADDLE.  Note that we do not try to
		  -- delay using any sort of wait statement: that won't work (not synthesziable).  
		  -- We have to build a counter to count a certain number of clock cycles.
		  -- ============================================================
		  
        when IDLE =>  
		  
		    -- See if we are still counting.  LOOP_SPEED indicates the maximum 
			 -- value of the counter
			 
			 plot <= '0';  -- nothing to draw while we are in this state
			 
			 if paddle_shrink_count = PADDLE_SHRINK_SPEED then 
				 paddle_shrink_count := 0;
				 
				 if paddle_shrink < MAX_PADDLE_SHRINK then
					paddle_shrink := paddle_shrink + 1;
				 end if;
				 
			 end if;
			 
          if clock_counter < LOOP_SPEED then
			    clock_counter := clock_counter + 1;
          else 
			 
			     -- otherwise, we are done counting.  So get ready for the 
				  -- next state which is ERASE_PADDLE_ENTER				  				  
				  paddle_shrink_count := paddle_shrink_count + 1;
              clock_counter := 0;
              state := ERASE_PADDLE_ENTER;  -- next state
				  
				  -- gravity
				  puck1_velocity.y := puck1_velocity.y + x"0008" + signed((x"000" & SW(3 downto 0)));
				  puck2_velocity.y := puck2_velocity.y + x"0008" + signed((x"000" & SW(3 downto 0)));
				  

			 end if;

			 
		  -- ============================================================
        -- In the ERASE_PADDLE_ENTER state, we will erase the first pixel of
		  -- the paddle. We will only stay here one cycle; the next cycle we will
		  -- be in ERASE_PADDLE_LOOP which will erase the rest of the pixels
		  -- ============================================================     		 

		  when ERASE_PADDLE_ENTER =>		  
              draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
		     	  draw.x <= paddle_x;	
              colour <= BLACK;
              plot <= '1';			
              state := ERASE_PADDLE_LOOP;				 
				  
		  -- ============================================================
        -- In the ERASE_PADDLE_LOOP state, we will erase the rest of the paddle. 
		  -- Since the paddle consists of multiple pixels, we will stay in this state for
		  -- multiple cycles.  draw.x will be used as the counter variable that
		  -- cycles through the pixels that make up the paddle.
		  -- ============================================================
		  
		  when ERASE_PADDLE_LOOP =>
		  
				-- Don't want to erase the right border
				if (paddle_x + PADDLE_WIDTH - paddle_shrink = RIGHT_LINE - 1) and (draw.x = paddle_x + PADDLE_WIDTH - paddle_shrink) then		
				
					state := DRAW_PADDLE_ENTER;
					
		  		-- See if we are done erasing the paddle (done with this state)
				-- erase one extra spot to account for paddle shrinking
				-- if this is black space, drawing black over it won't make a difference
            elsif draw.x = paddle_x + PADDLE_WIDTH - paddle_shrink + 1 then							
				  
              state := DRAW_PADDLE_ENTER;

            else

				  -- we are not done erasing the paddle.  Erase the pixel and update
				  -- draw.x by increasing it by 1
   		     draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
              draw.x <= draw.x + to_unsigned(1, draw.x'length);
				  
				  -- state stays the same, since we want to come back to this state
				  -- next time through the process (next rising clock edge) until 
				  -- the paddle has been erased
				  
            end if;

		  -- ============================================================
        -- The DRAW_PADDLE_ENTER state will start drawing the paddle.  In 
		  -- this state, the paddle position is updated based on the keys, and
		  -- then the first pixel of the paddle is drawn.  We then immediately
		  -- go to DRAW_PADDLE_LOOP to draw the rest of the pixels of the paddle.
		  -- ============================================================
		  
		  when DRAW_PADDLE_ENTER =>
		  		  -- change difficulty
				  paddle_speed := 2 + to_integer(unsigned(SW(17 downto 16)));
				  -- We need to figure out the x location of the paddle before the 
				  -- start of DRAW_PADDLE_LOOP.  The x location does not change, unless
				  -- the user has pressed one of the buttons.
				  
				  if (KEY(0) = '0') then 
				  
				     -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
				 
						if paddle_x <= to_unsigned(RIGHT_LINE - (PADDLE_WIDTH - paddle_shrink + 1) - paddle_speed, paddle_x'length) then 

								-- add 2 to the paddle position
								paddle_x := paddle_x + to_unsigned(paddle_speed, paddle_x'length) ;
				  
					  -- If the user has pressed the right button check to make sure we
					  -- are not already at the rightmost position of the screen
						--elsif paddle_x <= to_unsigned(RIGHT_LINE - (PADDLE_WIDTH - paddle_shrink + 1) - 1, paddle_x'length) then 
	               else
							paddle_x := to_unsigned(RIGHT_LINE - (PADDLE_WIDTH - paddle_shrink + 1), paddle_x'length) ;
								-- add 2 to the paddle position
	--							paddle_x := paddle_x + to_unsigned(1, paddle_x'length) ;
				  
						end if;
					  
				  elsif (KEY(1) = '0') then
				  
				     -- If the user has pressed the left button check to make sure we
					  -- are not already at the leftmost position of the screen
				  
				     if paddle_x >= to_unsigned(LEFT_LINE + 1 + paddle_speed, paddle_x'length) then 				 
					 
					      -- subtract 2 from the paddle position 
   				      paddle_x := paddle_x - to_unsigned(paddle_speed, paddle_x'length) ;	
					  else
							paddle_x := to_unsigned(LEFT_LINE + 1, paddle_x'length) ;
					  end if;
				  end if;

              -- In this state, draw the first element of the paddle	
				  
   		     draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);				  
				  draw.x <= paddle_x;  -- get ready for next state			  
              colour <= BLUE;
		        state := DRAW_PADDLE_LOOP;

		  -- ============================================================
        -- The DRAW_PADDLE_LOOP state will draw the rest of the paddle. 
		  -- Again, because we can only update one pixel per cycle, we will 
		  -- spend multiple cycles in this state.  
		  -- ============================================================
		  
		  when DRAW_PADDLE_LOOP =>
		  
		      -- See if we are done drawing the paddle

            if draw.x = paddle_x +(PADDLE_WIDTH - paddle_shrink) then
				
				  -- If we are done drawing the paddle, set up for the next state
				  
              plot  <= '0';  
              state := ERASE_PUCK1;	-- next state is ERASE_PUCK
				else		
				
				  -- Otherwise, update the x counter to the next location in the paddle 
              draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
              draw.x <= draw.x + to_unsigned(1, draw.x'length);

				  -- state stays the same so we come back to this state until we
				  -- are done drawing the paddle

				 end if;
				
		  -- ============================================================
        -- The ERASE_PUCK state erases the puck from its old location   
		  -- At also calculates the new location of the puck. Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.
		  -- ============================================================
		  
        when ERASE_PUCK1 =>
				  paddle_deflects := 0;
				  colour <= BLACK;  -- erase by setting colour to black
              plot <= '1';
				  --draw <= puck1;  -- the x and y lines are driven by "puck" which 
				                 -- holds the location of the puck.
				  draw.x <= puck1.x(15 downto 8);
				  draw.y <= puck1.y(15 downto 8);
				  state := DRAW_PUCK1;  -- next state is DRAW_PUCK.

				  -- update the location of the puck 
				  puck1.x := unsigned( signed(puck1.x) + puck1_velocity.x);
				  puck1.y := unsigned( signed(puck1.y) + puck1_velocity.y);				  
				  
				  if puck1.x(15 downto 8) >= paddle_x and puck1.x(15 downto 8) <= paddle_x + (PADDLE_WIDTH - paddle_shrink) then
				     paddle_deflects := 1;
				  end if;
				  
				  -- See if we have bounced off the top of the screen
				  if puck1.y(15 downto 8) = TOP_LINE + 1 then
				     puck1_velocity.y := 0-puck1_velocity.y;
				  end if;

				  -- See if we have bounced off the right or left of the screen
				  if puck1.x(15 downto 8) = LEFT_LINE + 1 or
				     puck1.x(15 downto 8) = RIGHT_LINE - 1 then
				     puck1_velocity.x := 0-puck1_velocity.x;
				  end if;				  
		
              -- See if we have bounced of the paddle on the bottom row of
	           -- the screen						  
				  
		        if puck1.y(15 downto 8) >= PADDLE_ROW - 1 or puck1.y(15 downto 0) <= TOP_LINE then
				     if paddle_deflects = 1 then
					  
					     -- we have bounced off the paddle
   				     puck1_velocity.y := 0-puck1_velocity.y;
						  puck1.y(15 downto 0) := to_unsigned(PADDLE_ROW - 1, 8) & x"00";
				     else
				        -- we are at the bottom row, but missed the paddle.  Reset game!
					     state := INIT;
					  end if;	  
				  end if;
				  
		  -- ============================================================
        -- The DRAW_PUCK draws the puck.  Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.					 
		  -- ============================================================
		  
        when DRAW_PUCK1 =>
				  colour <= YELLOW;
              plot <= '1';
				  --draw <= puck1;
				  draw.x <= puck1.x(15 downto 8);
				  draw.y <= puck1.y(15 downto 8);
				  state := ERASE_PUCK2;	  -- next state is IDLE (which is the delay state)			  

		  -- ============================================================
        -- The ERASE_PUCK state erases the puck from its old location   
		  -- At also calculates the new location of the puck. Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.
		  -- ============================================================
		  
        when ERASE_PUCK2 =>
				  paddle_deflects := 0;
				  colour <= BLACK;  -- erase by setting colour to black
              plot <= '1';
				  --draw <= puck2;  -- the x and y lines are driven by "puck" which 
				                 -- holds the location of the puck.
				  draw.x <= puck2.x(15 downto 8);
				  draw.y <= puck2.y(15 downto 8);
				  state := DRAW_PUCK2;  -- next state is DRAW_PUCK.

				  -- update the location of the puck 
				  puck2.x := unsigned( signed(puck2.x) + puck2_velocity.x);
				  puck2.y := unsigned( signed(puck2.y) + puck2_velocity.y);				  
				  
				  if puck2.x(15 downto 8) >= paddle_x and puck2.x(15 downto 8) <= paddle_x + (PADDLE_WIDTH - paddle_shrink) then
				     paddle_deflects := 1;
				  end if;
				 
				  -- See if we have bounced off the top of the screen
				  if puck2.y(15 downto 8) = TOP_LINE + 1 then
				     puck2_velocity.y := 0-puck2_velocity.y;
				  end if;

				  -- See if we have bounced off the right or left of the screen
				  if puck2.x(15 downto 8) = LEFT_LINE + 1 or
				     puck2.x(15 downto 8) = RIGHT_LINE - 1 then
				     puck2_velocity.x := 0-puck2_velocity.x;
				  end if;				  
		
              -- See if we have bounced of the paddle on the bottom row of
	           -- the screen		
				   
		        if puck2.y(15 downto 8) >= PADDLE_ROW - 1 or puck2.y(15 downto 0) <= TOP_LINE then
				     if paddle_deflects = 1 then
					  
					     -- we have bounced off the paddle
   				     puck2_velocity.y := 0-puck2_velocity.y;
						  puck2.y(15 downto 0) := to_unsigned(PADDLE_ROW - 1, 8) & x"00";
				     else
				        -- we are at the bottom row, but missed the paddle.  Reset game!
					     state := INIT;
					  end if;	  
				  end if;
				  
		  -- ============================================================
        -- The DRAW_PUCK draws the puck.  Note that since
		  -- the puck is only one pixel, we only need to be here for one cycle.					 
		  -- ============================================================
		  
        when DRAW_PUCK2 =>
				  colour <= CYAN;
              plot <= '1';
				  draw.x <= puck2.x(15 downto 8);
				  draw.y <= puck2.y(15 downto 8);
				  state := IDLE;	  -- next state is IDLE (which is the delay state)	  
		  
	 	  -- ============================================================
        -- We'll never get here, but good practice to include it anyway
		  -- ============================================================
		  
		  when others =>
		    state := START;
			 
      end case;
	 end if;
   end process;
end RTL;


