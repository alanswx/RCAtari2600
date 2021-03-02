--
library ieee;
    use ieee.std_logic_1164.all;

library A2600;
    use A2600.a2600_pkg.all;

entity a2600_mb is
port(
	-- Input reference clock (14.31MHz)
	clk               : in    std_logic;

        -------------------------------------------------------
        -- DB9 controller ports:
        -------------------------------------------------------
        -- Left 
        -------------------------------------------------------
        ctl_l            : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_l_0          : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_l_1          : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_l           : in    std_logic;                    -- Left trigger input      (pin 6)
        -------------------------------------------------------
        -- Right
        -------------------------------------------------------
        ctl_r            : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_r_0          : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_r_1          : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_r           : in    std_logic;                    -- Left trigger input      (pin 6)
        -------------------------------------------------------

        -------------------------------------------------------
	-- Video outputs
        -------------------------------------------------------
	red               : out   std_logic_vector(2 downto 0);
	grn               : out   std_logic_vector(2 downto 0);
	blu               : out   std_logic_vector(2 downto 0);
	hsync             : out   std_logic;
	vsync             : out   std_logic;

        -------------------------------------------------------
        -- Audio outputs
        -------------------------------------------------------
        speaker_r         : out   std_logic;
        speaker_l         : out   std_logic;

        -------------------------------------------------------
        -- UART pins
        -------------------------------------------------------
	uart_tx           : out   std_logic;
	uart_rx           : in    std_logic;
        uart_rts          : out   std_logic;
        uart_cts          : in    std_logic;

        -- LED pins for debugging
        leds              : out   std_logic_vector(7 downto 0);

        -------------------------------------------------------
        -- Memory bus
        -------------------------------------------------------
	sram_addr         : out   std_logic_vector(17 downto 0);
	sram_data         : inout std_logic_vector(15 downto 0);
	sram_wen          : out   std_logic;
	sram_cen          : out   std_logic;
	sram_oen          : out   std_logic;
	sram_ub           : out   std_logic;
	sram_lb           : out   std_logic

);
end a2600_mb;

architecture rtl of a2600_mb is

    -- Xilinx Microblaze Component...
    component system
    port (
      fpga_0_RS232_req_to_send_pin : out std_logic;
      fpga_0_RS232_RX_pin : in std_logic;
      fpga_0_RS232_TX_pin : out std_logic;
      fpga_0_Generic_GPIO_GPIO_d_out_pin : out std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_in_pin : in std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_t_out_pin : out std_logic_vector(0 to 31);
      fpga_0_Mem_A_pin : out std_logic_vector(0 to 31);
      fpga_0_Mem_BEN_pin : out std_logic_vector(0 to 1);
      fpga_0_Mem_WEN_pin : out std_logic;
      fpga_0_Mem_OEN_pin : out std_logic_vector(0 to 0);
      fpga_0_Mem_CEN_pin : out std_logic_vector(0 to 0);
      fpga_0_Mem_DQ_I_pin : in std_logic_vector(0 to 15);
      fpga_0_Mem_DQ_O_pin : out std_logic_vector(0 to 15);
      fpga_0_Mem_DQ_T_pin : out std_logic_vector(0 to 15);
      sys_clk_pin : in std_logic;
      sys_rst_pin : in std_logic
    );
    end component;

    signal red_i              : std_logic_vector(3 downto 0);
    signal grn_i              : std_logic_vector(3 downto 0);
    signal blu_i              : std_logic_vector(3 downto 0);

    signal a26_bram_wp_addr   : std_logic_vector(11 downto 0);
    signal a26_bram_wp_wdata  : std_logic_vector( 7 downto 0);
    signal a26_bram_wp_wena   : std_logic;
    signal a26_bram_wp_rdata  : std_logic_vector( 7 downto 0);
    signal a26_bram_wp_clk    : std_logic;                   

    signal mb_gpio_color      : std_logic;
    signal mb_gpio_diff_l     : std_logic;
    signal mb_gpio_diff_r     : std_logic;
    signal mb_gpio_gamesel    : std_logic;
    signal mb_gpio_start      : std_logic;

    signal microblaze_clock   : std_logic;
    signal poweron_rst        : std_logic;
    signal a26_system_clk     : std_logic;

    signal speaker            : std_logic;
  
    signal gnd                : std_logic;
    signal clk_ref            : std_logic;

    signal mb_gpiovec         : std_logic_vector(31 downto 0);
    signal gnd_vec            : std_logic_vector(31 downto 0);
    signal reset_n            : std_logic;

    signal ext_mem_addr       : std_logic_vector(31 downto 0);
    signal ext_mem_ben        : std_logic_vector( 1 downto 0);
    signal ext_mem_wen        : std_logic;
    signal ext_mem_oen        : std_logic_vector( 0 downto 0);
    signal ext_mem_cen        : std_logic_vector( 0 downto 0);
    signal ext_mem_dq_i       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_o       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_t       : std_logic_vector(15 downto 0);

