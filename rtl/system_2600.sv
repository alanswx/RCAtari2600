// Atari 2600 system glue module
// Jamie Dickson, 2019 - 2020

module system2600
(
	input  logic        clk,
	input  logic        clk2,
	input  logic        rst,
	input  logic  [7:0] di,
	input  logic  [7:0] pa,
	input  logic  [7:0] pb,
	input  logic  [7:0] paddle_0,
	input  logic  [7:0] paddle_1,
	input  logic  [7:0] paddle_2,
	input  logic  [7:0] paddle_3,
	input  logic        paddle_ena1,
	input  logic        paddle_ena2,
	input  logic        inpt4,
	input  logic        inpt5,
	input  logic        pal,
	output logic  [7:0] d_o,
	output logic [12:0] a,
	output logic        r,
	output logic        colu,
	output logic        vsyn,
	output logic        hsyn,
	output logic        hblank,
	output logic        vblank,
	output logic [23:0] rgbx2,
	output logic        au0,
	output logic        au1,
	output logic  [3:0] av0,
	output logic  [3:0] av1,
	output logic        ph0_out,
	output logic        ph2_out,
	output logic [15:0] audio_mono,

	// Debug
	input  logic        video_de,
	input  logic        audio_de,
	input  logic        clocks_de
);
logic [7:0] open_bus;
logic [7:0] bus_out;

wire  [7:0] riot_do;
wire  [7:0] tia_do;

wire  [7:0] cpu_do;
wire [12:0] cpu_addr;
wire        cpu_RW_n;
wire  [7:0] cpu_di;
wire        cpu_rdy;

wire phi0, phi2;

wire tia_cs =  ~cpu_addr[12] & ~cpu_addr[7];
wire riot_cs = ~cpu_addr[12] &  cpu_addr[7];
wire cart_cs =  cpu_addr[12];

always_comb begin
	cpu_di = open_bus;
	if (~cpu_RW_n)
		cpu_di = cpu_do;
	else if (tia_cs)
		cpu_di = {&cpu_addr[3:1] ? open_bus[7:6] : tia_do[7:6], open_bus[5:0]};
	else if (riot_cs)
		cpu_di = riot_do;
	else if (cart_cs)
		cpu_di = di;
end

always @(posedge clk2)
	if (rst)
		open_bus = 8'h00;
	else if (phi0)
		open_bus <= cpu_di;

assign r = cpu_RW_n;
assign d_o = cpu_do;
assign a = cpu_addr;
assign ph0_out = phi0;
assign ph2_out = phi2;

// The CPU would normally generate Phi2, however T65 is not phase accurate so
// we have to do this ourselves.

T65 CPU
(
	.Mode   (00),
	.Res_n  (~rst),
	.Clk    (clk2),       // System clock
	.Enable (phi0),      // FIXME: This should be Phi1 *NOT* Phi0 (which roughly aligns with Phi2)
	.A      (cpu_addr),
	.DI     (cpu_di),
	.DO     (cpu_do),
	.Rdy    (cpu_rdy),
	.IRQ_n  (1),
	.NMI_n  (1),
	.SO_n   (1),
	.Abort_n(1),
	.R_W_n  (cpu_RW_n)
);

// Atari 2600 port map
// PA: {Lpin4, Lpin3, Lpin2, Lpin1, Rpin4, Rpin3, Rpin2, Rpin1} - Controller ports (R, L, D, U is the pin order)
// PB7: Difficulty Right - 1 = A, 0 = B
// PB6: Difficulty Left  - 1 = A, 0 = B
// PB5: 0
// PB4: 0
// PB3: Color/BW         - 1 = Color, 0 = B&W
// PB2: 0
// PB1: Select           - 1 = Released, 0 = Pressed
// PB0: Start            - 1 = Released, 0 = Pressed


M6532 RIOT
(
	.clk    (clk2),
	.ce     (phi2),
	.res_n  (~rst),
	.addr   (cpu_addr[6:0]),
	.RW_n   (cpu_RW_n),
	.d_out  (riot_do),
	.d_in   (cpu_do),
	.RS_n   (cpu_addr[9]),
	.CS1    (cpu_addr[7]),
	.CS2_n  (cpu_addr[12]),
	.PA_in  (pa),
	.PA_out (),
	.PB_in  (pb),
	.PB_out ()
);

// TIA does the original clock division and generates phi0
// It is not supposed to generate, but rather recieve phi2 from the 6507

wire old_phi0, old_phi2, old_rdy;
wire old_vsync, old_hsync, old_vblank, old_hblank;
wire [3:0] old_aud0, old_aud1;
wire old_aud0_en, old_aud1_en;
wire [7:0] old_dout;
wire [23:0] old_rgbx2;

