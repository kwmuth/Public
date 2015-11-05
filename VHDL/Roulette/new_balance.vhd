library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.all;

entity new_balance is
  port(money : in unsigned(11 downto 0);  -- Current balance before this spin
       value1 : in unsigned(2 downto 0); 
       value2 : in unsigned(2 downto 0); 
       value3 : in unsigned(2 downto 0); 
       bet1_wins : in std_logic; 
       bet2_wins : in std_logic; 
       bet3_wins : in std_logic;  
       new_money : out unsigned(11 downto 0));
end new_balance;

architecture behavioural of new_balance is
begin
	
	calc_new_money : process(all)
		variable money_to_add      : unsigned((value1'LENGTH + money'LENGTH) downto 0);
		variable money_to_subtract : unsigned((value1'LENGTH + money'LENGTH) downto 0);
	begin
		money_to_add := x"0000";
		money_to_subtract := x"0000";
  
		if (bet1_wins = '1') then
      money_to_add := money_to_add + to_unsigned(35, money'LENGTH)*(value1);
		else
			money_to_subtract := money_to_subtract + value1;
		end if;

		if (bet2_wins = '1') then
			money_to_add := money_to_add + value2;
		else
			money_to_subtract := money_to_subtract + value2;
		end if;

		if (bet3_wins = '1') then
			money_to_add := money_to_add + to_unsigned(2, money'LENGTH)*value3;
		else
			money_to_subtract := money_to_subtract + value3;
		end if;

		new_money <= money + money_to_add(money'RANGE) - money_to_subtract(money'RANGE);
	
	end process;
	
end;
