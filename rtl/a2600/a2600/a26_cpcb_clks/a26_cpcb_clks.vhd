-------------------------------------------------------------------------------
--
--   Title     :  DCM Instantiations for the Altium version of the design
--
--   Author    :  Ed Henciak
--
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

library a2600;
    use a2600.all;

-- synthesis translate_off
library unisim;
-- synthesis translate_on

entity a26_cpcb_clks is
port (

    -- Input clock source...
    clk     : in  std_logic; -- 14.318 source

    -- Output clocks...
    clk_sys : out std_logic; -- Output of DCM 50MHz clock
    clk_a26 : out std_logic; -- Atari 2600 ref. clk (7.19MHz)

    -- Output resets...
    rst_mb  : out std_logic; -- Reset Microblaze
    por     : out std_logic  -- Power on reset

);
end a26_cpcb_clks;


architecture struct of a26_cpcb_clks is 

    signal gnd          : std_logic;
    signal clk_57_ref   : std_logic;
    signal a26_clk_i    : std_logic;
    signal a26_lock     : std_logic;
    signal poweron_rst  : std_logic := '1';
    signal rst_cnt      : std_logic_vector(7 downto 0) := x"00";

    -- The clock multiplier DCM...
    component a26_mult_dcm is
    port ( CLKIN_IN        : in    std_logic; 
           CLKFX_OUT       : out   std_logic; 
           LOCKED_OUT      : out   std_logic);
    end component;

    component a26_sys_dcm is
    port ( CLKIN_IN   : in    std_logic; 
           RST_IN     : in    std_logic; 
           CLKDV_OUT  : out   std_logic; 
           CLK0_OUT   : out   std_logic; 
           LOCKED_OUT : out   std_logic
    );
    end component;

begin

    -- Tie off ground.
    gnd <= '0';

    -- This DCM multiplies the 14.3181818MHz signal
    -- up to 57.27272MHz
    a26_mult4_dcm_0 : a26_mult_dcm
    port map( CLKIN_IN   => clk,
              CLKFX_OUT  => clk_57_ref,
              LOCKED_OUT => open
    );

    -- This DCM takes the multiplied clock from the above
    -- DCM and generates all the phase aligned system clocks.
    -- All in all, we distribute the 57MHz clock to the Microblaze
    -- and memory interface.  The 7.19MHz clock goes to the Atari
    -- component.
   a26_sys_dcm_0 : a26_sys_dcm
   port map( CLKIN_IN   => clk_57_ref,
             RST_IN     => gnd,
             CLKDV_OUT  => a26_clk_i,
             CLK0_OUT   => clk_sys,
             LOCKED_OUT => a26_lock
   );

    
    -- This process generates the power on reset signal for the 
    -- Atari 2600 core...
    process(a26_clk_i, a26_lock)
    begin

        if (a26_lock = '0') then

            rst_cnt     <= (others => '0');
            rst_mb      <= '1';
            poweron_rst <= '1';

        elsif(a26_clk_i'event and a26_clk_i = '1') then

            if (rst_cnt /= x"FF") then

                rst_cnt <= rst_cnt + 1;

                -- See if we can pull microblaze out of 
                -- reset
                if(rst_cnt = x"80") then
                   rst_mb <= '0';
                end if;

            else
                poweron_rst <= '0';
            end if;

        end if;

    end process;

    -- Concurrent signal assignments
    clk_a26 <= a26_clk_i;
    por     <= poweron_rst;
    
end struct;
