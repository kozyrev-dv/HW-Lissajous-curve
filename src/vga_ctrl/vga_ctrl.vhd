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
        DISPLAY_PXL_W: positive range 2 to positive'high := 16;
        DISPLAY_PXL_H: positive range 2 to positive'high := 16;

        IMG_PXL_W: positive range 2 to positive'high := 16;
        IMG_PXL_H: positive range 2 to positive'high := 16;
        
        -- let BLANKING_PXLS >= 88
        -- MIN_BLANKING_PXLS: positive range 3 to natural'high := 6;
        FRONT_PORCH_W : positive range 2 to positive'high := 2;
        SYNC_PULSE_W : positive range 2 to positive'high := 2;
        BACK_PORCH_W : positive range 2 to positive'high := 2;
        FRONT_PORCH_H : positive range 2 to positive'high := 2;
        SYNC_PULSE_H : positive range 2 to positive'high := 2;
        BACK_PORCH_H : positive range 2 to positive'high := 2;
        DISPLAY_FPS_HZ: positive := 83305
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
    
function calc_blanking_coef(clk_freq, desired_fps, img_w, img_h : integer) return real is
    constant D_b2 : real := real(22 * img_w + 80 * img_h)**2;
    constant D_4ac : real := 4.0 * 176.0 * (real(img_w * img_h) - real(clk_freq) / real(desired_fps));
    constant D : real := D_b2 - D_4ac;
begin
    assert D >= 0.0 report  "Invalid Windth x Height, clk_freq and desired FPS value combination. " & 
                            "Unable to calculate blanking pixels number" severity error;
    
    return (real(-22 * img_w - 80 * img_h) + sqrt(D)) / (2.0 * 176.0);
end function calc_blanking_coef;

type t_blanking_pixels is record
    front_porch : integer;
    sync_pulse : integer;
    back_porch : integer;
end record t_blanking_pixels;

function calc_blanking_w(clk_freq, desired_fps, img_w, img_h, min_front_porch, min_sync_pulse, min_back_porch : integer) return t_blanking_pixels is
    constant y1: real := calc_blanking_coef(clk_freq, desired_fps, img_w, img_h);
    constant x : real := 8.0 * y1;
    constant blanking_pixels : t_blanking_pixels := (
        front_porch => integer(x),
        sync_pulse => integer(6.0 * x),
        back_porch => integer(3.0 * x)
    );
