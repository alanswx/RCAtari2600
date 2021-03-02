-------------------------------------------------------------------------------------
--
-- Filename :   tiff_gen.vhd
--
-- Author   :   Ed Henciak 
--
-- Date     :   2-1-2005
--
-- Purpose  :   Generates TIFF file frames. Makes debugging video easier.
--
-- Notes    :   Based on Eric Crabill's TIFF generator (Verilog) available at 
--              www.fpga-games.com.  He did all the hard work WRT TIFF headers
--              and file formats!
--
--              This file is free to use for all.  However, no person mentioned
--              in this file is liable for any problems arising from the use of this 
--              file.  Use at your own risk!
--
-------------------------------------------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith.all;

library STD;
    use STD.textio.all;

entity tiff_gen is
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
end tiff_gen;

architecture create_frame of tiff_gen is

   -- Delay time constant for VSYNC (used for file maintenence...)
   constant DEL_TIME : time := 0.1 ns;

   -- VSYNC delayed
   signal vsync_del : std_logic;

   -- Decalre a binary file type...this will write a binary file!
   type bin_file    is file of character;
   file current_file : bin_file;

   -- Convert integer to string...
   function int2str (val : integer) return string is
       variable lin : line;
   begin
       write(lin,val);
       return (lin.all);
   end int2str;

   -- This procedure writes a byte to the TIFF file.
   procedure write_byte (      byte_val : in unsigned(7 downto 0);
                         FILE tiff_file : bin_file) is
        variable byte_val_char : character;
   begin

        -- Convert slv to character
        byte_val_char := character'val(conv_integer(byte_val));

        -- Write the character to the file
        write(tiff_file, byte_val_char);

   end procedure;
        
   -- This writes a TIFF file header.
   -- This was ripped from Eric Crabill's Verilog file
   -- and converted to a VHDL procedure.
   procedure write_tiff_header (FILE tiff_file : bin_file) is
      variable num_bytes     : integer;
      variable num_bytes_slv : unsigned(31 downto 0);
      variable x_dim_slv     : unsigned(15 downto 0);
      variable y_dim_slv     : unsigned(15 downto 0);
   begin

    -- calculate some additional info, the
    -- number of bytes in the image is going
    -- to be the number of pixels times 3
    -- for 24-bit pixel data.
    num_bytes := X_DIM * Y_DIM * 3;

    -- Convert a bunch of stuff to std_logic_vector
    -- for the byte_write procedure...
    x_dim_slv     := conv_unsigned(X_DIM, 16);
    y_dim_slv     := conv_unsigned(Y_DIM, 16);
    num_bytes_slv := conv_unsigned(num_bytes, 32);

    -- write the byte order in the header
    -- this indicates big endian, which
    -- means multi-byte fields are written
    -- with the highest order bytes first
    -- starting offset: 0x0000

    write_byte(x"4d", tiff_file);
    write_byte(x"4d", tiff_file);

    -- write the tiff file identifier
    -- starting offset: 0x0002

    write_byte(x"00", tiff_file);
    write_byte(x"2a", tiff_file);

    -- write a pointer to the first and only
    -- image file directory at 0x00000010,
    -- which must begin on a word boundary
    -- starting offset: 0x0004

    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"10", tiff_file);

    -- write out zeroes for padding up to the
    -- start of the image file directory
    -- starting offset: 0x0008

    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);

    -- start of the image file directory
    -- contains number of directory entries
    -- which are only the 12 required entries
    -- starting offset: 0x0010

    write_byte(x"00", tiff_file);
    write_byte(x"0c", tiff_file);

    -- entry one, image width
    -- starting offset: 0x0012

    write_byte(x"01", tiff_file); -- id
    write_byte(x"00", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 32-bit
    write_byte(x"04", tiff_file); -- type is 32-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for number of x-pixels
    write_byte(x"00", tiff_file); -- value for number of x-pixels
    write_byte(x_dim_slv(15 downto 8), tiff_file); -- value for number of x-pixels
    write_byte(x_dim_slv( 7 downto 0), tiff_file); -- value for number of x-pixels

    -- entry two, image length
    -- starting offset: 0x001e

    write_byte(x"01", tiff_file); -- id
    write_byte(x"01", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 32-bit
    write_byte(x"04", tiff_file); -- type is 32-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for number of y-pixels
    write_byte(x"00", tiff_file); -- value for number of y-pixels
    write_byte(y_dim_slv(15 downto 8), tiff_file); -- value for number of y-pixels
    write_byte(y_dim_slv( 7 downto 0), tiff_file); -- value for number of y-pixels

    -- entry three, bits per sample
    -- starting offset: 0x002a

    write_byte(x"01", tiff_file); -- id
    write_byte(x"02", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 16-bit
    write_byte(x"03", tiff_file); -- type is 16-bit
    write_byte(x"00", tiff_file); -- three values exist
    write_byte(x"00", tiff_file); -- three values exist
    write_byte(x"00", tiff_file); -- three values exist
    write_byte(x"03", tiff_file); -- three values exist
    write_byte(x"00", tiff_file); -- pointer to bps triple
    write_byte(x"00", tiff_file); -- pointer to bps triple
    write_byte(x"00", tiff_file); -- pointer to bps triple
    write_byte(x"b8", tiff_file); -- pointer to bps triple

    -- entry four, compression
    -- starting offset: 0x0036
    -- entry four, compression
    -- starting offset: 0x0036

    write_byte(x"01", tiff_file); -- id
    write_byte(x"03", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 16-bit
    write_byte(x"03", tiff_file); -- type is 16-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for non-compressed
    write_byte(x"01", tiff_file); -- value for non-compressed
    write_byte(x"00", tiff_file); -- zero padding
    write_byte(x"00", tiff_file); -- zero padding

    -- entry five, photometric interpretation
    -- starting offset: 0x0042

    write_byte(x"01", tiff_file); -- id
    write_byte(x"06", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 16-bit
    write_byte(x"03", tiff_file); -- type is 16-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for rgb
    write_byte(x"02", tiff_file); -- value for rgb
    write_byte(x"00", tiff_file); -- zero padding
    write_byte(x"00", tiff_file); -- zero padding

    -- entry six, strip offsets
    -- starting offset: 0x004e

    write_byte(x"01", tiff_file); -- id
    write_byte(x"11", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 32-bit
    write_byte(x"04", tiff_file); -- type is 32-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- pointer to image data
    write_byte(x"00", tiff_file); -- pointer to image data
    write_byte(x"00", tiff_file); -- pointer to image data
    write_byte(x"c0", tiff_file); -- pointer to image data

    -- entry seven, samples per pixel
    -- starting offset: 0x005a

    write_byte(x"01", tiff_file); -- id
    write_byte(x"15", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 16-bit
    write_byte(x"03", tiff_file); -- type is 16-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for three samples
    write_byte(x"03", tiff_file); -- value for three samples
    write_byte(x"00", tiff_file); -- zero padding
    write_byte(x"00", tiff_file); -- zero padding

    -- entry eight, rows per strip
    -- starting offset: 0x0066

    write_byte(x"01", tiff_file); -- id
    write_byte(x"16", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 32-bit
    write_byte(x"04", tiff_file); -- type is 32-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for rows per strip
    write_byte(x"00", tiff_file); -- value for rows per strip
    write_byte(y_dim_slv(15 downto 8), tiff_file); -- value for rows per strip
    write_byte(y_dim_slv( 7 downto 0), tiff_file); -- value for rows per strip

    -- entry nine, strip byte counts
    -- starting offset: 0x0072

    write_byte(x"01", tiff_file); -- id
    write_byte(x"17", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 32-bit
    write_byte(x"04", tiff_file); -- type is 32-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(num_bytes_slv(31 downto 24), tiff_file); -- value for byte count
    write_byte(num_bytes_slv(23 downto 16), tiff_file); -- value for byte count
    write_byte(num_bytes_slv(15 downto  8), tiff_file); -- value for byte count
    write_byte(num_bytes_slv( 7 downto  0), tiff_file); -- value for byte count

    -- entry ten, x-resolution
    -- starting offset: 0x007e

    write_byte(x"01", tiff_file); -- id
    write_byte(x"1a", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is rational
    write_byte(x"05", tiff_file); -- type is rational
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- pointer to x-res rational
    write_byte(x"00", tiff_file); -- pointer to x-res rational
    write_byte(x"00", tiff_file); -- pointer to x-res rational
    write_byte(x"a8", tiff_file); -- pointer to x-res rational

    -- entry eleven, y-resolution
    -- starting offset: 0x008a

    write_byte(x"01", tiff_file); -- id
    write_byte(x"1b", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is rational
    write_byte(x"05", tiff_file); -- type is rational
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- pointer to y-res rational
    write_byte(x"00", tiff_file); -- pointer to y-res rational
    write_byte(x"00", tiff_file); -- pointer to y-res rational
    write_byte(x"b0", tiff_file); -- pointer to y-res rational

    -- entry twelve, resolution unit
    -- starting offset: 0x0096

    write_byte(x"01", tiff_file); -- id
    write_byte(x"28", tiff_file); -- id
    write_byte(x"00", tiff_file); -- type is 16-bit
    write_byte(x"03", tiff_file); -- type is 16-bit
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- one value exists
    write_byte(x"01", tiff_file); -- one value exists
    write_byte(x"00", tiff_file); -- value for inches
    write_byte(x"02", tiff_file); -- value for inches
    write_byte(x"00", tiff_file); -- zero padding
    write_byte(x"00", tiff_file); -- zero padding

    -- write a pointer to the next image file
    -- directory, which is zero, since there
    -- is no other image file directory...
    -- starting offset: 0x00a2

    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);

    -- write out zeroes for padding to restore
    -- alignment for 32-bit values coming up...
    -- starting offset: 0x00a6

    write_byte(x"00", tiff_file);
    write_byte(x"00", tiff_file);

    -- x-resolution data in rational format
    -- entry ten of the first ifd points to
    -- this value since it won't fit in ifd
    -- starting offset: 0x00a8

    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"4b", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"01", tiff_file); -- denominator 1 resunit

    -- y-resolution data in rational format
    -- entry eleven of the first ifd points to
    -- this value since it won't fit in ifd
    -- starting offset: 0x00b0

    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- numerator 75 pixels
    write_byte(x"4b", tiff_file); -- numerator 75 pixels
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"00", tiff_file); -- denominator 1 resunit
    write_byte(x"01", tiff_file); -- denominator 1 resunit

    -- bits per sample information stored as
    -- a triple of 16-bit values (padded with
    -- an extra value to restore alignment)
    -- starting offset: 0x00b8

    write_byte(x"00", tiff_file); -- eight bits per sample
    write_byte(x"08", tiff_file); -- eight bits per sample
    write_byte(x"00", tiff_file); -- eight bits per sample
    write_byte(x"08", tiff_file); -- eight bits per sample
    write_byte(x"00", tiff_file); -- eight bits per sample
    write_byte(x"08", tiff_file); -- eight bits per sample
    write_byte(x"00", tiff_file); -- eight bits per sample
    write_byte(x"08", tiff_file); -- eight bits per sample

end procedure;      

begin

   -- Delay vsync
   vsync_del <= vsync after DEL_TIME;

   file_gen : process(vsync_del, vsync, pixel_clk, enable)

      constant lstr         : string  := "./sim_files/tiff_frames/frame_";
      constant rstr         : string  := ".tif";
      variable frame_count  : integer := 0;
      variable file_opened  : boolean := FALSE;

   begin

      -- If we see a rising edge on vsync delayed, then open a file!
      if (vsync_del'event and vsync_del = '1') then
  
          -- Report frame number
          report("Creating TIFF frame #" & int2str(frame_count));

          -- Open the current file based on VSYNC firing
          file_open(current_file,(lstr & int2str(frame_count) & rstr), WRITE_MODE);

          -- Write the TIFF file header...
          write_tiff_header(current_file);

          -- Indicate that a file is opened so that pixel data can be
          -- blasted into the file!
          file_opened := TRUE;

      end if;

      -- If we see a VSYNC rising edge and we have a file opened...
      if (vsync'event and vsync = '1') then

          if (file_opened = TRUE) then

             -- Report frame number
             report("Done with TIFF frame #" & int2str(frame_count));

             -- Close the current file
             file_close(current_file);
 
             -- Indicate that the file is closed
             file_opened := FALSE;

             -- Advance the frame counter
             frame_count := frame_count + 1;

          end if;

      end if;

      -- Snag the RGB values as the pixel clock blasts them in!
      if (pixel_clk'event and pixel_clk = '1') then
 
          if (file_opened = TRUE) and (enable = '1') then 
  
             -- Write the RGB values
             write_byte(unsigned(red)  , current_file);
             write_byte(unsigned(green), current_file);
             write_byte(unsigned(blue) , current_file);

          end if;

      end if;

   end process;

end create_frame;
