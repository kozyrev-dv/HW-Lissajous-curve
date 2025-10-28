library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library std;
    use std.env.all;

use work.basics_p;

entity img_buf_tb is
end entity img_buf_tb;

architecture RTL of img_buf_tb is
    constant CLK_PERIOD : time := 2 ns;
    constant DISPLAY_WIDTH : integer := 8;
    constant DISPLAY_HEIGHT : integer := 10;
    constant IMG_WIDTH : integer := 6;
    constant IMG_HEIGHT : integer := 6;
    constant ADR_WIDTH : integer := basics_p.clog2(DISPLAY_WIDTH * DISPLAY_HEIGHT);
    
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '1';
    signal filled_o : std_logic;
    signal we_i : std_logic := '0';
    signal data_i : unsigned(3 downto 0);
    signal rd_adr_i : unsigned(ADR_WIDTH - 1 downto 0);
    signal re_i : std_logic := '0';
    signal data_o : std_logic_vector(3 downto 0);

    signal read_loop_num : integer := -1;
    signal is_write_allow : boolean := FALSE;
    signal is_read_allow : boolean := FALSE;
    
    signal is_writing : boolean := FALSE;
    signal is_reading : boolean := FALSE;
begin

    img_buf_inst : entity work.img_buf
        generic map(
            DISPLAY_WIDTH  => DISPLAY_WIDTH,
            DISPLAY_HEIGHT => DISPLAY_HEIGHT,
            IMG_WIDTH => IMG_WIDTH,
            IMG_HEIGHT => IMG_HEIGHT
        )
        port map(
            clk      => clk,
            rst_n    => rst_n,
            filled_o => filled_o,
            we_i     => we_i,
            data_i   => std_logic_vector(data_i),
            rd_adr_i => std_logic_vector(rd_adr_i),
            re_i     => re_i,
            data_o   => data_o
        );
    
    clk <= not clk after CLK_PERIOD / 2;

    stimuli_read : process is
        variable i : integer := 0;
    begin
        while TRUE loop
            wait until is_read_allow;
            re_i <= '0' when read_loop_num = 0 else '1';
            read_loop : for j in 0 to DISPLAY_WIDTH * DISPLAY_HEIGHT - 1 loop
                is_reading <= TRUE;
                rd_adr_i <= to_unsigned(read_loop.j, rd_adr_i'length);
                wait until rising_edge(clk);
            end loop read_loop;
            is_reading <= FALSE;
            i := i + 1;
        end loop;
    end process stimuli_read;

    stimuli_write : process is
        variable i : integer := 0;
    begin
        while TRUE loop
            wait until is_write_allow;
            
            if i = 0 then we_i<='0'; else report "assert we_i" severity note; we_i<='1'; end if;
            if filled_o /= '0' then wait until filled_o = '0'; end if;

            write_loop : for j in 0 to IMG_WIDTH * IMG_HEIGHT - 1 loop
                is_writing <= TRUE;
                if filled_o = '1' then exit write_loop; end if;
                data_i <= to_unsigned(write_loop.j + i, data_i'length);
                wait until rising_edge(clk);
            end loop write_loop;

            report "deassert we_i" severity note;
            we_i <= '0';
            is_writing <= FALSE;
            i := i + 1;
        end loop;
    end process stimuli_write;   
    
    stimuli_rw_control : process is
    begin
        wait until rising_edge(clk);
        
        is_read_allow <= FALSE;
        is_write_allow <= FALSE;
        for i in 0 to 2 loop
            is_read_allow <= TRUE;
            wait until not is_reading;
            is_read_allow <= FALSE;
            is_write_allow <= TRUE;
            wait until not is_writing;
            is_write_allow <= FALSE;
        end loop;
        is_read_allow <= TRUE;
        wait until not is_reading;
        is_read_allow <= FALSE;
        stop;
    end process stimuli_rw_control;

end architecture RTL;
