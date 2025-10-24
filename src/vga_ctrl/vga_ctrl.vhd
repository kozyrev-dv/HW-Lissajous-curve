--===================================================
--== Author: Daniil Kozyrev 
--==    e-mail: k-daniilv@mail.ru
--==
--== VGA Controller top module. Controls VGA interface output to display the given image (assumes the image is with identical sides)
--==
--== Generics:
--==    CLK_FREQ_HZ: module's clk frequency (in Hz)
--==    DISPLAY_PXL_SIDE: square image's resultion (from 256 to 512 pxl)
--==    MIN_BLANKING_PXL: min number of pixels to pad the display to achieve desired freame rate and let the display to prepare foir next line/frame
--==    DISPLAY_FPS_HZ: frame rate for display (in Hz). If desire frame rate is smaller then the maximum available with the given MIN_BLANKING_PXL, adjusts number of blanking pixels
--===================================================


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity vga_ctrl is
    generic (
        CLK_FREQ_HZ: positive := 50_000_000;
        DISPLAY_PXL_SIDE: positive range 256 to 512 := 512;
        -- let BLANKING_PXLS >= 88
        MIN_BLANKING_PXLS: positive range 88 to natural'high := 88;
        DISPLAY_FPS_HZ: positive range 1 to CLK_FREQ_HZ / ((DISPLAY_PXL_SIDE + MIN_BLANKING_PXLS) ** 2)
    );
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        --===============================================
        -- Data Path Side (input from Lissajous img gen)
        --===============================================
        img_i: in std_logic_vector(3 downto 0);
        valid_i: in std_logic;
        ready_o: out std_logic;
        --===============================================
        -- Output to VGA
        --===============================================
        vga_r_o: out std_logic_vector(3 downto 0);
        vga_g_o: out std_logic_vector(3 downto 0);
        vga_b_o: out std_logic_vector(3 downto 0);
        vga_hsync_o: out std_logic;
        vga_vsync_o: out std_logic
    );
end entity vga_ctrl;

architecture RTL of vga_ctrl is
    constant BLANKING_PXLS : natural := maximum(MIN_BLANKING_PXLS, 
                                                integer(sqrt(real(CLK_FREQ_HZ) / real(DISPLAY_FPS_HZ))) - DISPLAY_PXL_SIDE);
    signal h_cnt : natural := 0;
    signal h_overflow : std_logic := '0';
    signal v_cnt : natural := 0;
    signal hsync : std_logic := '0';
    signal vsync : std_logic := '0';
    
    signal pxl_x_adr : natural := 0;
    signal pxl_y_adr : natural := 0;
    signal pxl_is_draw : std_logic := '0';
begin

horizontal_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_SIDE + BLANKING_PXLS
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => '0',
        cnt_o  => std_logic_vector(h_cnt),
        full_o => h_overflow
    );
hsync_gen : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_PXL_SIDE,
        FRONT_PORCH  => BLANKING_PXLS / 3,
        SYNC_PULSE   => BLANKING_PXLS / 3,
        BACK_PORCH   => BLANKING_PXLS / 3,
        POLARITY     => TRUE
    )
    port map(
        cnt_i  => std_logic_vector(h_cnt),
        sync_o => hsync
    );

vertical_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_SIDE + BLANKING_PXLS
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => h_overflow,
        cnt_o  => std_logic_vector(v_cnt)
    );
vsync_gen : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_PXL_SIDE,
        FRONT_PORCH  => BLANKING_PXLS / 3,
        SYNC_PULSE   => BLANKING_PXLS / 3,
        BACK_PORCH   => BLANKING_PXLS / 3,
        POLARITY     => TRUE
    )
    port map(
        cnt_i  => std_logic_vector(v_cnt),
        sync_o => vsync
    );

vga_address_gen_inst : entity work.vga_address_gen
    generic map(
        DISPLAY_PXL_SIDE => DISPLAY_PXL_SIDE,
        BLANKING_PXLS    => BLANKING_PXLS
    )
    port map(
        h_cnt    => std_logic_vector(h_cnt),
        v_cnt    => std_logic_vector(v_cnt),
        x        => std_logic_vector(pxl_x_adr),
        y        => std_logic_vector(pxl_y_adr),
        drawable => pxl_is_draw
    );

    

end architecture RTL;
