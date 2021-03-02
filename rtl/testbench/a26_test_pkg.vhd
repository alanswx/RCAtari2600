-------------------------------------------------------------------------------
--
--   Copyright (C) 2004
--
--   Title     : a26_test_pkg
--
--   Desc.     : Package of useful components for testing the Atari 2600
--
--   Author    : Ed Henciak 
--
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;

package a26_test_pkg is

    -- Silly clock driver.
    component clk_sim is
    generic(
        CLK_PERIOD  : time := 12 ns;
        CLK_INITVAL : std_logic := '0'
    );
    port(
        clk : out std_logic
    
    );
    end component;
    
    -- Silly TIFF file generator
    component tiff_gen
    generic(
         X_DIM : integer := 640;
         Y_DIM : integer := 480
    );
    port
    (
    
        pixel_clk : in std_logic;
        enable    : in std_logic;
        red       : in std_logic_vector(7 downto 0);
        green     : in std_logic_vector(7 downto 0);
        blue      : in std_logic_vector(7 downto 0);
        vsync     : in std_logic
    
    );
    end component;

    -- Silly component which maps Atari 2600 color to
    -- 24 bit TIFF color.
    component a26_cconv_tif
    port
    (

       col : in  std_logic_vector(3 downto 0);
       lum : in  std_logic_vector(2 downto 0);

       red : out std_logic_vector(7 downto 0);
       grn : out std_logic_vector(7 downto 0);
       blu : out std_logic_vector(7 downto 0)

    );
    end component;


end a26_test_pkg;
