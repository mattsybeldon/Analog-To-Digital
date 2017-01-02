module VGA_Output (
//Inputs
vid_clk, //25 Mhz clock for pixels
clk_50, //50 Mhz clock

//Outputs
video_mot,
address_mot,
oddeven,

//Bidirectionals
data_motl, //Low data on VGA out
data_moth, //High data on VGA out
read_lowl, //Enable odd low
read_lowh, //Enable odd high
read_highl, //Enable even low
read_highh, //Enable even high
vsync, //Vertical sync pulse
hsync, //Horizontal sync pulse
vid_blank, //Video blank
read, //Read enable
);

input vid_clk;
input clk_50;

output[7:0]	video_mot;
output[15:0] address_mot;
output	oddeven;

inout[15:0]	data_motl;
inout[15:0]	data_moth;
inout read_highh;
inout read_highl;
inout read_lowh;
inout read_lowl;

inout vsync;
inout hsync; 
inout vid_blank;
inout read;

reg[7:0] video_mot;
reg[15:0] address_mot;
reg[15:0] data_motl;
reg[15:0] data_moth;

// internal registers
reg[16:0] ramaddressl_odd;  // low address read from memory 
reg[16:0] ramaddressl_even; // high address read from memory 
reg[10:0] contvidv; // vertical counter
reg[10:0] contvidh; // horizontal counter


wire vsync = ((contvidv >= 491) & (contvidv < 493))? 1'b0 : 1'b1;
wire hsync = ((contvidh >= 664) & (contvidh < 760))? 1'b0 : 1'b1;
wire vid_blank = ((contvidv >= 8) & (contvidv <  420) &(contvidh >= 20) & (contvidh < 624))? 1'b1 : 1'b0;
wire clrvidh = (contvidh <= 800) ? 1'b0 : 1'b1;
wire clrvidv = (contvidv <= 525) ? 1'b0 : 1'b1;
wire ramvidv = ( ( (contvidv <= 420) ) ? 1'b0 : 1'b1); 


wire adden = ( (( contvidh < 624) & (contvidv <= 420) ) ? 1'b1 : 1'b0); // address enable

wire read = (vid_clk & adden) ? 1'b1 : 1'b0; // oe to memory enable
wire read_lowl = ( adden & !ramaddressl_odd[0] & vid_clk & !oddeven ) ? 1'b0 : 1'b1; // low odd address enable
wire read_highl = (adden & ramaddressl_odd[0] & vid_clk & !oddeven ) ? 1'b0 : 1'b1; // low even address enable
wire read_lowh = ( adden & !ramaddressl_even[0] & vid_clk & oddeven ) ? 1'b0 : 1'b1; // high odd address enable
wire read_highh = ( adden & ramaddressl_even[0] & vid_clk & oddeven ) ? 1'b0 : 1'b1; // high even address enable

parameter address_low = 19'h00000;  // lower address start at 0 meg


assign oddeven = contvidv[0];

always @ (posedge vid_clk )

begin 

		if(clrvidh)
		begin
		contvidh <= 0;
		end
		
		else
		begin
		contvidh <= contvidh + 1;
		end
end


always @ (posedge vid_clk)

begin 

		if (clrvidv)
		begin
		contvidv <= 0;
		end
		
		else
		begin
			if
			(contvidh == 798)
			begin
			contvidv <= contvidv + 1;
			end
		end
end

always @ (posedge vid_clk )

begin 

		if(ramvidv)
		begin
		ramaddressl_odd <= address_low;
		end
		
		else
		begin
		if (adden & !oddeven )
			begin
			ramaddressl_odd <= ramaddressl_odd + 1;
			end 
		end
end


always @ (posedge vid_clk)

begin 

		if (ramvidv)
		begin
		ramaddressl_even <= address_low;
		end
		
		else
		begin
			if
			(adden & oddeven )
			begin
			ramaddressl_even <= ramaddressl_even + 1;
			end
		end
end



always @ (negedge vid_clk)

begin
		if (!read_lowl )
		begin

		video_mot <= data_motl[7:0];
		address_mot <= ramaddressl_odd[16:1];
		end
		
		else 
		
		
		if (!read_highl )
		begin

		video_mot <= data_motl[15:8];
		address_mot <= ramaddressl_odd[16:1];
		end
		
		else
		
		
		if (!read_lowh )
		begin

		video_mot <= data_moth[7:0];
		address_mot <= ramaddressl_even[16:1];
		end
		
		else
		
		
		if (!read_highh )
		begin

		video_mot <= data_moth[15:8];
		address_mot <= ramaddressl_even[16:1];
		end
		
end		



endmodule
	