/*
TIA TIA
    (
		.clk(clk2),
		.master_reset(rst),
		.sys_rst(system_reset),
		.pixe_ref(pix_ref),
		.cpu_p0_ref(),
		.cpu_p0_ref_180(),
		.ref_newline(),
		.cpu_p0(),
		.cpu_clk(),
		.cpu_cs0n(),
		
			master_reset   => reset,
       pix_ref        => pix_ref,
       sys_rst        => system_rst_i,
       cpu_p0_ref     => cpu_p0_ref,
       cpu_p0_ref_180 => cpu_p0_ref_180,
       -- synthesis translate_off
       ref_newline    => ref_newline,
       -- synthesis translate_on
       cpu_p0         => cpu_p0,
       cpu_clk        => cpu_p0,
       cpu_cs0n       => cpu_addr(12),
       cpu_cs1        => vdd,
       cpu_cs2n       => gnd,
       cpu_cs3n       => cpu_addr(7),
       cpu_rwn        => cpu_rwn,
       cpu_addr       => cpu_addr(5 downto 0),
       cpu_din        => cpu_wdata,
       cpu_dout       => tia_dout,
       cpu_rdy        => cpu_rdy,
       ctl_in         => ctl_in,
       vid_csync      => vid_csyn,
       vid_hsync      => vid_hsyn,
       vid_vsync      => vid_vsyn,
       vid_lum        => vid_lum,      -- Requires a pix clk register!
       vid_color      => vid_col,      -- Requires a pix clk register!
       vid_cb         => vid_cb,
       vid_blank_n    => vid_blank_n,  -- Requires a pix clk register!
       vid_vblank     => vid_vblank,
       vid_hblank     => vid_hblank,

       aud_ch0        => aud_ch0,
       aud_ch1        => aud_ch1

    );

	 
	 
TIA TIA
(
	.clk         (clk), // 3.579575 MHZ
	.cs          (~cpu_addr[12] & ~cpu_addr[7]),
	.r           (cpu_RW_n),
	.a           (cpu_addr[5:0]),
	.di          (cpu_do),
	.d_o         (old_dout),
	.colu        (colu),
	.vsyn        (old_vsync),
	.hsyn        (old_hsync),
	.ohblank     (old_hblank),
	.ovblank     (old_vblank),
	.rgbx2       (old_rgbx2),
	.rdy         (old_rdy),
	.ph0         (old_phi0),
	.ph2         (old_phi2),
	.au0         (old_aud0_en),
	.au1         (old_aud1_en),
	.av0         (old_aud0),
	.av1         (old_aud1),
	.paddle_0    (paddle_0),
	.paddle_1    (paddle_1),
	.paddle_2    (paddle_2),
	.paddle_3    (paddle_3),
	.paddle_ena1 (paddle_ena1),
	.paddle_ena2 (paddle_ena2),
	.inpt4       (inpt4),
	.inpt5       (inpt5),
	.pal         (pal)
);
*/
wire phi2_gen;
wire [3:0] color;
wire [2:0] luma;
wire new_phi0, new_rdy;
wire new_vsync, new_hsync, new_vblank, new_hblank;
wire [3:0] new_aud0, new_aud1;
wire [7:0] new_dout;

TIA2 TIA2
(
	.clk      (clk2),
	.phi0     (), //out
	.phi2     (phi2_gen),
	.phi1     (new_phi0),
	.RW_n     (cpu_RW_n),
	.rdy      (new_rdy), //out
	.addr     (cpu_addr[5:0]),
	.d_in     (cpu_do),
	.d_out    (new_dout), //out
	.i        ({paddle_3, paddle_2, paddle_1, paddle_0}),
	.i4       (inpt4),
	.i5       (inpt5),
	.aud0     (new_aud0), //out
	.aud1     (new_aud1), //out
	.col      (color), //out
	.lum      (luma), //out
	.BLK_n    (), //out
	.sync     (), //out
	.cs0_n    (cpu_addr[12]),
	.cs2_n    (cpu_addr[7]),
	.rst      (),
	.ce       (1),
	.video_ce (1),
	.vblank   (new_vblank), //out
	.hblank   (), //out
	.hgap     (new_hblank), // Hblank that doesn't comb.
	.vsync    (new_vsync), //out
	.hsync    (new_hsync), //out
	.phi2_gen (phi2_gen) //out
);

wire [7:0] uv = {color, luma, luma[2]};

wire [23:0] new_rgbx2 = stella_palette[uv[7:1]];//{red_lut[uv], red_lut[uv], green_lut[uv], green_lut[uv], blue_lut[uv], blue_lut[uv]};

