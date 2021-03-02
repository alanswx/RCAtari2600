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

entity a26_mb_altium_clks is
port (

    -- Input clock source...
    clk     : in  std_logic; -- 50MHz source

    -- Output clocks...
    clk_50  : out std_logic; -- Output of DCM 50MHz clock
    clk_a26 : out std_logic; -- Atari 2600 ref. clk (7.19MHz)

    -- Output resets...
    rst_mb  : out std_logic; -- Reset Microblaze
    por     : out std_logic  -- Power on reset

);
end a26_mb_altium_clks;


architecture struct of a26_mb_altium_clks is 

    signal gnd          : std_logic;
    signal clk_ref      : std_logic;
    signal clk_pb       : std_logic;
    signal a26_clk_pb   : std_logic;
    signal a26_clk_i    : std_logic;
    signal a26_lock     : std_logic;
    signal pri_dcm_lock : std_logic;
    signal poweron_rst  : std_logic := '1';
    signal rst_cnt      : std_logic_vector(7 downto 0) := x"00";

begin

    -- Tie off ground.
    gnd <= '0';

    -- Stupid DCM to drop 50MHz clock down to the 
    -- 28.9125 MHz on my "real" board
    dcm_in_0 : entity a2600.dcm_altium
    port map( CLKIN_IN        => clk,
              RST_IN          => gnd,
              CLKFX_OUT       => clk_ref,  -- Close to multiple of 3.58MHz.
              CLKIN_IBUFG_OUT => open,
              CLK0_OUT        => clk_50,
              LOCKED_OUT      => pri_dcm_lock 
    );

    rst_dcm_2 <= not(pri_dcm_lock);

    -- This Xilinx DCM primitive basically takes the input
    -- clock and multiplies it up to ~70MHz.  
    xil_dcm_0 : entity a2600.xil_dcm
    port map( CLKIN_IN        => clk_ref,
              RST_IN          => rst_dcm_2,
              CLKDV_OUT       => clk_pb,
              CLKFX_OUT       => open,
              CLK0_OUT        => open,
              LOCKED_OUT      => a26_lock
    );

    -- We subsequently divide the input clock by two to create the
    -- Atari 2600 main system clock.  "EdKit" has a 14.31MHz osc.
    -- Divide this by two and route it through a BUFG for our "real" 
    -- clock....do not forget to constrain this in the UCF.
    process(clk_pb)
    begin

        if(clk_pb'event and clk_pb = '1') then
            a26_clk_pb <= not(a26_clk_pb);
        end if;

    end process;

    -- Drive the resulting clock onto global clock resources
    bufg_1 : BUFG
    port map ( I => a26_clk_pb,
               O => a26_clk_i
    );

    -- This process generates the power on reset signal for the 
    -- Atari 2600 core...
    process(a26_clk_i, a26_lock)
    begin

        if (a26_lock = '0') then

            rst_cnt     <= (others => '0');
            poweron_rst <= '1';

        elsif(a26_clk_i'event and a26_clk_i = '1') then

            if (rst_cnt /= x"FF") then
                rst_cnt <= rst_cnt + 1;
            else
                poweron_rst <= '0';
            end if;

        end if;

    end process;

    -- Concurrent signal assignments
    a26_clk <= a26_clk_i;
    rst_mb  <= rst_dcm_2;
    por     <= poweron_rst;
    
end struct;
