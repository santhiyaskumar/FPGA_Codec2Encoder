// Simulation : Waveform37.vwf

module log10 #(
	//Parameterized values
	parameter Q = 16,
	parameter N = 32
	)
	(
    input [N-1:0] in_x,
    output  [N-1:0] out_x
    );

wire  [N-1:0] res;
wire [N-1:0] add1,add2,div1,mult1,mult2,mult3,mult4,mult5,add3,add4,mult6,
				 mult7,mult8,mult9,add5,add6,mult10;

assign out_x = res ;

qadd   #(Q,N) adder1			(in_x,32'b0_000000000000001_0000000000000000,add1);
qadd   #(Q,N) adder2			(in_x,32'b1_000000000000001_0000000000000000,add2);
fpdiv  #(Q,N) divider1		(add2,add1,div1);
qmult  #(Q,N) multiplier1	(div1,div1,mult1);
qmult  #(Q,N) multiplier2	(mult1,div1,mult2);
qmult  #(Q,N) multiplier3	(mult2,mult1,mult3);
qmult  #(Q,N) multiplier4	(32'b00000000000000000101010101010101,mult2,mult4);
qmult  #(Q,N) multiplier5	(32'b00000000000000000011001100110011,mult3,mult5);
qmult  #(Q,N) multiplier6  (mult1,mult3,mult6); // power7
qmult  #(Q,N) multiplier7  (mult6,mult1,mult7); // power9
qmult  #(Q,N) multiplier8  (32'b00000000000000000010010010010010,mult6,mult8);		// (1/7)
qmult  #(Q,N) multiplier9  (32'b00000000000000000001110001110001,mult7,mult9);      //(1/9)

qadd   #(Q,N) adder3 		(mult4,mult5,add3);
qadd   #(Q,N) adder4			(div1,add3,add4);
qadd	 #(Q,N) adder5			(add4,mult8,add5);
qadd	 #(Q,N) adder6			(add5,mult9,add6);

qmult  #(Q,N) multiplier10  (add6,32'b0_000000000000010_0000000000000000,mult10);
qmult  #(Q,N) multiplier11  (mult10,32'b0000000000000000_0110111100101000,res);



	 

endmodule
	 