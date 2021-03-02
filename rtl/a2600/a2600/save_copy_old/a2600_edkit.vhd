--------------------------------------------------------------------------------------------------
--
--   Copyright (C) 2005
--
--   Title     :  Atari 2600 For Ed Henciak's "EdKit"
--
--   Author    :  Ed Henciak 
--
--   Date      :  January 6, 2007
--
--   Notes     :  Atari for my own pile of garbage kit.  Instantiates a Xilinx blockRAM
--                for games as well as a Xilinx DCM module + clock divider for generating
--                clocks required by this circuit.  Note that the DAC clock is running at
--                ~ 70MHZ...perfect for clocking a Microblaze at the higher level.
--                This is intended for use in a testbench as well since it is impossible to
--                simulate this and a Microblaze with the tools I have on hand.
--
--                Phase 1 : Simply use a 4KB blockRAM for game storage.
--                Phase 2 : Use 8KB blockRAM + 2KB RAM for various bankswitch schemes.
--                Phase 3 : Migrate to the "EdKit" Flash memory for game ROM and an
--                          embedded RAM for game RAM.
--                Phase 4 : Use external SRAM and flash ROM for game RAM....tricky seeing that
--                          Microblaze will need SRAM as well.
--                
--------------------------------------------------------------------------------------------------

-- Very useful IEEE package
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

library A2600;
    use A2600.a2600_pkg.all;

-- synopsys translate_off
library UNISIM;
    use UNISIM.Vcomponents.ALL;
-- synopsys translate_on

