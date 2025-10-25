library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library std;
    use std.env.all;

use work.basics_p;
entity overflow_counter_tb is
end entity overflow_counter_tb;

architecture RTL of overflow_counter_tb is
    constant SYNC_SIZE : integer := 10;
    constant CLK_PERIOD : time := 1 ns;
    
    
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '1';
    signal ena : std_logic := '1';
    signal cnt_o : std_logic_vector(basics_p.clog2(SYNC_SIZE) - 1 downto 0);
    signal overflow_o : std_logic;
begin

    overflow_counter_inst : entity work.overflow_counter
        generic map(
            SYNC_SIZE => SYNC_SIZE
        )
        port map(
            clk    => clk,
            rst_n  => rst_n,
            ena    => ena,
            cnt_o  => cnt_o,
            overflow_o => overflow_o
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimili : process is
    begin
        wait on clk;
        wait for CLK_PERIOD * SYNC_SIZE * 2.5;
        ena <= '0';
        wait for CLK_PERIOD * SYNC_SIZE;
        ena <= '1';
        wait for CLK_PERIOD * SYNC_SIZE;
        rst_n <= '0';
        wait for CLK_PERIOD * 2;
        rst_n <= '1';
        ena <= '0';
        wait for CLK_PERIOD * SYNC_SIZE;
        ena <= '1';
        wait for CLK_PERIOD * SYNC_SIZE;
        stop;
    end process stimili;
    

end architecture RTL;
