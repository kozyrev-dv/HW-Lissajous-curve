library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ADC is
   port (
      ----------------- CLOCK
      clk_adc_10_mhz          : in std_logic;
      reset                   : in std_logic;

      ------------------ OUTPUT
      data_adc_1_o            : out std_logic_vector (11 downto 0)   := (others => '0'); --- заменить сигналы на data_o выходные
      data_adc_2_o            : out std_logic_vector (11 downto 0)   := (others => '0');
      data_valid_o            : out std_logic                        := '0'
   );
end entity ADC;


architecture arch of ADC is
   ------------------ ADC
   signal adc_slave_waitrequest  : std_logic                         := '0';             -- waitrequest
   signal adc_slave_readdata     : std_logic_vector (31 downto 0)    := (others => '0'); -- readdata

   signal adc_slave_write        : std_logic                         := '0';             -- write
   signal adc_slave_writedata    : std_logic_vector (31 downto 0)    := (others => '0'); -- writedata
   signal adc_slave_address      : std_logic_vector (2 downto 0)     := (others => '0'); -- address
   signal adc_slave_read         : std_logic                         := '0';

   -- Component declaration
   component ADC_Avalon is
      port (
         clk_clk                     : in  std_logic;
         reset_reset_n               : in  std_logic;
         adc_0_adc_slave_write       : in  std_logic;
         adc_0_adc_slave_readdata    : out std_logic_vector(31 downto 0);
         adc_0_adc_slave_writedata   : in  std_logic_vector(31 downto 0);
         adc_0_adc_slave_address     : in  std_logic_vector(2 downto 0);
         adc_0_adc_slave_waitrequest : out std_logic;
         adc_0_adc_slave_read        : in  std_logic
      );
   end component;

   type STATE is (INIT, IDLE, WRITE_ADDRESS_1, READ_DATA_1, AVALON_CLEAR, WRITE_ADDRESS_2, READ_DATA_2);
   type SEND  is (INIT, WAIT_VALID);

   constant ADDRESS_ADC_1        : std_logic_vector (2 downto 0) := "000";
   constant ADDRESS_ADC_2        : std_logic_vector (2 downto 0) := "001";
   constant ADDRESS_AUTO_UPDATE  : std_logic_vector (2 downto 0) := "001";
   constant ADDRESS_UPDATE       : std_logic_vector (2 downto 0) := "000";   

   signal data_out_1_reg, data_out_2_reg     : std_logic_vector (31 downto 0) := (others => '0');
   signal state_read_reg, state_read_next    : STATE                          := INIT;
   signal state_send_reg, state_send_next    : SEND                           := INIT;
   signal data_reg_valid                     : std_logic                      := '0';
   signal waitrequest_new, waitrequest_old   : std_logic                      := '0';

begin

   -- PLL instance
   ADC_Avalon_inst : ADC_Avalon
   port map (
      clk_clk                     => clk_adc_10_mhz,
      reset_reset_n               => reset,
      adc_0_adc_slave_write       => adc_slave_write,
      adc_0_adc_slave_readdata    => adc_slave_readdata,
      adc_0_adc_slave_writedata   => adc_slave_writedata,
      adc_0_adc_slave_address     => adc_slave_address,
      adc_0_adc_slave_waitrequest => adc_slave_waitrequest,
      adc_0_adc_slave_read        => adc_slave_read
   );

   ------- STATE SEND Logic -------
   process(state_send_reg, data_reg_valid)
   begin
      state_send_next <= state_send_reg;

      case state_send_reg is
         when INIT =>
            data_valid_o <= '0';
            if (data_reg_valid = '0') then
               state_send_next <= WAIT_VALID;
            end if;

         when WAIT_VALID =>
            if (data_reg_valid = '1') then
               data_adc_1_o <= data_out_1_reg(11 downto 0);
               data_adc_2_o <= data_out_2_reg(11 downto 0);
               data_valid_o <= '1';
               state_send_next <= INIT;
            end if;
      end case;
   end process;

   ------- STATE READ Logic -------
   process (all)
   begin
      adc_slave_write   <= '0';
      adc_slave_read    <= '0';
      adc_slave_address <= (others => '0');
      data_reg_valid    <= '0';
      state_read_next   <= state_read_reg;
   -- Для регистров данных: сохраняем прежнее значение, пока нет нового чтения
      data_out_1_reg    <= data_out_1_reg;
      data_out_2_reg    <= data_out_2_reg;

      case state_read_reg is
         when INIT =>
            adc_slave_write <= '1';
            adc_slave_address <= ADDRESS_AUTO_UPDATE;
            adc_slave_writedata <= (others => '1');
            if (waitrequest_old = '1' and waitrequest_new = '0') then 
               state_read_next <= IDLE;
               adc_slave_write <= '0';
               adc_slave_writedata <= (others => '0');
            end if;

         when IDLE =>
            adc_slave_read <= '0';
            data_reg_valid <= '0';
            state_read_next <= WRITE_ADDRESS_1;

         when WRITE_ADDRESS_1 =>
            adc_slave_read <= '1';
            adc_slave_address <= ADDRESS_ADC_1;
            state_read_next <= READ_DATA_1;

         when READ_DATA_1 =>
            If(waitrequest_new = '0') then
               adc_slave_read <= '1';
               adc_slave_address <= (others => '0');
               data_out_1_reg <= adc_slave_readdata;
               state_read_next <= AVALON_CLEAR;
            end if;

         when AVALON_CLEAR =>
            adc_slave_read <= '0';
            state_read_next <= WRITE_ADDRESS_2;

         when WRITE_ADDRESS_2 =>
            adc_slave_read <= '1';
            adc_slave_address <= ADDRESS_ADC_2;
            state_read_next <= READ_DATA_2;

         when READ_DATA_2 =>
            if (waitrequest_new = '0') then
               adc_slave_read <= '1';
               adc_slave_address <= (others => '0');
               data_out_2_reg <= adc_slave_readdata;
               data_reg_valid <= '1';
               state_read_next <= IDLE;
            end if;

      end case;
   end process;

   ------- INSIDE BLOCK -------
   process(clk_adc_10_mhz, reset)
   begin 
      if reset = '0' then
         state_read_reg <= INIT;
      elsif rising_edge(clk_adc_10_mhz) then
         state_read_reg <= state_read_next;

         waitrequest_new <= adc_slave_waitrequest;
         waitrequest_old <= waitrequest_new;
      end if;
   end process;

end architecture arch;