begin

    -- Ground vector
    gnd_vec <= (others => '0');

    -- Tie these off for now
    mb_gpio_color      <= mb_gpiovec(4);
    mb_gpio_diff_l     <= mb_gpiovec(3);
    mb_gpio_diff_r     <= mb_gpiovec(2);
    mb_gpio_gamesel    <= mb_gpiovec(1);
    mb_gpio_start      <= mb_gpiovec(0);

    leds(7) <= '1';
    leds(6) <= '0';
    leds(5) <= '1';
    leds(4) <= mb_gpiovec(4);
    leds(3) <= mb_gpiovec(3);
    leds(2) <= mb_gpiovec(2);
    leds(1) <= mb_gpiovec(1);
    leds(0) <= mb_gpiovec(0);

    a26_bram_wp_addr   <= (others => '0');
    a26_bram_wp_wdata  <= (others => '0');
    a26_bram_wp_wena   <= '0';
    a26_bram_wp_clk    <= microblaze_clock;

    reset_n <= not(poweron_rst);

    mb_sys_0 : system
    port map (

      fpga_0_RS232_req_to_send_pin       => open,
      fpga_0_RS232_RX_pin                => uart_rx,
      fpga_0_RS232_TX_pin                => uart_tx,

      fpga_0_Generic_GPIO_GPIO_d_out_pin => mb_gpiovec,
      fpga_0_Generic_GPIO_GPIO_in_pin    => gnd_vec,
      fpga_0_Generic_GPIO_GPIO_t_out_pin => open,

      fpga_0_Mem_A_pin                   => ext_mem_addr, -- : out std_logic_vector(0 to 31);
      fpga_0_Mem_BEN_pin                 => ext_mem_ben,  -- : out std_logic_vector(0 to 1);
      fpga_0_Mem_WEN_pin                 => ext_mem_wen,  -- : out std_logic;
      fpga_0_Mem_OEN_pin                 => ext_mem_oen, -- : out std_logic_vector(0 to 1);
      fpga_0_Mem_CEN_pin                 => ext_mem_cen, -- : out std_logic_vector(0 to 1);

      fpga_0_Mem_DQ_I_pin                => ext_mem_dq_i,  -- 0 to 31
      fpga_0_Mem_DQ_O_pin                => ext_mem_dq_o,  -- 0 to 31
      fpga_0_Mem_DQ_T_pin                => ext_mem_dq_t,  -- 0 to 31

      sys_clk_pin                        => microblaze_clock,
      sys_rst_pin                        => reset_n

    );

    -- Generate tristate drivers for the memory
    tsb_0: for i in 0 to 15 generate
    begin

         sram_data(i)    <= ext_mem_dq_o(i) when (ext_mem_dq_t(i) = '0') else 'Z';
         ext_mem_dq_i(i) <= sram_data(i);

    end generate;

    -- Various signals to drive to external memory...
    sram_addr     <= ext_mem_addr(17 downto 0);
    sram_wen      <= ext_mem_wen;
    sram_cen      <= ext_mem_cen(0);
    sram_oen      <= ext_mem_oen(0);
    sram_ub       <= ext_mem_ben(1);
    sram_lb       <= ext_mem_ben(0);

    -- Useful Atari 2600 core.
    a2600_sys_0 : a2600_edkit
    port map
    (
    
       -- Clock (we'll generate Power On reset locally)
       -- All other required clocks are derived from this clock.
       clk              => clk,
    
       -- synthesis translate_off
       ref_newline      => open,
       -- synthesis translate_on
    
       -- This port allows the Microblaze to talk with the onboard
       -- BlockRAM...allows us to load games from host PC.
       bram_wp_addr     => a26_bram_wp_addr,  
       bram_wp_wdata    => a26_bram_wp_wdata, 
       bram_wp_wena     => a26_bram_wp_wena,  
       bram_wp_rdata    => a26_bram_wp_rdata, 
       bram_wp_clk      => a26_bram_wp_clk,   
    
       -- Output clocks...
       mb_clk           => microblaze_clock,
    
       -- Useful for debugging
       a26_system_clock => a26_system_clk,
       a26_system_reset => poweron_rst,
    
       -------------------------------------------------------
       -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
       bw_col           => mb_gpio_color,
       diff_l           => mb_gpio_diff_l,
       diff_r           => mb_gpio_diff_r,
       gamesel          => mb_gpio_gamesel,
       start            => mb_gpio_start,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Atari controller ports:
       -------------------------------------------------------
       -- Left 
       -------------------------------------------------------
       ctl_l            => ctl_l,
       pad_l_0          => pad_l_0,
       pad_l_1          => pad_l_1,
       trig_l           => trig_l,
       -------------------------------------------------------
       -- Right
       -------------------------------------------------------
       ctl_r            => ctl_r,
       pad_r_0          => pad_r_0,
       pad_r_1          => pad_r_1,
       trig_r           => trig_r,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Video Output.
       red              => red_i,
       grn              => grn_i,
       blu              => blu_i,
       vs_n             => vsync,
       hs_n             => hsync,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Audio Output (mono since I had to remove one pin)
       audio            => speaker
       -------------------------------------------------------
    
    
    );

    -- Drive the speakers on the board.
    speaker_l  <= speaker;
    speaker_r  <= speaker;

    red        <= red_i(3 downto 1);
    grn        <= grn_i(3 downto 1);
    blu        <= blu_i(3 downto 1);

    -------------------------------------------------------
    -- Tie off for now...
    -------------------------------------------------------
    uart_rts   <= '0';

end;
