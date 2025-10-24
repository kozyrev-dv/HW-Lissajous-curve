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

use work.basics_p;
entity vga_ctrl is
    generic (
        CLK_FREQ_HZ: positive := 50_000_000;
        DISPLAY_PXL_SIDE: positive range 256 to 512 := 512;
        -- let BLANKING_PXLS >= 88
        MIN_BLANKING_PXLS: positive range 88 to natural'high := 88;
        DISPLAY_FPS_HZ: positive := 10
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
    
    constant MAX_FPS : integer := CLK_FREQ_HZ / ((DISPLAY_PXL_SIDE + MIN_BLANKING_PXLS) ** 2);
    
    constant BLANKING_PXLS : natural := basics_p.max(MIN_BLANKING_PXLS, 
                                            integer(sqrt(real(CLK_FREQ_HZ) / real(DISPLAY_FPS_HZ))) - DISPLAY_PXL_SIDE);

    constant PXL_CNTR_WIDTH : integer := natural(ceil(log2(real(DISPLAY_PXL_SIDE + BLANKING_PXLS))));
    constant IMG_ADR_WIDTH : integer := natural(ceil(log2(real(DISPLAY_PXL_SIDE))));
    
    signal h_cnt : std_logic_vector(PXL_CNTR_WIDTH - 1 downto 0):= (others => '0');
    signal h_overflow : std_logic := '0';
    signal v_cnt : std_logic_vector(PXL_CNTR_WIDTH - 1 downto 0):= (others => '0');
    
    signal img_x_adr : std_logic_vector(IMG_ADR_WIDTH - 1 downto 0):= (others => '0');
    signal img_y_adr : std_logic_vector(IMG_ADR_WIDTH - 1 downto 0):= (others => '0');
    signal pxl_is_draw : std_logic := '0';

    signal rgb : std_logic_vector(3 downto 0);
begin

    assert DISPLAY_FPS_HZ <= MAX_FPS
        report "Unable to ensure the desired display FPS. Please choose value <= " & integer'image(MAX_FPS)
        severity error;
    
    basics_p.print_dgb("MAX_FPS length is " & integer'image(MAX_FPS));
    basics_p.print_dgb("BLANKING_PXLS length is " & integer'image(BLANKING_PXLS));
    basics_p.print_dgb("PXL_CNTR_WIDTH length is " & integer'image(PXL_CNTR_WIDTH));
    basics_p.print_dgb("IMG_ADR_WIDTH length is " & integer'image(IMG_ADR_WIDTH));

    basics_p.print_dgb("h_cnt length is " & integer'image(h_cnt'length));
    basics_p.print_dgb("v_cnt length is " & integer'image(v_cnt'length));

    basics_p.print_dgb("img_x_adr length is " & integer'image(img_x_adr'length));
    basics_p.print_dgb("img_y_adr length is " & integer'image(img_y_adr'length));

horizontal_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_SIDE + BLANKING_PXLS
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => '0',
        cnt_o  => h_cnt,
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
        cnt_i  => h_cnt,
        sync_o => vga_hsync_o
    );

vertical_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_SIDE + BLANKING_PXLS
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => h_overflow,
        cnt_o  => v_cnt
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
        cnt_i  => v_cnt,
        sync_o => vga_vsync_o
    );

vga_address_gen_inst : entity work.vga_address_gen
    generic map(
        DISPLAY_PXL_SIDE => DISPLAY_PXL_SIDE,
        BLANKING_PXLS    => BLANKING_PXLS
    )
    port map(
        h_cnt    => h_cnt,
        v_cnt    => v_cnt,
        x        => img_x_adr,
        y        => img_y_adr,
        drawable => pxl_is_draw
    );

img_buf_inst : entity work.img_buf
    generic map(
        IMG_WIDTH  => DISPLAY_PXL_SIDE,
        IMG_HEIGHT => DISPLAY_PXL_SIDE
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        filled_o    => ready_o,
        we_i    => valid_i,
        data_i  => img_i,
        re_i    => pxl_is_draw,
        rd_adr_i    => std_logic_vector(unsigned(img_x_adr) + unsigned(img_y_adr) * DISPLAY_PXL_SIDE),
        data_o  => rgb
    );

vga_r_o <= rgb;
vga_g_o <= rgb;
vga_b_o <= rgb;

end architecture RTL;
