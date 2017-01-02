module Video_Input (
//Inputs
clk_27,		// 27 Mhz clock 
video_in, // Video input data

//Outputs
vid_ldl, // low byte odd address enable
vid_ldh, // high byte odd address enable
vid_udl, // low byte even address enable
vid_udh, //high byte even address enable
frame,		// frame size
address_video, //address of video memory
data_videol, //Low frame data
data_videoh, //High frame data
we_video,	//Write enable to store video in memory

//Bidirectionals
vid_vs,		// vertical sync pulses
vid_hs		// horizontal sync pulses
);

input 		clk_27; 
input[7:0] 	video_in;		

output		vid_ldl;
output		vid_ldh;
output		vid_udl;
output		vid_udh;
output		frame;
output[15:0] address_video;
output[15:0] data_videol;
output[15:0] data_videoh;
output		we_video;

inout 		vid_hs; 		
inout 		vid_vs; 


reg[15:0] address_video;
reg[15:0] data_videol;
reg[15:0] data_videoh;

reg[10:0] horizontal; 
reg[17:0] timer1;
reg[2:0]  timer2;
reg[17:0] vid_address_low;

wire[7:0] video_in;
 
wire vid_ldl = (frame & !timer2[0] & !vid_address_low[1] & !vid_address_low[0] & clk_27 ) ? 1'b1 : 1'b0; 
wire vid_ldh = (frame & !timer2[0] & vid_address_low[1] & !vid_address_low[0] & clk_27 ) ? 1'b1 : 1'b0;
wire vid_udl = (frame & timer2[0] & !vid_address_low[1] & !vid_address_low[0] & clk_27 ) ? 1'b1 : 1'b0;
wire vid_udh = (frame & timer2[0] & vid_address_low[1] & !vid_address_low[0] & clk_27 ) ? 1'b1 : 1'b0;
wire we_video = (frame & !vid_address_low[0] & clk_27 ) ? 1'b1 : 1'b0;


wire vert = ( ( timer1 > 30 &  timer1 <= 240 ) ) ? 1'b1 : 1'b0;
wire horiz = ( ( horizontal > 300 & horizontal <= 1548) ) ? 1'b1 : 1'b0;
wire frame = ( horiz  & vert) ? 1'b1 : 1'b0 ;


parameter address_0 = 16'h00000;

always @ (posedge vid_hs)
begin
	
	if (! vid_vs)
		timer1 <= address_0;
		else
		
		begin
		
		timer1 <= timer1 + 1;
		end
	end
	

always @ (posedge  vid_vs)
begin

		timer2 <= timer2 + 1;
end


always @(posedge clk_27 )

begin
		if (vid_hs)
		horizontal <= 0;
	
		else
		
		begin
		horizontal <= horizontal + 1;
		end

end		

//Address memory counter

always @ (posedge clk_27)

begin

	if (!vert)	
		begin
			vid_address_low <= address_0;
		end
		
		else
		
		begin	
		if (frame)
			vid_address_low <= vid_address_low + 1;
		end
		
end


always @ (negedge clk_27)

begin

	if ( vid_ldl )
		
			begin
			address_video <= vid_address_low[17:2]; // low byte 
			data_videol[7:0] <= video_in;
			end
			
		else
		
			if ( vid_ldh )
		
			begin
			address_video <= vid_address_low[17:2]; // high byte
			data_videol[15:8] <= video_in;
			end
			
		else

//even bytes
		
			if ( vid_udl )
		
			begin
			address_video <= vid_address_low[17:2]; // low byte
			data_videoh[7:0] <= video_in;
			end
			
		else
		
					
			if ( vid_udh )
		
			begin
			address_video <= vid_address_low[17:2]; // high byte
			data_videoh[15:8] <= video_in;
			end
		

	end

endmodule	
	