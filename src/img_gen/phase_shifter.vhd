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
			  shift_reg 			<= std_logic_vector(to_unsigned(32 * to_integer( unsigned("0000" & phase_shift_val)), 8));
			  addr_a    			<= std_logic_vector(addr_cnt);
			  addr_b  				<= std_logic_vector(unsigned(shift_reg) + addr_cnt);
			  addr_cnt  			<= addr_cnt + to_unsigned(1,8);	  
			end if;
	end process;
	
end architecture;
