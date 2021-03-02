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

library a26_test;
    use a26_test.a26_test_pkg.all;

entity a2600_mb_altium_2_tb is
end    a2600_mb_altium_2_tb;

architecture struct of a2600_mb_altium_2_tb is

    -- Signal declaration
    signal system_clk     : std_logic; -- The Atari 2600 system clock x2 (roughly 7MHz)
    signal primary_clk    : std_logic; -- The main clock input (50MHz in this case)
    signal sample_pix_clk : std_logic;

    -- Video outputs (all outputs)
    signal vid_vsyn       : std_logic;
    signal red            : std_logic_vector(2 downto 0);
    signal grn            : std_logic_vector(2 downto 0);
    signal blu            : std_logic_vector(2 downto 0);
    signal dbg_red        : std_logic_vector(7 downto 0);
    signal dbg_grn        : std_logic_vector(7 downto 0);
    signal dbg_blu        : std_logic_vector(7 downto 0);
    signal pix_clk        : std_logic;

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

    -- Supplies
    signal vdd            : std_logic;
    signal gnd            : std_logic;
    signal gnd_vec        : std_logic_vector(15 downto 0);

begin

    vdd <= '1';
    gnd <= '0';
    gnd_vec <= (others => '0');

    -- System X uses a 25.175MHz clock input
    sys_clk_0 : a26_test.a26_test_pkg.clk_sim
    generic map(
         --CLK_PERIOD   => 20.00 ns,
         CLK_PERIOD   => 69.84127 ns,
         CLK_INITVAL  => '0'
    ) 
    port map(
         clk      => primary_clk
    );


    process
    begin
  
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

    a2600_uut : entity a2600.a2600_mb_altium_2
    port map
    (
    
       -- Clock (we'll generate Power On reset locally)
       -- All other required clocks are derived from this clock.
       clk              => primary_clk,

       pix_clk_ref      => pix_clk,
    
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
       vsync            => vid_vsyn,
       hsync            => open,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Audio Output (mono since I had to remove one pin)
       speaker_r        => open,
       speaker_l        => open,
       -------------------------------------------------------

       -------------------------------------------------------
       -- UART pins
       -------------------------------------------------------
       uart_tx          => open,
       uart_rx          => gnd,
       uart_rts         => open,
       uart_cts         => gnd,
       
       -- LED pins for debugging
       leds             => open,
       
       -------------------------------------------------------
       -- Memory bus
       -------------------------------------------------------
       sram_addr        => open,
       sram_data        => open,
       sram_wen         => open,
       sram_cen         => open,
       sram_oen         => open,
       sram_ub          => open,
       sram_lb          => open 
    
    );

   -- Create 8-bit color values from the 4-bit color outputs
    dbg_red <= red & "00000";
    dbg_grn <= grn & "00000";
    dbg_blu <= blu & "00000";

   sample_pix_clk <= not(pix_clk);

   -- Generates TIFF files so one can actually see frame data
   -- and not have to view signals like one would in The Matrix.
   tiff_gen_0 : a26_test.a26_test_pkg.tiff_gen
   generic map(
        X_DIM => 228,
        Y_DIM => 525
   ) 
   port map
   (

       pixel_clk => sample_pix_clk,
       enable    => vdd,
       red       => dbg_red,
       green     => dbg_grn,
       blue      => dbg_blu,
       vsync     => vid_vsyn

   );


end struct;
