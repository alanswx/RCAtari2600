//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,

`ifdef USE_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

`ifdef USE_DDRAM
	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,
`endif

`ifdef USE_SDRAM
	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,
`endif

`ifdef DUAL_SDRAM
	//Secondary SDRAM
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER = 0;
wire speaker_r, speaker_l;
assign AUDIO_S = 0;
//assign AUDIO_L = { 2'b0,speaker_l,speaker_l,speaker_l,3'b0,8'b0};
//assign AUDIO_R = { 2'b0,speaker_r,speaker_r,speaker_r,3'b0,8'b0};
assign AUDIO_MIX = 0;

assign AUDIO_L = { 2'b0,snd0,2'b0,8'b0};
assign AUDIO_R = { 2'b0,snd1,2'b0,8'b0};
	 wire [3:0] snd0;
	 wire [3:0] snd1;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

wire [1:0] ar = status[9:8];

assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

`include "build_id.v" 
localparam CONF_STR = {
	"Atari2600;;",
	"FS1,A26;",
	"-;",
	"O89,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"-;",
	"O3,Difficulty P1,B,A;",
	"O4,Difficulty P2,B,A;",
	"-;",
	"R0,Reset and close OSD;",
	"J1,Fire 1,Stick Btn,Paddle Btn,Game Reset,Game Select,Pause,Fire 2,Switch B/W,P1 difficulty,P2 difficulty;",
	"jn,A,B,X|P,Start,Select,L,Y;",
	"jp,A,B,X|P,Start,Select,L,Y;",
	"V,v",`BUILD_DATE 
};

wire forced_scandoubler;
wire  [1:0] buttons;
wire [31:0] status;
wire [10:0] ps2_key;
	wire [15:0] joystick_0, joystick_1;
wire        ioctl_download;
wire [24:0] ioctl_addr;
wire [7:0]  ioctl_dout;
wire        ioctl_wr;
wire [7:0]  ioctl_index;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(),

	.conf_str(CONF_STR),
	.forced_scandoubler(forced_scandoubler),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wr(ioctl_wr),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wait(ioctl_wait),

	.buttons(buttons),
	.status(status),
	.status_menumask({status[5]}),
	.joystick_0(joystick_0),
	.joystick_1(joystick_1),

	.ps2_key(ps2_key)
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys,clk_a26,clk_vid;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_vid), // 56MHz
	.outclk_1(clk_sys), // 14.31MHz
	.outclk_2(clk_a26) // 7.19MHz
);

wire reset = RESET | status[0] | buttons[1] | ioctl_download;

//////////////////////////////////////////////////////////////////

wire [1:0] col = status[4:3];

wire HBlank;
wire HSync;
wire VBlank;
wire VSync;
wire blank_n;

wire [7:0] video;

wire [3:0] r,g,b;
wire [7:0] rr = {r ,r};
wire [7:0] gg = {g ,g};
wire [7:0] bb = {b ,b};




////////////////////////////  MEMORY  ///////////////////////////////////

wire [3:0] force_bs;
wire sc;

wire pclk_0;

logic [31:0] cart_size;
logic [7:0] cart_data;
wire [12:0] cart_addr;

detect2600 detect2600
(
	.clk(clk_sys),
	.addr(ioctl_addr[12:0]),
	.enable(ioctl_wr & ioctl_download),
	.data(ioctl_dout),
	.force_bs(force_bs),
	.sc(sc)
);


always_ff @(posedge clk_sys) begin
	if (ioctl_download && ioctl_wr)
		cart_size <= ioctl_addr  + 1'd1; // 32 bit 1
end

