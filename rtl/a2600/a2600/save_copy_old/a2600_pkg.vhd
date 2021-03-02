-------------------------------------------------------------------------------
--
--   Copyright (C) 2004 Retrocircuits, LLC.
--
--   Title       : Atari 2600 Package
--
--   Description : This package holds the actual Atari 2600 core component
--                 as well as other misc. goodies people may want to use.
--
--   Author      : Ed Henciak
--
--   Date        : February 19, 2005
--
-------------------------------------------------------------------------------
-- synthesis library a2600
library IEEE;
    use IEEE.std_logic_1164.all;

package a2600_pkg is

    -- Useful Atari 2600 core.
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
        rom_addr    : out std_logic_vector(11 downto 0); -- The program address bus..A12 is kept internal
        rom_wdata   : out std_logic_vector( 7 downto 0); -- For programs w. external RAM
        rom_rdata   : in  std_logic_vector( 7 downto 0); -- Program data bus (input)

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

    -- Core with Xilinx primitives...
    component a2600_xilinx
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
    end component;

    -- Chroma and Luma  mapping to 12 bit RGB values.
    component a2600_12bit_color
    port
    (
    
       col : in  std_logic_vector(3 downto 0);
       lum : in  std_logic_vector(2 downto 0);
    
       red : out std_logic_vector(3 downto 0);
       grn : out std_logic_vector(3 downto 0);
       blu : out std_logic_vector(3 downto 0)
    
    );
    end component;

    -- RAM for the Xilinx doublescan component
    component dpr_512x12_xil
    port (

        addra : IN  std_logic_VECTOR(8 downto 0);
        addrb : IN  std_logic_VECTOR(8 downto 0);
        clka  : IN  std_logic;
        clkb  : IN  std_logic;
        dina  : IN  std_logic_VECTOR(11 downto 0);
        doutb : OUT std_logic_VECTOR(11 downto 0);
        ena   : IN  std_logic;
        wea   : IN  std_logic

    );
    end component;

    -- Xilinx doublescanner
    component a2600_dblscan_xil
    port (

       R_IN          : in    std_logic_vector( 3 downto 0);
       G_IN          : in    std_logic_vector( 3 downto 0);
       B_IN          : in    std_logic_vector( 3 downto 0);

       HSYNC_IN      : in    std_logic;
       VSYNC_IN      : in    std_logic;

       R_OUT         : out   std_logic_vector( 3 downto 0);
       G_OUT         : out   std_logic_vector( 3 downto 0);
       B_OUT         : out   std_logic_vector( 3 downto 0);

       HSYNC_OUT     : out   std_logic;
       VSYNC_OUT     : out   std_logic;

       CLK_HALF_ENA  : in    std_logic; -- Enable signal @ 1/2 system clk rate 
       CLK_FAST      : in    std_logic  -- A2600 System clock (7.16)
    );
    end component;

    -- The "EdKit" component...
    component a2600_edkit
    port
    (
    
       -- Clock (we'll generate Power On reset locally)
       -- All other required clocks are derived from this clock.
       clk           : in std_logic;
    
       -- synthesis translate_off
       ref_newline   : out std_logic; -- Used by testbench..assists in debugging
       -- synthesis translate_on
    
       -- This port allows the Microblaze to talk with the onboard
       -- BlockRAM...allows us to load games from host PC.
       bram_wp_addr  : in std_logic_vector(11 downto 0); -- 8KB at first.
       bram_wp_wdata : in std_logic_vector( 7 downto 0);
       bram_wp_wena  : in std_logic;
       bram_wp_rdata : out std_logic_vector(7 downto 0);
       bram_wp_clk   : in std_logic;                     -- Clock for write port
    
       -- Output clocks...
       mb_clk        : out std_logic;                    -- Used to clock Microblaze.

       -- USeful for debugging
       a26_system_clock : out std_logic;
       a26_system_reset : out std_logic;
    
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
       -- Video Output.
       red           : out   std_logic_vector(3 downto 0);   -- 4 bit red value
       grn           : out   std_logic_vector(3 downto 0);   -- 4 bit green value
       blu           : out   std_logic_vector(3 downto 0);   -- 4 bit blue value
       vs_n          : out   std_logic;                      -- Vertical sync
       hs_n          : out   std_logic;                      -- Horizontal sync
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Audio Output (mono since I had to remove one pin)
       audio         : out   std_logic
       -------------------------------------------------------
    
    
    );
    end component;

    -- Guess what this is....
    component a2600_dac
    port (
    
        clk     : in  std_logic;
        reset   : in  std_logic;
        sample  : in  std_logic_vector(8 downto 0);
        l       : out std_logic;
        r       : out std_logic
    
    );
    end component;

    -- Xilinx DCM model...
    component xilinx_dcm is
    port ( CLKIN_IN        : in    std_logic; 
           RST_IN          : in    std_logic; 
           CLKFX_OUT       : out   std_logic; 
           CLKIN_IBUFG_OUT : out   std_logic; 
           LOCKED_OUT      : out   std_logic);
    end component;

    -- Xilinx 4Kx8 blockRAM
    component xil_rom_4kx8 IS
    port (
	addra : IN  std_logic_VECTOR(11 downto 0);
	addrb : IN  std_logic_VECTOR(11 downto 0);
	clka  : IN  std_logic;
	clkb  : IN  std_logic;
	dinb  : IN  std_logic_VECTOR(7 downto 0);
	douta : OUT std_logic_VECTOR(7 downto 0);
	doutb : OUT std_logic_VECTOR(7 downto 0);
	web   : IN  std_logic
    );
    end component;

    component xil_rom IS
    	port (
    	addr: IN std_logic_VECTOR(11 downto 0);
    	clk: IN std_logic;
    	dout: OUT std_logic_VECTOR(7 downto 0));
    END component; 

end a2600_pkg;
