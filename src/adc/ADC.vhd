library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ADC is
   port (
      ----------------- CLOCK
      clk_sys                 : in std_logic;
      clk_adc                 : in std_logic;
      reset                   : in std_logic;

      ------------------ OUTPUT
      data_adc_0_o            : out std_logic_vector (11 downto 0)   := (others => '0'); 
      data_adc_1_o            : out std_logic_vector (11 downto 0)   := (others => '0');
      data_valid_o            : out std_logic                        := '0';

      LED0                    : out std_logic                        := '0';
      LED1                    : out std_logic                        := '0';
      LED2                    : out std_logic                        := '0';
      LED3                    : out std_logic                        := '0';
      LED4                    : out std_logic                        := '0';
      LED5                    : out std_logic                        := '0';
      LED6                    : out std_logic                        := '0';
      LED7                    : out std_logic                        := '0';
      LED8                    : out std_logic                        := '0'
   );
end entity ADC;


architecture arch of ADC is
   ------------------ Clock

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

   type STATE is (INIT_START, INIT_END, IDLE, READ_DATA_0, AVALON_CLEAR, READ_DATA_1);

   constant ADDRESS_ADC_0        : std_logic_vector (2 downto 0) := "000";
   constant ADDRESS_ADC_1        : std_logic_vector (2 downto 0) := "001";
   constant ADDRESS_AUTO_UPDATE  : std_logic_vector (2 downto 0) := "001";
   constant ADDRESS_UPDATE       : std_logic_vector (2 downto 0) := "000";   

   signal memory                             : std_logic_vector (31 downto 0) := (others => '0');
   signal data_out_0_reg, data_out_1_reg     : std_logic_vector (11 downto 0) := (others => '0');
   signal state_read_reg, state_read_next    : STATE                            := INIT_START;

   signal data_reg_0_valid, old_reg_0_valid  : std_logic                      := '0';
   signal data_reg_1_valid, old_reg_1_valid  : std_logic                      := '0';
   signal waitrequest_new, waitrequest_old   : std_logic                      := '0';
   signal locked_sig                         : std_logic                      := '0';

begin

   -- PLL instance
   ADC_Avalon_inst : ADC_Avalon
   port map (
      clk_clk                     => clk_adc,
      reset_reset_n               => reset,
      adc_0_adc_slave_write       => adc_slave_write,
      adc_0_adc_slave_readdata    => adc_slave_readdata,
      adc_0_adc_slave_writedata   => adc_slave_writedata,
      adc_0_adc_slave_address     => adc_slave_address,
      adc_0_adc_slave_waitrequest => adc_slave_waitrequest,
      adc_0_adc_slave_read        => adc_slave_read
   );

   ------- STATE READ Logic -------
   process(all)
   begin
      state_read_next      <= state_read_reg;
   
      adc_slave_write      <= '0';
      adc_slave_read       <= '0';
      adc_slave_address    <= (others => '0');
      data_reg_0_valid     <= '0';
      data_reg_1_valid     <= '0';
      
      memory               <= (others => '0');
      adc_slave_writedata  <= (others => '0');

      case state_read_reg is
         when INIT_START =>
            adc_slave_write <= '1';
            adc_slave_address <= ADDRESS_AUTO_UPDATE;
            adc_slave_writedata <= (others => '1');
            state_read_next <= INIT_END;

         when INIT_END =>
            if (waitrequest_old = '1' and waitrequest_new = '0') then 
               state_read_next <= IDLE;
               adc_slave_write <= '0';
               adc_slave_writedata <= (others => '0');

            else 
               state_read_next <= INIT_END;
               adc_slave_write <= '1';
               adc_slave_writedata <= (others => '0');

            end if;

         when IDLE =>
            adc_slave_address <= (others => '0');
            adc_slave_read    <= '0';
            data_reg_0_valid  <= '0';
            data_reg_1_valid  <= '0';
            memory            <= (others => '0');

            state_read_next   <= READ_DATA_0;

         when READ_DATA_0 =>
            adc_slave_read    <= '1';
            adc_slave_address <= ADDRESS_ADC_0;

            If(waitrequest_new = '0') then
               memory            <= adc_slave_readdata;
               data_reg_0_valid  <= '1';
               state_read_next   <= AVALON_CLEAR;

            else
               memory            <= (others => '0');
               data_reg_0_valid  <= '0';
               state_read_next   <= READ_DATA_0;
            end if;

         when AVALON_CLEAR =>
            adc_slave_read    <= '0';
            state_read_next   <= READ_DATA_1;
            adc_slave_address <= (others => '0');
            memory            <= (others => '0');

         when READ_DATA_1 =>
            adc_slave_read       <= '1';
            adc_slave_address    <= ADDRESS_ADC_1;
            
            if (waitrequest_new = '0') then
               memory            <= adc_slave_readdata;
               data_reg_1_valid  <= '1';
               state_read_next   <= IDLE;

            else 
               memory            <= (others => '0');
               data_reg_1_valid  <= '0';
               state_read_next   <= READ_DATA_1;
            end if;
      end case;
   end process;

   ------- INSIDE BLOCK -------
   process(clk_adc, reset)
   begin 
      if (reset = '0') then
         state_read_reg <= INIT_START;
         waitrequest_new <= '0';
         waitrequest_old <= '0';

      elsif rising_edge(clk_adc) then
         state_read_reg <= state_read_next;

         waitrequest_new <= adc_slave_waitrequest;
         waitrequest_old <= waitrequest_new;
      end if;
   end process;

   ------- OUTPUT BLOCK -------
   process(clk_out, reset)
   begin
      if (reset = '0') then
         old_reg_0_valid   <= '0';
         old_reg_1_valid   <= '0';

         data_out_0_reg    <= (others => '0');
         data_adc_0_o      <= (others => '0');
         data_adc_1_o      <= (others => '0');
         data_valid_o      <= '0';

      elsif rising_edge(clk_out) then
         if ((not old_reg_0_valid) and (data_reg_0_valid)) then
            old_reg_0_valid <= data_reg_0_valid;
            old_reg_1_valid <= data_reg_1_valid;
            
            data_out_0_reg <= memory(11 downto 0);
            
            LED0 <= memory(8);
            LED1 <= memory(9);
            LED2 <= memory(10);
            LED3 <= memory(11);

         elsif ((not old_reg_1_valid) and (data_reg_1_valid)) then
            old_reg_0_valid <= data_reg_0_valid;
            old_reg_1_valid <= data_reg_1_valid;
            
            data_adc_0_o <= data_out_0_reg;
            data_adc_1_o <= memory(11 downto 0);
            
            data_valid_o <= '1';

            LED4 <= memory(8);
            LED5 <= memory(9);
            LED6 <= memory(10);
            LED7 <= memory(11);
         else
            old_reg_0_valid <= data_reg_0_valid;
            old_reg_1_valid <= data_reg_1_valid;
            
            data_adc_0_o <= data_adc_0_o;
            data_adc_1_o <= data_adc_1_o;

            data_valid_o <= '0';
            
         end if;
      end if;
   end process;
end architecture arch;
