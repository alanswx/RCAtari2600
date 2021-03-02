-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    fpga_0_RS232_req_to_send_pin : out std_logic;
    fpga_0_RS232_RX_pin : in std_logic;
    fpga_0_RS232_TX_pin : out std_logic;
    fpga_0_Generic_GPIO_GPIO_d_out_pin : out std_logic_vector(0 to 31);
    fpga_0_Generic_GPIO_GPIO_in_pin : in std_logic_vector(0 to 31);
    fpga_0_Generic_GPIO_GPIO_t_out_pin : out std_logic_vector(0 to 31);
    fpga_0_Generic_GPIO_GPIO_IO_pin : inout std_logic_vector(0 to 31);
    fpga_0_Mem_A_pin : out std_logic_vector(0 to 31);
    fpga_0_Mem_BEN_pin : out std_logic_vector(0 to 1);
    fpga_0_Mem_WEN_pin : out std_logic;
    fpga_0_Mem_OEN_pin : out std_logic_vector(0 to 0);
    fpga_0_Mem_CEN_pin : out std_logic_vector(0 to 0);
    sys_clk_pin : in std_logic;
    sys_rst_pin : in std_logic;
    fpga_0_Mem_DQ_I_pin : in std_logic_vector(0 to 15);
    fpga_0_Mem_DQ_O_pin : out std_logic_vector(0 to 15);
    fpga_0_Mem_DQ_T_pin : out std_logic_vector(0 to 15)
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      fpga_0_RS232_req_to_send_pin : out std_logic;
      fpga_0_RS232_RX_pin : in std_logic;
      fpga_0_RS232_TX_pin : out std_logic;
      fpga_0_Generic_GPIO_GPIO_d_out_pin : out std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_in_pin : in std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_t_out_pin : out std_logic_vector(0 to 31);
      fpga_0_Mem_A_pin : out std_logic_vector(0 to 31);
      fpga_0_Mem_BEN_pin : out std_logic_vector(0 to 1);
      fpga_0_Mem_WEN_pin : out std_logic;
      fpga_0_Mem_OEN_pin : out std_logic_vector(0 to 0);
      fpga_0_Mem_CEN_pin : out std_logic_vector(0 to 0);
      sys_clk_pin : in std_logic;
      sys_rst_pin : in std_logic;
      fpga_0_Mem_DQ_I_pin : in std_logic_vector(0 to 15);
      fpga_0_Mem_DQ_O_pin : out std_logic_vector(0 to 15);
      fpga_0_Mem_DQ_T_pin : out std_logic_vector(0 to 15);
      fpga_0_Generic_GPIO_GPIO_IO_pin_I : in std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_IO_pin_O : out std_logic_vector(0 to 31);
      fpga_0_Generic_GPIO_GPIO_IO_pin_T : out std_logic_vector(0 to 31)
    );
  end component;

  component OBUF is
    port (
      I : in std_logic;
      O : out std_logic
    );
  end component;

  component IBUF is
    port (
      I : in std_logic;
      O : out std_logic
    );
  end component;

  component IOBUF is
    port (
      I : in std_logic;
      IO : inout std_logic;
      O : out std_logic;
      T : in std_logic
    );
  end component;

  component IBUFG is
    port (
      I : in std_logic;
      O : out std_logic
    );
  end component;

  -- Internal signals

  signal fpga_0_Generic_GPIO_GPIO_IO_pin_I : std_logic_vector(0 to 31);
  signal fpga_0_Generic_GPIO_GPIO_IO_pin_O : std_logic_vector(0 to 31);
  signal fpga_0_Generic_GPIO_GPIO_IO_pin_T : std_logic_vector(0 to 31);
  signal fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF : std_logic_vector(0 to 31);
  signal fpga_0_Generic_GPIO_GPIO_in_pin_IBUF : std_logic_vector(0 to 31);
  signal fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF : std_logic_vector(0 to 31);
  signal fpga_0_Mem_A_pin_OBUF : std_logic_vector(0 to 31);
  signal fpga_0_Mem_BEN_pin_OBUF : std_logic_vector(0 to 1);
  signal fpga_0_Mem_CEN_pin_OBUF : std_logic_vector(0 to 0);
  signal fpga_0_Mem_DQ_I_pin_IBUF : std_logic_vector(0 to 15);
  signal fpga_0_Mem_DQ_O_pin_OBUF : std_logic_vector(0 to 15);
  signal fpga_0_Mem_DQ_T_pin_OBUF : std_logic_vector(0 to 15);
  signal fpga_0_Mem_OEN_pin_OBUF : std_logic_vector(0 to 0);
  signal fpga_0_Mem_WEN_pin_OBUF : std_logic;
  signal fpga_0_RS232_RX_pin_IBUF : std_logic;
  signal fpga_0_RS232_TX_pin_OBUF : std_logic;
  signal fpga_0_RS232_req_to_send_pin_OBUF : std_logic;
  signal sys_clk_pin_IBUFG : std_logic;
  signal sys_rst_pin_IBUF : std_logic;

