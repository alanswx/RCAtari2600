-------------------------------------------------------------------------------
--
--   Copyright (C) 2004
--
--   Title     :  Atari 2600 audio DAC....another design taken from
--                Eric Crabill's nice Verilog approach to Atari 2600ing in
--                programmable logic!  The optimal clock frequency for this
--                circuit is around 32MHz....50MHz should be fine and will
--                probably screw something up as I have no idea what the
--                hell this is doing yet.  I'm so drunk right now that I can
--                hardly see straight.
--
--   Author    :  Ed Henciak (monkey work ... Eric did all the hard work!)
--
-------------------------------------------------------------------------------


-- /***********************************************************************
-- 
--   File: dac.v
-- 
--   This is a synthesizable delta-sigma DAC, discussed in the Xilinx 
--   XAPP154 application note.  I have reformatted it to my liking.
--   The input is signed binary of width 9.  The output must be
--   filtered as discussed in the application note.  This has been
--   modified for the cx2600 design.
-- 
--   Copyright (c) 2004 Eric Crabill.  All rights reserved.  Eric Crabill
--   makes no warranties, and accepts no liability, with respect to this
--   design or its use, and any use thereof is solely at the risk of the
--   user.  This copyright notice must be retained as part of this text
--   at all times.
-- 
-- ***********************************************************************/

-- synthesis library a2600

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

entity a2600_dac is
port (

    clk     : in  std_logic;
    reset   : in  std_logic;
    sample  : in  std_logic_vector(8 downto 0);
    l       : out std_logic;
    r       : out std_logic

);
end a2600_dac;


architecture struct of a2600_dac is 

  signal UnsignedSample : std_logic_vector( 8 downto 0);
  signal DeltaAdder     : std_logic_vector(10 downto 0);
  signal SigmaAdder     : std_logic_vector(10 downto 0);
  signal DeltaB         : std_logic_vector(10 downto 0);
  signal Sigma          : std_logic_vector(10 downto 0);
  signal SigmaReg       : std_logic_vector(10 downto 0);

begin

  -- //******************************************************************//
  -- // Implement the delta-sigma converter.                             //
  -- //******************************************************************//

  -- Concurrent gargonzola smott...
  -- By the way, for Verilog experts out there, how the hell does {} imply
  -- concatenation?  I mean, really, couldn't you use something better...like &?
  -- (For those lacking a sense of humor and take HDL coding way too seriously,
  -- this is what we mere mortals call a joke...if that offends you, well, please
  -- find some comfort in the arms of a goat fish you phleb).

  UnsignedSample <= not(sample(8)) & sample(7 downto 0);
  DeltaB         <= (Sigma(10) & Sigma(10) & "000000000");
  SigmaAdder     <= DeltaAdder + Sigma;
  DeltaAdder     <= UnsignedSample + DeltaB;

  process(clk, reset)
  begin
    if (reset = '1') then
        SigmaReg <= "01000000000";
    elsif(clk'event and clk = '1') then
        SigmaReg <= SigmaAdder;
    end if;
  end process;

  Sigma <= SigmaReg;

  process(clk, reset)
  begin
    if (reset = '1') then
      l <= '0';
      r <= '0';
    elsif(clk'event and clk = '1') then
      l <= Sigma(10);
      r <= Sigma(10);
    end if;
  end process;

end struct;
