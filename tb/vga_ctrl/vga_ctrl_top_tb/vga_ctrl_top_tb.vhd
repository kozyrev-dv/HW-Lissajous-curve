library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library std;
    use std.env.all;

use work.basics_p.all;

entity vga_ctrl_top_tb is
end entity vga_ctrl_top_tb;


architecture RTL of vga_ctrl_top_tb is
    constant CLK_SIM_PERIOD : time := 2 ns;

    signal clk : std_logic := '0';
    signal rst_n : std_logic := '1';

    signal ready_o : std_logic;
    signal vga_r_o : std_logic_vector(3 downto 0);
    signal vga_g_o : std_logic_vector(3 downto 0);
    signal vga_b_o : std_logic_vector(3 downto 0);
    signal vga_hsync_o : std_logic;
    signal vga_vsync_o : std_logic;
begin

    vga_ctrl_top_inst : entity work.vga_ctrl_top
        port map(
            clk         => clk,
            rst_n       => rst_n,
            ready_o     => ready_o,
            vga_r_o     => vga_r_o,
            vga_g_o     => vga_g_o,
            vga_b_o     => vga_b_o,
            vga_hsync_o => vga_hsync_o,
            vga_vsync_o => vga_vsync_o
        );
    
    
    clk <= not clk after CLK_SIM_PERIOD / 2;

    stimuli : process is
    begin
        rst_n <= '1';
        wait until rising_edge(clk);
        for i in 0 to 32 loop
            wait until rising_edge(vga_vsync_o);
            report "VGA_Vsync counted = " & integer'image(i) severity note;
        end loop;
        stop;
    end process stimuli;
end architecture RTL;
