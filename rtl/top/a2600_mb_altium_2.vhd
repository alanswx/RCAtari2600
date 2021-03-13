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
    a26_sysclk        : in std_logic;                       -- 

	 a26_powon_rst     :  in  std_logic;

    pix_clk_ref       : out   std_logic;
    
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
    red               : out   std_logic_vector(3 downto 0);
    grn               : out   std_logic_vector(3 downto 0);
    blu               : out   std_logic_vector(3 downto 0);
    hsync             : out   std_logic;
    vsync             : out   std_logic;
    blank_n           : out   std_logic;
        vid_hblank : out std_logic;                    -- Blank!...register on a pix clk tick!
        vid_vblank : out std_logic;                    -- Blank!...register on a pix clk tick!
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

	 
    aout0              : out std_logic_vector(3 downto 0);
    aout1              : out std_logic_vector(3 downto 0)



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
        clk2x        : in std_logic;                       -- Use 2x the main osc clock
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
        vid_hblank : out std_logic;                    -- Blank!...register on a pix clk tick!
        vid_vblank : out std_logic;                    -- Blank!...register on a pix clk tick!
    
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

  --  signal aout0              : std_logic_vector(3 downto 0);
  --  signal aout1              : std_logic_vector(3 downto 0);

	 
    signal reg_ext_addr       : std_logic_vector(27 downto 0);
    signal reg_ext_mem       : std_logic_vector(15 downto 0);
    signal addr_cnt          : std_logic_vector( 3 downto 0);

    -- Video interconnect
    signal vid_hsyn_i     : std_logic;
    signal vid_vsyn_i     : std_logic;
    signal vid_blank_n    : std_logic;
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
blank_n <= vid_blank_n;

    -- Tieoffs  
    gnd_vec <= (others => '0');



    -- Invert reset for CPU system 
    cpu_rst_n <= not(cpu_rst);


    ---------------------------------------------------------------------

    reset_2600 <=  a26_powon_rst;


    -- The beloved Atari 2600...
    a2600_core_0 : a2600_core
    port map
    (
    
        -- Clock and reset
        clk2x         => clk,
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
        vid_hblank => vid_hblank,
        vid_vblank => vid_vblank,
    
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




	 -- Color table
    col_map_0 : work.a2600_12bit_color
    port map
    (
    
       col => vid_col,
       lum => vid_lum,
    
       red => red,
       grn => grn,
       blu => blu    
    );

        vsync   <= vid_vsyn_i;
        hsync   <= vid_hsyn_i;
        blank_n <= vid_blank_n;

    -- synthesis translate_off
    --pix_clk_ref <= a26_sysclk;
	 pix_clk_ref <= pix_ref_i;
    -- synthesis translate_on

end struct;
