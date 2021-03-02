--------------------------------------------------------------------------------------------------
--
--   Copyright (C) 2007
--
--   Title     :  Atari 2600 with Xilinx-based primitives...
--
--   Author    :  Ed Henciak 
--
--   Date      :  January 5, 2007
--
--   Notes     :  This is an instance of the Atari 2600 with Xilinx specific video decoding to 
--                RGB...clocks and ROM must be instantiated at a higher level.  Basically the top 
--                level instantiates the DCM and the 
--                
--------------------------------------------------------------------------------------------------

-- Very useful IEEE package
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

-- Reference the Atari 2600 core from here
library A2600;
    use A2600.a2600_pkg.all;

-- Second revision of 2600 for the Altium dev. kit.
entity a2600_mb_altium_2 is
port
(
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
end a2600_mb_altium_2;

architecture struct of a2600_xilinx is

    -- Clock circuit for the Altium board
    component a26_mb_altium_clks
    port (
    
        clk     : in  std_logic; -- 50MHz source
    
        clk_50  : out std_logic; -- Output of DCM 50MHz clock
        clk_a26 : out std_logic; -- Atari 2600 ref. clk (7.19MHz)
    
        rst_mb  : out std_logic; -- Reset Microblaze
        por     : out std_logic  -- Power on reset
    
    );
    end component;

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

    -- The Atari 2600 core logic...
    component a2600_core
    port
    (
    
        -- Clock and reset
        clk         : in std_logic;                       -- Use 2x the main osc clock
        reset       : in std_logic;                       -- Master, primary reset
    
        -- synthesis translate_off
        ref_newline : out std_logic;                      -- Used in the simulation environment
        -- synthesis translate_on
    
        -- Reference for pixel clock
        pix_ref     : out std_logic;                      -- Not an actual Atari 2600 signal.
    
        -- System reset 
        system_rst  : out std_logic;                      -- Not an actual Atari 2600 signal.
         
        -- Controller ports...
    
        -- Left Controller Port
        ctl_l       : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_l_0     : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_l_1     : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_l      : in    std_logic;                    -- Left trigger input      (pin 6)
    
        -- Right Controller Port
        ctl_r       : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_r_0     : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_r_1     : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_r      : in    std_logic;                    -- Left trigger input      (pin 6)
    
        -- Cartridge port
        rom_addr    : out std_logic_vector(11 downto 0); -- The program address bus
        rom_rdata   : in  std_logic_vector( 7 downto 0); -- Program data bus (input)
        rom_wdata   : out std_logic_vector( 7 downto 0); -- Program data bus (input)
    
        -- Console switches (momentary switches are normally open)
        bw_col      : inout std_logic;                   -- Slide switch...selects black & white or color
        diff_l      : inout std_logic;                   -- Slide switch...selects difficulty for left player
        diff_r      : inout std_logic;                   -- Slide switch...selects difficulty for right player
        gamesel     : inout std_logic;                   -- Momentary switch...selects game variation
        start       : inout std_logic;                   -- Momentary switch...starts the game!
    
        -- Video Output.
        vid_lum     : out std_logic_vector(2 downto 0); -- Luma...register on a pix clk tick
        vid_col     : out std_logic_vector(3 downto 0); -- Color...register on a pix clk tick
        vid_vsyn    : out std_logic;                    -- Vertical sync
        vid_hsyn    : out std_logic;                    -- Horizontal sync
        vid_csyn    : out std_logic;                    -- Composite sync
        vid_cb      : out std_logic;                    -- Colorburst
        vid_blank_n : out std_logic;                    -- Blank!...register on a pix clk tick!
    
        -- Audio Output
        aud_ch0     : out std_logic_vector(3 downto 0); -- Four bit audio channel 1
        aud_ch1     : out std_logic_vector(3 downto 0)  -- Four bit audio channel 2
    
    );
    end component;

    -- The lovely audio DAC...custom made for our Atari.
    component a26_audio_dac
    port (
    
        clk     : in  std_logic;
        reset   : in  std_logic;
        a_in_1  : in  std_logic_vector(3 downto 0);
        a_in_2  : in  std_logic_vector(3 downto 0);
        aout    : out std_logic
    
    );
    end component;

    -- Video circuit...
    component a26_video_decode
    port (
    
        clk         : in  std_logic;
        reset       : in  std_logic;
        freq_sel    : in  std_logic;
        pix_clk_ref : in  std_logic;
        chroma      : in  std_logic_vector(3 downto 0);
        luma        : in  std_logic_vector(2 downto 0);
        hsync_in    : in  std_logic;
        vsync_in    : in  std_logic;
    
        -- Video output signals
        red         : out std_logic_vector(3 downto 0);
        grn         : out std_logic_vector(3 downto 0);
        blu         : out std_logic_vector(3 downto 0);
        hsync_o     : out std_logic;
        vsync_o     : out std_logic
    
    );
    end component;

    -- Interconnect and other goodies...
    signal red_i              : std_logic_vector(3 downto 0);
    signal grn_i              : std_logic_vector(3 downto 0);
    signal blu_i              : std_logic_vector(3 downto 0);

    signal mb_gpio_color      : std_logic;
    signal mb_gpio_diff_l     : std_logic;
    signal mb_gpio_diff_r     : std_logic;
    signal mb_gpio_gamesel    : std_logic;
    signal mb_gpio_start      : std_logic;
    signal mb_gpio_freqsel    : std_logic;

    signal microblaze_clock   : std_logic;
    signal poweron_rst        : std_logic;
    signal a26_system_clk     : std_logic;

    signal speaker            : std_logic;
  
    signal gnd                : std_logic;
    signal clk_ref            : std_logic;

    signal mb_gpiovec         : std_logic_vector(31 downto 0);
    signal gnd_vec            : std_logic_vector(31 downto 0);
    signal reset_n            : std_logic;

    -- External memory from Microblaze bus
    signal ext_mem_addr       : std_logic_vector(31 downto 0);
    signal ext_mem_ben        : std_logic_vector( 1 downto 0);
    signal ext_mem_wen        : std_logic;
    signal ext_mem_oen        : std_logic_vector( 0 downto 0);
    signal ext_mem_cen        : std_logic_vector( 0 downto 0);
    signal ext_mem_dq_i       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_o       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_t       : std_logic_vector(15 downto 0);

    -- Video interconnect
    signal vid_hsyn_i   : std_logic;
    signal vid_vsyn_i   : std_logic;
    signal vid_red_i    : std_logic_vector(3 downto 0);
    signal vid_grn_i    : std_logic_vector(3 downto 0);
    signal vid_blu_i    : std_logic_vector(3 downto 0);
    signal vid_col      : std_logic_vector(3 downto 0);
    signal vid_lum      : std_logic_vector(2 downto 0);
    signal pix_ref_i    : std_logic; 

begin

    -- Clock circuit.  This provides the Microblaze clock 
    -- as well as the Atari 2600 clock...
    clk_rst_0 : a26_mb_altium_clks
    port map(
    
        clk     => clk,
    
        clk_50  => cpu_clk,
        clk_a26 => a26_sysclk,
    
        rst_mb  => cpu_rst,
        por     => a26_powon_rst
    
    );

    -- Invert reset for CPU system 
    cpu_rst_n <= not(cpu_rst);

    -- This is the Microblaze System component.  The goal is to
    -- replace this with a free, opensource RISC CPU (i.e. OpenRISC).
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

      sys_clk_pin                        => cpu_clk,
      sys_rst_pin                        => cpu_rst_n

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

    -- The beloved Atari 2600...
    a2600_core_0 : a2600_core
    port map
    (
    
        -- Clock and reset
        clk         => a26_sysclk,
        reset       => a26_powon_rst,
    
        -- synthesis translate_off
        ref_newline => ref_newline,
        -- synthesis translate_on
    
        -- Reference for pixel clock
        pix_ref     => pix_ref_i,
    
        -- System reset 
        system_rst  => a26_sysrst,
         
        -- Controller ports...
    
        -- Left Controller Port
        ctl_l       => ctl_l,
        pad_l_0     => pad_l_0,
        pad_l_1     => pad_l_1,
        trig_l      => trig_l,
    
        -- Right Controller Port
        ctl_r       => ctl_r,
        pad_r_0     => pad_r_0,
        pad_r_1     => pad_r_1,
        trig_r      => trig_r,
    
        -- Cartridge port
        rom_addr    => rom_addr,
        rom_rdata   => rom_rdata,
        rom_wdata   => rom_wdata,
    
        -- Console switches 
        bw_col      => bw_col,
        diff_l      => diff_l,
        diff_r      => diff_r,
        gamesel     => gamesel,
        start       => start,
    
        -- Video Output.
        vid_lum     => vid_lum,
        vid_col     => vid_col,
        vid_vsyn    => vid_vsyn_i,
        vid_hsyn    => vid_hsyn_i,
        vid_csyn    => open,
        vid_cb      => open,
        vid_blank_n => open,
    
        -- Audio Output
        aud_ch0     => aout0,
        aud_ch1     => aout1
    
    );

    -- This circuit takes the audio channels from the Atari and 
    -- converts them into a PWM stream.  A low pass filter off chip
    -- makes those sounds we know and love from that stream.
    a26_aud_dac_0 : a26_audio_dac
    port map(
    
        clk    => cpu_clk,   -- We need a "fast" clock cource
        reset  => a26_sysrst, 
        a_in_1 => aout0, 
        a_in_2 => aout1, 
        aout   => speaker
    
    );

    -- Drive out the same audio on both speakers.
    speaker_l <= speaker;
    speaker_r <= speaker;

    -- This logic handles video stuff...
    a26_vid : a26_video_decode
    port map(
    
        clk         => a26_sysclk,
        reset       => a26_sysrst,
        freq_sel    => mb_gpio_freqsel,
        pix_clk_ref => pix_ref_i,
        chroma      => vid_col,
        luma        => vid_lum,
        hsync_in    => vid_hsyn_i,
        vsync_in    => vid_vsyn_i,
    
        -- Video output signals
        red         => red,
        grn         => grn,
        blu         => blu,
        hsync_o     => hsync,
        vsync_o     => vsync
    
    );

end struct;
