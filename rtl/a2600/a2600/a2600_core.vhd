------------------------------------------------------------------------------------------------
--
--   Copyright (C) 2005
--
--   Title     :  Atari 2600 System... VHDL Style ... Oh yeah!!!!
--
--   Author    :  Ed Henciak 
--
--   Date      :  February 19, 2005
--
--   Notes     :  This represents the guts of the Atari 2600...the system of
--                champions.  You young 'uns out there had better show some 
--                respect for this system as you decend through the hierarchy
--                that recreates this wonderful machine :) .  Nothing like it
--                will ever be designed or exploited again!
--
------------------------------------------------------------------------------------------------
-- Very useful IEEE package
library IEEE;
    use IEEE.std_logic_1164.all;

library A2600;
    use A2600.riot_pkg.all;
    use A2600.tia_pkg.all;
    use A2600.T65_Pack.all;

-- Useful Atari 2600 core.
entity a2600_core is
port
(

    -- Clock and reset
    clk         : in std_logic;                       -- Use 2x the main osc clock
    clk2x         : in std_logic;                       -- Use 2x the main osc clock
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
	 ctl_l_o     : out std_logic_vector(3 downto 0);
    pad_l_0     : in    std_logic;                    -- Analog (paddle) 0 input (pin 5)
    pad_l_1     : in    std_logic;                    -- Analog (paddle) 1 input (pin 9)
    trig_l      : in    std_logic;                    -- Left trigger input      (pin 6)

    -- Right Controller Port
    ctl_r       : in  std_logic_vector(3 downto 0); -- Joystick / Keypad input (pins 1 to 4)
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
end a2600_core;

architecture struct of a2600_core is

    ------------------------------
    -- CPU related interconnect --
    ------------------------------

    -- CPU clocks (reference)
    signal cpu_p0         : std_logic; 
    signal cpu_clk        : std_logic; 
    signal cpu_p0_ref     : std_logic;
    signal cpu_p0_ref_180 : std_logic;

    -- Read/write
    signal cpu_rwn    : std_logic;

    -- Address
    signal cpu_addr   : std_logic_vector(12 downto 0);

    -- Data I/O
    signal cpu_wdata  : std_logic_vector(7 downto 0);
    signal cpu_rdata  : std_logic_vector(7 downto 0);

    -- CPU "Ready" signal
    signal cpu_rdy    : std_logic;

    -- CPU sync (indicates OPCODE is on DBUS)
    signal cpu_sync   : std_logic;

    ----------------------------------
    -- Controller port related I/O  --
    ----------------------------------

    -- Paddle / Trigger input to TIA
    signal ctl_in     : std_logic_vector(5 downto 0);

    -- PIA I/O (Joysticks, Keypads, Control switches, etc.)
    signal pia_port_a_in  : std_logic_vector(7 downto 0);
    signal pia_port_b_in  : std_logic_vector(7 downto 0);
    signal pia_port_a_out : std_logic_vector(7 downto 0);
    signal pia_port_b_out : std_logic_vector(7 downto 0);
    signal pia_port_a_ctl : std_logic_vector(7 downto 0);
    signal pia_port_b_ctl : std_logic_vector(7 downto 0);
    signal pia_port_a : std_logic_vector(7 downto 0);
    signal pia_port_b : std_logic_vector(7 downto 0);

    ----------------------------
    -- TIA and RIOT Read data --
    ----------------------------
    signal tia_dout   : std_logic_vector(7 downto 0);
    signal riot_dout  : std_logic_vector(7 downto 0);

    signal latched_rdata : std_logic_vector(7 downto 0);

    ------------------------------------------------
    -- Internal reset signal for the whole system --
    ------------------------------------------------
    signal system_rst_i : std_logic;

    -------------------------------
    -- Logic levels for tie-offs --
    -------------------------------
    signal vdd        : std_logic;
    signal gnd        : std_logic;

begin

    -- Tie off supplies
    gnd       <= '0';  -- Low level.
    vdd       <= '1';  -- High level.

    -- Paddle / Trigger inputs
    ctl_in(5) <= trig_r;
    ctl_in(4) <= trig_l;
    ctl_in(3) <= pad_r_0;
    ctl_in(2) <= pad_r_1;
    ctl_in(1) <= pad_l_1;
    ctl_in(0) <= pad_l_0;

    -- Joystick (etc.) inputs
    pia_port_a_in(7 downto 4) <= ctl_l;
    pia_port_a_in(3 downto 0) <= ctl_r;

    -- Drive port outputs (i.e. keypad)
    ctl_l_o <= pia_port_a(7 downto 4);
    ctl_r_o <= pia_port_a(3 downto 0);

    -- Console control inputs...these are always inputs on the Atari 2600
    pia_port_b_in(3) <= bw_col;
    pia_port_b_in(6) <= diff_l;
    pia_port_b_in(7) <= diff_r;
    pia_port_b_in(1) <= gamesel;
    pia_port_b_in(0) <= start;

    -- Route to PIA (RIOT) unused port B I/O
    pia_port_b_in(2) <= pia_port_b(2);
    pia_port_b_in(4) <= pia_port_b(4);
    pia_port_b_in(5) <= pia_port_b(5);

    -- RIOT Tristate buffer instantiation
    tri_buf : for i in 0 to 7 generate
       pia_port_a(i) <= pia_port_a_out(i) when (pia_port_a_ctl(i) = '1') else 'Z';
       pia_port_b(i) <= pia_port_b_out(i) when (pia_port_b_ctl(i) = '1') else 'Z';
    end generate;

    -- Fake "latch last read" value from the databus...
    process(clk)
    begin

        if (clk'event and clk = '1') then

            if (cpu_addr(12) = '1') then
                latched_rdata <= cpu_rdata;
            elsif(cpu_addr(7) = '1') then
                latched_rdata <= cpu_rdata;
            end if;

        end if;

    end process;

    -- Component address decoding (i.e. data mux).
    process(cpu_addr, rom_rdata, tia_dout, riot_dout)
    begin

        if (cpu_addr(12) = '1') then
            cpu_rdata <= rom_rdata;
        elsif (cpu_addr(7) = '0') then
            cpu_rdata <= tia_dout(7 downto 6) & latched_rdata(5 downto 0);
        else
            cpu_rdata <= riot_dout;
        end if;

    end process;

    -- Drive out ROM address
    rom_addr <= cpu_addr(12 downto 0);

    -- Processor
    --m6507_0 : A2600.T65_Pack.m6507
    m6507_0 : entity A2600.m6507
    port map(

       reset          => system_rst_i,
       clk            => clk,
       enable         => cpu_p0_ref_180,
       a              => cpu_addr,
       din            => cpu_rdata,
       dout           => cpu_wdata,
       sync           => cpu_sync,
       rdy            => cpu_rdy,
       rwn            => cpu_rwn

    );

    -- Only the CPU can write data to the 2600
    -- "ROM" port...
    rom_wdata <= cpu_wdata;

    -- RIOT (6532 PIA)
    -- riot_0 : A2600.riot_pkg.riot
    riot_0 : entity A2600.riot
    port map
    (
       clk            => clk,
       reset          => system_rst_i,
       go_clk         => cpu_p0_ref,
       go_clk_180     => cpu_p0_ref_180,
       port_a_in      => pia_port_a_in,
       port_b_in      => pia_port_b_in,
       port_a_out     => pia_port_a_out,
       port_b_out     => pia_port_b_out,
       port_a_ctl     => pia_port_a_ctl,
       port_b_ctl     => pia_port_b_ctl,
       addr           => cpu_addr(6 downto 0),
       din            => cpu_wdata,
       dout           => riot_dout,
       rwn            => cpu_rwn,
       ramsel_n       => cpu_addr(9),
       cs1            => cpu_addr(7),
       cs2n           => cpu_addr(12),
       irqn           => open

    );

    -- TIA top level...see notes on video output
    tia_0 : entity A2600.tia
    port map
    (

      -- clkena            => clk,
       clk            => clk,
       master_reset   => reset,
       pix_ref        => pix_ref,
       sys_rst        => system_rst_i,
       cpu_p0_ref     => cpu_p0_ref,
       cpu_p0_ref_180 => cpu_p0_ref_180,
       -- synthesis translate_off
       ref_newline    => ref_newline,
       -- synthesis translate_on
       cpu_p0         => cpu_p0,
       cpu_clk        => cpu_p0,
       cpu_cs0n       => cpu_addr(12),
       cpu_cs1        => vdd,
       cpu_cs2n       => gnd,
       cpu_cs3n       => cpu_addr(7),
       cpu_rwn        => cpu_rwn,
       cpu_addr       => cpu_addr(5 downto 0),
       cpu_din        => cpu_wdata,
       cpu_dout       => tia_dout,
       cpu_rdy        => cpu_rdy,
       ctl_in         => ctl_in,
       vid_csync      => vid_csyn,
       vid_hsync      => vid_hsyn,
       vid_vsync      => vid_vsyn,
       vid_lum        => vid_lum,      -- Requires a pix clk register!
       vid_color      => vid_col,      -- Requires a pix clk register!
       vid_cb         => vid_cb,
       vid_blank_n    => vid_blank_n,  -- Requires a pix clk register!
       vid_vblank     => vid_vblank,
       vid_hblank     => vid_hblank,

       aud_ch0        => aud_ch0,
       aud_ch1        => aud_ch1

    );

    -- Concurrent signal assignments (for outputs)
    system_rst <= system_rst_i;

end struct;
