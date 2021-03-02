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

-- Second revision of 2600 for the Altium dev. kit.
entity a2600_mb_altium_2 is
port
(
    -- Input reference clock (14.31MHz)
    clk               : in    std_logic;
    a26_sysclk           : in std_logic;                       -- 

	 a26_powon_rst             :  in  std_logic;
    -- synthesis translate_off
    pix_clk_ref       : out   std_logic;
    -- synthesis translate_on
    
    -------------------------------------------------------
    -- DB9 controller ports:
    -------------------------------------------------------
    -- Left 
    -------------------------------------------------------
    ctl_l            : in std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
    ctl_l_o            : out std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
    pad_l_0          : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
    pad_l_1          : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
    trig_l           : in    std_logic;                    -- Left trigger input      (pin 6)
    -------------------------------------------------------
    -- Right
    -------------------------------------------------------
    ctl_r            : in std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
    ctl_r_O            : out std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
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
    
    bw_col            :  in   std_logic;
    diff_l            :  in   std_logic;
    diff_r            :  in   std_logic;
    gamesel           :  in   std_logic;
    start             :  in   std_logic;

    lcd_vblank       : out std_logic;
    lcd_hblank       : out std_logic;

    -------------------------------------------------------
    -- UART pins
    -------------------------------------------------------
    uart_tx           : out   std_logic;
    uart_rx           : in    std_logic;
    uart_rts          : out   std_logic;
    uart_cts          : in    std_logic;
    
    -- LED pins for debugging
    leds              : out   std_logic_vector(7 downto 0);

    -- 7 Seg. display
    dig0_seg          : out   std_logic_vector(7 downto 0);
    dig1_seg          : out   std_logic_vector(7 downto 0);
    dig2_seg          : out   std_logic_vector(7 downto 0);
    dig3_seg          : out   std_logic_vector(7 downto 0);
    dig4_seg          : out   std_logic_vector(7 downto 0);
    dig5_seg          : out   std_logic_vector(7 downto 0);
    
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

architecture struct of a2600_mb_altium_2 is

    -- 7 segment driver..
    component hex_7seg
    port(hex_digit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         segment   : OUT STD_LOGIC_VECTOR(7 downto 0)
    );
    end component;

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
        ctl_l       : in std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        ctl_l_o       : out std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_l_0     : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_l_1     : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_l      : in    std_logic;                    -- Left trigger input      (pin 6)
    
        -- Right Controller Port
        ctl_r       : in std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        ctl_r_o       : out std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
        pad_r_0     : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
        pad_r_1     : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
        trig_r      : in    std_logic;                    -- Left trigger input      (pin 6)
    
        -- Cartridge port
        rom_addr    : out std_logic_vector(12 downto 0); -- The program address bus
        rom_rdata   : in  std_logic_vector( 7 downto 0); -- Program data bus (input)
        rom_wdata   : out std_logic_vector( 7 downto 0); -- Program data bus (input)
    
        -- Console switches (momentary switches are normally open)
        bw_col      : in std_logic;                   -- Slide switch...selects black & white or color
        diff_l      : in std_logic;                   -- Slide switch...selects difficulty for left player
        diff_r      : in std_logic;                   -- Slide switch...selects difficulty for right player
        gamesel     : in std_logic;                   -- Momentary switch...selects game variation
        start       : in std_logic;                   -- Momentary switch...starts the game!
    
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

    -- Xilinx ROM...remove this once SRAM works
    component xil_rom
    port (
	addr : IN std_logic_VECTOR(11 downto 0);
	clk  : IN std_logic;
	dout : OUT std_logic_VECTOR(7 downto 0));
    end component;

    -- Signals that drive Atari control switches
    -- from the Microblaze...
    signal mb_gpio_banksw     : std_logic_vector(7 downto 0);
    signal mb_gpio_bw_col     : std_logic;
    signal mb_gpio_diff_l     : std_logic;
    signal mb_gpio_diff_r     : std_logic;
    signal mb_gpio_gamesel    : std_logic;
    signal mb_gpio_start      : std_logic;
    signal mb_gpio_freqsel    : std_logic;
    signal mb_gpio_ramsel     : std_logic;

    --signal a26_powon_rst      : std_logic;
    --signal a26_sysclk         : std_logic;
    signal reset_2600         : std_logic;

    signal speaker            : std_logic;
  
    signal cpu_clk            : std_logic;
    signal cpu_rst            : std_logic;
    signal cpu_rst_n          : std_logic;
    signal mb_gpiovec         : std_logic_vector(31 downto 0);
    signal gnd_vec            : std_logic_vector(31 downto 0);
    signal ref_newline        : std_logic;

    signal rom_addr           : std_logic_vector(12 downto 0);
    signal reg_rom_addr       : std_logic_vector(15 downto 0); -- Includes banking for now..
    signal rom_rdata          : std_logic_vector( 7 downto 0);
    signal rom_wdata          : std_logic_vector( 7 downto 0);

    signal aout0              : std_logic_vector(3 downto 0);
    signal aout1              : std_logic_vector(3 downto 0);

    -- External memory from Microblaze bus
    signal ext_mem_addr       : std_logic_vector(31 downto 0);
    signal ext_mem_ben        : std_logic_vector( 1 downto 0);
    signal ext_mem_wen        : std_logic;
    signal ext_mem_oen        : std_logic_vector( 0 downto 0);
    signal ext_mem_cen        : std_logic_vector( 0 downto 0);
    signal ext_mem_dq_i       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_o       : std_logic_vector(15 downto 0);
    signal ext_mem_dq_t       : std_logic_vector(15 downto 0);

    signal sram_addr_i        : std_logic_vector(17 downto 0);
    signal reg_ext_addr       : std_logic_vector(27 downto 0);
    signal reg_ext_mem       : std_logic_vector(15 downto 0);
    signal addr_cnt          : std_logic_vector( 3 downto 0);

    -- Video interconnect
    signal vid_hsyn_i     : std_logic;
    signal vid_vsyn_i     : std_logic;
    signal vid_blank_n    : std_logic;
    signal red_i          : std_logic_vector(3 downto 0);
    signal grn_i          : std_logic_vector(3 downto 0);
    signal blu_i          : std_logic_vector(3 downto 0);
    signal vid_col        : std_logic_vector(3 downto 0);
    signal vid_lum        : std_logic_vector(2 downto 0);
    signal pix_ref_i      : std_logic; 

    component a2600_9bit_color
    port
    (
    
       col : in  std_logic_vector(3 downto 0);
       lum : in  std_logic_vector(2 downto 0);
     
       red : out std_logic_vector(2 downto 0);
       grn : out std_logic_vector(2 downto 0);
       blu : out std_logic_vector(2 downto 0) 
    
    );
    end component;

    component scanlram_2kx9
    port (
    	addra : IN  std_logic_VECTOR(10 downto 0);
    	addrb : IN  std_logic_VECTOR(10 downto 0);
    	clka  : IN  std_logic;
    	clkb  : IN  std_logic;
    	dina  : IN  std_logic_VECTOR(8 downto 0);
    	doutb : OUT std_logic_VECTOR(8 downto 0);
    	wea   : IN  std_logic
    );
    end component;



    signal lcd_hsync_n      : std_logic;
    signal lcd_vsync_n      : std_logic;
    signal lcd_red          : std_logic_vector(2 downto 0);
    signal lcd_grn          : std_logic_vector(2 downto 0);
    signal lcd_blu          : std_logic_vector(2 downto 0);
    signal lcd_clk_i        : std_logic;
    signal lcd_rst_n_i      : std_logic;
    signal lcd_horiz_cnt    : integer range 0 to 511;
    signal lcd_vert_cnt     : integer range 0 to 511;
    signal lcd_field        : std_logic;

    signal prev_vsync       : std_logic; 
    signal vsync_fe         : std_logic;
    signal push_pix_cnt     : integer range 0 to 255;
    signal push_scanl_cnt   : integer range 0 to 255;
    signal push_wdata       : std_logic_vector(8 downto 0);
    signal push_we          : std_logic;
    signal cconv_9bit_pixel : std_logic_vector(8 downto 0);

    type push_state_t is (WAIT_FOR_VSYNC, WAIT_FOR_BLANK, PUSH_BLANK_OFF, WAIT_BLANK_ON);
    signal push_state : push_state_t;

    signal scanlmem_waddr   : std_logic_vector(10 downto 0);
    signal scanlmem_raddr   : std_logic_vector(10 downto 0);
    signal scanlmem_rdata   : std_logic_vector( 8 downto 0);

begin

    -- Tieoffs  
    gnd_vec <= (others => '0');

    -- Clock circuit.  This provides the Microblaze clock 
    -- as well as the Atari 2600 clock...
    --clk_rst_0 : a26_mb_altium_clks
    --port map(
    --
    --    clk     => clk,
    --
    --    clk_50  => cpu_clk,
    --    clk_a26 => a26_sysclk,
    --
    --    rst_mb  => cpu_rst,
    --    por     => a26_powon_rst
    --
    --);

    -- Invert reset for CPU system 
    cpu_rst_n <= not(cpu_rst);

    --------------------------------------------------------------------
    -- WHEN SYNTHESIZING, USE THE BELOW SETTINGS>>>>>
    --------------------------------------------------------------------

    ---- This is the Microblaze System component.  The goal is to
    ---- replace this with a free, opensource RISC CPU (i.e. OpenRISC).
    --mb_sys_0 : system
    --port map (

    --  fpga_0_RS232_req_to_send_pin       => open,
    --  fpga_0_RS232_RX_pin                => uart_rx,
    --  fpga_0_RS232_TX_pin                => uart_tx,

    --  fpga_0_Generic_GPIO_GPIO_d_out_pin => mb_gpiovec,
    --  fpga_0_Generic_GPIO_GPIO_in_pin    => gnd_vec,
    --  fpga_0_Generic_GPIO_GPIO_t_out_pin => open,

    --  fpga_0_Mem_A_pin                   => ext_mem_addr, -- : out std_logic_vector(0 to 31);
    --  fpga_0_Mem_BEN_pin                 => ext_mem_ben,  -- : out std_logic_vector(0 to 1);
    --  fpga_0_Mem_WEN_pin                 => ext_mem_wen,  -- : out std_logic;
    --  fpga_0_Mem_OEN_pin                 => ext_mem_oen, -- : out std_logic_vector(0 to 1);
    --  fpga_0_Mem_CEN_pin                 => ext_mem_cen, -- : out std_logic_vector(0 to 1);

    --  fpga_0_Mem_DQ_I_pin                => ext_mem_dq_i,  -- 0 to 31
    --  fpga_0_Mem_DQ_O_pin                => ext_mem_dq_o,  -- 0 to 31
    --  fpga_0_Mem_DQ_T_pin                => ext_mem_dq_t,  -- 0 to 31

    --  sys_clk_pin                        => cpu_clk,
    --  sys_rst_pin                        => cpu_rst_n

    --);

    ---- Map the GPIO to "readable" signals
    --mb_gpio_banksw   <= mb_gpiovec(15 downto 8);
    --mb_gpio_ramsel   <= mb_gpiovec(6);
    --mb_gpio_freqsel  <= mb_gpiovec(5);
    --mb_gpio_bw_col   <= mb_gpiovec(4);
    --mb_gpio_diff_l   <= mb_gpiovec(2);
    --mb_gpio_diff_r   <= mb_gpiovec(3);
    --mb_gpio_gamesel  <= mb_gpiovec(1);
    --mb_gpio_start    <= mb_gpiovec(0);

    --leds(0) <= mb_gpio_ramsel; 
    --leds(1) <= mb_gpio_freqsel;
    --leds(2) <= mb_gpio_bw_col; 
    --leds(3) <= mb_gpio_diff_l; 
    --leds(4) <= mb_gpio_diff_r; 
    --leds(5) <= mb_gpio_gamesel;
    --leds(6) <= mb_gpio_start;
    --leds(7) <= '1'; 

    ----leds <= ext_mem_dq_t(7 downto 0);

    ---- Generate tristate drivers for the memory
    --tsb_0: for i in 0 to 15 generate
    --begin

    --     sram_data(i)    <= ext_mem_dq_o(i) when (ext_mem_dq_t(i) = '0') else 'Z';
    --     ext_mem_dq_i(i) <= sram_data(i);

    --end generate;

    ---- Various signals to drive to external memory...
    --sram_addr_i   <= ext_mem_addr(17 downto 0) when (mb_gpio_ramsel = '1') 
    --                                           else ("00" & reg_rom_addr(15 downto 1) & '0');
    --                                             --else ("00000000000000" & addr_cnt);
    --sram_addr     <= sram_addr_i;
    --sram_wen      <= ext_mem_wen               when (mb_gpio_ramsel = '1') else '1';
    --sram_cen      <= ext_mem_cen(0)            when (mb_gpio_ramsel = '1') else '0';
    --sram_oen      <= ext_mem_oen(0)            when (mb_gpio_ramsel = '1') else '0';
    --sram_ub       <= ext_mem_ben(1)            when (mb_gpio_ramsel = '1') else '0';
    --sram_lb       <= ext_mem_ben(0)            when (mb_gpio_ramsel = '1') else '0';

    --rom_rdata     <= ext_mem_dq_i(15 downto 8) when (reg_rom_addr(0) = '0') else ext_mem_dq_i(7 downto 0);



    --seg_5 : hex_7seg
    --port map(hex_digit => addr_cnt(3 downto 0),
    --         segment   => dig5_seg 
    --);
    --seg_4 : hex_7seg
    --port map(hex_digit => gnd_vec(3 downto 0),
    --         segment   => dig4_seg 
    --);
    --seg_3 : hex_7seg
    --port map(hex_digit => ext_mem_dq_i( 3 downto 0),
    --         segment   => dig3_seg 
    --);
    --seg_2 : hex_7seg
    --port map(hex_digit => ext_mem_dq_i( 7 downto 4),
    --         segment   => dig2_seg 
    --);
    --seg_1 : hex_7seg
    --port map(hex_digit => ext_mem_dq_i(11 downto 8),
    --         segment   => dig1_seg 
    --);
    --seg_0 : hex_7seg
    --port map(hex_digit => ext_mem_dq_i(15 downto 12),
    --         segment   => dig0_seg 
    --);

    --process(cpu_rst_n, cpu_clk)
    --begin

    --    if (cpu_rst_n = '0') then

    --        reg_ext_addr <= (others => '1');
    --        addr_cnt <= (others => '0');

    --    elsif(cpu_clk'event and cpu_clk = '0') then

    --       if (mb_gpio_ramsel = '0') then

    --           reg_ext_addr <= reg_ext_addr + 1;

    --           if (reg_ext_addr = x"2FAF080") then
    --               reg_ext_addr <= (others => '0');
    --               addr_cnt     <= addr_cnt + 1;
    --           end if;

    --       end if;

    --    end if;

    --end process; 

    --process(cpu_rst_n, cpu_clk)
    --begin

    --    if (cpu_rst_n = '0') then

    --        reg_ext_mem <= (others => '1');

    --    elsif(cpu_clk'event and cpu_clk = '1') then

    --       if (ext_mem_cen(0) = '0') then
    --           reg_ext_mem <= ext_mem_dq_i;
    --       end if;

    --    end if;

    --end process;

    ---- Silly bankswitch circuit...
    --process(reset_2600, a26_sysclk)
    --begin

    --    if (reset_2600 = '1') then

    --        reg_rom_addr <= (others => '0');

    --    elsif (a26_sysclk'event and a26_sysclk = '1') then

    --        reg_rom_addr <= reg_rom_addr(15 downto 12) & rom_addr(11 downto 0);

    --        -- I am being very explicit here using all the bits of the address...
    --        -- either the synthesis tool is going to optimize this or I will since
    --        -- there is no need for so many comparitors...
    --        if (rom_addr(12) = '1') then

    --            -- This sets up bankswitching when the proper ROM address line
    --            -- is asserted....
    --            case mb_gpio_banksw is

    --                 -- With 2K, all we want to insure is that bit 11 of the
    --                 -- address is always clear...
    --                 when x"00" => reg_rom_addr(11) <= '0';

    --                 -- With 4K, we don't have to do anything...just
    --                 -- keep what we have (this case is only included in here
    --                 -- for "completeness and clarity"...it does not need
    --                 -- to be here at all...synthesis tools will optimize this 
    --                 -- away...
    --                 when x"01" => reg_rom_addr <= "0000" & rom_addr(11 downto 0);

    --                 -- This is the 8K, 0xF8 bankswitch method
    --                 when x"F8" => if (rom_addr(11 downto 0) = x"FF8") then
    --                                   reg_rom_addr(15 downto 12) <= "0000";
    --                               elsif(rom_addr(11 downto 0) = x"FF9") then
    --                                   reg_rom_addr(15 downto 12) <= "0001";
    --                               end if;

    --                 -- This is the 16K, 0xF6 bankswitch method
    --                 when x"F6" => if (rom_addr(11 downto 0) = x"FF6") then
    --                                   reg_rom_addr(15 downto 12) <= "0000";
    --                               elsif(rom_addr(11 downto 0) = x"FF7") then
    --                                   reg_rom_addr(15 downto 12) <= "0001";
    --                               elsif(rom_addr(11 downto 0) = x"FF8") then
    --                                   reg_rom_addr(15 downto 12) <= "0010";
    --                               elsif(rom_addr(11 downto 0) = x"FF9") then
    --                                   reg_rom_addr(15 downto 12) <= "0011";
    --                               end if;

    --                 -- This is the 32K, 0xF4 bankswitch method (Fatal Run)
    --                 when x"F4" => if (rom_addr(11 downto 0) = x"FF4") then
    --                                   reg_rom_addr(15 downto 12) <= "0000";
    --                               elsif(rom_addr(11 downto 0) = x"FF5") then
    --                                   reg_rom_addr(15 downto 12) <= "0001";
    --                               elsif(rom_addr(11 downto 0) = x"FF6") then
    --                                   reg_rom_addr(15 downto 12) <= "0010";
    --                               elsif(rom_addr(11 downto 0) = x"FF7") then
    --                                   reg_rom_addr(15 downto 12) <= "0011";
    --                               elsif(rom_addr(11 downto 0) = x"FF8") then
    --                                   reg_rom_addr(15 downto 12) <= "0100";
    --                               elsif(rom_addr(11 downto 0) = x"FF9") then
    --                                   reg_rom_addr(15 downto 12) <= "0101";
    --                               elsif(rom_addr(11 downto 0) = x"FFa") then
    --                                   reg_rom_addr(15 downto 12) <= "0110";
    --                               elsif(rom_addr(11 downto 0) = x"FFb") then
    --                                   reg_rom_addr(15 downto 12) <= "0111";
    --                               end if;

    --                 -- No other magic accesses are supported yet, so do nothing.
    --                 when others => null;

    --            end case;
    --       
    --       end if;

    --    end if;

    --end process;

    --------------------------------------------------------------------
    -- WHEN SIMULATING, USE THE BELOW SETTINGS>>>>>
    --------------------------------------------------------------------

    -- Various signals to drive to external memory...
    sram_addr        <= (others => '0');
    sram_data        <= (others => '0');
    sram_wen         <= '1';
    sram_cen         <= '1';
    sram_oen         <= '1';
    sram_ub          <= '1';
    sram_lb          <= '1';
    mb_gpio_ramsel   <= '0';
    mb_gpio_freqsel  <= '1';
    mb_gpio_bw_col   <= '1';
    mb_gpio_diff_l   <= '1';
    mb_gpio_diff_r   <= '1';
    mb_gpio_gamesel  <= '1';
    mb_gpio_start    <= '1';
    leds             <= (others => '0');

    ---------------------------------------------------------------------

    reset_2600 <= mb_gpio_ramsel or a26_powon_rst;


    -- The beloved Atari 2600...
    a2600_core_0 : a2600_core
    port map
    (
    
        -- Clock and reset
        clk         => a26_sysclk,
        reset       => reset_2600,
    
        -- synthesis translate_off
        ref_newline => ref_newline,
        -- synthesis translate_on
    
        -- Reference for pixel clock
        pix_ref     => pix_ref_i,
    
        -- System reset from Atari 2600 component
        system_rst  => open,
         
        -- Controller ports...
    
        -- Left Controller Port
        ctl_l       => ctl_l,
        ctl_l_o     => ctl_l_o,
        pad_l_0     => pad_l_0,
        pad_l_1     => pad_l_1,
        trig_l      => trig_l,
    
        -- Right Controller Port
        ctl_r       => ctl_r,
        ctl_r_o     => ctl_r_o,
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
        vid_blank_n => vid_blank_n,
    
        -- Audio Output
        aud_ch0     => aout0,
        aud_ch1     => aout1
    
    );

    -- ROM of some Atari game...this is going to be
    -- replaced with happy SRAM.
--    gamerom_0 : xil_rom
--    port map(
--        addr => rom_addr(11 downto 0),
--        clk  => a26_sysclk,
--        dout => rom_rdata 
--    );
	 
gamerom_0 :  work.barnstorming 
port map (
        addr => rom_addr(11 downto 0),
        clk  => a26_sysclk,
        data => rom_rdata 
);

    -- This circuit takes the audio channels from the Atari and 
    -- converts them into a PWM stream.  A low pass filter off chip
    -- makes those sounds we know and love from that stream.
    a26_aud_dac_0 : a26_audio_dac
    port map(
    
        clk    => cpu_clk,   -- We need a "fast" clock cource
        reset  => cpu_rst, 
        a_in_1 => aout0, 
        a_in_2 => aout1, 
        aout   => speaker
    
    );

    -- Drive out the same audio on both speakers.
    speaker_l <= speaker;
    speaker_r <= speaker;

    -- Here's a nice circuit to test the LCD
    process(a26_sysclk, a26_powon_rst)
    begin

        if (a26_powon_rst = '1') then

           lcd_red       <= (others => '0');
           lcd_grn       <= (others => '0');
           lcd_blu       <= (others => '0');
           lcd_clk_i     <= '0';
           lcd_rst_n_i   <= '0';
           lcd_horiz_cnt <=  0;
           lcd_vert_cnt  <=  0;
           lcd_field     <= '0';

        elsif (a26_sysclk'event and a26_sysclk = '1') then

           -- Default
           lcd_field <= '0';

           -- Create the clock we drive to the LCD...this also 
           -- creates a reference 3.5MHz clock
           lcd_clk_i <= not(lcd_clk_i);

           -- Next simply count from 0 to 269 for the horizontal
           -- timing...

           if (lcd_clk_i = '1') then

               if (lcd_horiz_cnt /= 271) then
                   lcd_horiz_cnt <= lcd_horiz_cnt + 1;
               else

                   -- Clear the horizontal counter
                   lcd_horiz_cnt <= 0;
        
                   -- See if the vertical counter needs attention 
                   if (lcd_vert_cnt /= 199) then
                       lcd_vert_cnt <= lcd_vert_cnt + 1;
                   else
                       lcd_vert_cnt <= 0;
                       lcd_field    <= '1';
                   end if;

               end if;

           end if;

--           -- Based on blank, clock out pixels
--           if ((lcd_vblank = '0') and (lcd_hblank = '0')) then
--              lcd_red       <= (others => '1');
--              lcd_grn       <= (others => '1');
--              lcd_blu       <= (others => '1');
--           else
--              lcd_red       <= (others => '0');
--              lcd_grn       <= (others => '0');
--              lcd_blu       <= (others => '0');
--           end if;
         
           -- The data sheet says that we should deassert LCD reset
           -- after one field...so, when the pulse is present, deassert
           -- the reset!
           if (lcd_field = '1') then
               lcd_rst_n_i <= '1';
           end if;

        end if;

    end process;

    lcd_hsync_n   <= '0' when ((lcd_horiz_cnt >= 255) and (lcd_horiz_cnt < 265)) else '1';
    lcd_vsync_n   <= '0' when ((lcd_vert_cnt >= 180) and (lcd_vert_cnt < 183)) else '1';

    lcd_vblank    <= '1' when ((lcd_vert_cnt >= 160) and (lcd_vert_cnt <= 199)) else '0';
    lcd_hblank    <= '1' when ((lcd_horiz_cnt >= 240) and (lcd_horiz_cnt <= 271)) else '0';

    process(a26_sysclk, a26_powon_rst)
    begin

        if (a26_powon_rst = '1') then

            scanlmem_waddr <= (others => '0');
           
        elsif(a26_sysclk'event and a26_sysclk = '1') then

            if (pix_ref_i = '1') then

                if (push_we = '1') then
                    scanlmem_waddr <= scanlmem_waddr + 1;
                end if;

            end if;

        end if;

    end process;

    -- Partial scanline RAM...it can store about 12.8 scanlines    
--    scanl_ram_0 : scanlram_2kx9
--    port map(
--    	addra => scanlmem_waddr,
--    	addrb => scanlmem_raddr,
--    	clka  => a26_sysclk,
--    	clkb  => a26_sysclk,
--    	dina  => push_wdata,
--    	doutb => scanlmem_rdata,
--    	wea   => push_we
--    );

scanl_ram_0 : work.dpram generic map (11,9)
port map
(
	address_a => scanlmem_waddr,
	address_b => scanlmem_raddr,
	clock_a   => a26_sysclk,
	clock_b   => a26_sysclk,
	data_a    => push_wdata,
	q_b       => scanlmem_rdata,
	wren_a    => push_we
);

    process(a26_sysclk, a26_powon_rst)
    begin

        if (a26_powon_rst = '1') then

            prev_vsync     <= '0';
            vsync_fe       <= '0';
            push_pix_cnt   <=  0;
            push_scanl_cnt <=  0;
            push_wdata     <= (others => '0');
            push_we        <= '0';
            push_state     <= WAIT_FOR_VSYNC;
              
        elsif(a26_sysclk'event and a26_sysclk = '1') then

            -- Make sure the push signal is cleared on the 
            -- virtual half cycle tick of the pixel clock
            push_we <= '0';

            -- Rate limit down to 3.579545 MHz
            if (pix_ref_i = '1') then

                -- Create edge detect circuit to see when vsync ends.
                -- This will allow us to wait for removal of blank (valid frame)
                prev_vsync <= vid_vsyn_i;
                
                if ((prev_vsync = '1') and (vid_vsyn_i = '0')) then
                    vsync_fe <= '1';
                else
                    vsync_fe <= '0';
                end if;

                case push_state is

                    when WAIT_FOR_VSYNC =>

                        if (vsync_fe = '1') then
                            push_state <= WAIT_FOR_BLANK;
                        end if;

                    when WAIT_FOR_BLANK =>
 
                        -- If we are not blanking, then this
                        -- data is worth holding onto!!!!  SAVE IT!!! 
                        if (vid_blank_n = '1') then

                            push_wdata    <= cconv_9bit_pixel;
                            push_we       <= '1';
                            push_pix_cnt  <= push_pix_cnt + 1;
                            push_state    <= PUSH_BLANK_OFF;

                        end if;

                    when PUSH_BLANK_OFF =>

                        -- Register color space converted data
                        -- and indicate that a write needs to take place.
                        push_wdata  <= cconv_9bit_pixel;
                        push_we     <= '1';

                        -- Siphon up the next 159 pixels for the scanline...
                        if (push_pix_cnt = 159) then
                            push_pix_cnt <= 0;
                            push_scanl_cnt <= push_scanl_cnt + 1;
                            push_state     <= WAIT_BLANK_ON;
                        else
                            push_pix_cnt   <= push_pix_cnt + 1;
                        end if;

                    when WAIT_BLANK_ON =>

                        if (vid_blank_n = '0') then

                            if (push_scanl_cnt = 192) then
                                push_scanl_cnt <= 0;
                                push_state <= WAIT_FOR_VSYNC;
                            else
                                push_state <= WAIT_FOR_BLANK;
                            end if;

                        end if;

                end case;

            end if;

        end if;

    end process;
                       
    -- Map chrom/lum to 9 bit RGB                        
    a26_lcdcconv : a2600_9bit_color
    port map
    (
    
       col => vid_col,
       lum => vid_lum,
     
       red => cconv_9bit_pixel(8 downto 6),
       grn => cconv_9bit_pixel(5 downto 3),
       blu => cconv_9bit_pixel(2 downto 0) 
    
    );

    -- This logic handles video stuff...(TVs and VGA)
    a26_vid : a26_video_decode
    port map(
    
        clk         => a26_sysclk,
        reset       => a26_powon_rst,
        freq_sel    => mb_gpio_freqsel,
        pix_clk_ref => pix_ref_i,
        chroma      => vid_col,
        luma        => vid_lum,
        hsync_in    => vid_hsyn_i,
        vsync_in    => vid_vsyn_i,
    
        -- Video output signals
        red         => red_i,
        grn         => grn_i,
        blu         => blu_i,
        hsync_o     => hsync,
        vsync_o     => vsync
    
    );

    -- Only drive out the video bits the board supports
    red <= red_i(3 downto 1);
    grn <= grn_i(3 downto 1);
    blu <= blu_i(3 downto 1);

    -- synthesis translate_off
    pix_clk_ref <= a26_sysclk;
    -- synthesis translate_on

end struct;
