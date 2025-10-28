library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.basics_p;
entity vga_ctrl_top is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        ready_o : out std_logic;
        vga_r_o : out std_logic_vector(3 downto 0);
        vga_g_o : out std_logic_vector(3 downto 0);
        vga_b_o : out std_logic_vector(3 downto 0);
        vga_hsync_o : out std_logic;
        vga_vsync_o : out std_logic
    );
end entity vga_ctrl_top;

architecture RTL of vga_ctrl_top is
    constant CLK_FREQ_HZ: positive := 25_175_000;
    constant DISPLAY_PXL_W: positive range 2 to positive'high := 640;
    constant DISPLAY_PXL_H: positive range 2 to positive'high := 480;
    constant IMG_PXL_W: positive range 2 to positive'high := 480;
    constant IMG_PXL_H: positive range 2 to positive'high := 480;
    constant DISPLAY_FPS_HZ: positive := 59;
    
    signal img_i : std_logic_vector(3 downto 0) := (others => '0');
    signal cnt : unsigned(basics_p.clog2(IMG_PXL_W * IMG_PXL_H) - 1 downto 0) := (others => '0');
    signal valid_i : std_logic := '1';
begin

    init : process (clk) is
    begin
        if (rising_edge(clk)) then
            if (rst_n = '0') then
                cnt <= (others => '0');
                valid_i <= '0';
            else
                if (cnt < to_unsigned(2 ** (cnt'high + 1) - 1, cnt'length)) then
                    valid_i <= '1';
                    cnt <= cnt + 1;
                else
                    cnt <= cnt;
                    valid_i <= '0';
                end if;
            end if;
        end if;
    end process init;

    img_i <= std_logic_vector(cnt(3 downto 0) + to_unsigned(to_integer(cnt(3 downto 0)) * DISPLAY_PXL_H, img_i'length));

    vga_ctrl_inst : entity work.vga_ctrl
        generic map(
            CLK_FREQ_HZ       => CLK_FREQ_HZ,
            DISPLAY_PXL_W  => DISPLAY_PXL_W,
            DISPLAY_PXL_H  => DISPLAY_PXL_H,
            IMG_PXL_W => IMG_PXL_W,
            IMG_PXL_H => IMG_PXL_H,
            FRONT_PORCH_W  => 16, -- sum = 950
            SYNC_PULSE_W   => 96,
            BACK_PORCH_W   => 48,
            FRONT_PORCH_H  => 10, -- sum = 44
            SYNC_PULSE_H   => 2,
            BACK_PORCH_H   => 33,
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
    
end architecture RTL;