begin

  system : system
    port map (
      fpga_0_RS232_req_to_send_pin => fpga_0_RS232_req_to_send_pin_OBUF,
      fpga_0_RS232_RX_pin => fpga_0_RS232_RX_pin_IBUF,
      fpga_0_RS232_TX_pin => fpga_0_RS232_TX_pin_OBUF,
      fpga_0_Generic_GPIO_GPIO_d_out_pin => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF,
      fpga_0_Generic_GPIO_GPIO_in_pin => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF,
      fpga_0_Generic_GPIO_GPIO_t_out_pin => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF,
      fpga_0_Mem_A_pin => fpga_0_Mem_A_pin_OBUF,
      fpga_0_Mem_BEN_pin => fpga_0_Mem_BEN_pin_OBUF,
      fpga_0_Mem_WEN_pin => fpga_0_Mem_WEN_pin_OBUF,
      fpga_0_Mem_OEN_pin => fpga_0_Mem_OEN_pin_OBUF(0 to 0),
      fpga_0_Mem_CEN_pin => fpga_0_Mem_CEN_pin_OBUF(0 to 0),
      sys_clk_pin => sys_clk_pin_IBUFG,
      sys_rst_pin => sys_rst_pin_IBUF,
      fpga_0_Mem_DQ_I_pin => fpga_0_Mem_DQ_I_pin_IBUF,
      fpga_0_Mem_DQ_O_pin => fpga_0_Mem_DQ_O_pin_OBUF,
      fpga_0_Mem_DQ_T_pin => fpga_0_Mem_DQ_T_pin_OBUF,
      fpga_0_Generic_GPIO_GPIO_IO_pin_I => fpga_0_Generic_GPIO_GPIO_IO_pin_I,
      fpga_0_Generic_GPIO_GPIO_IO_pin_O => fpga_0_Generic_GPIO_GPIO_IO_pin_O,
      fpga_0_Generic_GPIO_GPIO_IO_pin_T => fpga_0_Generic_GPIO_GPIO_IO_pin_T
    );

  obuf_0 : OBUF
    port map (
      I => fpga_0_RS232_req_to_send_pin_OBUF,
      O => fpga_0_RS232_req_to_send_pin
    );

  ibuf_1 : IBUF
    port map (
      I => fpga_0_RS232_RX_pin,
      O => fpga_0_RS232_RX_pin_IBUF
    );

  obuf_2 : OBUF
    port map (
      I => fpga_0_RS232_TX_pin_OBUF,
      O => fpga_0_RS232_TX_pin
    );

  obuf_3 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(0),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(0)
    );

  obuf_4 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(1),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(1)
    );

  obuf_5 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(2),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(2)
    );

  obuf_6 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(3),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(3)
    );

  obuf_7 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(4),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(4)
    );

  obuf_8 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(5),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(5)
    );

  obuf_9 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(6),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(6)
    );

  obuf_10 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(7),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(7)
    );

  obuf_11 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(8),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(8)
    );

  obuf_12 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(9),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(9)
    );

  obuf_13 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(10),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(10)
    );

  obuf_14 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(11),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(11)
    );

  obuf_15 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(12),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(12)
    );

  obuf_16 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(13),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(13)
    );

  obuf_17 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(14),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(14)
    );

  obuf_18 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(15),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(15)
    );

  obuf_19 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(16),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(16)
    );

  obuf_20 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(17),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(17)
    );

  obuf_21 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(18),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(18)
    );

  obuf_22 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(19),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(19)
    );

  obuf_23 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(20),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(20)
    );

  obuf_24 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(21),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(21)
    );

  obuf_25 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(22),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(22)
    );

  obuf_26 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(23),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(23)
    );

  obuf_27 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(24),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(24)
    );

  obuf_28 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(25),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(25)
    );

  obuf_29 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(26),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(26)
    );

  obuf_30 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(27),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(27)
    );

  obuf_31 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(28),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(28)
    );

  obuf_32 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(29),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(29)
    );

  obuf_33 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(30),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(30)
    );

  obuf_34 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_d_out_pin_OBUF(31),
      O => fpga_0_Generic_GPIO_GPIO_d_out_pin(31)
    );

  ibuf_35 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(0),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(0)
    );

  ibuf_36 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(1),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(1)
    );

  ibuf_37 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(2),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(2)
    );

  ibuf_38 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(3),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(3)
    );

  ibuf_39 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(4),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(4)
    );

  ibuf_40 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(5),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(5)
    );

  ibuf_41 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(6),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(6)
    );

  ibuf_42 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(7),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(7)
    );

  ibuf_43 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(8),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(8)
    );

  ibuf_44 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(9),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(9)
    );

  ibuf_45 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(10),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(10)
    );

  ibuf_46 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(11),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(11)
    );

  ibuf_47 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(12),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(12)
    );

  ibuf_48 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(13),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(13)
    );

  ibuf_49 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(14),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(14)
    );

  ibuf_50 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(15),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(15)
    );

  ibuf_51 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(16),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(16)
    );

  ibuf_52 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(17),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(17)
    );

  ibuf_53 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(18),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(18)
    );

  ibuf_54 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(19),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(19)
    );

  ibuf_55 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(20),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(20)
    );

  ibuf_56 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(21),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(21)
    );

  ibuf_57 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(22),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(22)
    );

  ibuf_58 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(23),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(23)
    );

  ibuf_59 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(24),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(24)
    );

  ibuf_60 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(25),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(25)
    );

  ibuf_61 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(26),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(26)
    );

  ibuf_62 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(27),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(27)
    );

  ibuf_63 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(28),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(28)
    );

  ibuf_64 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(29),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(29)
    );

  ibuf_65 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(30),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(30)
    );

  ibuf_66 : IBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_in_pin(31),
      O => fpga_0_Generic_GPIO_GPIO_in_pin_IBUF(31)
    );

  obuf_67 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(0),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(0)
    );

  obuf_68 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(1),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(1)
    );

  obuf_69 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(2),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(2)
    );

  obuf_70 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(3),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(3)
    );

  obuf_71 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(4),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(4)
    );

  obuf_72 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(5),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(5)
    );

  obuf_73 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(6),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(6)
    );

  obuf_74 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(7),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(7)
    );

  obuf_75 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(8),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(8)
    );

  obuf_76 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(9),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(9)
    );

  obuf_77 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(10),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(10)
    );

  obuf_78 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(11),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(11)
    );

  obuf_79 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(12),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(12)
    );

  obuf_80 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(13),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(13)
    );

  obuf_81 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(14),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(14)
    );

  obuf_82 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(15),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(15)
    );

  obuf_83 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(16),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(16)
    );

  obuf_84 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(17),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(17)
    );

  obuf_85 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(18),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(18)
    );

  obuf_86 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(19),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(19)
    );

  obuf_87 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(20),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(20)
    );

  obuf_88 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(21),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(21)
    );

  obuf_89 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(22),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(22)
    );

  obuf_90 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(23),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(23)
    );

  obuf_91 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(24),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(24)
    );

  obuf_92 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(25),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(25)
    );

  obuf_93 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(26),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(26)
    );

  obuf_94 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(27),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(27)
    );

  obuf_95 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(28),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(28)
    );

  obuf_96 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(29),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(29)
    );

  obuf_97 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(30),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(30)
    );

  obuf_98 : OBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_t_out_pin_OBUF(31),
      O => fpga_0_Generic_GPIO_GPIO_t_out_pin(31)
    );

  iobuf_99 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(0),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(0),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(0),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(0)
    );

  iobuf_100 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(1),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(1),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(1),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(1)
    );

  iobuf_101 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(2),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(2),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(2),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(2)
    );

  iobuf_102 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(3),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(3),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(3),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(3)
    );

  iobuf_103 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(4),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(4),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(4),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(4)
    );

  iobuf_104 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(5),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(5),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(5),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(5)
    );

  iobuf_105 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(6),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(6),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(6),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(6)
    );

  iobuf_106 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(7),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(7),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(7),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(7)
    );

  iobuf_107 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(8),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(8),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(8),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(8)
    );

  iobuf_108 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(9),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(9),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(9),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(9)
    );

  iobuf_109 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(10),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(10),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(10),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(10)
    );

  iobuf_110 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(11),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(11),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(11),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(11)
    );

  iobuf_111 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(12),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(12),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(12),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(12)
    );

  iobuf_112 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(13),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(13),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(13),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(13)
    );

  iobuf_113 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(14),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(14),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(14),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(14)
    );

  iobuf_114 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(15),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(15),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(15),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(15)
    );

  iobuf_115 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(16),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(16),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(16),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(16)
    );

  iobuf_116 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(17),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(17),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(17),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(17)
    );

  iobuf_117 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(18),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(18),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(18),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(18)
    );

  iobuf_118 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(19),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(19),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(19),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(19)
    );

  iobuf_119 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(20),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(20),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(20),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(20)
    );

  iobuf_120 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(21),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(21),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(21),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(21)
    );

  iobuf_121 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(22),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(22),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(22),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(22)
    );

  iobuf_122 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(23),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(23),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(23),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(23)
    );

  iobuf_123 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(24),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(24),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(24),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(24)
    );

  iobuf_124 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(25),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(25),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(25),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(25)
    );

  iobuf_125 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(26),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(26),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(26),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(26)
    );

  iobuf_126 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(27),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(27),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(27),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(27)
    );

  iobuf_127 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(28),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(28),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(28),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(28)
    );

  iobuf_128 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(29),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(29),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(29),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(29)
    );

  iobuf_129 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(30),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(30),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(30),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(30)
    );

  iobuf_130 : IOBUF
    port map (
      I => fpga_0_Generic_GPIO_GPIO_IO_pin_O(31),
      IO => fpga_0_Generic_GPIO_GPIO_IO_pin(31),
      O => fpga_0_Generic_GPIO_GPIO_IO_pin_I(31),
      T => fpga_0_Generic_GPIO_GPIO_IO_pin_T(31)
    );

  obuf_131 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(0),
      O => fpga_0_Mem_A_pin(0)
    );

  obuf_132 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(1),
      O => fpga_0_Mem_A_pin(1)
    );

  obuf_133 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(2),
      O => fpga_0_Mem_A_pin(2)
    );

  obuf_134 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(3),
      O => fpga_0_Mem_A_pin(3)
    );

  obuf_135 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(4),
      O => fpga_0_Mem_A_pin(4)
    );

  obuf_136 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(5),
      O => fpga_0_Mem_A_pin(5)
    );

  obuf_137 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(6),
      O => fpga_0_Mem_A_pin(6)
    );

  obuf_138 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(7),
      O => fpga_0_Mem_A_pin(7)
    );

  obuf_139 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(8),
      O => fpga_0_Mem_A_pin(8)
    );

  obuf_140 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(9),
      O => fpga_0_Mem_A_pin(9)
    );

  obuf_141 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(10),
      O => fpga_0_Mem_A_pin(10)
    );

  obuf_142 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(11),
      O => fpga_0_Mem_A_pin(11)
    );

  obuf_143 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(12),
      O => fpga_0_Mem_A_pin(12)
    );

  obuf_144 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(13),
      O => fpga_0_Mem_A_pin(13)
    );

  obuf_145 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(14),
      O => fpga_0_Mem_A_pin(14)
    );

  obuf_146 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(15),
      O => fpga_0_Mem_A_pin(15)
    );

  obuf_147 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(16),
      O => fpga_0_Mem_A_pin(16)
    );

  obuf_148 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(17),
      O => fpga_0_Mem_A_pin(17)
    );

  obuf_149 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(18),
      O => fpga_0_Mem_A_pin(18)
    );

  obuf_150 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(19),
      O => fpga_0_Mem_A_pin(19)
    );

  obuf_151 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(20),
      O => fpga_0_Mem_A_pin(20)
    );

  obuf_152 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(21),
      O => fpga_0_Mem_A_pin(21)
    );

  obuf_153 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(22),
      O => fpga_0_Mem_A_pin(22)
    );

  obuf_154 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(23),
      O => fpga_0_Mem_A_pin(23)
    );

  obuf_155 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(24),
      O => fpga_0_Mem_A_pin(24)
    );

  obuf_156 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(25),
      O => fpga_0_Mem_A_pin(25)
    );

  obuf_157 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(26),
      O => fpga_0_Mem_A_pin(26)
    );

  obuf_158 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(27),
      O => fpga_0_Mem_A_pin(27)
    );

  obuf_159 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(28),
      O => fpga_0_Mem_A_pin(28)
    );

  obuf_160 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(29),
      O => fpga_0_Mem_A_pin(29)
    );

  obuf_161 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(30),
      O => fpga_0_Mem_A_pin(30)
    );

  obuf_162 : OBUF
    port map (
      I => fpga_0_Mem_A_pin_OBUF(31),
      O => fpga_0_Mem_A_pin(31)
    );

  obuf_163 : OBUF
    port map (
      I => fpga_0_Mem_BEN_pin_OBUF(0),
      O => fpga_0_Mem_BEN_pin(0)
    );

  obuf_164 : OBUF
    port map (
      I => fpga_0_Mem_BEN_pin_OBUF(1),
      O => fpga_0_Mem_BEN_pin(1)
    );

  obuf_165 : OBUF
    port map (
      I => fpga_0_Mem_WEN_pin_OBUF,
      O => fpga_0_Mem_WEN_pin
    );

  obuf_166 : OBUF
    port map (
      I => fpga_0_Mem_OEN_pin_OBUF(0),
      O => fpga_0_Mem_OEN_pin(0)
    );

  obuf_167 : OBUF
    port map (
      I => fpga_0_Mem_CEN_pin_OBUF(0),
      O => fpga_0_Mem_CEN_pin(0)
    );

  ibufg_168 : IBUFG
    port map (
      I => sys_clk_pin,
      O => sys_clk_pin_IBUFG
    );

  ibuf_169 : IBUF
    port map (
      I => sys_rst_pin,
      O => sys_rst_pin_IBUF
    );

  ibuf_170 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(0),
      O => fpga_0_Mem_DQ_I_pin_IBUF(0)
    );

  ibuf_171 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(1),
      O => fpga_0_Mem_DQ_I_pin_IBUF(1)
    );

  ibuf_172 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(2),
      O => fpga_0_Mem_DQ_I_pin_IBUF(2)
    );

  ibuf_173 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(3),
      O => fpga_0_Mem_DQ_I_pin_IBUF(3)
    );

  ibuf_174 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(4),
      O => fpga_0_Mem_DQ_I_pin_IBUF(4)
    );

  ibuf_175 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(5),
      O => fpga_0_Mem_DQ_I_pin_IBUF(5)
    );

  ibuf_176 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(6),
      O => fpga_0_Mem_DQ_I_pin_IBUF(6)
    );

  ibuf_177 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(7),
      O => fpga_0_Mem_DQ_I_pin_IBUF(7)
    );

  ibuf_178 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(8),
      O => fpga_0_Mem_DQ_I_pin_IBUF(8)
    );

  ibuf_179 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(9),
      O => fpga_0_Mem_DQ_I_pin_IBUF(9)
    );

  ibuf_180 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(10),
      O => fpga_0_Mem_DQ_I_pin_IBUF(10)
    );

  ibuf_181 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(11),
      O => fpga_0_Mem_DQ_I_pin_IBUF(11)
    );

  ibuf_182 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(12),
      O => fpga_0_Mem_DQ_I_pin_IBUF(12)
    );

  ibuf_183 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(13),
      O => fpga_0_Mem_DQ_I_pin_IBUF(13)
    );

  ibuf_184 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(14),
      O => fpga_0_Mem_DQ_I_pin_IBUF(14)
    );

  ibuf_185 : IBUF
    port map (
      I => fpga_0_Mem_DQ_I_pin(15),
      O => fpga_0_Mem_DQ_I_pin_IBUF(15)
    );

  obuf_186 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(0),
      O => fpga_0_Mem_DQ_O_pin(0)
    );

  obuf_187 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(1),
      O => fpga_0_Mem_DQ_O_pin(1)
    );

  obuf_188 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(2),
      O => fpga_0_Mem_DQ_O_pin(2)
    );

  obuf_189 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(3),
      O => fpga_0_Mem_DQ_O_pin(3)
    );

  obuf_190 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(4),
      O => fpga_0_Mem_DQ_O_pin(4)
    );

  obuf_191 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(5),
      O => fpga_0_Mem_DQ_O_pin(5)
    );

  obuf_192 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(6),
      O => fpga_0_Mem_DQ_O_pin(6)
    );

  obuf_193 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(7),
      O => fpga_0_Mem_DQ_O_pin(7)
    );

  obuf_194 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(8),
      O => fpga_0_Mem_DQ_O_pin(8)
    );

  obuf_195 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(9),
      O => fpga_0_Mem_DQ_O_pin(9)
    );

  obuf_196 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(10),
      O => fpga_0_Mem_DQ_O_pin(10)
    );

  obuf_197 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(11),
      O => fpga_0_Mem_DQ_O_pin(11)
    );

  obuf_198 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(12),
      O => fpga_0_Mem_DQ_O_pin(12)
    );

  obuf_199 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(13),
      O => fpga_0_Mem_DQ_O_pin(13)
    );

  obuf_200 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(14),
      O => fpga_0_Mem_DQ_O_pin(14)
    );

  obuf_201 : OBUF
    port map (
      I => fpga_0_Mem_DQ_O_pin_OBUF(15),
      O => fpga_0_Mem_DQ_O_pin(15)
    );

  obuf_202 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(0),
      O => fpga_0_Mem_DQ_T_pin(0)
    );

  obuf_203 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(1),
      O => fpga_0_Mem_DQ_T_pin(1)
    );

  obuf_204 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(2),
      O => fpga_0_Mem_DQ_T_pin(2)
    );

  obuf_205 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(3),
      O => fpga_0_Mem_DQ_T_pin(3)
    );

  obuf_206 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(4),
      O => fpga_0_Mem_DQ_T_pin(4)
    );

  obuf_207 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(5),
      O => fpga_0_Mem_DQ_T_pin(5)
    );

  obuf_208 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(6),
      O => fpga_0_Mem_DQ_T_pin(6)
    );

  obuf_209 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(7),
      O => fpga_0_Mem_DQ_T_pin(7)
    );

  obuf_210 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(8),
      O => fpga_0_Mem_DQ_T_pin(8)
    );

  obuf_211 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(9),
      O => fpga_0_Mem_DQ_T_pin(9)
    );

  obuf_212 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(10),
      O => fpga_0_Mem_DQ_T_pin(10)
    );

  obuf_213 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(11),
      O => fpga_0_Mem_DQ_T_pin(11)
    );

  obuf_214 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(12),
      O => fpga_0_Mem_DQ_T_pin(12)
    );

  obuf_215 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(13),
      O => fpga_0_Mem_DQ_T_pin(13)
    );

  obuf_216 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(14),
      O => fpga_0_Mem_DQ_T_pin(14)
    );

  obuf_217 : OBUF
    port map (
      I => fpga_0_Mem_DQ_T_pin_OBUF(15),
      O => fpga_0_Mem_DQ_T_pin(15)
    );

end architecture STRUCTURE;

