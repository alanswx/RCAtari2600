-------------------------------------------------------------------------------
--
--   Copyright (C) 2007 Retrocircuits LLC.
--
--   Title     :  Circuit that decodes chroma/luma and overscans
--                video if necessary...
--
--   Author    :  Ed Henciak 
--
-------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

entity a26_video_decode is
port (

    clk         : in  std_logic;
    reset       : in  std_logic;
    freq_sel    : in  std_logic;
    pix_clk_ref : in  std_logic;
    chroma      : in  std_logic_vector(3 downto 0);
    luma        : in  std_logic_vector(2 downto 0);
    hsync_in    : in  std_logic;
    vsync_in    : in  std_logic;

    -- Video output signals
    red         : out std_logic_vector(3 downto 0);
    grn         : out std_logic_vector(3 downto 0);
    blu         : out std_logic_vector(3 downto 0);
    hsync_o     : out std_logic;
    vsync_o     : out std_logic

);
end a26_video_decode;


architecture struct of a26_video_decode is 

    -- Simple lookup table to convert chroma to luma
    component a2600_12bit_color
    port
    (
    
       col : in  std_logic_vector(3 downto 0);
       lum : in  std_logic_vector(2 downto 0);
     
       red : out std_logic_vector(3 downto 0);
       grn : out std_logic_vector(3 downto 0);
       blu : out std_logic_vector(3 downto 0) 
    
    );
    end component;
    
    -- Simple overscan circuit taken from the archives
    -- at www.fpgaarcade.com.  This uses a Xilinx memory primitive.
    component a2600_dblscan_xil
    port (
    
    	R_IN          : in    std_logic_vector( 3 downto 0);
    	G_IN          : in    std_logic_vector( 3 downto 0);
    	B_IN          : in    std_logic_vector( 3 downto 0);
    
    	HSYNC_IN      : in    std_logic;
    	VSYNC_IN      : in    std_logic;
    
    	R_OUT         : out   std_logic_vector( 3 downto 0);
    	G_OUT         : out   std_logic_vector( 3 downto 0);
    	B_OUT         : out   std_logic_vector( 3 downto 0);
    
    	HSYNC_OUT     : out   std_logic;
    	VSYNC_OUT     : out   std_logic;
    
    	CLK_HALF_ENA  : in    std_logic; -- Enable signal @ 1/2 system clk rate 
    	CLK_FAST      : in    std_logic  -- A2600 System clock (7.16)
    	);
    end component;
    
    -- Outputs of lookup table
    signal vid_red_i : std_logic_vector(3 downto 0);
    signal vid_grn_i : std_logic_vector(3 downto 0);
    signal vid_blu_i : std_logic_vector(3 downto 0);
    
    -- Registered color lookup outputs for 15Khz monitors.
    signal vid_red   : std_logic_vector(3 downto 0);
    signal vid_grn   : std_logic_vector(3 downto 0);
    signal vid_blu   : std_logic_vector(3 downto 0);
    
    -- Color outputs of frequency converter.
    signal red_30khz : std_logic_vector(3 downto 0);
    signal grn_30khz : std_logic_vector(3 downto 0);
    signal blu_30khz : std_logic_vector(3 downto 0);
    
    -- Sync outputs of frequency converter
    signal hs_30khz_i : std_logic;
    signal vs_i       : std_logic;

begin

    -----------------------------------------------------------------------
    -- The following circuit converts chroma/luma info and overscans it
    -- if one is driving a VGA monitor... 
    -----------------------------------------------------------------------

    -- Color table
    col_map_0 : a2600_12bit_color
    port map
    (
    
       col => chroma,
       lum => luma,
    
       red => vid_red_i,
       grn => vid_grn_i,
       blu => vid_blu_i
    
    );

    -- USE THIS IF DRIVING A VGA monitor that requires higher 
    -- frequencies
    dblscan_0 : a2600_dblscan_xil
    port map(

        R_IN          => vid_red_i,
        G_IN          => vid_grn_i,
        B_IN          => vid_blu_i,

        HSYNC_IN      => hsync_in,
        VSYNC_IN      => vsync_in,

        R_OUT         => red_30khz,
        G_OUT         => grn_30khz,
        B_OUT         => blu_30khz,

        HSYNC_OUT     => hs_30khz_i,
        VSYNC_OUT     => vs_i,

        CLK_HALF_ENA  => pix_clk_ref,
        CLK_FAST      => clk

    );

    -----------------------------------------------------------------------

    -- USE THE FOLLOWING IF YOU ARE DRIVING A MONITOR THAT
    -- SUPPORTS 15.7KHz hsync frequencies!!!
    -- Register the outputs of the color mapper...
    -- This is the additional clock needed for accurate
    -- driving of pixels...
    process(clk)
    begin

        if (clk'event and clk = '1') then

            if (pix_clk_ref = '1') then
                vid_red <= vid_red_i;
                vid_grn <= vid_grn_i;
                vid_blu <= vid_blu_i;
            end if;

        end if;

    end process;

    -- Drive out the selected video signals..
    red     <= red_30khz  when (freq_sel = '1') else vid_red;
    grn     <= grn_30khz  when (freq_sel = '1') else vid_grn;
    blu     <= blu_30khz  when (freq_sel = '1') else vid_blu;
    hsync_o <= hs_30khz_i when (freq_sel = '1') else hsync_in;
    vsync_o <= vs_i       when (freq_sel = '1') else vsync_in;

end struct;
