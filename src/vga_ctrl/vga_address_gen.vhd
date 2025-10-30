library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

use work.basics_p;
entity vga_address_gen is
    generic(
        DISPLAY_PXL_W : positive := 512;
        DISPLAY_PXL_H : positive := 512;
        BLANKING_PXLS_W : positive := 512;
        BLANKING_PXLS_H : positive := 512
    );
    port(
        h_cnt : in std_logic_vector(basics_p.clog2(DISPLAY_PXL_W + BLANKING_PXLS_W) - 1 downto 0);
        v_cnt : in std_logic_vector(basics_p.clog2(DISPLAY_PXL_H + BLANKING_PXLS_H) - 1 downto 0);
        x : out std_logic_vector(basics_p.clog2(DISPLAY_PXL_W) - 1 downto 0);
        y : out std_logic_vector(basics_p.clog2(DISPLAY_PXL_H) - 1 downto 0);
        drawable : out std_logic
    );
end entity vga_address_gen;

architecture RTL of vga_address_gen is
    
begin
    
    drawable <= '1' when (unsigned(h_cnt) < DISPLAY_PXL_W) and (unsigned(v_cnt) < DISPLAY_PXL_H)
                else '0';

    x <= h_cnt(x'length - 1 downto 0) when drawable = '1' else (others => '0');
    y <= v_cnt(y'length - 1 downto 0) when drawable = '1' else (others => '0');
end architecture RTL;
