module mult_test(x0,mult,add1check,lt3check,gt1check,xp0,lt4,add2,x1,xp1);

output  [31:0] mult,add2;

output reg lt3check,gt1check;
output lt4;

input [31:0] x0,xp0,x1,xp1;
output reg [N-1:0] add1check;

wire ltres, gtres,gt1,lt3;
wire [31:0] add1;



parameter N = 32;
parameter Q = 16;

parameter [31:0] a = 32'b10000000000001010000000000000000;
parameter [31:0] b = 32'b00000000000001100000000000000000;

qmult	#(Q,N) mult1(a,b,mult); 
fplessthan #(Q,N) lessthan1 (a,b,ltres) ;
fpgreaterthan #(Q,N) greaterthan1 (a,b,gtres) ;

qadd #(Q,N) my_qadd1(x0,{(xp0[N-1] == 0)?1'b1:1'b0,xp0[N-2:0]},add1);    // answer 1 + 2 = 3
fpgreaterthan #(Q,N) fpgt1 (add1,32'b0_00000_00000_00000_1000_0000_0000_0000,gt1);	// x0 - xp0 > 0.5   // 3 > 0.5 - true
fplessthan #(Q,N) fplt3 (add1,32'b0_000000000000000_0011001100110011,lt3);	  // x0 - xp0 < 0.2  // 3 < 0.2 -- false

qadd #(Q,N) qadd2(xp1,32'b1_00000_00000_01010_0000000000000000,add2);  //xp1 -10
fplessthan #(Q,N) fplt4 (x1,add2,lt4);	// x1 < xp1 -10  -12 < -12 --- giving 1


always@(*)
begin
	 lt3check = lt3;
	 add1check = add1;
	 gt1check = gt1;

end

endmodule