begin
    basics_p.print_dgb(integer'image(clk_freq));
    basics_p.print_dgb(integer'image(desired_fps));
    basics_p.print_dgb(integer'image(img_w));
    basics_p.print_dgb(integer'image(img_h));
    assert blanking_pixels.front_porch >= min_front_porch
        report "unable to set up FRONT_PORCH_W (" & integer'image(blanking_pixels.front_porch) &") lower than the required minimum ("&integer'image(min_front_porch)&")"
        severity error;
    
    assert blanking_pixels.sync_pulse >= min_sync_pulse
        report "unable to set up SYNC_PULSE_W (" & integer'image(blanking_pixels.sync_pulse) &") lower than the required minimum ("&integer'image(min_sync_pulse)&")"
        severity error;

    assert blanking_pixels.back_porch >= min_back_porch
        report "unable to set up BACK_PORCH_W (" & integer'image(blanking_pixels.back_porch) &") lower than the required minimum ("&integer'image(min_back_porch)&")"
        severity error;
    
    return blanking_pixels;
end function calc_blanking_w;

function calc_blanking_h(clk_freq, desired_fps, img_w, img_h, min_front_porch, min_sync_pulse, min_back_porch : integer) return t_blanking_pixels is
    constant y1: real := calc_blanking_coef(clk_freq, desired_fps, img_w, img_h);
    constant blanking_pixels : t_blanking_pixels := (
        front_porch => integer(5.0 * y1),
        sync_pulse => integer(1.0 * y1),
        back_porch => integer(16.0 * y1)
    );
begin
    assert blanking_pixels.front_porch >= min_front_porch
        report "unable to set up FRONT_PORCH_H (" & integer'image(blanking_pixels.front_porch) &") lower than the required minimum ("&integer'image(min_front_porch)&")"
        severity error;
    
    assert blanking_pixels.sync_pulse >= min_sync_pulse
        report "unable to set up SYNC_PULSE_H (" & integer'image(blanking_pixels.sync_pulse) &") lower than the required minimum ("&integer'image(min_sync_pulse)&")"
        severity error;

    assert blanking_pixels.back_porch >= min_back_porch
        report "unable to set up BACK_PORCH_H (" & integer'image(blanking_pixels.back_porch) &") lower than the required minimum ("&integer'image(min_back_porch)&")"
        severity error;
    
    return blanking_pixels;
end function calc_blanking_h;

    constant BLANKING_PXLS_W : t_blanking_pixels := calc_blanking_w(
        CLK_FREQ_HZ,
        DISPLAY_FPS_HZ,
        DISPLAY_PXL_W,
        DISPLAY_PXL_H,
        FRONT_PORCH_W,
        SYNC_PULSE_W,
        BACK_PORCH_W
    );
    constant BLANKING_PXLS_SUM_W : integer := BLANKING_PXLS_W.front_porch + BLANKING_PXLS_W.sync_pulse + BLANKING_PXLS_W.back_porch;
    
    constant BLANKING_PXLS_H : t_blanking_pixels := calc_blanking_h(
        CLK_FREQ_HZ,
        DISPLAY_FPS_HZ,
        DISPLAY_PXL_W,
        DISPLAY_PXL_H,
        FRONT_PORCH_H,
        SYNC_PULSE_H,
        BACK_PORCH_H
    );
    constant BLANKING_PXLS_SUM_H : integer := BLANKING_PXLS_H.front_porch + BLANKING_PXLS_H.sync_pulse + BLANKING_PXLS_H.back_porch;
    
    constant MAX_FPS : integer := CLK_FREQ_HZ / ((DISPLAY_PXL_W + FRONT_PORCH_W + SYNC_PULSE_W + BACK_PORCH_W) * (DISPLAY_PXL_H + FRONT_PORCH_H + SYNC_PULSE_H + BACK_PORCH_H));

    constant PXL_X_CNTR_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_W + BLANKING_PXLS_SUM_W);
    constant PXL_Y_CNTR_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_H + BLANKING_PXLS_SUM_H);
    constant IMG_ADR_X_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_W);
    constant IMG_ADR_Y_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_H);
    
    signal h_cnt : std_logic_vector(PXL_X_CNTR_WIDTH - 1 downto 0):= (others => '0');
    signal h_overflow : std_logic := '0';
    signal v_cnt : std_logic_vector(PXL_Y_CNTR_WIDTH - 1 downto 0):= (others => '0');
    
    signal disp_x_adr : std_logic_vector(IMG_ADR_X_WIDTH - 1 downto 0):= (others => '0');
    signal disp_y_adr : std_logic_vector(IMG_ADR_Y_WIDTH - 1 downto 0):= (others => '0');
    signal pxl_is_draw : std_logic := '0';
    
    signal filled_o : std_logic;
    signal rgb : std_logic_vector(3 downto 0);
