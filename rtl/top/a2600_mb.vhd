--
library ieee;
    use ieee.std_logic_1164.all;

library A2600;
    use A2600.a2600_pkg.all;

entity a2600_mb is
port(
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
	red               : out   std_logic_vector(3 downto 0);
	grn               : out   std_logic_vector(3 downto 0);
	blu               : out   std_logic_vector(3 downto 0);
	hsync             : out   std_logic;
	vsync             : out   std_logic;

        -------------------------------------------------------
        -- Audio outputs
        -------------------------------------------------------
        speaker           : out   std_logic;

        -------------------------------------------------------
        -- UART pins
        -------------------------------------------------------
	uart_tx           : out   std_logic;
	uart_rx           : in    std_logic;

        -------------------------------------------------------
        -- Memory bus
        -------------------------------------------------------
	addr_bus          : out   std_logic_vector(22 downto 0);
	data_bus          : inout std_logic_vector(15 downto 0);
	mem_wen           : out   std_logic;
	sram_cen          : out   std_logic;
	sram_oen          : out   std_logic;
	flash_cen         : out   std_logic;
	flash_oen         : out   std_logic;
	flash_sts         : in    std_logic;
	flash_rp_n        : out   std_logic 

);
end a2600_mb;

architecture rtl of a2600_mb is

    signal a26_bram_wp_addr   : std_logic_vector(11 downto 0);
    signal a26_bram_wp_wdata  : std_logic_vector( 7 downto 0);
    signal a26_bram_wp_wena   : std_logic;
    signal a26_bram_wp_rdata  : std_logic_vector( 7 downto 0);
    signal a26_bram_wp_clk    : std_logic;                   

    signal mb_gpio_color      : std_logic;
    signal mb_gpio_diff_l     : std_logic;
    signal mb_gpio_diff_r     : std_logic;
    signal mb_gpio_gamesel    : std_logic;
    signal mb_gpio_start      : std_logic;

    signal microblaze_clock   : std_logic;
    signal poweron_rst        : std_logic;
    signal a26_system_clk     : std_logic;


begin

    -- Tie these off for now
    mb_gpio_color      <= '1';
    mb_gpio_diff_l     <= '0';
    mb_gpio_diff_r     <= '0';
    mb_gpio_gamesel    <= '1';
    mb_gpio_start      <= '1';

    a26_bram_wp_addr   <= (others => '0');
    a26_bram_wp_wdata  <= (others => '0');
    a26_bram_wp_wena   <= '0';
    a26_bram_wp_clk    <= microblaze_clock;

    -- Useful Atari 2600 core.
    a2600_sys_0 : a2600_edkit
    port map
    (
    
       -- Clock (we'll generate Power On reset locally)
       -- All other required clocks are derived from this clock.
       clk              => clk,
    
       -- synthesis translate_off
       ref_newline      => open,
       -- synthesis translate_on
    
       -- This port allows the Microblaze to talk with the onboard
       -- BlockRAM...allows us to load games from host PC.
       bram_wp_addr     => a26_bram_wp_addr,  
       bram_wp_wdata    => a26_bram_wp_wdata, 
       bram_wp_wena     => a26_bram_wp_wena,  
       bram_wp_rdata    => a26_bram_wp_rdata, 
       bram_wp_clk      => a26_bram_wp_clk,   
    
       -- Output clocks...
       mb_clk           => microblaze_clock,
    
       -- Useful for debugging
       a26_system_clock => a26_system_clk,
       a26_system_reset => poweron_rst,
    
       -------------------------------------------------------
       -- Atari switchboard I/O (i.e. diff, sel, color, etc.)
       bw_col           => mb_gpio_color,
       diff_l           => mb_gpio_diff_l,
       diff_r           => mb_gpio_diff_r,
       gamesel          => mb_gpio_gamesel,
       start            => mb_gpio_start,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Atari controller ports:
       -------------------------------------------------------
       -- Left 
       -------------------------------------------------------
       ctl_l            => ctl_l,
       pad_l_0          => pad_l_0,
       pad_l_1          => pad_l_1,
       trig_l           => trig_l,
       -------------------------------------------------------
       -- Right
       -------------------------------------------------------
       ctl_r            => ctl_r,
       pad_r_0          => pad_r_0,
       pad_r_1          => pad_r_1,
       trig_r           => trig_r,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Video Output.
       red              => red,
       grn              => grn,
       blu              => blu,
       vs_n             => vsync,
       hs_n             => hsync,
       -------------------------------------------------------
    
       -------------------------------------------------------
       -- Audio Output (mono since I had to remove one pin)
       audio            => speaker
       -------------------------------------------------------
    
    
    );

        -------------------------------------------------------
        -- Tie off for now...
        -------------------------------------------------------
	uart_tx           <= '0';
	addr_bus          <= (others => '0');
	data_bus          <= (others => 'Z');
	mem_wen           <= '1';
	sram_cen          <= '1';
	sram_oen          <= '1';
	flash_cen         <= '1';
	flash_oen         <= '1';
	flash_rp_n        <= '1';
end;
