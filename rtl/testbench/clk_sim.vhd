-------------------------------------------------------------------------------
--   
--   Copyright (C) 2004
--
--   Title     :  Simple clock generator for simulating things both big 
--                and small.
--
--   Author    :  Ed Henciak 
--
--   Date      :  I forget when I first made something like this....probably 
--                back in the mid 90s.  
--                
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity clk_sim is
generic(

    CLK_PERIOD  : time      := 25 ns;
    CLK_INITVAL : std_logic := '0'
);
port(
    clk     : out std_logic
);
end clk_sim;

architecture beh of clk_sim is

    signal clk_i : std_logic := CLK_INITVAL;

begin

    -- Generate the clock
    clk_i    <= not clk_i      after (CLK_PERIOD/2);

    -- Drive it out of the component
    clk      <= clk_i;

end beh;