begin

    assert DISPLAY_FPS_HZ <= MAX_FPS
        report "Unable to ensure the desired display FPS (" & integer'image(DISPLAY_FPS_HZ) & "). Please choose value <= " & integer'image(MAX_FPS)
        severity error;
    
    basics_p.print_dgb("MAX_FPS = " & integer'image(MAX_FPS));
    basics_p.print_dgb("---------------------------------------------------------");
    basics_p.print_dgb("BLANKING_PXLS_W = " & integer'image(BLANKING_PXLS_SUM_W));
    basics_p.print_dgb("FRONT_PORCH_W = "& integer'image(BLANKING_PXLS_W.front_porch));
    basics_p.print_dgb("SYNC_PULSE_W = "& integer'image(BLANKING_PXLS_W.sync_pulse));
    basics_p.print_dgb("BACK_PORCH_W = "& integer'image(BLANKING_PXLS_W.back_porch));
    basics_p.print_dgb("---------------------------------------------------------");
    basics_p.print_dgb("BLANKING_PXLS_H length is " & integer'image(BLANKING_PXLS_SUM_H));
    basics_p.print_dgb("FRONT_PORCH_H = "& integer'image(BLANKING_PXLS_H.front_porch));
    basics_p.print_dgb("SYNC_PULSE_H = "& integer'image(BLANKING_PXLS_H.sync_pulse));
    basics_p.print_dgb("BACK_PORCH_H = "& integer'image(BLANKING_PXLS_H.back_porch));
    basics_p.print_dgb("---------------------------------------------------------");
    basics_p.print_dgb("PXL_X_CNTR_WIDTH = " & integer'image(PXL_X_CNTR_WIDTH));
    basics_p.print_dgb("PXL_Y_CNTR_WIDTH = " & integer'image(PXL_Y_CNTR_WIDTH));
    basics_p.print_dgb("IMG_ADR_X_WIDTH = " & integer'image(IMG_ADR_X_WIDTH));
    basics_p.print_dgb("IMG_ADR_Y_WIDTH = " & integer'image(IMG_ADR_Y_WIDTH));
    basics_p.print_dgb("---------------------------------------------------------");
    basics_p.print_dgb("H-Frequency is " & real'image(real(CLK_FREQ_HZ) / real(DISPLAY_PXL_W + BLANKING_PXLS_SUM_W)));
    basics_p.print_dgb("V-Frequency is " & real'image(real(CLK_FREQ_HZ) / (real((DISPLAY_PXL_W + BLANKING_PXLS_SUM_W)*(DISPLAY_PXL_H + BLANKING_PXLS_SUM_H)))));
    basics_p.print_dgb("h_cnt length is " & integer'image(h_cnt'length));
    basics_p.print_dgb("v_cnt length is " & integer'image(v_cnt'length));
    basics_p.print_dgb("---------------------------------------------------------");
    basics_p.print_dgb("disp_x_adr length is " & integer'image(disp_x_adr'length));
    basics_p.print_dgb("disp_y_adr length is " & integer'image(disp_y_adr'length));


horizontal_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_W + BLANKING_PXLS_SUM_W
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => '1',
        cnt_o  => h_cnt,
        overflow_o => h_overflow
    );
hsync_gen : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_PXL_W,
        FRONT_PORCH  => BLANKING_PXLS_W.front_porch,
        SYNC_PULSE   => BLANKING_PXLS_W.sync_pulse,
        BACK_PORCH   => BLANKING_PXLS_W.back_porch,
        POLARITY     => TRUE
    )
    port map(
        cnt_i  => h_cnt,
        sync_o => vga_hsync_o
    );

vertical_cnt : entity work.overflow_counter
    generic map(
        SYNC_SIZE => DISPLAY_PXL_H + BLANKING_PXLS_SUM_H
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        ena    => h_overflow,
        cnt_o  => v_cnt
    );
vsync_gen : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_PXL_H,
        FRONT_PORCH  => BLANKING_PXLS_H.front_porch,
        SYNC_PULSE   => BLANKING_PXLS_H.sync_pulse,
        BACK_PORCH   => BLANKING_PXLS_H.back_porch,
        POLARITY     => TRUE
    )
    port map(
        cnt_i  => v_cnt,
        sync_o => vga_vsync_o
    );

vga_address_gen_inst : entity work.vga_address_gen
    generic map(
        DISPLAY_PXL_W => DISPLAY_PXL_W,
        DISPLAY_PXL_H => DISPLAY_PXL_H,
        BLANKING_PXLS_W    => BLANKING_PXLS_SUM_W,
        BLANKING_PXLS_H    => BLANKING_PXLS_SUM_H
    )
    port map(
        h_cnt    => h_cnt,
        v_cnt    => v_cnt,
        x        => disp_x_adr,
        y        => disp_y_adr,
        drawable => pxl_is_draw
    );

img_buf_inst : entity work.img_buf
    generic map(
        DISPLAY_WIDTH  => DISPLAY_PXL_W,
        DISPLAY_HEIGHT => DISPLAY_PXL_H,
        IMG_WIDTH => IMG_PXL_W,
        IMG_HEIGHT => IMG_PXL_H
    )
    port map(
        clk    => clk,
        rst_n  => rst_n,
        filled_o    => filled_o,
        we_i    => valid_i,
        data_i  => img_i,
        re_i    => pxl_is_draw,
        rd_adr_x_i => disp_x_adr,
        rd_adr_y_i => disp_y_adr,
        data_o  => rgb
    );

    ready_o <= not filled_o;
    vga_r_o <= rgb;
    vga_g_o <= rgb;
    vga_b_o <= rgb;

end architecture RTL;