assign tia_do = clocks_de ? new_dout : old_dout;
assign vsyn = video_de ? new_vsync : old_vsync;
assign hsyn = video_de ? new_hsync : old_hsync;
assign hblank = video_de ? new_hblank : old_hblank;
assign vblank = video_de ? new_vblank : old_vblank;
assign rgbx2 = video_de ? new_rgbx2 : old_rgbx2;
assign cpu_rdy = clocks_de ? new_rdy : old_rdy;
assign phi0 = clocks_de ? new_phi0 : old_phi0;
assign phi2 = clocks_de ? phi2_gen : old_phi2;
assign au0 = audio_de ? |new_aud0 : old_aud0_en;
assign au1 = audio_de ? |new_aud1 : old_aud1_en;
assign av0 = audio_de ? new_aud0 : (old_aud0_en ? old_aud0 : 4'd0);
assign av1 = audio_de ? new_aud1 : (old_aud1_en ? old_aud1 : 4'd0);


// UV Palette data found at: http://atariage.com/forums/topic/209210-complete-ntsc-pal-color-palettes/
// These three assign statements generated by Atari7800/palettes.py

// Ripped strait from stella
logic [23:0] stella_palette[128];
assign stella_palette = '{
	24'h000000, 24'h4a4a4a, 24'h6f6f6f, 24'h8e8e8e,
	24'haaaaaa, 24'hc0c0c0, 24'hd6d6d6, 24'hececec,
	24'h484800, 24'h69690f, 24'h86861d, 24'ha2a22a,
	24'hbbbb35, 24'hd2d240, 24'he8e84a, 24'hfcfc54,
	24'h7c2c00, 24'h904811, 24'ha26221, 24'hb47a30,
	24'hc3903d, 24'hd2a44a, 24'hdfb755, 24'hecc860,
	24'h901c00, 24'ha33915, 24'hb55328, 24'hc66c3a,
	24'hd5824a, 24'he39759, 24'hf0aa67, 24'hfcbc74,
	24'h940000, 24'ha71a1a, 24'hb83232, 24'hc84848,
	24'hd65c5c, 24'he46f6f, 24'hf08080, 24'hfc9090,
	24'h840064, 24'h97197a, 24'ha8308f, 24'hb846a2,
	24'hc659b3, 24'hd46cc3, 24'he07cd2, 24'hec8ce0,
	24'h500084, 24'h68199a, 24'h7d30ad, 24'h9246c0,
	24'ha459d0, 24'hb56ce0, 24'hc57cee, 24'hd48cfc,
	24'h140090, 24'h331aa3, 24'h4e32b5, 24'h6848c6,
	24'h7f5cd5, 24'h956fe3, 24'ha980f0, 24'hbc90fc,
	24'h000094, 24'h181aa7, 24'h2d32b8, 24'h4248c8,
	24'h545cd6, 24'h656fe4, 24'h7580f0, 24'h8490fc,
	24'h001c88, 24'h183b9d, 24'h2d57b0, 24'h4272c2,
	24'h548ad2, 24'h65a0e1, 24'h75b5ef, 24'h84c8fc,
	24'h003064, 24'h185080, 24'h2d6d98, 24'h4288b0,
	24'h54a0c5, 24'h65b7d9, 24'h75cceb, 24'h84e0fc,
	24'h004030, 24'h18624e, 24'h2d8169, 24'h429e82,
	24'h54b899, 24'h65d1ae, 24'h75e7c2, 24'h84fcd4,
	24'h004400, 24'h1a661a, 24'h328432, 24'h48a048,
	24'h5cba5c, 24'h6fd26f, 24'h80e880, 24'h90fc90,
	24'h143c00, 24'h355f18, 24'h527e2d, 24'h6e9c42,
	24'h87b754, 24'h9ed065, 24'hb4e775, 24'hc8fc84,
	24'h303800, 24'h505916, 24'h6d762b, 24'h88923e,
	24'ha0ab4f, 24'hb7c25f, 24'hccd86e, 24'he0ec7c,
	24'h482c00, 24'h694d14, 24'h866a26, 24'ha28638,
	24'hbb9f47, 24'hd2b656, 24'he8cc63, 24'hfce070
};

// wire [255:0][3:0] red_lut = {
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0,
// 	4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0
// };

// wire [255:0][3:0] green_lut = {
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0,
// 	4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h2, 4'h1, 4'h0,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h1, 4'h0, 4'h0,
// 	4'hf, 4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'he, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0
// };

// wire [255:0][3:0] blue_lut = {
// 	4'ha, 4'h9, 4'h8, 4'h7, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'ha, 4'h9, 4'h8, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'he, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h4, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4,
// 	4'hf, 4'hf, 4'hf, 4'hf, 4'hd, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h4, 4'h3, 4'h2, 4'h1,
// 	4'hf, 4'he, 4'hc, 4'hb, 4'ha, 4'h9, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0,
// 	4'hb, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'ha, 4'h9, 4'h8, 4'h7, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0, 4'h0,
// 	4'hf, 4'hf, 4'he, 4'hd, 4'hc, 4'hb, 4'ha, 4'h8, 4'h7, 4'h6, 4'h5, 4'h4, 4'h3, 4'h2, 4'h1, 4'h0
// };

logic [15:0] audio_lut[32];
assign audio_lut = '{
	16'h0000, 16'h0842, 16'h0FFF, 16'h1745, 16'h1E1D, 16'h2492, 16'h2AAA, 16'h306E,
	16'h35E4, 16'h3B13, 16'h3FFF, 16'h44AE, 16'h4924, 16'h4D64, 16'h5173, 16'h5554,
	16'h590A, 16'h5C97, 16'h5FFF, 16'h6343, 16'h6665, 16'h6968, 16'h6C4D, 16'h6F17,
	16'h71C6, 16'h745C, 16'h76DA, 16'h7942, 16'h7B95, 16'h7DD3, 16'h7FFF, 16'hFFFF
};

assign audio_mono = audio_lut[{1'b0, av0} + {1'b0, av1}];

endmodule