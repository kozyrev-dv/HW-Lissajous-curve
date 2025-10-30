library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity phase_shifter is
    port (
        clk     				: in  std_logic;
        rst     				: in  std_logic;
        phase_shift_val 	: in  std_logic_vector(3 downto 0) := (others => '0');
        addr_a 				: out std_logic_vector(7 downto 0) := (others => '0');
		  addr_b 				: out std_logic_vector(7 downto 0) := (others => '0')
    );
end entity;

architecture rtl of phase_shifter is
	signal addr_cnt  			: unsigned (7 downto 0) := (others => '0');
	signal shift_reg 			: std_logic_vector(7 downto 0) := (others => '0');
begin

   process(clk,rst)
		begin
			if rst = '0' then
			  addr_a      			<= (others => '0');
			  addr_cnt    			<= to_unsigned(0,8);
			 elsif rising_edge(clk) then
				if phase_shift_val(3) = '1' then
					shift_reg <= std_logic_vector(to_unsigned(32 * 4, 8));
				elsif phase_shift_val(2) = '1' then
					shift_reg <= std_logic_vector(to_unsigned(32 * 3, 8));
				elsif phase_shift_val(1) = '1' then
					shift_reg <= std_logic_vector(to_unsigned(32 * 2, 8));
				elsif phase_shift_val(0) = '1' then
					shift_reg <= std_logic_vector(to_unsigned(32, 8));
				else 
               shift_reg <= (others => '0');
				end if;
			  -- Gen addres to sinus table
			  addr_a    			<= std_logic_vector(addr_cnt);
			  addr_b  				<= std_logic_vector(unsigned(shift_reg) + addr_cnt);
			  addr_cnt  			<= addr_cnt + to_unsigned(1,8);	  
			end if;
	end process;
	
end architecture;
