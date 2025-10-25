library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library std;
    use std.env.all;

use work.basics_p;

entity sync_gen_tb is
end entity sync_gen_tb;

architecture RTL of sync_gen_tb is
    constant CLK_PERIOD : time := 2 ns;

    constant DISPLAY_SIZE : integer := 256;
    constant FRONT_PORCH : integer := 5;
    constant SYNC_PULSE : integer := 10;
    constant BACK_PORCH : integer := 5;
    constant CNT_WIDTH : integer := basics_p.clog2(DISPLAY_SIZE + FRONT_PORCH + SYNC_PULSE + BACK_PORCH);
    
    signal cnt_i: unsigned(CNT_WIDTH -1 downto 0) := (others => '0');
    signal sync_o_1 : std_logic := '0';
    signal sync_o_2 : std_logic := '0';
begin

sync_gen_inst_1 : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_SIZE,
        FRONT_PORCH  => FRONT_PORCH,
        SYNC_PULSE   => SYNC_PULSE,
        BACK_PORCH   => BACK_PORCH,
        POLARITY     => TRUE
    )
    port map(
        cnt_i  => std_logic_vector(cnt_i),
        sync_o => sync_o_1
    );

sync_gen_inst_2 : entity work.sync_gen
    generic map(
        DISPLAY_SIZE => DISPLAY_SIZE,
        FRONT_PORCH  => FRONT_PORCH,
        SYNC_PULSE   => SYNC_PULSE,
        BACK_PORCH   => BACK_PORCH,
        POLARITY     => FALSE
    )
    port map(
        cnt_i  => std_logic_vector(cnt_i),
        sync_o => sync_o_2
    );

    stimuli : process is
    begin
        for i in 0 to DISPLAY_SIZE * 4 loop
            cnt_i <= cnt_i + 1;
            wait for CLK_PERIOD;
        end loop;
        stop;
    end process stimuli;
    
end architecture RTL;
