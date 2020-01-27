//Simulation : Waveform40.vwf

module log10_lookup(in_x, out_x);
	
	parameter N = 4;
	input [N-1:0] in_x;
	output reg [N-1:0] out_x;

	
always@(in_x)
begin
	case (1)
//		(in_x >= 4'd0 && in_x <= 4'd1) : out_x = 4'd1;
//		(in_x >= 4'd2 && in_x <= 4'd4) : out_x = 4'd2;
//		(in_x >= 4'd5 && in_x <= 4'd8) : out_x = 4'd7;
	
		
	endcase
	

end


endmodule