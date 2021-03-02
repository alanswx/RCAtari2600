-------------------------------------------------------------------------------------
--
-- Filename :   a26_cconv_tif.vhd
--
-- Author   :   Ed Henciak 
--
-- Date     :   2-1-2005
--
-- Purpose  :   Maps Atari 2600 Chroma and Luma values to 24-bit RGB
--
-- Notes    :   Another rip-off of all the hard work Eric Crabill put into
--              his colorspace converter for his Verilog Atari 2600....these
--              colors may not be 100% accurate.
--
--              This file is free for anyone to use.  However, the author
--              or anyone else mentioned in this file is not to blame if 
--              anything goes wrong.  This means YOU!
--
-------------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;

entity a26_cconv_tif is
port
(

   col : in  std_logic_vector(3 downto 0);
   lum : in  std_logic_vector(2 downto 0);
 
   red : out std_logic_vector(7 downto 0);
   grn : out std_logic_vector(7 downto 0);
   blu : out std_logic_vector(7 downto 0) 

);
end a26_cconv_tif;

architecture convert of a26_cconv_tif is
   signal rgb_vec : std_logic_vector(23 downto 0);
begin

   cconv : process(col, lum)
      variable ccat_vals : std_logic_vector(6 downto 0);
   begin

      -- Concatenate the chroma and luma values...
      ccat_vals := col & lum;

      -- Decode 'Em 
      case ccat_vals is

         when "0000000" => rgb_vec <= x"000000";
         when "0000001" => rgb_vec <= x"4a4a4a";
         when "0000010" => rgb_vec <= x"6f6f6f";
         when "0000011" => rgb_vec <= x"8e8e8e";
         when "0000100" => rgb_vec <= x"aaaaaa";
         when "0000101" => rgb_vec <= x"c0c0c0";
         when "0000110" => rgb_vec <= x"d6d6d6";
         when "0000111" => rgb_vec <= x"ececec";

         when "0001000" => rgb_vec <= x"484800";
         when "0001001" => rgb_vec <= x"69690f";
         when "0001010" => rgb_vec <= x"86861d";
         when "0001011" => rgb_vec <= x"a2a22a";
         when "0001100" => rgb_vec <= x"bbbb35";
         when "0001101" => rgb_vec <= x"d2d240";
         when "0001110" => rgb_vec <= x"e8e84a";
         when "0001111" => rgb_vec <= x"fcfc54";

         when "0010000" => rgb_vec <= x"7c2c00";
         when "0010001" => rgb_vec <= x"904811";
         when "0010010" => rgb_vec <= x"a26221";
         when "0010011" => rgb_vec <= x"b47a30";
         when "0010100" => rgb_vec <= x"c3903d";
         when "0010101" => rgb_vec <= x"d2a44a";
         when "0010110" => rgb_vec <= x"dfb755";
         when "0010111" => rgb_vec <= x"ecc860";

         when "0011000" => rgb_vec <= x"901c00";
         when "0011001" => rgb_vec <= x"a33915";
         when "0011010" => rgb_vec <= x"b55328";
         when "0011011" => rgb_vec <= x"c66c3a";
         when "0011100" => rgb_vec <= x"d5824a";
         when "0011101" => rgb_vec <= x"e39759";
         when "0011110" => rgb_vec <= x"f0aa67";
         when "0011111" => rgb_vec <= x"fcbc74";

         when "0100000" => rgb_vec <= x"940000";
         when "0100001" => rgb_vec <= x"a71a1a";
         when "0100010" => rgb_vec <= x"b83232";
         when "0100011" => rgb_vec <= x"c84848";
         when "0100100" => rgb_vec <= x"d65c5c";
         when "0100101" => rgb_vec <= x"e46f6f";
         when "0100110" => rgb_vec <= x"f08080";
         when "0100111" => rgb_vec <= x"fc9090";

         when "0101000" => rgb_vec <= x"840064";
         when "0101001" => rgb_vec <= x"97197a";
         when "0101010" => rgb_vec <= x"a8308f";
         when "0101011" => rgb_vec <= x"b846a2";
         when "0101100" => rgb_vec <= x"c659b3";
         when "0101101" => rgb_vec <= x"d46cc3";
         when "0101110" => rgb_vec <= x"e07cd2";
         when "0101111" => rgb_vec <= x"ec8ce0";

         when "0110000" => rgb_vec <= x"500084";
         when "0110001" => rgb_vec <= x"68199a";
         when "0110010" => rgb_vec <= x"7d30ad";
         when "0110011" => rgb_vec <= x"9246c0";
         when "0110100" => rgb_vec <= x"a459d0";
         when "0110101" => rgb_vec <= x"b56ce0";
         when "0110110" => rgb_vec <= x"c57cee";
         when "0110111" => rgb_vec <= x"d48cfc";

         when "0111000" => rgb_vec <= x"140090";
         when "0111001" => rgb_vec <= x"331aa3";
         when "0111010" => rgb_vec <= x"4e32b5";
         when "0111011" => rgb_vec <= x"6848c6";
         when "0111100" => rgb_vec <= x"7f5cd5";
         when "0111101" => rgb_vec <= x"956fe3";
         when "0111110" => rgb_vec <= x"a980f0";
         when "0111111" => rgb_vec <= x"bc90fc";

         when "1000000" => rgb_vec <= x"000094";
         when "1000001" => rgb_vec <= x"181aa7";
         when "1000010" => rgb_vec <= x"2d32b8";
         when "1000011" => rgb_vec <= x"4248c8";
         when "1000100" => rgb_vec <= x"545cd6";
         when "1000101" => rgb_vec <= x"656fe4";
         when "1000110" => rgb_vec <= x"7580f0";
         when "1000111" => rgb_vec <= x"8490fc";

         when "1001000" => rgb_vec <= x"001c88";
         when "1001001" => rgb_vec <= x"183b9d";
         when "1001010" => rgb_vec <= x"2d57b0";
         when "1001011" => rgb_vec <= x"4272c2";
         when "1001100" => rgb_vec <= x"548ad2";
         when "1001101" => rgb_vec <= x"65a0e1";
         when "1001110" => rgb_vec <= x"75b5ef";
         when "1001111" => rgb_vec <= x"84c8fc";

         when "1010000" => rgb_vec <= x"003064";
         when "1010001" => rgb_vec <= x"185080";
         when "1010010" => rgb_vec <= x"2d6d98";
         when "1010011" => rgb_vec <= x"4288b0";
         when "1010100" => rgb_vec <= x"54a0c5";
         when "1010101" => rgb_vec <= x"65b7d9";
         when "1010110" => rgb_vec <= x"75cceb";
         when "1010111" => rgb_vec <= x"84e0fc";

         when "1011000" => rgb_vec <= x"004030";
         when "1011001" => rgb_vec <= x"18624e";
         when "1011010" => rgb_vec <= x"2d8169";
         when "1011011" => rgb_vec <= x"429e82";
         when "1011100" => rgb_vec <= x"54b899";
         when "1011101" => rgb_vec <= x"65d1ae";
         when "1011110" => rgb_vec <= x"75e7c2";
         when "1011111" => rgb_vec <= x"84fcd4";

         when "1100000" => rgb_vec <= x"004400";
         when "1100001" => rgb_vec <= x"1a661a";
         when "1100010" => rgb_vec <= x"328432";
         when "1100011" => rgb_vec <= x"48a048";
         when "1100100" => rgb_vec <= x"5cba5c";
         when "1100101" => rgb_vec <= x"6fd26f";
         when "1100110" => rgb_vec <= x"80e880";
         when "1100111" => rgb_vec <= x"90fc90";

         when "1101000" => rgb_vec <= x"143c00";
         when "1101001" => rgb_vec <= x"355f18";
         when "1101010" => rgb_vec <= x"527e2d";
         when "1101011" => rgb_vec <= x"6e9c42";
         when "1101100" => rgb_vec <= x"87b754";
         when "1101101" => rgb_vec <= x"9ed065";
         when "1101110" => rgb_vec <= x"b4e775";
         when "1101111" => rgb_vec <= x"c8fc84";
         when "1110000" => rgb_vec <= x"303800";
         when "1110001" => rgb_vec <= x"505916";
         when "1110010" => rgb_vec <= x"6d762b";
         when "1110011" => rgb_vec <= x"88923e";
         when "1110100" => rgb_vec <= x"a0ab4f";
         when "1110101" => rgb_vec <= x"b7c25f";
         when "1110110" => rgb_vec <= x"ccd86e";
         when "1110111" => rgb_vec <= x"e0ec7c";

         when "1111000" => rgb_vec <= x"482c00";
         when "1111001" => rgb_vec <= x"694d14";
         when "1111010" => rgb_vec <= x"866a26";
         when "1111011" => rgb_vec <= x"a28638";
         when "1111100" => rgb_vec <= x"bb9f47";
         when "1111101" => rgb_vec <= x"d2b656";
         when "1111110" => rgb_vec <= x"e8cc63";
         when "1111111" => rgb_vec <= x"fce070";

         when others    => rgb_vec <= x"000000";

    end case;

   end process;

   -- Concurrent simprini's for the silly justice of 
   -- fluffy hamsters and fishies we respect.
   red <= rgb_vec(23 downto 16) after 0.1 ns;
   grn <= rgb_vec(15 downto  8) after 0.1 ns;
   blu <= rgb_vec( 7 downto  0) after 0.1 ns;

end convert;


