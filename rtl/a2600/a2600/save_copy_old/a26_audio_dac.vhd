-------------------------------------------------------------------------------
--
--   Copyright (C) 2007 Retrocircuits LLC.
--
--   Title     :  Dual Channel audio DAC with mixer. Takes two 4 bit
--                inputs, mixes them, normalizes them, and shoves them into
--                a sigma delta DAC.
--
--   Author    :  Ed Henciak (based on work from Eric Crabill)
--
--   Notes     :  Audio output requires a low pass filter.
--
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

entity a26_audio_dac is
port (

    clk     : in  std_logic;
    reset   : in  std_logic;
    a_in_1  : in  std_logic_vector(3 downto 0);
    a_in_2  : in  std_logic_vector(3 downto 0);
    aout    : out std_logic

);
end a26_audio_dac;


architecture struct of a2600_dac is 

  signal audiosum       : std_logic_vector( 4 downto 0);
  signal pcm_data       : std_logic_vector( 8 downto 0);
  signal UnsignedSample : std_logic_vector( 8 downto 0);
  signal DeltaAdder     : std_logic_vector(10 downto 0);
  signal SigmaAdder     : std_logic_vector(10 downto 0);
  signal DeltaB         : std_logic_vector(10 downto 0);
  signal Sigma          : std_logic_vector(10 downto 0);
  signal SigmaReg       : std_logic_vector(10 downto 0);

begin


  -- This circuit mixes the two channels for the audio DAC input...
  --------------------------------------------------------------------
  -- THE FOLLOWING LOGIC MIXES THE AUDIO CIRCUIT AND DRIVES IT OFF  --
  -- CHIP AS A ONE BIT AUDIO VALUE (PWM).                           --
  --------------------------------------------------------------------

  -- Silly mixer that adjusts audio data (again, ripped off from
  -- Eric Crabill :)! )
  audiosum <= ('0' & a_in_1) + ('0' & a_in_2);

  -- // The pcm data sent to the dac needs
  -- // to be 9-bit, and signed.  What I do
  -- // here is multiply the audiosum by four
  -- // to get 9'b000000000 to 9'b001111000
  -- // and then negatively offset the value
  -- // by about half that range, trying to
  -- // recenter it about zero.
  process(clk, reset)
  begin 
    if (reset = '1') then
         pcm_data <= (others => '0');
    elsif(clk'event and clk = '1') then
         pcm_data <= ("00" & audiosum & "00") + "111000100";
    end if;
  end process;


  -- //******************************************************************//
  -- // Implement the delta-sigma converter.                             //
  -- //******************************************************************//
  UnsignedSample <= not(pcm_data(8)) & pcm_data(7 downto 0);
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
      aout <= '0';
    elsif(clk'event and clk = '1') then
      aout <= Sigma(10);
    end if;
  end process;

end struct;
