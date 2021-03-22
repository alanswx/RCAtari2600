/*
------------------------------------------------------------------------------------------------
--
--   Copyright (C) 2005
--
--   Title     :  Atari 2600 System... VHDL Style ... Oh yeah!!!!
--
--   Author    :  Ed Henciak 
--
--   Date      :  February 19, 2005
--
--   Notes     :  This represents the guts of the Atari 2600...the system of
--                champions.  You young 'uns out there had better show some 
--                respect for this system as you decend through the hierarchy
--                that recreates this wonderful machine :) .  Nothing like it
--                will ever be designed or exploited again!
--
------------------------------------------------------------------------------------------------
*/


module top2600 (
// clock and reset
	input logic clk,
	input logic clk2x,
	input logic reset,
	
	output logic ref_newline,
	output logic pix_ref,
	output logic system_rst,
	input logic [7:0] PAin,
   input logic [7:0] PBin,

	input logic [3:0] ctl_l,
	output logic [3:0] ctl_l_o,
	input logic pad_l_0,
	input logic pad_l_1,
	input logic trig_l,
	
	input logic [3:0] ctl_r,
	output logic [3:0] ctl_r_o,
	input logic pad_r_0,
	input logic pad_r_1,
	input logic trig_r,
	
// Cartridge port
    output logic [12:0] rom_addr,// The program address bus
    input logic [7:0] rom_rdata ,// Program data bus (input)
    output logic [7:0] rom_wdata ,// Program data bus (input)

    // Console switches (momentary switches are normally open)
    input logic bw_col, //Slide switch...selects black & white or color
    input logic diff_l, //Slide switch...selects difficulty for left player
    input logic diff_r, // Slide switch...selects difficulty for right player
    input logic gamesel, // Momentary switch...selects game variation
    input logic start ,  // Momentary switch...starts the game!

    // Video Output.
    output logic [2:0] vid_lum,    // Luma...register on a pix clk tick
    output logic [3:0]  vid_col,   // Color...register on a pix clk tick
    output logic vid_vsyn,   //Vertical sync
    output logic vid_hsyn,   // Horizontal sync
    output logic vid_csyn,   // Composite sync
    output logic vid_cb  ,   // Colorburst
    output logic vid_blank_n, //Blank!...register on a pix clk tick!
    output logic vid_hblank,//Blank!...register on a pix clk tick!
    output logic vid_vblank, // Blank!...register on a pix clk tick!

    // Audio Output
    output logic [3:0] aud_ch0, // Four bit audio channel 1
   output logic [3:0]  aud_ch1 // Four bit audio channel 2
);




//    ------------------------------
//    -- CPU related interconnect --
//    ------------------------------

//    -- CPU clocks (reference)
    logic cpu_p0; 
    logic cpu_clk; 
    logic cpu_p0_ref;
    logic cpu_p0_ref_180;

    //-- Read/write
    logic cpu_rwn;

    //-- Address
    logic [12:0]  cpu_addr;

    //-- Data I/O
    logic [7:0]  cpu_wdata;
    logic [7:0]  cpu_rdata;

    //-- CPU "Ready" signal
    logic cpu_rdy;

    //-- CPU sync (indicates OPCODE is on DBUS)
    logic cpu_sync;

    //----------------------------------
    //-- Controller port related I/O  --
    //----------------------------------

    //-- Paddle / Trigger input to TIA
    logic [5:0] ctl_in;

    //-- PIA I/O (Joysticks, Keypads, Control switches, etc.)
    logic [7:0] pia_port_a_in;
    logic [7:0] pia_port_b_in;
    logic [7:0] pia_port_a_out;
    logic [7:0] pia_port_b_out;
    logic [7:0] pia_port_a_ctl;
    logic [7:0] pia_port_b_ctl;
    logic [7:0] pia_port_a;
    logic [7:0] pia_port_b;

    //----------------------------
    //-- TIA and RIOT Read data --
    //----------------------------
    logic [7:0] tia_dout;
    logic [7:0] riot_dout;

    logic [7:0] latched_rdata;

    //------------------------------------------------
   // -- Internal reset signal for the whole system --
   // ------------------------------------------------
    logic system_rst_i;

    //-------------------------------
    //-- Logic levels for tie-offs --
    //-------------------------------
    logic vdd    ;
    logic gnd   ;



assign gnd = 1'b0;
assign vdd = 1'b1;

