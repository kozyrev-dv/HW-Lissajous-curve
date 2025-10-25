library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

use work.basics_p;
entity overflow_counter is
    generic(
        SYNC_SIZE : natural := 600
    );
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        ena : in std_logic;
        cnt_o : out std_logic_vector(basics_p.clog2(SYNC_SIZE) - 1 downto 0) := (others => '0');
        overflow_o : out std_logic := '0'
    );
end entity overflow_counter;

architecture RTL of overflow_counter is
    
begin
    counter : process (clk) is
    begin
        if rising_edge(clk) then
            if (rst_n = '0') then
                cnt_o <= (others => '0');
            else
                if (ena = '1') then
                    if (unsigned(cnt_o) < SYNC_SIZE - 1) then
                        cnt_o <= std_logic_vector(unsigned(cnt_o) + 1);
                    else
                        cnt_o <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process counter;
    
    overflow_o <= '1' when (unsigned(cnt_o) = SYNC_SIZE - 1) else '0';

end architecture RTL;
