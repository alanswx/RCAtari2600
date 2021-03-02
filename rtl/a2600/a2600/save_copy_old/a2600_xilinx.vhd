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

-- Useful Atari 2600 core.
entity a2600_xilinx is
port
(

    -- Clocks and reset
    system_clk    : in    std_logic;  -- Main clock input...must be 7.16MHz or else
    dac_clk       : in    std_logic;  -- Fast clock for DAC.
    powon_reset   : in    std_logic;  -- Acts as system power-on-reset
    system_reset  : out   std_logic;  -- Reset from virtual TIA component

    -- synthesis translate_off
    ref_newline   : out   std_logic;  -- Used in the simulation environment
    -- synthesis translate_on

    -------------------------------------------------------
    -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
    bw_col        : inout std_logic;
    diff_l        : inout std_logic;
    diff_r        : inout std_logic;
    gamesel       : inout std_logic;
    start         : inout std_logic;
    -------------------------------------------------------

    -------------------------------------------------------
    -- Atari controller ports:
    -------------------------------------------------------
    -- Left 
    -------------------------------------------------------
    ctl_l         : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
    pad_l_0       : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
    pad_l_1       : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
    trig_l        : in    std_logic;                    -- Left trigger input      (pin 6)
    -------------------------------------------------------
    -- Right
    -------------------------------------------------------
    ctl_r         : inout std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
    pad_r_0       : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
    pad_r_1       : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
    trig_r        : in    std_logic;                    -- Left trigger input      (pin 6)
    -------------------------------------------------------

    -------------------------------------------------------
    -- Interface to ROM...ROM wdata sounds silly, but keep
    -- in mind that the ROM port of the 2600 may get write
    -- data depending on the bankswitch scheme used!!!!
    rom_addr      : out   std_logic_vector(11 downto 0);
    rom_rdata     : in    std_logic_vector( 7 downto 0);
    rom_wdata     : out   std_logic_vector( 7 downto 0);
    -------------------------------------------------------
                                      
    -------------------------------------------------------
    -- Video Output.
    red           : out   std_logic_vector(3 downto 0);   -- 4 bit red value
    grn           : out   std_logic_vector(3 downto 0);   -- 4 bit green value
    blu           : out   std_logic_vector(3 downto 0);   -- 4 bit blue value
    vs_n          : out   std_logic;                      -- Vertical sync
    hs_n          : out   std_logic;                      -- Horizontal sync
    -------------------------------------------------------

    -------------------------------------------------------
    -- Audio Output
    aud_l         : out   std_logic;
    aud_r         : out   std_logic
    -------------------------------------------------------

);
end a2600_xilinx;

architecture struct of a2600_xilinx is

    -- Video interconnect
    signal vid_hsyn_i   : std_logic;
    signal vid_vsyn_i   : std_logic;
    signal vid_red_i    : std_logic_vector(3 downto 0);
    signal vid_grn_i    : std_logic_vector(3 downto 0);
    signal vid_blu_i    : std_logic_vector(3 downto 0);
    signal vid_col      : std_logic_vector(3 downto 0);
    signal vid_lum      : std_logic_vector(2 downto 0);
    signal pix_ref_i    : std_logic;

    ----------------------------------
    -- Audio DAC Interface and signals
    ----------------------------------
    signal aout0        : std_logic_vector(3 downto 0);
    signal aout1        : std_logic_vector(3 downto 0);
    signal audiosum     : std_logic_vector(4 downto 0);
    signal pcm_data     : std_logic_vector(8 downto 0);

    signal hs_n_i       : std_logic;
    signal vs_n_i       : std_logic;

begin

    -- The beloved Atari 2600...
    a2600_core_0 : a2600_core
    port map
    (
    
        -- Clock and reset
        clk         => system_clk,
        reset       => powon_reset,
    
        -- synthesis translate_off
        ref_newline => ref_newline,
        -- synthesis translate_on
    
        -- Reference for pixel clock
        pix_ref     => pix_ref_i,
    
        -- System reset 
        system_rst  => system_reset,
         
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

    --------------------------------------------------------------------
    -- THE FOLLOWING LOGIC MIXES THE AUDIO CIRCUIT AND DRIVES IT OFF  --
    -- CHIP AS A ONE BIT AUDIO VALUE (PWM).                           --
    --------------------------------------------------------------------

    -- Silly mixer that adjusts audio data (again, ripped off from
    -- Eric Crabill :)! )
    audiosum <= ('0' & aout0) + ('0' & aout1);

    -- // The pcm data sent to the dac needs
    -- // to be 9-bit, and signed.  What I do
    -- // here is multiply the audiosum by four
    -- // to get 9'b000000000 to 9'b001111000
    -- // and then negatively offset the value
    -- // by about half that range, trying to
    -- // recenter it about zero.
    process(system_clk, powon_reset)
    begin 
      if (powon_reset = '1') then
           pcm_data <= (others => '0');
      elsif(system_clk'event and system_clk = '1') then
           pcm_data <= ("00" & audiosum & "00") + "111000100";
      end if;
    end process;

    -- We'll drive audio here!
    dac_0 : a2600_dac
    port map(

        clk     => dac_clk,
        reset   => powon_reset,
        sample  => pcm_data,
        l       => aud_l,
        r       => aud_r

    );

    -----------------------------------------------------------------------

    -----------------------------------------------------------------------
    -- The following circuits drive video data off chip...               --
    -----------------------------------------------------------------------

    -- Color table
    col_map_0 : a2600_12bit_color
    port map
    (
    
       col => vid_col,
       lum => vid_lum,
    
       red => vid_red_i,
       grn => vid_grn_i,
       blu => vid_blu_i
    
    );

    -- USE THIS IF DRIVING A VGA monitor that requires higher 
    -- frequencies
    dblscan_0 : a2600_dblscan_xil
    port map(

        R_IN          => vid_red_i,
        G_IN          => vid_grn_i,
        B_IN          => vid_blu_i,

        HSYNC_IN      => vid_hsyn_i,
        VSYNC_IN      => vid_vsyn_i,

        R_OUT         => red,
        G_OUT         => grn,
        B_OUT         => blu,

        HSYNC_OUT     => hs_n_i,
        VSYNC_OUT     => vs_n_i,

        CLK_HALF_ENA  => pix_ref_i,
        CLK_FAST      => system_clk

    );

    -- Inveert the sync signals.
    hs_n <= hs_n_i;
    vs_n <= vs_n_i;

    -----------------------------------------------------------------------

    -- USE THE FOLLOWING IF YOU ARE DRIVING A MONITOR THAT
    -- SUPPORTS 15.7KHz hsync frequencies!!!
    -- Register the outputs of the color mapper...
    -- This is the additional clock needed for accurate
    -- driving of pixels...
--    process(system_clk)
--    begin

--        if (system_clk'event and system_clk = '1') then
--
--            if (pix_ref_i = '1') then
--                vid_red <= vid_red_i;
--                vid_grn <= vid_grn_i;
--                vid_blu <= vid_blu_i;
--            end if;
--
--        end if;

--    end process;


end struct;
