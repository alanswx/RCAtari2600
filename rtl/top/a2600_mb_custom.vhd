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
entity a2600_mb_custom is
port
(
    -- Input reference clock (14.31MHz)
    clk               : in    std_logic;

    -- synthesis translate_off
    pix_clk_ref       : out   std_logic;
    -- synthesis translate_on
    
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
    red               : out   std_logic_vector(3 downto 0);
    grn               : out   std_logic_vector(3 downto 0);
    blu               : out   std_logic_vector(3 downto 0);
    hsync             : out   std_logic;
    vsync             : out   std_logic;

    lcd_clk           : out   std_logic;
    lcd_rst_n         : out   std_logic;
    
    -------------------------------------------------------
    -- Audio outputs
    -------------------------------------------------------
    speaker           : out   std_logic;
    
    -------------------------------------------------------
    -- UART pins
    -------------------------------------------------------
    uart_tx           : out   std_logic;
    uart_rx           : in    std_logic;

    -- Flash control (tie off)
    flash_cen         : out   std_logic;
    flash_oen         : out   std_logic;
    flash_rp_n        : out   std_logic;
    
    -------------------------------------------------------
    -- Memory bus
    -------------------------------------------------------
    sram_addr         : out   std_logic_vector(17 downto 0);
    sram_data         : inout std_logic_vector(15 downto 0);
    sram_wen          : out   std_logic;
    sram_cen          : out   std_logic;
    sram_oen          : out   std_logic

);
end a2600_mb_custom;

architecture struct of a2600_mb_custom is

    -- Clock circuit for the Altium board
    component a26_cpcb_clks
    port (
    
        clk     : in  std_logic; -- 50MHz source
    
        clk_sys : out std_logic; -- Output of DCM 50MHz clock
        clk_a26 : out std_logic; -- Atari 2600 ref. clk (7.19MHz)
    
        rst_mb  : out std_logic; -- Reset Microblaze
        por     : out std_logic  -- Power on reset
    
    );
    end component;

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
        rom_addr    : out std_logic_vector(12 downto 0); -- The program address bus
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
    signal mb_gpio_lcd        : std_logic;

    signal a26_powon_rst      : std_logic;
    signal a26_sysclk         : std_logic;
    signal reset_2600         : std_logic;

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
    signal addr_cnt           : std_logic_vector( 3 downto 0);

    -- Video interconnect
    signal vid_hsyn_i   : std_logic;
    signal vid_vsyn_i   : std_logic;
    signal vid_blank_n  : std_logic;
    signal red_i        : std_logic_vector(3 downto 0);
    signal grn_i        : std_logic_vector(3 downto 0);
    signal blu_i        : std_logic_vector(3 downto 0);
    signal vid_col      : std_logic_vector(3 downto 0);
    signal vid_lum      : std_logic_vector(2 downto 0);
    signal pix_ref_i    : std_logic; 
    signal hsync_i      : std_logic;
    signal vsync_i      : std_logic;

    signal sram_ctl_addr  : std_logic_vector(17 downto 0);
    signal sram_ctl_wdata : std_logic_vector(15 downto 0);

    signal sram_wdata     : std_logic_vector(15 downto 0);
    signal sram_ts        : std_logic_vector(15 downto 0);

    type sram_access_t is (SRAM_IDLE, SRAM_WAIT_ROM, SRAM_FETCH_ROMDATA,
                           SRAM_WAIT_VBUF_READ, SRAM_REG_VBUF_DATA, SRAM_WRITE);
                       
    signal sram_access    : sram_access_t;

    signal reg_pix_ref    : std_logic;
    signal kick_pix_ref   : std_logic;
    signal reg_romdata    : std_logic_vector(7 downto 0);
    signal reg_vbuf_rdata : std_logic_vector(8 downto 0);
    signal vbuffer_raddr  : std_logic_vector(16 downto 0);
    signal vbuffer_waddr  : std_logic_vector(16 downto 0);
    signal sram_ctl_wen   : std_logic;
    signal sram_ctl_oen   : std_logic;

    signal prev_vsync       : std_logic; 
    signal vsync_fe         : std_logic;
    signal prev_hsync       : std_logic; 
    signal hsync_fe         : std_logic;
    signal lline_cnt        : integer range 0 to 7;
    signal push_pix_cnt     : integer range 0 to 255;
    signal push_scanl_cnt   : integer range 0 to 255;
    signal push_wdata       : std_logic_vector(8 downto 0);
    signal push_we          : std_logic;
    signal push_waddr       : std_logic_vector(16 downto 0);
    signal cconv_9bit_pixel : std_logic_vector(8 downto 0);

    type push_state_t is (WAIT_FOR_VSYNC, WAIT_FOR_BLANK, WAIT_FOR_HSYNC, PUSH_VDATA, WAIT_BLANK_ON);
    signal push_state : push_state_t;

    signal lcd_hsync_n   : std_logic;
    signal lcd_vsync_n   : std_logic;
    signal lcd_red       : std_logic_vector(2 downto 0);
    signal lcd_grn       : std_logic_vector(2 downto 0);
    signal lcd_blu       : std_logic_vector(2 downto 0);
    signal lcd_clk_i     : std_logic;
    signal lcd_rst_n_i   : std_logic;
    signal lcd_horiz_cnt : integer range 0 to 511;
    signal lcd_vert_cnt  : integer range 0 to 511;
    signal lcd_field     : std_logic;
    signal lcd_vblank    : std_logic;
    signal lcd_hblank    : std_logic;
    signal off           : std_logic_vector(5 downto 0);
    signal adv_ptr       : std_logic;

