library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

use work.basics_p;
entity img_buf is
    generic(
        DISPLAY_WIDTH : positive := 512;
        DISPLAY_HEIGHT : positive := 512;
        IMG_WIDTH : positive := 512;
        IMG_HEIGHT : positive := 512
    );
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        filled_o : out std_logic := '0';
        --=============================================
        -- Write Side
        --=============================================
        we_i : in std_logic;
        data_i : in std_logic_vector(3 downto 0);
        --=============================================
        -- Read Side
        --=============================================
        rd_adr_x_i : in std_logic_vector(basics_p.clog2(DISPLAY_WIDTH) - 1 downto 0);
        rd_adr_y_i : in std_logic_vector(basics_p.clog2(DISPLAY_HEIGHT) - 1 downto 0);
        re_i : in std_logic;
        data_o : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity img_buf;

architecture RTL of img_buf is
    constant mem_len : integer := IMG_WIDTH * IMG_HEIGHT;
    
    type MEM is array (0 to mem_len - 1) of std_logic_vector(3 downto 0);

    signal ram_block : MEM;
    signal wr_adr_x : natural range 0 to IMG_WIDTH - 1 := 0;
    signal wr_adr_y : natural range 0 to IMG_HEIGHT - 1 := 0;
    signal wr_adr_y_ena : std_logic;
    signal wr_mem_adr : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1 := 0;
    
    signal rd_adr_x_in : natural range 0 to IMG_WIDTH - 1 := 0;
    signal rd_adr_y_in : natural range 0 to IMG_HEIGHT - 1 := 0;
    signal rd_mem_adr : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1 := 0;

    signal mem_data_o : std_logic_vector(3 downto 0);
begin
    
    rd_adr_x_in <= to_integer(unsigned(rd_adr_x_i)) when unsigned(rd_adr_x_i) < IMG_WIDTH  else 0;
    rd_adr_y_in <= to_integer(unsigned(rd_adr_y_i)) when unsigned(rd_adr_y_i) < IMG_HEIGHT else 0;

    wr_adr_x_gen_cntr : process (clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                wr_adr_x <= 0;
                wr_adr_y_ena <= '0';
            else
                if we_i = '1' and filled_o = '0' then
                    if wr_adr_x = IMG_WIDTH - 2 then
                        wr_adr_x <= wr_adr_x + 1;
                        wr_adr_y_ena <= '1';
                    elsif wr_adr_x >= IMG_WIDTH - 1 then
                        wr_adr_x <= 0;
                        wr_adr_y_ena <= '0';
                    else
                        wr_adr_x <= wr_adr_x + 1;
                        wr_adr_y_ena <= '0';
                    end if;
                elsif we_i = '0' and filled_o = '1' then
                    wr_adr_x <= 0;
                    wr_adr_y_ena <= '0';
                end if;
            end if;
        end if;
    end process wr_adr_x_gen_cntr;

    wr_adr_y_gen_cntr : process (clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                wr_adr_y <= 0;
                filled_o <= '0';
            else
                if (wr_adr_y_ena = '1') then
                    if we_i = '1' and filled_o = '0' then
                        if wr_adr_y >= IMG_HEIGHT - 1 then
                            wr_adr_y <= 0;
                            filled_o <= '1';
                        else
                            wr_adr_y <= wr_adr_y + 1;
                            filled_o <= '0';
                        end if;
                    end if;
                end if;
                if we_i = '0' and filled_o = '1' then
                    filled_o <= '0';
                end if;
            end if;
        end if;
    end process wr_adr_y_gen_cntr;
    
    wr_mem_adr <= wr_adr_x + wr_adr_y * IMG_WIDTH;
    rd_mem_adr <= rd_adr_x_in + rd_adr_y_in * IMG_WIDTH;

    memory : process (clk) is
    begin
        if (rising_edge(clk)) then
            if (we_i = '1' and filled_o = '0') then
                ram_block(wr_mem_adr) <= data_i;
            end if;
            mem_data_o <= ram_block(rd_mem_adr);
        end if;
    end process memory;
    
    data_o <= mem_data_o when re_i = '1' and unsigned(rd_adr_x_i) < IMG_WIDTH and unsigned(rd_adr_y_i) < IMG_HEIGHT else (others => '0');
    
end architecture RTL;