/*
* Module 		- compute_weights
* Top module	- encode_WoE
* CODEC2_ENCODE_2400

Description: Compute w[0] and w[1]
Inputs : x[2], xq[2], clk, rst

*32 bits fixed point representation

S - E	 - M
1 - 15 - 16

*/


module compute_weights(clk,rst,x0,x1,xp0,xp1,w0,w1,done_cw);

	parameter N = 32;
	parameter Q = 16;
	input clk,rst;
	input [N-1:0] x0,x1,xp0,xp1;
	output reg [N-1:0] w0,w1;
	output reg done_cw;
	
	wire [N-1:0] w0_s1,w1_s1,w0_s2,w1_s2,w0_s3,w1_s3,w0_s4,w1_s5,w1_s6,w0_s7,w1_s7,add1,add2,add3;
	wire lt1,lt2,lt3,lt4,lt5,gt1;
	
	parameter w_0 = 32'b0_00000_00000_11110__0000_0000_0000_0000;   // 30
	parameter w_1 = 32'b0_00000_00000_00001__0000_0000_0000_0000;   // 1

	// states
	reg [3:0] state,next_state;
	localparam START = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, S4 = 4'd4, S5 = 4'd5, S6 = 4'd6, S7 = 4'd7,
				  DONE = 4'd8;  

//S1
qmult	#(Q,N) mult1(w_0,32'b0_00000_00000_00000_1001_1001_1001_1001, w0_s1);  //0.6
qmult	#(Q,N) mult2(w_1,32'b0_00000_00000_00000_0100_1100_1100_1100, w1_s1);  //0.3
//S2
qmult	#(Q,N) mult3(w0, 32'b0_00000_00000_00000_0100_1100_1100_1100,w0_s2);  //0.3
qmult	#(Q,N) mult4(w1, 32'b0_00000_00000_00000_0100_1100_1100_1100,w1_s2);  //0.3
//S3
qmult	#(Q,N) mult5(w0, 32'b0_00000_00000_00010_0000_0000_0000_0000,w0_s3);  //2
qmult	#(Q,N) mult6(w1, 32'b0_00000_00000_00001_1000_0000_0000_0000,w1_s3);  //1.5
//S4
qmult	#(Q,N) mult7(w0, 32'b0_00000_00000_00000_1000_0000_0000_0000,w0_s4);  //0.5
//S5
qmult	#(Q,N) mult8(w1, 32'b0_00000_00000_00000_1000_0000_0000_0000,w1_s5);  //0.5
//S6
qmult	#(Q,N) mult9(w1, 32'b0_00000_00000_00000_1000_0000_0000_0000,w1_s6);  //0.5
//S7
qmult	#(Q,N) mult10(w0, w0, w0_s7);  //0.5
qmult	#(Q,N) mult11(w1, w1, w1_s7);  //0.5

// conditions inside if statements
fplessthan #(Q,N) fplt1 (x1,32'b0,lt1);   												// x1 < 0
fplessthan #(Q,N) fplt2 (x1,32'b1_00000_00000_01010_0000000000000000,lt2);  	// x1 < -10

qadd #(Q,N) qadd1(x0,{(xp0[N-1] == 0)?1'b1:1'b0,xp0[N-2:0]},add1); 				// x0 - xp0
qadd #(Q,N) qadd2(xp1,32'b1_00000_00000_01010_0000000000000000,add2);  			// xp1 - 10
qadd #(Q,N) qadd3(xp1,32'b1_00000_00000_10100_0000000000000000,add3);  			// xp1 - 20

fplessthan #(Q,N) fplt3 (add1,32'b0_000000000000000_0011001100110011,lt3);		// x0 - xp0 < 0.2
fplessthan #(Q,N) fplt4 (x1,add2,lt4);														// x1 < xp1 - 10
fplessthan #(Q,N) fplt5 (x1,add3,lt5);														// x1 < xp1 - 20

fpgreaterthan #(Q,N) fpgt1 (add1,32'b0_00000_00000_00000_1000_0000_0000_0000,gt1);	// x0 - xp0 > 0.5



// ------------------Update state--------------------------------------------------------------------//
always@(posedge clk or negedge rst) 
begin
	if(!rst) begin
		state <= START;
	end	
	else begin 
		state <= next_state;
	end
	
end
//---------------------------------------------------------------------------------------------------//


//--------------Compute next state-------------------------------------------------------------------//
always@(*) 
begin
	next_state  = state;
   case(state)
		START: 
			begin
				if(lt1) begin
					next_state = S1;
				end
				else if(lt3 && !lt1) begin
					next_state = S3;
				end
				else if(gt1 && !lt1) begin
					next_state = S4;
				end
				else if(lt4) begin
					next_state = S5;
				end
				else begin
					next_state = S7;
				end
			end			 
		S1: 
			begin
				if(lt2) begin
					next_state = S2;
				end
				else if(lt3 && !lt2) begin
					next_state = S3;
				end
				else if(gt1 && !lt2) begin
					next_state = S4;
				end
				else if(lt4) begin
					next_state = S5;
				end
				else begin
					next_state = S7;
				end
			end
		S2:
			begin
				if(lt3) begin
					next_state = S3;
				end	
				else if(gt1) begin
					next_state = S4;
				end
				else if(lt4) begin
					next_state = S5;
				end
				else begin
					next_state = S7;
				end
			end
		S3:
			begin
				if(lt4) begin
					next_state = S5;
				end
				else begin
					next_state = S7;
				end
			end
		S4:
			begin
				if(lt4) begin
					next_state = S5;
				end
				else begin
					next_state = S7;
				end
			end
		S5:
			begin
				if(lt5) begin
					next_state = S6;
				end
				else begin
					next_state = S7;
				end
			end
		S6:
			begin
					next_state = S7;
			end
		S7:
			begin
				next_state = DONE;
			end
		DONE : 
			begin
				next_state = DONE;
			end
			endcase

end
//-------------------------------------------------------------------------------------------------//


//--------------Compute Output---------------------------------------------------------------------//
always@(posedge clk or negedge rst)
begin

	if(!rst)
		begin
			w0 <= 32'b0;
			w1 <= 32'b0;
			done_cw <= 1'b0;
		end
		
	else 
	begin
		case(state)
		START:
			begin
				w0 <= w_0;
				w1 <= w_1;
				done_cw <= 1'b0;
			end
		S1: 
			begin
				w0 <= w0_s1;
				w1 <= w1_s1;
			end
		S2: 
			begin
				w0 <= w0_s2;
				w1 <= w1_s2;
			end
		S3: 
			begin
				w0 <= w0_s3;
				w1 <= w1_s3;
			end
		S4: 
			begin
				w0 <= w0_s4;
			end
		S5: 
			begin
				w1 <= w1_s5;
			end
		S6: 
			begin
				w1 <= w1_s6;
			end
		S7: 
			begin
				w0 <= w0_s7;
				w1 <= w1_s7;
				done_cw <= 1'b1;
			end
		DONE: 
			begin
				done_cw <= 1'b1;
			end
	endcase 
	end
end


// -----------------------------------------------------------------------------------------------//

endmodule