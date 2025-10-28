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
        signal data_a            :  std_logic_vector(8 downto 0);
        signal data_b            :  std_logic_vector(8 downto 0);
        signal data_valid        :  std_logic ;
		  signal i         			: unsigned (3 downto 0);
begin
	

		  
	--DUUUUUUUUUUUUT
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
		  clk <= not clk after 10ns;
		  
   --PROCESSSS
			stim_proc : process
				
			begin
--					 rst <= '1';
--					 wait for 50 ns;
--					 rst <= '0';
--
--					 -- задержка перед первой сменой фазы
--					 wait for 200_000 ns;
						phase_shift_val <= std_logic_vector(unsigned(phase_shift_val) + x"1");
						i <= i +1;
						wait for 25_000 ns;
					 
					--
						phase_shift_val <= std_logic_vector(unsigned(phase_shift_val) + x"1");
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(unsigned(phase_shift_val) + x"1");
						i <= i +1;
						wait for 25_000 ns;
					--
						phase_shift_val <= std_logic_vector(unsigned(phase_shift_val) + x"1");
						i <= i +1;
						wait for 25_000 ns;
						

					 
					 wait;             -- останавливаем процесс
							
				
			end process;
			
end architecture;
