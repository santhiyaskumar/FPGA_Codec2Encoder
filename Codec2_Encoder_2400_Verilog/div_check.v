module div_check (d_out);
	parameter N = 32;
	parameter Q = 16;
	output reg [N-1:0] d_out;
	

parameter [N-1:0]  d1_in1 = 32'b0000000000000001_0101000001101110;
parameter [N-1:0]  d1_in2 = 32'b1000000000000100_1110011001001110;

wire [N-1:0] d1_out;
fpdiv  #(Q,N)	divider1   (d1_in1,d1_in2,d1_out);

always@(*)
begin
 d_out = d1_out;
end



endmodule