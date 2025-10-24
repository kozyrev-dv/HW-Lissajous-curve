library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity sync_gen is
    generic (
        DISPLAY_SIZE : positive := 512;
        FRONT_PORCH : positive := 20;
        SYNC_PULSE : positive := 20;
        BACK_PORCH : positive := 20;
        POLARITY : boolean := TRUE -- if TRUE SYNC pulse '1' else '0'
    );
    port(
        cnt_i : in std_logic_vector(natural(ceil(log2(real(DISPLAY_SIZE + FRONT_PORCH + SYNC_PULSE + BACK_PORCH)))) downto 0);
        sync_o : out std_logic 
    );
end entity sync_gen;

architecture RTL of sync_gen is
    signal temp : std_logic;
begin
    temp <= '1' when (natural(cnt_i) >= DISPLAY_SIZE + FRONT_PORCH and natural(cnt_i) < DISPLAY_SIZE + FRONT_PORCH + SYNC_PULSE)
            else '0';
    
    sync_o <= temp when POLARITY else not temp;
end architecture RTL;
