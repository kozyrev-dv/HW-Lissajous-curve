library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

use work.basics_p;
entity img_buf is
    generic(
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
        rd_adr_i : in std_logic_vector(basics_p.clog2(IMG_WIDTH * IMG_HEIGHT) - 1 downto 0);
        re_i : in std_logic;
        data_o : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity img_buf;

architecture RTL of img_buf is
    constant mem_len : integer := IMG_WIDTH * IMG_HEIGHT;
    
    type MEM is array (0 to mem_len - 1) of std_logic_vector(3 downto 0);
    signal ram_block : MEM;
    signal wr_adr : natural := 0;
    signal mem_data_o : std_logic_vector(3 downto 0);
begin

    wr_adr_gen_cntr : process (clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                wr_adr <= 0;
                filled_o <= '0';
            else
                if we_i = '1' and filled_o = '0' then
                    if wr_adr = mem_len - 1 then
                        wr_adr <= 0;
                        filled_o <= '1';
                    else
                        wr_adr <= wr_adr + 1;
                        filled_o <= '0';
                    end if;
                elsif we_i = '0' and filled_o = '1' then
                    wr_adr <= 0;
                    filled_o <= '0';
                end if;
            end if;
        end if;
    end process wr_adr_gen_cntr;
    

    memory : process (clk) is
    begin
        if (rising_edge(clk)) then
            if (we_i = '1' and filled_o = '0') then
                ram_block(wr_adr) <= data_i;
            end if;
            mem_data_o <= ram_block(to_integer(unsigned(rd_adr_i)));
        end if;
    end process memory;
    
    data_o <= mem_data_o when re_i = '1' else (others => '0');

end architecture RTL;