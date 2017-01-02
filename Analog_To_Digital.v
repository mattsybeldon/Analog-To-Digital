/*
Analog input to digital output

This project was motivated by converting analog inputs into a form suitable for digital displays.
Namely, it's meant to output Super Smash Bros. Melee to non-CRT TVs, hopefully with lower latency than most TVs
The project was developed on a DE-1 SOC and has a unit for outputting to the VGA on board.
Additional modifications can be done using the GPIo to interface with something like a PlutoIIx for HDMI.

Current status: 4:2:2 output. Green offset?
To do : 4:4:4 output (see Altera example documentation). Measure input latency
*/

module Analog_To_Digital (

//Outputs
video_rgb, // 8 bit video value 3 red, 3 blue, 2 green
I2C_SDATA, // serial data bus
I2C_SCLK, // clock line serial data bus
gpio, // general purpose registers for debug purposes
led, // LED outputs

//Inputs
clk_50, // 50 Mhz clock 
clk_27, // 27 Mhz clock for video in chip
clk_en, // clock enable for 27 Mhz clock

video_in, // 8 bit video input 
swt, // switch inputs

//Bidirectionals
vsync, // video vertical sync
hsync, // video horizontal sync
vid_blank, // video blank 
vid_hs, // horizontal sync videra capture
vid_vs, // vertical sync videra capture
clk_vid // 25 Mhz clock to video chip




);

output[7:0]		video_rgb;
output 			I2C_SCLK;
output			clk_en;
output[7:0]		led;
output[15:0] 	gpio;

input[7:0] 	video_in;
input		clk_50;
input 		clk_27;
input[7:0]	swt;

inout		I2C_SDATA;
inout		vid_hs;
inout		vid_vs;
inout 		vsync;
inout 		hsync;
inout		vid_blank;
inout		clk_vid;

reg[10:0]	clkcount; // Need to achieve approx 25 kHz clock

//VGA

wire[7:0]	video_rgb;
wire[7:0] 	video_mot;
wire[15:0] 	address_mot;
wire 		hsync;
wire		vsync;
wire		vid_blank;
wire 		read_hl;
wire 		read_hh;
wire 		read;
wire 		read_lh;
wire 		read_ll;

//Video input

wire[15:0] 	address_vid;
wire 			vid_ldl;
wire 			vid_ldh;
wire 			vid_udl;
wire 			vid_udh;
wire			we_vid;
wire			clk_27;
wire			clk_50;
wire 			oddeven;
wire			frame;


//Memory for video

wire[15:0]	data_vidl;
wire[15:0]	data_vidh;
wire[31:0]  data_in;
wire[15:0]  data_motl;
wire[15:0]  data_moth;
wire[31:0]  data_q;
wire[3:0]	vid_en;
wire[15:0]	rdaddress;
wire[15:0]	wraddress;

//Instantiations


Video_Input  video_src(
		//Inputs
		.clk_27(clk_27),
		.video_in(video_in),

		//Outputs
		.vid_ldl(vid_ldl),
		.vid_ldh(vid_ldh),
		.vid_udl(vid_udl),
		.vid_udh(vid_udh),
		.frame(frame),
		.address_video(address_vid),
		.data_videol(data_vidl),
		.data_videoh(data_vidh),
		.we_video(we_vid),

		//Bidirectionals
		.vid_vs(vid_vs),
		.vid_hs(vid_hs)
);

VGA_Output vga_out (
			//Inputs		
			.vid_clk(clk_vid),
			.clk_50(clk_50),

			//Outputs
			.video_mot(video_mot),
			.address_mot(address_mot),
			.oddeven(oddeven),

			//Bidirectionals
			.data_motl(data_motl),
			.data_moth(data_moth),
			.read_lowl(read_ll),	
			.read_highl(read_lh),
			.read_lowh(read_hl), 
			.read_highh(read_hh),
			.vsync(vsync),
			.hsync(hsync),
			.vid_blank(vid_blank),
			.read(read)
);

I2C_Master I2C_unit(
 			
 			//Inputs
			.RESET(swt[1]),
			.I2C_clk(clk_27),

			//Outputs
			.I2C_SCLK(I2C_SCLK),
			.TRN_END(TRN_END),
			.ACK(ACK),
			.ACK_enable(ACK_enable),

			//Bidirectionals
			.I2C_SDATA(I2C_SDATA)
 );

//Mostly generated with Quartus
ram_16 ram (

			.clock(clk_50),
			.wraddress(wraddress),
			.rdaddress(rdaddress),
			.data(data_in),
			.byteena_a(vid_en),
			.q(data_q),
			.rden(read),
			.wren(!read)
);

//I2C programmer
 
 wire I2C_SCLK; 
 wire I2C_SDATA; 
 
 wire ACK ;
 wire ACK_enable;
 wire [23:0] data_23;
 wire TRN_END;
 
 //Clock divider

 
 always @ (posedge clk_50 )

begin 
	if (!swt[0]) 
		begin		
		clkcount = 0;
		end
		
		else
		begin
		clkcount <= clkcount + 1;
		end
end

	
//Memory - 16 addr lines, 32 data, 4 byte enables


assign wraddress = address_vid;
assign rdaddress = address_mot;
	 
assign data_in[31:16] = data_vidh;
assign data_in[15:0] = data_vidl;
	 
assign data_motl = data_q[15:0];
assign data_moth = data_q[31:16];
 
assign vid_en[0] = vid_ldl;
assign vid_en[1] = vid_ldh;
assign vid_en[2] = vid_udl;
assign vid_en[3] = vid_udh;
assign clk_vid = clkcount[0];
assign clk_en = swt[0]; 
assign led = swt;
assign video_rgb = video_mot; 

assign gpio[0] = clk_vid;
assign gpio[1] = read;
assign gpio[2] = we_vid;
assign gpio[3] = oddeven;
assign gpio[4] = vid_ldl;
assign gpio[5] = vid_ldh;
assign gpio[6] = vid_udl;
assign gpio[7] = vid_udh;
assign gpio[15:8] = address_vid[7:0];

endmodule	
