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
        rd_adr_i : in std_logic_vector(basics_p.clog2(DISPLAY_WIDTH * DISPLAY_HEIGHT) - 1 downto 0);
        re_i : in std_logic;
        data_o : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity img_buf;

architecture RTL of img_buf is
    constant mem_len : integer := DISPLAY_WIDTH * DISPLAY_HEIGHT;
    
    type MEM is array (0 to mem_len - 1) of std_logic_vector(3 downto 0);
    -- function initialize_ram return MEM is
    --     variable result : MEM;
    -- begin 
    --     for i in 0 to mem_len - 1 loop
    --         result(i) := std_logic_vector(to_unsigned(i, 4));
    --     end loop; 
    --     return result;
    -- end initialize_ram;

    signal ram_block : MEM;
    signal wr_adr_x : natural := 0;
    signal wr_adr_y : natural := 0;
    signal wr_adr_y_ena : std_logic;
    signal wr_mem_adr : natural := 0;
    signal mem_data_o : std_logic_vector(3 downto 0);
begin
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
                    elsif we_i = '0' and filled_o = '1' then
                        wr_adr_y <= 0;
                        filled_o <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process wr_adr_y_gen_cntr;
    
    wr_mem_adr <= wr_adr_x + wr_adr_y * DISPLAY_WIDTH;

    memory : process (clk) is
    begin
        if (rising_edge(clk)) then
            if (we_i = '1' and filled_o = '0') then
                ram_block(wr_mem_adr) <= data_i;
            end if;
            mem_data_o <= ram_block(to_integer(unsigned(rd_adr_i)));
        end if;
    end process memory;
    
    data_o <= mem_data_o when re_i = '1' else (others => '0');
    -- data_o_gen : process (clk) is
    -- begin
    --     if rising_edge(clk) then
    --         if rst_n = '0' then
    --             data_o <= (others => '0');
    --         else
    --             if (re_i = '0') then
    --                 data_o <= mem_data_o;
    --             end if;
    --         end if;
    --     end if;
    -- end process data_o_gen;
end architecture RTL;