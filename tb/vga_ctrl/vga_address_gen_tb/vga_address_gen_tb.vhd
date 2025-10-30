library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library std;
    use std.env.all;
use work.basics_p;

entity vga_address_gen_tb is
end entity vga_address_gen_tb;

architecture RTL of vga_address_gen_tb is
    constant CLK_PERIOD : time := 2 ns;
    constant DISPLAY_PXL_SIDE : integer := 10;
    constant BLANKING_PXLS : integer := 5;
    constant CNT_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_SIDE + BLANKING_PXLS);
    constant ADR_WIDTH : integer := basics_p.clog2(DISPLAY_PXL_SIDE);
    
    
    signal h_cnt : unsigned(CNT_WIDTH - 1 downto 0) := (others => '0');
    signal v_cnt : unsigned(CNT_WIDTH - 1 downto 0) := (others => '0');
    signal x : std_logic_vector(ADR_WIDTH - 1 downto 0);
    signal y : std_logic_vector(ADR_WIDTH - 1 downto 0);
    signal drawable : std_logic;

    signal v_cnt_ena : boolean := FALSE;
begin

    vga_address_gen_inst : entity work.vga_address_gen
        generic map(
            DISPLAY_PXL_SIDE => DISPLAY_PXL_SIDE,
            BLANKING_PXLS    => BLANKING_PXLS
        )
        port map(
            h_cnt    => std_logic_vector(h_cnt),
            v_cnt    => std_logic_vector(v_cnt),
            x        => x,
            y        => y,
            drawable => drawable
        );
    
    stimuli_h_cnt : process is
    begin
        while TRUE loop
            wait for CLK_PERIOD;
            if v_cnt_ena then
                h_cnt <= (others => '0');
            else
                h_cnt <= h_cnt + 1;
            end if;
            v_cnt_ena <= (h_cnt = DISPLAY_PXL_SIDE + BLANKING_PXLS - 1);
        end loop;
    end process stimuli_h_cnt;

    stimuli_v_cnt : process is
    begin
        while TRUE loop
            wait for CLK_PERIOD;
            if v_cnt_ena then
                if v_cnt = DISPLAY_PXL_SIDE + BLANKING_PXLS - 1 then
                    v_cnt <= (others => '0');
                else
                    v_cnt <= v_cnt + 1;
                end if;
            end if;
        end loop;
    end process stimuli_v_cnt;
    
    stimuli : process is
    begin
        wait until v_cnt = 0;
        wait until v_cnt = 0;
        wait until v_cnt = 0;
        stop;
    end process stimuli;
    


end architecture RTL;
