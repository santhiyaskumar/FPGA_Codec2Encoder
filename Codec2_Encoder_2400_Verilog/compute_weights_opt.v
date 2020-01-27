/*
* Module 		- compute_weights_opt
* Top module	- encode_WoE
* CODEC2_ENCODE_2400

Description: Compute w[0] and w[1]
Inputs : x[2], xq[2], clk, rst
Optimised version of compute_weights. Uses only 2 multipliers.

*32 bits fixed point representation

S - E	 - M
1 - 15 - 16

*/
module compute_weights_opt(startcw,clk,rst,x0,x1,xp0,xp1,w0,w1,donecw);

	parameter N = 32;
	parameter Q = 16;
	input startcw;
	input clk,rst;
	input [N-1:0] x0,x1,xp0,xp1;
	output reg [N-1:0] w0,w1;
	output reg donecw;
	
	reg [N-1:0] a0,b0,a1,b1;
	wire [N-1:0] add1,add2,add3,w0_out,w1_out;
	wire lt1,lt2,lt3,lt4,lt5,gt1;
	
	parameter w_0 = 32'b0_00000_00000_11110__0000_0000_0000_0000;   // 30
	parameter w_1 = 32'b0_00000_00000_00001__0000_0000_0000_0000;   // 1

	// states
	reg [3:0] state,next_state;
	localparam START = 4'd0, 
					INIT = 4'd1,
					S1 = 4'd2, 
					S2 = 4'd3, 
					S3 = 4'd4, 
					S4 = 4'd5, 
					S5 = 4'd6,
					S6 = 4'd7, 
					S7 = 4'd8,
				  DONE = 4'd9;  

//S1
qmult	#(Q,N) mult1(a0,b0, w0_out);  //0.6
qmult	#(Q,N) mult2(a1,b1, w1_out);  //0.3


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
			if(startcw == 1'b1)
			begin
				next_state = INIT;
			end
			else 
			begin
				next_state = START;
			end
		
		end
		INIT: 
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
				next_state = START;
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
			donecw <= 1'b0;
		end
		
	else 
	begin
		case(state)
		START:
			begin
				w0 <= w_0;
				w1 <= w_1;
				a0 <= w_0;
				a1 <= w_1;
				if(lt1) 
				begin
					b0 <= 32'b0_00000_00000_00000_1001_1001_1001_1001;
					b1 <= 32'b0_00000_00000_00000_0100_1100_1100_1100;
				end
				else if(lt3 && !lt1) 
				begin
					b0 <= 32'b0_00000_00000_00010_0000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_1000_0000_0000_0000;
				end
				else if(gt1 && !lt1) 
				begin
					b0 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else if(lt4) 
				begin
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w_0;
					b1 <= w_1;
				end
				donecw <= 1'b0;
			end
		S1: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				if(lt2) 
				begin
					b0 <= 32'b0_00000_00000_00000_0100_1100_1100_1100;
					b1 <= 32'b0_00000_00000_00000_0100_1100_1100_1100;
				end
				else if(lt3 && !lt2) 
				begin
					b0 <= 32'b0_00000_00000_00010_0000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_1000_0000_0000_0000;
				end
				else if(gt1 && !lt2) 
				begin
					b0 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else if(lt4) 
				begin
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w0_out;
					b1 <= w1_out;
				end
			end
		S2: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				if(lt3) 
				begin
					b0 <= 32'b0_00000_00000_00010_0000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_1000_0000_0000_0000;
				end	
				else if(gt1) 
				begin
					b0 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b1 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else if(lt4) 
				begin
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w0_out;
					b1 <= w1_out;
				end
			end
		S3: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				if(lt4) 
				begin
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w0_out;
					b1 <= w1_out;
				end
			end
		S4: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				if(lt4) 
				begin
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w0_out;
					b1 <= w1_out;
				end
			end
		S5: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				if(lt5) 
				begin
					b1 <= 32'b0_00000_00000_00000_1000_0000_0000_0000;
					b0 <= 32'b0_00000_00000_00001_0000_0000_0000_0000;
				end
				else 
				begin
					b0 <= w0_out;
					b1 <= w1_out;
				end
			end
		S6: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				a0 <= w0_out;
				a1 <= w1_out;
				b0 <= w0_out;
				b1 <= w1_out;
			end
		S7: 
			begin
				w0 <= w0_out;
				w1 <= w1_out;
				donecw <= 1'b1;
			end
		DONE: 
			begin
				donecw <= 1'b1;
			end
	endcase 
	end
end


// -----------------------------------------------------------------------------------------------//

endmodule