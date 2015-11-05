LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

ENTITY wrapper_tb IS
END wrapper_tb;

ARCHITECTURE behavioural OF wrapper_tb IS

   TYPE test_case_record IS RECORD
       val_hex : unsigned(11 downto 0);
       val_bcd : unsigned(15 downto 0);
   END RECORD;

   TYPE test_case_array_type IS ARRAY (0 to 12) OF test_case_record;

   signal test_case_array : test_case_array_type := (
        (x"000", x"0000"),
        (x"FFF", x"4095"),
        (x"031", x"0049"),
        (x"A0E", x"2574"),
        (x"4F6", x"1270"),
        (x"5D9", x"1497"),
        (x"6EA", x"1770"),
        (x"86B", x"2155"),
        (x"9CF", x"2511"),
        (x"DFA", x"3578"),
        (x"E21", x"3617"),
        (x"FBA", x"4026"),
        (x"700", x"1792")                                                                                        
        );  
		  
	component threeDigitHexToBCD is
		port(   val_hex : in unsigned(11 downto 0);
				  val_bcd : out unsigned(15 downto 0) 
		);
	end component;

   SIGNAL val_hex : unsigned(11 downto 0) := x"000";
   SIGNAL val_bcd : unsigned(15 downto 0);

begin

   dut : threeDigitHexToBCD PORT MAP(
          val_hex => val_hex,
          val_bcd => val_bcd);

   process
   begin   

      val_hex <= x"000";
    
      for i in test_case_array'low to test_case_array'high loop
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " val_hex=" & integer'image(to_integer(test_case_array(i).val_hex));

        val_hex <= test_case_array(i).val_hex;                   

        wait for 1 ns;
        
        report "Expected result= " &  
                    integer'image(to_integer(test_case_array(i).val_bcd)) &
               "  Actual result= " &  
                    integer'image(to_integer(val_bcd));
                                                                    
        assert (test_case_array(i).val_bcd = val_bcd )
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; 
    end process;
end behavioural;