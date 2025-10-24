library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity vga_address_gen is
    generic(
        DISPLAY_PXL_SIDE : positive := 512;
        BLANKING_PXLS : positive := 512
    );
    port(
        h_cnt : in std_logic_vector(natural(ceil(log2(real(DISPLAY_PXL_SIDE + BLANKING_PXLS)))) downto 0);
        v_cnt : in std_logic_vector(natural(ceil(log2(real(DISPLAY_PXL_SIDE + BLANKING_PXLS)))) downto 0);
        x : out std_logic_vector(natural(ceil(log2(real(DISPLAY_PXL_SIDE + BLANKING_PXLS)))) downto 0);
        y : out std_logic_vector(natural(ceil(log2(real(DISPLAY_PXL_SIDE + BLANKING_PXLS)))) downto 0);
        drawable : out std_logic
    );
end entity vga_address_gen;

architecture RTL of vga_address_gen is
    
begin
    drawable <= std_logic((natural(h_cnt) < DISPLAY_PXL_SIDE) and (natural(v_cnt) < DISPLAY_PXL_SIDE));

    x <= h_cnt when drawable else (others => '0');
    y <= v_cnt when drawable else (others => '0');
end architecture RTL;
