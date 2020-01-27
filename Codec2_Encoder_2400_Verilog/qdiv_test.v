//Simulation : Waveform30.vwf

module qdiv_test(clk,o_quotient_out,o_complete,o_overflow,qout,fpout);

parameter N = 32;
input clk;
output reg [N-1:0]  o_quotient_out;
output 	reg o_complete;
output	reg o_overflow;
output  [N-1:0] qout,fpout;
wire [N-1:0] qout_wire;

parameter [N-1:0] i_dividend = 32'b1_000000000000100_1000000000000000;
parameter [N-1:0] i_divisor  = 32'b0_000000000000011_1000000000000000;


wire [N-1:0] quotient_out;
wire complete,overflow;

//qdiv #(16,32) qdiv1(i_dividend, i_divisor,1,clk,quotient_out,complete,overflow);
fpdiv #(16,32) fpdiv1(i_dividend, i_divisor,fpout);
	
always@(posedge clk)
begin
	o_quotient_out <= quotient_out;
	o_complete <= complete;
	o_overflow <= overflow;

end

assign qout = ((i_dividend << 8 )/i_divisor ) << 8;

//assign qout = qout_wire << 8;



endmodule
 