assign ctl_in = {trig_r,trig_l,pad_r_0,pad_r_1,pad_l_1,pad_l_0};

assign pia_port_a_in = { ctl_l,ctl_r};

//Drive port outputs (i.e. keypad)
assign ctl_l_o = pia_port_a[7:4];
	 
assign ctl_r_o = pia_port_a[3:0];

//Console control inputs...these are always inputs on the Atari 2600
assign pia_port_b_in = {diff_r,diff_l, pia_port_b[5], pia_port_b[4], bw_col, pia_port_b[2], gamesel,start }; 
//Route to PIA (RIOT) unused port B I/O

assign pia_port_a[0] = (pia_port_a_ctl[0] == 1'b1) ?  pia_port_a_out[0] : 1'bz;
assign pia_port_a[1] = (pia_port_a_ctl[1] == 1'b1) ?  pia_port_a_out[1] : 1'bz;
assign pia_port_a[2] = (pia_port_a_ctl[2] == 1'b1) ?  pia_port_a_out[2] : 1'bz;
assign pia_port_a[3] = (pia_port_a_ctl[3] == 1'b1) ?  pia_port_a_out[3] : 1'bz;
assign pia_port_a[4] = (pia_port_a_ctl[4] == 1'b1) ?  pia_port_a_out[4] : 1'bz;
assign pia_port_a[5] = (pia_port_a_ctl[5] == 1'b1) ?  pia_port_a_out[5] : 1'bz;
assign pia_port_a[6] = (pia_port_a_ctl[6] == 1'b1) ?  pia_port_a_out[6] : 1'bz;
assign pia_port_a[7] = (pia_port_a_ctl[7] == 1'b1) ?  pia_port_a_out[7] : 1'bz;

assign pia_port_b[0] = (pia_port_b_ctl[0] == 1'b1) ?  pia_port_b_out[0] : 1'bz;
assign pia_port_b[1] = (pia_port_b_ctl[1] == 1'b1) ?  pia_port_b_out[1] : 1'bz;
assign pia_port_b[2] = (pia_port_b_ctl[2] == 1'b1) ?  pia_port_b_out[2] : 1'bz;
assign pia_port_b[3] = (pia_port_b_ctl[3] == 1'b1) ?  pia_port_b_out[3] : 1'bz;
assign pia_port_b[4] = (pia_port_b_ctl[4] == 1'b1) ?  pia_port_b_out[4] : 1'bz;
assign pia_port_b[5] = (pia_port_b_ctl[5] == 1'b1) ?  pia_port_b_out[5] : 1'bz;
assign pia_port_b[6] = (pia_port_b_ctl[6] == 1'b1) ?  pia_port_b_out[6] : 1'bz;
assign pia_port_b[7] = (pia_port_b_ctl[7] == 1'b1) ?  pia_port_b_out[7] : 1'bz;


//pia_port_b_in(2) <= pia_port_b(2);
//pia_port_b_in(4) <= pia_port_b(4);
//pia_port_b_in(5) <= pia_port_b(5);

 //   -- Fake "latch last read" value from the databus...
always @(posedge clk)
begin
	if (cpu_addr[12])
		latched_rdata <= cpu_rdata;
	else if (cpu_addr[7])
		latched_rdata<= cpu_rdata;
	
end

//    -- Component address decoding (i.e. data mux).

//assign cpu_rdata =  cpu_addr[12] ? rom_rdata : ~cpu_addr[7] ? {tia_dout[7:6],latched_rdata[5:0]} : riot_dout;
always_comb begin
	if (cpu_addr[12])
		cpu_rdata = rom_rdata;
	else if (cpu_addr[7]==0)
		cpu_rdata = {tia_dout[7:6],latched_rdata[5:0]};
	else
		cpu_rdata = riot_dout;
end


// Drive out ROM address
assign    rom_addr = cpu_addr[12:0];

    //-- Processor
    m6507 m6507 (
		.reset(system_rst),
       .clk    (clk),
       .enable(cpu_p0_ref_180),
       .a    (cpu_addr),
       .din (cpu_rdata),
       .dout ( cpu_wdata),
       .sync(cpu_sync),
       .rdy(cpu_rdy),
       .rwn(cpu_rwn)

    );


	 
    //-- Only the CPU can write data to the 2600
    //-- "ROM" port...
    assign rom_wdata = cpu_wdata;

    //-- RIOT (6532 PIA)
 /*
	riot riot
    (
       .clk(clk),
       .reset(system_rst_i),
       .go_clk(cpu_p0_ref),
       .go_clk_180(cpu_p0_ref_180),
       .port_a_in(pia_port_a_in),
       .port_b_in(pia_port_b_in),
       .port_a_out(pia_port_a_out),
       .port_b_out(pia_port_b_out),
       .port_a_ctl( pia_port_a_ctl),
       .port_b_ctl ( pia_port_b_ctl),
       .addr   ( cpu_addr[6:0]),
       .din (cpu_wdata),
       .dout  (riot_dout),
       .rwn  (cpu_rwn),
       .ramsel_n(cpu_addr[9]),
       .cs1  ( cpu_addr[7]),
       .cs2n ( cpu_addr[12]),
       .irqn  ()

    );
*/

 M6532 RIOT
(
	.clk    (clk),
	.ce     (cpu_p0_ref),
	.res_n  (~system_rst),
	.addr   (cpu_addr[6:0]),
	.RW_n   (cpu_rwn),
	.d_out  (riot_dout),
	.d_in   (cpu_wdata),
	.RS_n   (cpu_addr[9]),
	.CS1    (cpu_addr[7]),
	.CS2_n  (cpu_addr[12]),
	.PA_in  (PAin),
	.PA_out (pia_port_a_out),
	.PB_in  (PBin),
	.PB_out (pia_port_b_out)
);

	 
    //-- TIA top level...see notes on video output
    tia tia
    (

      //-- clkena            => clk,
       .clk( clk),
       .master_reset( reset),
       .pix_ref (pix_ref),
       .sys_rst ( system_rst_i),
       .cpu_p0_ref(cpu_p0_ref),
       .cpu_p0_ref_180 (cpu_p0_ref_180),
       //-- synthesis translate_off
       //.ref_newline (ref_newline),
       //-- synthesis translate_on
       .cpu_p0 (cpu_p0),
       .cpu_clk  (cpu_p0),
       .cpu_cs0n (cpu_addr[12]),
       .cpu_cs1  (vdd),
       .cpu_cs2n  ( gnd),
       .cpu_cs3n ( cpu_addr[7]),
       .cpu_rwn  (cpu_rwn),
       .cpu_addr (cpu_addr[5:0]),
       .cpu_din  ( cpu_wdata),
       .cpu_dout  ( tia_dout),
       .cpu_rdy   ( cpu_rdy),
       .ctl_in    ( ctl_in),
       .vid_csync( vid_csyn),
       .vid_hsync (vid_hsyn),
       .vid_vsync (vid_vsyn),
       .vid_lum  (vid_lum_l),   //   -- Requires a pix clk register!
       .vid_color(vid_col_l),//      -- Requires a pix clk register!
       .vid_cb  ( vid_cb),
       .vid_blank_n(vid_blank_n),//  -- Requires a pix clk register!
       .vid_vblank(vid_vblank),
       .vid_hblank (vid_hblank),

       .aud_ch0 (aud_ch0),
       .aud_ch1(aud_ch1)

    );
	 
	 
/*	 
    tia2 tia2
    (

      //-- clkena            => clk,
       .clk( clk),
	output       phi0(cpu_p0_ref),
	input        phi2(cpu_p0_ref_180),
	output logic phi1,

	 module TIA2
(
	// Original Pins
	input        clk,
	output       phi0,
	input        phi2,
	output logic phi1,
	input        RW_n,
	output logic   rdy,
	input  [5:0] addr,
	input  [7:0] d_in,
	output [7:0] d_out,
	input  [3:0] i,     // On real hardware, these would be ADC pins. i0..3
	input        i4,
	input        i5,
	output [3:0] aud0,
	output [3:0] aud1,
	output [3:0] col,
	output [2:0] lum,
	output       BLK_n,
	output       sync,
	input        cs0_n,
	input        cs2_n,

	// Abstractions
	input        rst,
	input        ce,     // Clock enable for CLK generation only
	input        video_ce,
	output       vblank,
	output       hblank,
	output       hgap,
	output       vsync,
	output       hsync,
	output       phi2_gen
);
*/
	 
	 
     logic [2:0] vid_lum_l;    // Luma...register on a pix clk tick
    logic [3:0]  vid_col_l;   // Color...register on a pix clk tick
    //-- Concurrent signal assignments (for outputs)
    always@(posedge clk) begin
		system_rst <= system_rst_i;
		vid_lum<=vid_lum_l;
		vid_col<=vid_col_l;
		end 

endmodule
