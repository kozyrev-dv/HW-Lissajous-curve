library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library std;
    use std.env.all;

use work.basics_p.all;

entity vga_ctrl_tb is
end entity vga_ctrl_tb;

architecture RTL of vga_ctrl_tb is
    constant CLK_SIM_PERIOD : time := 2 ns;

    constant CLK_FREQ_HZ : integer := 50_000_000;
    constant DISPLAY_PXL_SIDE : integer := 16;
    constant MIN_BLANKING_PXLS : integer := 6;
    constant DISPLAY_FPS_HZ : integer := 83305;
    
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '1';

    signal img_i : std_logic_vector(3 downto 0);
    signal valid_i : std_logic := '0';
    signal ready_o : std_logic;

    signal vga_r_o : std_logic_vector(3 downto 0);
    signal vga_g_o : std_logic_vector(3 downto 0);
    signal vga_b_o : std_logic_vector(3 downto 0);
    signal vga_hsync_o : std_logic;
    signal vga_vsync_o : std_logic;

    signal write_start : boolean := FALSE;
    signal write_finished : boolean := TRUE;
begin

    vga_ctrl_inst : entity work.vga_ctrl
        generic map(
            CLK_FREQ_HZ       => CLK_FREQ_HZ,
            DISPLAY_PXL_SIDE  => DISPLAY_PXL_SIDE,
            MIN_BLANKING_PXLS => MIN_BLANKING_PXLS,
            DISPLAY_FPS_HZ    => DISPLAY_FPS_HZ
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,
            img_i       => img_i,
            valid_i     => valid_i,
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
        wait for CLK_SIM_PERIOD * 700;

        rst_n <= '0';
        wait for CLK_SIM_PERIOD * 2;
        rst_n <= '1';
        
        wait for CLK_SIM_PERIOD * 700;
        
        write_start <= TRUE;
        wait until write_finished;
        write_start <= FALSE;

        wait for CLK_SIM_PERIOD * 700;

        rst_n <= '0';
        wait for CLK_SIM_PERIOD * 2;
        rst_n <= '1';
        
        write_start <= TRUE;
        wait until write_finished;
        write_start <= FALSE;

        for i in 0 to DISPLAY_PXL_SIDE - 1 loop
            wait until rising_edge(vga_vsync_o);
            report "VGA_Vsync counted = " & integer'image(i) severity note;
            
        end loop;
        
        wait for CLK_SIM_PERIOD * 100;

        stop;
    end process stimuli;
    
    write_img : process is
    begin
        while TRUE loop
            wait until write_start;
            write_finished <= FALSE;
            report boolean'image(write_finished) severity note;

            for i in 0 to DISPLAY_PXL_SIDE * DISPLAY_PXL_SIDE - 1 loop
                valid_i <= '1';
                img_i <= std_logic_vector(to_unsigned((i + 1) mod 16, img_i'length));
                wait until rising_edge(clk);
            end loop;

            valid_i <= '0';
            write_finished <= TRUE;
        end loop;
    end process write_img;
    


end architecture RTL;
