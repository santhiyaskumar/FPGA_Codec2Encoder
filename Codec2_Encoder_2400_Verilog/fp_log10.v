/*
* Module         - fp_log10
* Top module     - encode_WoE
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Mon Feb 25 16:28:11 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform42.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/



module fp_log10 (startlog,clk,rst,in_x,out_y,donelog);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
	parameter N = 32;
	parameter Q = 16;
	input startlog, clk, rst;
	input [N-1:0] in_x;
	output reg [N-1:0] out_y;
	output reg donelog;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 5'd1,
          CHECK_IFS = 5'd2,
          IF1_1 = 5'd3,
          SET_Y = 5'd4,
          IF2_1 = 5'd5,
          SET_WHILE = 5'd6,
			 CHECK_WHILE = 5'd7,
          SQ_X = 5'd8,
          SET_SQ_X = 5'd9,
          IF_3_CHECK = 5'd10,
          SET_X_Y = 5'd11,
          SET_B = 5'd12,
          DECR_C = 5'd13,
          CHECK_C = 5'd14,
          LOG10_CALC = 5'd15,
          SET_OUT_Y = 5'd16,
          DONE = 5'd17;

reg [4:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N-1:0] NUMBER_TWO = 32'b00000000000000100000000000000000,
				  NUMBER_ONE = 32'b00000000000000010000000000000000,
				  NUMBER_POINT_FIVE = 32'b00000000000000001000000000000000,
				  NUMBER_NEG_ONE = 32'b10000000000000010000000000000000,
				  LOG2 = 32'b00000000000000000100110100010000;

				  
reg [N-1:0] x,y,b;
reg [4:0] count;

reg [N-1:0] lt1_in1, lt1_in2, gt1_in1, gt1_in2, add1_in1, add1_in2, mult1_in1, mult1_in2;
wire [N-1:0] add1_out, mult1_out;
wire lt1,gt1;



fplessthan		#(Q,N)	 fplt1 (lt1_in1,lt1_in2,lt1);
fpgreaterthan	#(Q,N)    fpgt1 (gt1_in1,gt1_in2,gt1);
qadd 				#(Q,N)	 qadd1 (add1_in1,add1_in2,add1_out);
qmult				#(Q,N)    qmult1(mult1_in1, mult1_in2, mult1_out);
 


//------------------------------------------------------------------
//                 -- Begin Declarations & Coding --                  
//------------------------------------------------------------------

always@(posedge clk or negedge rst)     // Determine STATE
begin

	if (rst == 1'b0)
		STATE <= START;
	else
		STATE <= NEXT_STATE;

end


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		if(startlog)
		begin
			NEXT_STATE = INIT;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end

	INIT:
	begin
		NEXT_STATE = CHECK_IFS;
	end

	CHECK_IFS:
	begin
		if(lt1)
		begin
			NEXT_STATE = IF1_1;
		end
		else if(!lt1 && (gt1 || (x == NUMBER_TWO)))
		begin
			NEXT_STATE = IF2_1;
		end
		else
		begin
			NEXT_STATE = SET_WHILE;
		end
		
	end

	IF1_1:
	begin
		NEXT_STATE = SET_Y;
	end

	SET_Y:
	begin
		NEXT_STATE = SET_WHILE;
	end

	IF2_1:
	begin
		NEXT_STATE = SET_Y;
	end


	SET_WHILE:
	begin
		NEXT_STATE = CHECK_WHILE;
	end

	CHECK_WHILE:
	begin
		if(!((gt1 || (x == NUMBER_ONE)) && (lt1)))
		begin
			NEXT_STATE = CHECK_IFS;
		end
		else
		begin
			NEXT_STATE = SQ_X;
		end
	end
	
	SQ_X:
	begin
		NEXT_STATE = SET_SQ_X;
	end

	SET_SQ_X:
	begin
		NEXT_STATE = IF_3_CHECK;
	end

	IF_3_CHECK:
	begin
		NEXT_STATE = SET_X_Y;
	end

	SET_X_Y:
	begin
		NEXT_STATE = SET_B;
	end

	SET_B:
	begin
		NEXT_STATE = DECR_C;
	end

	DECR_C:
	begin
		NEXT_STATE = CHECK_C;
	end

	CHECK_C:
	begin
		if(count == 5'd0)
		begin
			NEXT_STATE = LOG10_CALC;
		end
		else
		begin
			NEXT_STATE = SQ_X;
		end
	end

	LOG10_CALC:
	begin
		NEXT_STATE = SET_OUT_Y;
	end

	SET_OUT_Y:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = START;
	end

	default:
	begin
		NEXT_STATE = DONE;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		out_y <= 32'b0;
		donelog <= 0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donelog <= 1'b0;
		end

		INIT:
		begin
			y <= 32'b0;
			b <= NUMBER_POINT_FIVE;
			x <= in_x;
			count <= 5'd10;
			donelog <= 0;
		end

		CHECK_IFS:
		begin
			lt1_in1 <= x;
			lt1_in2 <= NUMBER_ONE;
			
			gt1_in1 <= x;
			gt1_in2 <= NUMBER_TWO;
		end

		IF1_1:
		begin
			x <= x << 1;
			add1_in1 <= y;
			add1_in2 <= NUMBER_NEG_ONE;
		end

		SET_Y:
		begin
			y <= add1_out;
		end

		IF2_1:
		begin
			x <= x >> 1;
			add1_in1 <= y;
			add1_in2 <= NUMBER_ONE;
		end

		SET_WHILE:
		begin
			lt1_in1 <= x;
			lt1_in2 <= NUMBER_TWO;
			
			gt1_in1 <= x;
			gt1_in2 <= NUMBER_ONE;
		end
		
		CHECK_WHILE:
		begin
		
		end

		SQ_X:
		begin
			mult1_in1 <= x;
			mult1_in2 <= x;
		end

		SET_SQ_X:
		begin
			x <= mult1_out;
		end

		IF_3_CHECK:
		begin
			gt1_in1 <= x;
			gt1_in2 <= NUMBER_TWO;
		end

		SET_X_Y:
		begin
			if(gt1 || (x == NUMBER_TWO))
			begin
				x <= x >> 1;
				add1_in1 <= y;
				add1_in2 <= b;
			end
		end

		SET_B:
		begin
			if(gt1 || (x == NUMBER_TWO))
			begin
				y <= add1_out;
			end
			b <= b >> 1;
		end

		DECR_C:
		begin
			count <= count - 5'd1;
		end

		CHECK_C:
		begin
			
		end

		LOG10_CALC:
		begin
			mult1_in1 <= y;
			mult1_in2 <= LOG2;
		end

		SET_OUT_Y:
		begin
			out_y <= mult1_out;
		end

		DONE:
		begin
			donelog <= 1'b1;
		end

		endcase
	end

end


endmodule