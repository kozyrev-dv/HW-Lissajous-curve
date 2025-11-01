library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gen_sinus_top is
	 generic (
			CLK_FREQ_HZ	: integer := 50_000_000;
			FPS    		: integer := 39_062
    );
	 
    Port (
        clk               : in  std_logic;
        rst               : in  std_logic;
        phase_shift_val   : in  std_logic_vector(3 downto 0);
        data_a            : out std_logic_vector(8 downto 0);
        data_b            : out std_logic_vector(8 downto 0);
        data_valid        : out std_logic
    );
end gen_sinus_top;

architecture rtl of gen_sinus_top is
    signal   addr_a_sig  	: std_logic_vector(7 downto 0);
    signal 	 addr_b_sig  	: std_logic_vector(7 downto 0);
	 signal 	 clk_devider  	: integer range  0 to CLK_FREQ_HZ - 1 := 0;
	 constant strob_Hz  		: integer range  0 to CLK_FREQ_HZ - 1  := CLK_FREQ_HZ / (256 * FPS);
	 signal 	 enable     	: std_logic := '0';

begin

    -- Блок фазового сдвига
    phase_gen_inst : entity work.phase_shifter
        port map (
				enable			 => enable,
            clk             => clk,
            rst             => rst,
            phase_shift_val => phase_shift_val,
            addr_a          => addr_a_sig,
            addr_b          => addr_b_sig
        );

    -- ROM синусоиды
    sinus_lookup_inst : entity work.sinus
        port map (
				enable	  => enable,
            clk        => clk,
				rst        => rst,
            addr_a     => addr_a_sig,
            addr_b     => addr_b_sig,
            data_a     => data_a,
            data_b     => data_b,
            data_valid => data_valid
        );
	
		process(clk,rst)
		begin
			
			-- ClOCK DEVIDER
			
			--RESET
			if rst = '0' then
			  clk_devider <= 0;
			-- CLOCK FRONT EDGE
			elsif rising_edge(clk) then
					-- ClOCK DEVIDER
					if clk_devider = strob_Hz - 1  then
						enable <= '1';
						clk_devider <= 0;
						else
						clk_devider <= clk_devider + 1;
						enable <= '0';
					end if;
			end if;
			
	end process;
		  
		  
		  
end rtl;