dpram_dc #(.widthad_a(13)) cart
(
	.address_a(cart_addr),
	.clock_a(clk_a26),
	.byteena_a(~ioctl_download),
	.q_a(cart_data),

	.address_b(ioctl_addr[12:0]),
	.clock_b(clk_sys),
	.data_b(ioctl_dout),
	.wren_b(ioctl_wr & ioctl_download),
	.byteena_b(1'b1)
);


	
	
cart2600 cart2600
(
	.reset(reset),
	.clk(clk_sys),
	.ph0_en(clk_a26),
	.cpu_d_out(rom_rdata),
	.cpu_d_in(rom_wdata),
	.cpu_a(rom_addr[12:0]),
	.sc(sc),
	.force_bs(force_bs),
	.rom_a(cart_addr),
	.rom_do(cart_data),
	.rom_size(cart_size)
);	


reg [3:0] ctl_l;
reg [3:0] ctl_r;
always @(posedge clk_sys) begin
	ctl_l <= ~{joystick_0[3:0]|joystick_1[3:0]};
	ctl_r <= ~{joystick_0[3:0]|joystick_1[3:0]};
end


wire [12:0] rom_addr;
wire [7:0]  rom_rdata;
wire [7:0]  rom_wdata;
/*

barnstorming barnstorming 
(
.addr(rom_addr[11:0]),
.clk(clk_a26),
.data(rom_rdata)
);
*/
wire pix_ref;

a2600_core a2600_core(
	.clk2x(clk_sys),
	.clk(clk_a26),
	.reset(reset),
	.ref_newline(),
	.pix_ref(pix_ref),
	.system_rst(),
	
	.ctl_l(ctl_l),
	.ctl_l_o(),
	.pad_l_0(),
	.pad_l_1(),
	.trig_l(~joystick_0[4]),
	
	.ctl_r(ctl_r),
	.ctl_r_o(),
	.pad_r_0(),
	.pad_r_1(),
	.trig_r(~joystick_0[4]),
	
	.rom_addr(rom_addr),
	.rom_rdata(rom_rdata),
	.rom_wdata(rom_wdata),

    .bw_col(1'b1),
    .diff_l(status[3]),
    .diff_r(status[4]),
    .gamesel(~joystick_0[8]),
    .start(~joystick_0[7]),

 	 .vid_lum(vid_lum),
	 .vid_col(vid_col),
	 
	 .vid_hsyn(HSync),
	 .vid_vsyn(VSync),
	 
	 .vid_vblank(VBlank),
	 .vid_hblank(HBlank),
	  
	 .aud_ch0(snd0),
	 .aud_ch1(snd1)
    
    );
	 
	 wire [3:0] vid_col;
	 wire [2:0] vid_lum;

    a2600_12bit_color a2600_12bit_color (
		.col(vid_col),
		.lum(vid_lum),
		
		.red(r),
		.grn(g),
		.blu(b)
    ); 

	 /*

a2600_mb_altium_2 a2600_mb_altium_2 
(
    // Input reference clock (14.31MHz)
    .clk(clk_sys),
    .a26_sysclk(clk_a26),
	 .a26_powon_rst(reset),

    //.pix_clk_ref(ce_pix),

	 .ctl_l(ctl_l),
	 .trig_l(joystick_0[4]),
	 .ctl_r(ctl_r),
	 .trig_r(joystick_1[4]),
	 

    .bw_col(1'b1),
    .diff_l(status[3]),
    .diff_r(status[4]),
    .gamesel(~joystick_0[8]),
    .start(~joystick_0[7]),

	 
	 .red(r),
	 .grn(g),
	 .blu(b),
	 .hsync(HSync),
	 .vsync(VSync),
	 .blank_n(blank_n),
	 .vid_vblank(VBlank),
	 .vid_hblank(HBlank),
	 

	 .speaker_r(speaker_r),
	 .speaker_l(speaker_l),

	 .aout0(snd0), 
    .aout1(snd1)

);
*/

reg ce_pix;
always @(posedge clk_sys) begin
	reg  div;
	div <= ~div;
	ce_pix <= !div;
end

assign CLK_VIDEO = clk_vid;
//assign CE_PIXEL = ce_pix;
assign CE_PIXEL = pix_ref;

assign VGA_DE = ~(HBlank | VBlank);
assign VGA_HS = ~HSync;
assign VGA_VS = ~VSync;
assign VGA_G  = gg;
assign VGA_R  = rr;
assign VGA_B  = bb;

reg  [26:0] act_cnt;
always @(posedge clk_sys) act_cnt <= act_cnt + 1'd1; 
assign LED_USER    = act_cnt[26]  ? act_cnt[25:18]  > act_cnt[7:0]  : act_cnt[25:18]  <= act_cnt[7:0];

endmodule
