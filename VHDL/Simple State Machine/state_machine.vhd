library ieee;
use ieee.std_logic_1164.all;

entity state_machine is
   port (clk : in std_logic;  -- clock input to state machine
         resetb : in std_logic;  -- active-low reset input
         dir : in std_logic;     -- dir input
         hex0 : out std_logic_vector(6 downto 0)  -- output of state machine
   );
end state_machine;

architecture behavioural of state_machine is
	type letters is (A_FIRST, L_SECOND, E_THIRD, X_FOURTH, A_FIFTH, N_SIXTH, D_SEVENTH, E_EIGTH);
	signal curr_state : letters;
begin	

	state_change: process(all)
		variable next_state : letters;
	begin
		if(resetb = '0') then
			curr_state <= A_FIRST;
		elsif(rising_edge(clk)) then
			if(dir = '1') then
				case curr_state is	  
					when A_FIRST   => next_state := L_SECOND;
				   when L_SECOND  => next_state := E_THIRD;
				   when E_THIRD   => next_state := X_FOURTH;	  
				   when X_FOURTH  => next_state := A_FIFTH;
				   when A_FIFTH   => next_state := N_SIXTH;
				   when N_SIXTH   => next_state := D_SEVENTH;
				   when D_SEVENTH => next_state := E_EIGTH;
				   when others    => next_state := A_FIRST; --others should always be E_EIGTH
				end case;
			else
				case curr_state is	  
					when A_FIRST   => next_state := E_EIGTH;
				   when L_SECOND  => next_state := A_FIRST;
				   when E_THIRD   => next_state := L_SECOND;
				   when X_FOURTH  => next_state := E_THIRD;
				   when A_FIFTH   => next_state := X_FOURTH;
				   when N_SIXTH   => next_state := A_FIFTH;
				   when D_SEVENTH => next_state := N_SIXTH;
				   when others    => next_state := D_SEVENTH;
				end case;
			end if;

			curr_state <= next_state;
		end if;
	end process;	

	hex_output: process(all)
	begin
		case curr_state is
			when A_FIRST   => hex0 <= "0001000";
			when L_SECOND  => hex0 <= "1000111";
			when E_THIRD   => hex0 <= "0000110";
			when X_FOURTH  => hex0 <= "0001001";
			when A_FIFTH   => hex0 <= "0001000";
			when N_SIXTH   => hex0 <= "0101011";
			when D_SEVENTH => hex0 <= "0100001";
			when others    => hex0 <= "0000110"; --others should always be E_EIGTH
		end case;
	end process;
	
	
end behavioural;
