-------------------------------------------------------------------------------
--
--   Copyright (C) 2004
--
--   Title     :  Atari 2600 Testbench.  This uses the "edkit" version of the
--                2600...
--
--   Author    :  Ed Henciak 
--
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;

library a2600;
    use a2600.a2600_pkg.all;

library a26_test;
    use a26_test.a26_test_pkg.all;

entity a2600_edkit_tb is
end    a2600_edkit_tb;

architecture struct of a2600_edkit_tb is

    -- Signal declaration
    signal system_clk     : std_logic; -- The Atari 2600 system clock x2 (roughly 7MHz)
    signal primary_clk    : std_logic; -- The main clock input (50MHz in this case)

    -- Video outputs (all outputs)
    signal vid_vsyn       : std_logic;
    signal vid_red        : std_logic_vector(3 downto 0);
    signal vid_grn        : std_logic_vector(3 downto 0);
    signal vid_blu        : std_logic_vector(3 downto 0);

    -- Left Controller Port
    signal ctl_l          : std_logic_vector(3 downto 0);
    signal pad_l_0        : std_logic;                   
    signal pad_l_1        : std_logic;                   
    signal trig_l         : std_logic;                   
    
    -- Right Controller Port
    signal ctl_r          : std_logic_vector(3 downto 0);
    signal pad_r_0        : std_logic;                   
    signal pad_r_1        : std_logic;                   
    signal trig_r         : std_logic;                   

    -- Console I/O
    signal bw_col         : std_logic;
    signal diff_l         : std_logic;
    signal diff_r         : std_logic;
    signal gamesel        : std_logic;
    signal start          : std_logic;

    -- Supplies
    signal vdd            : std_logic;
    signal gnd            : std_logic;
    signal gnd_vec        : std_logic_vector(15 downto 0);

    -- Debug Signals
    signal line_cnt       : integer;
    signal frame_cnt      : integer;
    signal cpu_cycle_cnt  : integer;
    signal first_cpu_sync : std_logic;
    signal ref_newline    : std_logic;
    signal red            : std_logic_vector(3 downto 0);
    signal grn            : std_logic_vector(3 downto 0);
    signal blu            : std_logic_vector(3 downto 0);
    signal dbg_red        : std_logic_vector(7 downto 0);
    signal dbg_grn        : std_logic_vector(7 downto 0);
    signal dbg_blu        : std_logic_vector(7 downto 0);
    signal pix_clk        : std_logic;
 
begin

    vdd <= '1';
    gnd <= '0';
    gnd_vec <= (others => '0');

    -- System X uses a 25.175MHz clock input
    sys_clk_0 : a26_test.a26_test_pkg.clk_sim
    generic map(
         CLK_PERIOD   => 20.00 ns,
         CLK_INITVAL  => '0'
    ) 
    port map(
         clk      => primary_clk
    );


    process
    begin
  
        bw_col      <= '1';             -- Color!
        diff_l      <= '0';             -- Select Novice
        diff_r      <= '0';             -- Select Novice
        gamesel     <= '1';             -- Do not select game
        start       <= '1';             -- Do not start game
        pad_l_0     <= '1';             -- Paddle Pot 0 Left
        pad_l_1     <= '1';             -- Paddle Pot 1 Left
        pad_r_0     <= '1';             -- Paddle Pot 0 Right
        pad_r_1     <= '1';             -- Paddle Pot 0 Right
        ctl_l       <= (others => '1'); -- Controller Left
        ctl_r       <= (others => '1'); -- Controller right
        trig_l      <= '1';             -- Trigger right
        trig_r      <= '1';             -- Trigger left
 
        wait for 10 ns;

        wait;

    end process;

    a2600_uut : a2600.a2600_pkg.a2600_edkit
    port map
    (
    
       -- Clock (we'll generate Power On reset locally)
       -- All other required clocks are derived from this clock.
       clk              => primary_clk,
    
       -- synthesis translate_off
       ref_newline      => ref_newline,
       -- synthesis translate_on
    
       -- This port allows the Microblaze to talk with the onboard
       -- BlockRAM...allows us to load games from host PC.
       bram_wp_addr     => gnd_vec(11 downto 0),
       bram_wp_wdata    => gnd_vec(7 downto 0),
       bram_wp_wena     => gnd,
       bram_wp_rdata    => open,
       bram_wp_clk      => gnd,
    
       -- Output clocks...
       mb_clk           => open,
    
       -- Output resets
       a26_system_reset => open,
       a26_system_clock => system_clk,
    
       -------------------------------------------------------
       -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
       bw_col           => bw_col,
       diff_l           => diff_l,
       diff_r           => diff_r,
       gamesel          => gamesel,
       start            => start,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Atari controller ports:
       -------------------------------------------------------
       -- Left 
       -------------------------------------------------------
       ctl_l            => ctl_l,    -- Joystick / Keypad input (pins 1 to 4)
       pad_l_0          => pad_l_0,  -- Analog (paddle) 0 input (pin 5)
       pad_l_1          => pad_l_1,  -- Analog (paddle) 1 input (pin 9)
       trig_l           => trig_l,   -- Left trigger input      (pin 6)
       -------------------------------------------------------
       -- Right
       ------------------------------------------------------- 
       ctl_r            => ctl_r,    -- Joystick / Keypad input (pins 1 to 4)
       pad_r_0          => pad_r_0,  -- Analog (paddle) 0 input (pin 5)
       pad_r_1          => pad_r_1,  -- Analog (paddle) 1 input (pin 9)
       trig_r           => trig_r,   -- Left trigger input      (pin 6)
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Video Output.
       red              => red,
       grn              => grn,
       blu              => blu,
       vs_n             => vid_vsyn,
       hs_n             => open,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Audio Output (mono since I had to remove one pin)
       audio            => open
       -------------------------------------------------------
    
    
    );

   -- Create 8-bit color values from the 4-bit color outputs
    dbg_red <= red & "0000";
    dbg_grn <= grn & "0000";
    dbg_blu <= blu & "0000";

   -- Create the pixel clock
   pix_clk <= system_clk;

   -- Generates TIFF files so one can actually see frame data
   -- and not have to view signals like one would in The Matrix.
   tiff_gen_0 : a26_test.a26_test_pkg.tiff_gen
   generic map(
        X_DIM => 228,
        Y_DIM => 525
   ) 
   port map
   (

       pixel_clk => pix_clk,
       enable    => vdd,
       red       => dbg_red,
       green     => dbg_grn,
       blue      => dbg_blu,
       vsync     => vid_vsyn

   );


end struct;
