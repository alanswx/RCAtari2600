-------------------------------------------------------------------------------
--
--   Copyright (C) 2005
--
--   Title     :  6507 wrapper for the 6502 core
--
--   Author    :  Ed Henciak 
--
--   Date      :  December 19, 2004
--
--   Notes     :  Wraps the Opencores 6502 core so that it is
--                a 6507 for the Atari 2600.
--                
-------------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;

library A2600;
    use A2600.T65_pack.all;

entity m6507 is
port(

     -- Reset and clocks
     reset    : in   std_logic; -- Active high reset
     clk      : in   std_logic; -- Input clock
     enable   : in   std_logic; -- Restrictor
	
     -- Address and data bus
     a       : out   std_logic_vector(12 downto 0);
     din     : in    std_logic_vector( 7 downto 0);
     dout    : out   std_logic_vector( 7 downto 0);

     -- Sync Pulse (for debugging)
     sync    : out   std_logic;

     -- Control
     rdy     : in    std_logic;
     rwn     : out   std_logic

);
end m6507;


architecture struct of m6507 is

   signal vdd      : std_logic;
   signal reset_n  : std_logic;
   signal a_i      : std_logic_vector(23 downto 0);
   signal sim_sync : std_logic;

begin

-- Tie off to a logic level (for unused pins)
vdd <= '1';

-- Invert reset
reset_n <= not(reset);

-- Only drive out the address bits we need
a <= a_i(12 downto 0);

-- 6502 instantiation
u0 : T65
     port map(
         Mode     => "00",
         Res_n    => reset_n,
         Enable   => enable,
         Clk      => clk,
         Rdy      => rdy,
         Abort_n  => vdd,
         IRQ_n    => vdd,
         NMI_n    => vdd,
         SO_n     => vdd,
         R_W_n    => rwn,
         Sync     => sim_sync,
         EF       => open,
         MF       => open,
         XF       => open,
         ML_n     => open,
         VP_n     => open,
         VDA      => open,
         VPA      => open,
         A        => a_i,
         DI       => din,
         DO       => dout
     );

  sync <= sim_sync;

end;
