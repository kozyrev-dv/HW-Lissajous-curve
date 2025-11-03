 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity gen_sinus_top_tb is
end entity;

architecture tb of gen_sinus_top_tb is

        signal clk               :   std_logic:= '0';
        signal rst               :   std_logic := '1';
        signal phase_shift_val   :   std_logic_vector(3 downto 0) := (others => '0');
        signal data_a            :   std_logic_vector(8 downto 0);
        signal data_b            :   std_logic_vector(8 downto 0);
        signal data_valid        :   std_logic ;
		  signal i         			:   unsigned (3 downto 0);
begin
	

		  
	--DUT
    DUT : entity work.gen_sinus_top
        port map(
           clk            		=> clk,
			  rst              	=> rst,
			  phase_shift_val   	=> phase_shift_val,
 			  data_a           	=> data_a,
			  data_b            	=> data_b,
			  data_valid        	=> data_valid  
        );
	
		-- clock 10 ns
		  clk <= not clk after 10
		  ns;
		  
   --PROCESSSS
			stim_proc : process
				
			begin
			      --
						phase_shift_val <= std_logic_vector(to_unsigned(0,4));
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(to_unsigned(1,4));
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(to_unsigned(2,4));
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(to_unsigned(4,4));
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(to_unsigned(8,4));
						i <= i +1;
						wait for 25_000 ns;
	-- останавливаем процесс
					 wait;             
							
				
			end process;
			
end architecture;
