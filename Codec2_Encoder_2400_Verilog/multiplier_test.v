// Simulation : Waveform34.vwf
module multiplier_test(a,b,out);
	input [7:0] a,b;
	output [7:0] out;
	
	
	
	assign out = (a*b) + 7'd9;
	
	
	
	endmodule