begin

    -- Tieoffs  
    gnd_vec <= (others => '0');

    -- Clock circuit.  This provides the Microblaze clock 
    -- as well as the Atari 2600 clock...
    clk_rst_0 : a26_cpcb_clks
    port map(
    
        clk     => clk,
    
        clk_sys => cpu_clk,
        clk_a26 => a26_sysclk,
    
        rst_mb  => cpu_rst,
        por     => a26_powon_rst
    
    );

    -- Invert reset for CPU system 
    cpu_rst_n <= not(cpu_rst);

    --------------------------------------------------------------------
    -- WHEN SYNTHESIZING, USE THE BELOW SETTINGS>>>>>
    --------------------------------------------------------------------

    ---- This is the Microblaze System component.  The goal is to
    ---- replace this with a free, opensource RISC CPU (i.e. OpenRISC).
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

    -- Map the GPIO to "readable" signals
    mb_gpio_lcd      <= mb_gpiovec(16);
    mb_gpio_banksw   <= mb_gpiovec(15 downto 8);
    mb_gpio_ramsel   <= mb_gpiovec(6);
    mb_gpio_freqsel  <= mb_gpiovec(5);
    mb_gpio_bw_col   <= mb_gpiovec(4);
    mb_gpio_diff_l   <= mb_gpiovec(2);
    mb_gpio_diff_r   <= mb_gpiovec(3);
    mb_gpio_gamesel  <= mb_gpiovec(1);
    mb_gpio_start    <= mb_gpiovec(0);

    -- Generate tristate drivers for the memory
    tsb_0: for i in 0 to 15 generate
    begin

         sram_ts(i)      <= '0' when (((ext_mem_dq_t(i) = '0') and (mb_gpio_ramsel = '1')) or
                                      ((sram_ctl_wen = '0')    and (mb_gpio_ramsel = '0')) ) else '1';

         sram_data(i)    <= sram_wdata(i) when (sram_ts(i) = '0') else 'Z';

         ext_mem_dq_i(i) <= sram_data(i);

    end generate;

    -- Various signals to drive to external memory...
    sram_addr_i   <= ext_mem_addr(17 downto 0) when (mb_gpio_ramsel = '1') 
                                               --else ("00" & reg_rom_addr(15 downto 1) & '0');
                                               else sram_ctl_addr; -- CHANGED FOR CONTROLLER USE
                                                 --else ("00000000000000" & addr_cnt);

    sram_wdata    <= ext_mem_dq_o              when (mb_gpio_ramsel = '1')
                                               else sram_ctl_wdata;

    sram_addr     <= sram_addr_i;
    sram_wen      <= ext_mem_wen               when (mb_gpio_ramsel = '1') else sram_ctl_wen;
    sram_cen      <= ext_mem_cen(0)            when (mb_gpio_ramsel = '1') else '0';
    sram_oen      <= ext_mem_oen(0)            when (mb_gpio_ramsel = '1') else sram_ctl_oen;
    --sram_ub     <= ext_mem_ben(1)            when (mb_gpio_ramsel = '1') else '0';
    --sram_lb     <= ext_mem_ben(0)            when (mb_gpio_ramsel = '1') else '0';

    -- CHANGED FOR CONTROLLER USE
    --rom_rdata     <= ext_mem_dq_i(15 downto 8) when (reg_rom_addr(0) = '0') else ext_mem_dq_i(7 downto 0);
    rom_rdata     <= reg_romdata;

    -- Silly bankswitch circuit...
    process(reset_2600, a26_sysclk)
    begin

        if (reset_2600 = '1') then

            reg_rom_addr <= (others => '0');

        elsif (a26_sysclk'event and a26_sysclk = '1') then

            reg_rom_addr <= reg_rom_addr(15 downto 12) & rom_addr(11 downto 0);

            -- I am being very explicit here using all the bits of the address...
            -- either the synthesis tool is going to optimize this or I will since
            -- there is no need for so many comparitors...
            if (rom_addr(12) = '1') then

                -- This sets up bankswitching when the proper ROM address line
                -- is asserted....
                case mb_gpio_banksw is

                     -- With 2K, all we want to insure is that bit 11 of the
                     -- address is always clear...
                     when x"00" => reg_rom_addr(11) <= '0';

                     -- With 4K, we don't have to do anything...just
                     -- keep what we have (this case is only included in here
                     -- for "completeness and clarity"...it does not need
                     -- to be here at all...synthesis tools will optimize this 
                     -- away...
                     when x"01" => reg_rom_addr <= "0000" & rom_addr(11 downto 0);

                     -- This is the 8K, 0xF8 bankswitch method
                     when x"F8" => if (rom_addr(11 downto 0) = x"FF8") then
                                       reg_rom_addr(15 downto 12) <= "0000";
                                   elsif(rom_addr(11 downto 0) = x"FF9") then
                                       reg_rom_addr(15 downto 12) <= "0001";
                                   end if;

                     -- This is the 16K, 0xF6 bankswitch method
                     when x"F6" => if (rom_addr(11 downto 0) = x"FF6") then
                                       reg_rom_addr(15 downto 12) <= "0000";
                                   elsif(rom_addr(11 downto 0) = x"FF7") then
                                       reg_rom_addr(15 downto 12) <= "0001";
                                   elsif(rom_addr(11 downto 0) = x"FF8") then
                                       reg_rom_addr(15 downto 12) <= "0010";
                                   elsif(rom_addr(11 downto 0) = x"FF9") then
                                       reg_rom_addr(15 downto 12) <= "0011";
                                   end if;

                     -- This is the 32K, 0xF4 bankswitch method (Fatal Run)
                     when x"F4" => if (rom_addr(11 downto 0) = x"FF4") then
                                       reg_rom_addr(15 downto 12) <= "0000";
                                   elsif(rom_addr(11 downto 0) = x"FF5") then
                                       reg_rom_addr(15 downto 12) <= "0001";
                                   elsif(rom_addr(11 downto 0) = x"FF6") then
                                       reg_rom_addr(15 downto 12) <= "0010";
                                   elsif(rom_addr(11 downto 0) = x"FF7") then
                                       reg_rom_addr(15 downto 12) <= "0011";
                                   elsif(rom_addr(11 downto 0) = x"FF8") then
                                       reg_rom_addr(15 downto 12) <= "0100";
                                   elsif(rom_addr(11 downto 0) = x"FF9") then
                                       reg_rom_addr(15 downto 12) <= "0101";
                                   elsif(rom_addr(11 downto 0) = x"FFa") then
                                       reg_rom_addr(15 downto 12) <= "0110";
                                   elsif(rom_addr(11 downto 0) = x"FFb") then
                                       reg_rom_addr(15 downto 12) <= "0111";
                                   end if;

                     -- No other magic accesses are supported yet, so do nothing.
                     when others => null;

                end case;
           
           end if;

        end if;

    end process;

    -- This process here drives the external SRAM...we drive this
    -- on the nice, FAST clock domain...
    process(cpu_clk, cpu_rst_n)
    begin

        if (cpu_rst_n = '0') then

            sram_ctl_addr  <= (others => '0');
            sram_ctl_wdata <= (others => '0');
            sram_access    <= SRAM_IDLE;
            reg_pix_ref    <= '0';
            kick_pix_ref   <= '0';
            reg_romdata    <= (others => '0');
            reg_vbuf_rdata <= (others => '0');
            sram_ctl_wen   <= '1';
            sram_ctl_oen   <= '0';

        elsif(cpu_clk'event and cpu_clk = '1') then

            -- Defaults for SRAM control
            sram_ctl_wen <= '1';
            sram_ctl_oen <= '0';

            -- Generate a detect of the pix_ref signal edge going
            -- high....this is our nice kick signal...
            reg_pix_ref <= pix_ref_i;

            if ((pix_ref_i = '1') and (reg_pix_ref = '0')) then
                kick_pix_ref <= '1';
            else
                kick_pix_ref <= '0';
            end if;
              
            -- We basically have 16 cycles to cram as many
            -- external accesses of SRAM as we can into
            -- one "main" Atari CPU cycle.
            case sram_access is 

                when SRAM_IDLE => 

                    -- Wait for our enable pulse...
                    if (kick_pix_ref = '1') then
 
                        -- If we see that the pix_ref signal is
                        -- high, that lets us know that we can drive
                        -- an access...we'll start with the ROM address
                        sram_ctl_addr <= ("00" & reg_rom_addr(15 downto 1) & '0');
                        sram_access   <= SRAM_WAIT_ROM;

                    end if;

                when SRAM_WAIT_ROM =>
                    sram_access   <= SRAM_FETCH_ROMDATA;

                when SRAM_FETCH_ROMDATA =>

                    -- Register the ROM data
                    if (reg_rom_addr(0) = '0') then
                        reg_romdata <= ext_mem_dq_i(15 downto 8);
                    else
                        reg_romdata <= ext_mem_dq_i( 7 downto 0);
                    end if;

                    -- Set up the video buffer read access
                    sram_ctl_addr <= '1' & vbuffer_raddr; -- Use upper 128K locations for video buffer.
                    sram_access   <= SRAM_WAIT_VBUF_READ;

                when SRAM_WAIT_VBUF_READ =>
                    sram_access   <= SRAM_REG_VBUF_DATA;

                when SRAM_REG_VBUF_DATA =>

                    -- Register the pixel read from video memory...
                    reg_vbuf_rdata <= ext_mem_dq_i(8 downto 0);

                    -- See if we should set up a write...
                    if (push_we = '1') then
                        sram_ctl_wdata <= ("0000000" & push_wdata);
                        sram_ctl_addr  <= ('1' & push_waddr);
                        sram_access    <= SRAM_WRITE;
                    else
                        sram_access    <= SRAM_IDLE;
                    end if;
                        
                when SRAM_WRITE =>

                    -- Drive data to SRAM...
                    sram_ctl_wen  <= '0';
                    sram_ctl_oen  <= '1';
                    sram_access   <= SRAM_IDLE;

            end case;

        end if;

    end process;            

    -- This process shall push pixel data into the video buffer..
    process(a26_sysclk, a26_powon_rst)
    begin

        if (a26_powon_rst = '1') then

            prev_vsync     <= '0';
            prev_hsync     <= '0';
            vsync_fe       <= '0';
            hsync_fe       <= '0';
            push_pix_cnt   <=  0;
            push_scanl_cnt <=  0;
            push_wdata     <= (others => '0');
            push_we        <= '0';
            lline_cnt      <= 0;
            push_waddr     <= (others => '0');
            vbuffer_waddr  <= (others => '0');
            push_state     <= WAIT_FOR_VSYNC;
              
        elsif(a26_sysclk'event and a26_sysclk = '1') then

            -- Rate limit down to 3.579545 MHz
            if (pix_ref_i = '1') then

                -- By default we do not push a pixel
                push_we <= '0';

                -- Create edge detect circuit to see when vsync ends.
                -- This will allow us to wait for removal of blank (valid frame)
                prev_vsync <= vid_vsyn_i;
                prev_hsync <= vid_hsyn_i;
                
                if ((prev_vsync = '1') and (vid_vsyn_i = '0')) then
                    vsync_fe <= '1';
                else
                    vsync_fe <= '0';
                end if;

                if ((prev_hsync = '1') and (vid_hsyn_i = '0')) then
                    hsync_fe <= '1';
                else
                    hsync_fe <= '0';
                end if;

                case push_state is

                    when WAIT_FOR_VSYNC =>

                        if (vsync_fe = '1') then
                            push_state <= WAIT_FOR_BLANK;
                        end if;

                    when WAIT_FOR_BLANK =>
 
                        -- Wait for the first blank signal...
                        -- We will not draw this scanline on the LCD
                        if (vid_blank_n = '1') then

                            -- Clear the local line counter
                            lline_cnt <= 0;

                            -- Goto state where we wait for
                            -- hsync...
                            push_state    <= WAIT_FOR_HSYNC;

                        end if;

                    when WAIT_FOR_HSYNC =>

                        -- Once we see HSYNC asserted, we know that
                        -- we can begin capturing data after a few cycles
                        -- elapse...specificly, 16 cycles...
                        if (hsync_fe = '1') then

                            if (lline_cnt = 5) then 
                               lline_cnt <= 0;
                            else
                               lline_cnt  <= lline_cnt + 1;
                               push_state <= PUSH_VDATA;
                            end if;

                        end if;

                    when PUSH_VDATA =>

                        -- Register color space converted data
                        -- and indicate that a write needs to take place.
                        if (push_pix_cnt > 15) then

                            push_wdata    <= cconv_9bit_pixel;
                            push_we       <= '1';
                            push_waddr    <= vbuffer_waddr;
                            vbuffer_waddr <= vbuffer_waddr + 1;

                        end if;

                        -- Siphon up the next 159 pixels for the scanline...
                        if (push_pix_cnt = 189) then
                            push_pix_cnt   <= 0;
                            push_scanl_cnt <= push_scanl_cnt + 1;
                            push_state     <= WAIT_BLANK_ON;
                        else
                            push_pix_cnt   <= push_pix_cnt + 1;
                        end if;

                    when WAIT_BLANK_ON =>

                        if (vid_blank_n = '0') then

                            if (push_scanl_cnt = 192) then
                                push_scanl_cnt <= 0;
                                vbuffer_waddr  <= (others => '0');
                                push_state     <= WAIT_FOR_VSYNC;
                            else
                                push_state     <= WAIT_FOR_HSYNC;
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

    -- Gate for resetting the 2600.
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
        bw_col      => mb_gpio_bw_col,
        diff_l      => mb_gpio_diff_l,
        diff_r      => mb_gpio_diff_r,
        gamesel     => mb_gpio_gamesel,
        start       => mb_gpio_start,
    
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
           vbuffer_raddr <= (others => '0');
           adv_ptr       <= '0';
           off           <= "000000";

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

               -- Based on blank, clock out pixels
               if ((lcd_vblank = '0') and (lcd_hblank = '0')) then

                  lcd_red <= reg_vbuf_rdata(8 downto 6);
                  lcd_grn <= reg_vbuf_rdata(5 downto 3);
                  lcd_blu <= reg_vbuf_rdata(2 downto 0);

                  vbuffer_raddr <= vbuffer_raddr + 1;

                  --if (lcd_horiz_cnt > 199) then
                  --    --lcd_red       <= off(5 downto 3);
                  --    --lcd_grn       <= (others => '0');
                  --    --lcd_blu       <= off(5 downto 3);
                  --    lcd_red       <= (others => '1');
                  --    lcd_grn       <= (others => '1');
                  --    lcd_blu       <= (others => '1');
                  --elsif (lcd_horiz_cnt > 159) then
                  --    --lcd_red       <= not(off(5 downto 3));
                  --    --lcd_grn       <= (others => '0');
                  --    --lcd_blu       <= (others => '0');
                  --    lcd_red       <= (others => '1');
                  --    lcd_grn       <= (others => '0');
                  --    lcd_blu       <= (others => '1');
                  --elsif (lcd_horiz_cnt > 119) then
                  --    --lcd_red       <= (others => '0');
                  --    --lcd_grn       <= off(5 downto 3);
                  --    --lcd_blu       <= (others => '0');
                  --    lcd_red       <= (others => '0');
                  --    lcd_grn       <= (others => '1');
                  --    lcd_blu       <= (others => '1');
                  --elsif (lcd_horiz_cnt > 79) then
                  --    --lcd_red       <= not(off(5 downto 3));
                  --    --lcd_grn       <= not(off(5 downto 3));
                  --    --lcd_blu       <= (others => '0');
                  --    lcd_red       <= (others => '0');
                  --    lcd_grn       <= (others => '0');
                  --    lcd_blu       <= (others => '1');
                  --elsif (lcd_horiz_cnt > 39) then
                  --    --lcd_red       <= (others => '0');
                  --    --lcd_grn       <= off(5 downto 3);
                  --    --lcd_blu       <= off(5 downto 3);
                  --    lcd_red       <= (others => '0');
                  --    lcd_grn       <= (others => '1');
                  --    lcd_blu       <= (others => '0');
                  --else
                  --    lcd_red       <= (others => '1');
                  --    lcd_grn       <= (others => '0');
                  --    lcd_blu       <= (others => '0');
                  --    --lcd_blu       <= not(off(5 downto 3));
                  --end if;
                  
               else

                  -- If we are in vertical blank, then we know to 
                  -- reset the read pointer.
                  if (lcd_vblank = '1') then
                      vbuffer_raddr <= (others => '0');
                  end if;
                      
                  lcd_red       <= (others => '0');
                  lcd_grn       <= (others => '0');
                  lcd_blu       <= (others => '0');

               end if;

           end if;
         
           -- The data sheet says that we should deassert LCD reset
           -- after one field...so, when the pulse is present, deassert
           -- the reset!
           if (lcd_field = '1') then
               off <= off + 1;
               lcd_rst_n_i <= '1';
           end if;

        end if;

    end process;

    lcd_hsync_n   <= '0' when ((lcd_horiz_cnt >= 255) and (lcd_horiz_cnt < 265)) else '1';
    lcd_vsync_n   <= '0' when ((lcd_vert_cnt >= 180) and (lcd_vert_cnt < 183)) else '1';

    lcd_vblank    <= '1' when ((lcd_vert_cnt >= 160) and (lcd_vert_cnt <= 199)) else '0';
    --lcd_hblank    <= '1' when ((lcd_horiz_cnt >= 241) and (lcd_horiz_cnt <= 271)) else '0';
    lcd_hblank    <= '1' when ((lcd_horiz_cnt >= 207) or (lcd_horiz_cnt <= 32)) else '0';

    lcd_clk       <= lcd_clk_i;
    lcd_rst_n     <= lcd_rst_n_i;
           
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

    -- This logic handles video stuff...
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
        hsync_o     => hsync_i,
        vsync_o     => vsync_i
    
    );

    -- Only drive out the video bits the board supports
    red        <= red_i   when (mb_gpio_lcd = '1') else (lcd_red & '0');
    grn        <= grn_i   when (mb_gpio_lcd = '1') else (lcd_grn & '0');
    blu        <= blu_i   when (mb_gpio_lcd = '1') else (lcd_blu & '0');
    hsync      <= hsync_i when (mb_gpio_lcd = '1') else (lcd_hsync_n);
    vsync      <= vsync_i when (mb_gpio_lcd = '1') else (lcd_vsync_n);

    flash_cen  <= '1';       
    flash_oen  <= '1'; 
    flash_rp_n <= '1'; 

    -- synthesis translate_off
    pix_clk_ref <= a26_sysclk;
    -- synthesis translate_on

end struct;
