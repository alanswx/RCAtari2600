
module vcart2600
(
	input clk,
	input reset,
	input pho0_en,
	
	output [7:0] cpu_d_out_p,
	input  [7:0] cpu_d_in,
	input [12:0] cpu_a,
	
	input sc,  // superchip enable
	input [3:0] force_bs, // force bank switch from detector
	
	output [15:0] rom_a,
	input  [7:0]  rom_do,
	input  [16:0] rom_size
);
/*

enum logic[3:0] 
 bss_type ;

constant BANK00: bss_type := "0000";
constant BANKF8: bss_type := "0001";
constant BANKF6: bss_type := "0010";
constant BANKFE: bss_type := "0011";
constant BANKE0: bss_type := "0100";
constant BANK3F: bss_type := "0101";
constant BANKF4: bss_type := "0110";
constant BANKP2: bss_type := "0111";
constant BANKFA: bss_type := "1000";
constant BANKCV: bss_type := "1001";
constant BANK2K: bss_type := "1010";
constant BANKUA: bss_type := "1011";
constant BANKE7: bss_type := "1100";
constant BANKF0: bss_type := "1101";
constant BANK32: bss_type := "1110";

*/

endmodule