-- Useful Atari 2600 core.
entity a2600_edkit is
port
(

   -- Clock (we'll generate Power On reset locally)
   -- All other required clocks are derived from this clock.
   clk              : in  std_logic;

   -- synthesis translate_off
   ref_newline      : out std_logic; -- Used by testbench..assists in debugging
   -- synthesis translate_on

   -- This port allows the Microblaze to talk with the onboard
   -- BlockRAM...allows us to load games from host PC.
   bram_wp_addr     : in  std_logic_vector(11 downto 0); -- 4KB at first.
   bram_wp_wdata    : in  std_logic_vector( 7 downto 0);
   bram_wp_wena     : in  std_logic;
   bram_wp_rdata    : out std_logic_vector( 7 downto 0);
   bram_wp_clk      : in  std_logic;                     -- Clock for write port

   -- Output clocks...
   mb_clk           : out std_logic;                    -- Used to clock Microblaze.

   -- Useful for debugging
   a26_system_clock : out std_logic;  -- Used for verification
   a26_system_reset : out std_logic;  -- Atari reset status.

   -------------------------------------------------------
   -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
   bw_col           : inout std_logic;
   diff_l           : inout std_logic;
   diff_r           : inout std_logic;
   gamesel          : inout std_logic;
   start            : inout std_logic;
   -------------------------------------------------------

   -------------------------------------------------------
   -- Atari controller ports:
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
   -- Video Output.
   red              : out   std_logic_vector(3 downto 0);   -- 4 bit red value
   grn              : out   std_logic_vector(3 downto 0);   -- 4 bit green value
   blu              : out   std_logic_vector(3 downto 0);   -- 4 bit blue value
   vs_n             : out   std_logic;                      -- Vertical sync
   hs_n             : out   std_logic;                      -- Horizontal sync
   -------------------------------------------------------

   -------------------------------------------------------
   -- Audio Output (mono since I had to remove one pin)
   audio            : out   std_logic 
   -------------------------------------------------------


);
end a2600_edkit;

architecture struct of a2600_edkit is

    component BUFG
    port ( I : in    std_logic; 
           O : out   std_logic);
    end component;
   
    -- Tie off...
    signal gnd       : std_logic;

    -- Misc DCM related signals...
    signal clk_fast      : std_logic;
    signal dcm_lock      : std_logic;
    signal system_clk_pb : std_logic := '0';
    signal system_clk    : std_logic;
    signal poweron_rst   : std_logic := '1';
    signal rst_cnt       : std_logic_vector(15 downto 0) := x"0000";
    signal bram_rp_addr  : std_logic_vector(11 downto 0);
    signal bram_rp_rdata : std_logic_vector( 7 downto 0);
    signal clk_pb        : std_logic;
    signal clk_ref       : std_logic;
  


begin

    -- YOU NEED TO CHANGE THIS BACK SO THAT IT ACCEPTS A 14MHZ CLOCK FROM 
    -- AN 

    -- Tie off ground.
    gnd <= '0';

    -- Stupid DCM to drop 50MHz clock down to the 
    -- 28.9125 MHz on my "real" board
    dcm_in_0 : entity a2600.dcm_altium
    port map( CLKIN_IN        => clk,
              RST_IN          => gnd,
              CLKFX_OUT       => clk_ref,
              CLKIN_IBUFG_OUT => open,
              CLK0_OUT        => clk_fast,
              LOCKED_OUT      => open 
    );

    -- This Xilinx DCM primitive basically takes the input
    -- clock and multiplies it up to ~70MHz.  
    xil_dcm_0 : entity a2600.xil_dcm
    port map( CLKIN_IN        => clk_ref,
              RST_IN          => gnd,
              CLKDV_OUT       => clk_pb,
              CLKFX_OUT       => open,
              CLK0_OUT        => open,
              LOCKED_OUT      => dcm_lock
    );

    --xil_dcm_0 : xilinx_dcm 
    --port map( CLKIN_IN        => clk,
    --          RST_IN          => gnd,
    --          CLKFX_OUT       => clk_fast,
    --          CLKIN_IBUFG_OUT => open,
    --          LOCKED_OUT      => dcm_lock
    --);

    -- We subsequently divide the input clock by two to create the
    -- Atari 2600 main system clock.  "EdKit" has a 14.31MHz osc.
    -- Divide this by two and route it through a BUFG for our "real" 
    -- clock....do not forget to constrain this in the UCF.
    process(clk_pb)
    begin

        if(clk_pb'event and clk_pb = '1') then
            system_clk_pb <= not(system_clk_pb);
        end if;

    end process;

    -- Drive the resulting clock onto global clock resources
    bufg_1 : BUFG
    port map ( I => system_clk_pb,
               O => system_clk
    );

    -- Drive this out for other uses
    a26_system_clock <= system_clk;

    -- This process generates the power on reset signal for the 
    -- Atari 2600 core...
    process(system_clk)
    begin

        if(system_clk'event and system_clk = '1') then

            if (rst_cnt /= x"00FF") then
                rst_cnt <= rst_cnt + 1;
            else
                poweron_rst <= '0';
            end if;

        end if;

    end process;

    -- This is the Atari 2600 core with Xilinx primitives used for
    -- the RIOT RAM, Video doublescan to VGA, and other stuff...
    a2600_xilinx_0 : a2600_xilinx
    port map
    (
    
        -- Clocks and reset
        system_clk    => system_clk,
        dac_clk       => clk_fast,
        powon_reset   => poweron_rst,
        system_reset  => a26_system_reset,
    
        -- synthesis translate_off
        ref_newline   => ref_newline,
        -- synthesis translate_on
    
        -------------------------------------------------------
        -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
        bw_col        => bw_col,
        diff_l        => diff_l,
        diff_r        => diff_r,
        gamesel       => gamesel,
        start         => start,
        -------------------------------------------------------
    
        -------------------------------------------------------
        -- Atari controller ports:
        -------------------------------------------------------
        -- Left 
        -------------------------------------------------------
        ctl_l         => ctl_l ,
        pad_l_0       => pad_l_0,
        pad_l_1       => pad_l_1,
        trig_l        => trig_l,
        -------------------------------------------------------
        -- Right
        -------------------------------------------------------
        ctl_r         => ctl_r,
        pad_r_0       => pad_r_0,
        pad_r_1       => pad_r_1,
        trig_r        => trig_r,
        -------------------------------------------------------
    
        -------------------------------------------------------
        -- Interface to ROM...ROM wdata sounds silly, but keep
        -- in mind that the ROM port of the 2600 may get write
        -- data depending on the bankswitch scheme used!!!!
        rom_addr      => bram_rp_addr,
        rom_rdata     => bram_rp_rdata,
        rom_wdata     => open, -- For now...later we'll enable this
        -------------------------------------------------------
                                          
        -------------------------------------------------------
        -- Video Output.
        red           => red,
        grn           => grn,
        blu           => blu,
        vs_n          => vs_n,
        hs_n          => hs_n,
        -------------------------------------------------------
    
        -------------------------------------------------------
        -- Audio Output
        aud_l         => open, 
        aud_r         => audio
        -------------------------------------------------------
    
    );

    game_rom : entity a2600.xil_rom
    port map(
	addr => bram_rp_addr,
	clk  => system_clk,
	dout => bram_rp_rdata
    );
    
    -- This is simply an 4Kx8 Xilinx blockRAM for games...
    --game_rom : xil_rom_4kx8
    --port map (
    --    addra => bram_rp_addr,
    --    addrb => bram_wp_addr,
    --    clka  => system_clk,
    --    clkb  => clk_fast,
    --    dinb  => bram_wp_wdata,
    --    douta => bram_rp_rdata,
    --    doutb => bram_wp_rdata,
    --    web   => bram_wp_wena
    --);

 
    -- Concurrent signal assignments
    mb_clk <= clk_fast;

end struct;
