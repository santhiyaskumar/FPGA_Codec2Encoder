/*
* Module         - hs_pitch_refinement
* Top module     - two_stage_pitch_refinement
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Thu Apr 11 10:57:04 2019
*
* Description    -
* Inputs         -
* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module hs_pitch_refinement (starthpr,clk,rst,Wo_in,L,pmin,pmax,pstep,out_real,out_imag,Wo_out,addr_real,addr_imag,
							m1_in1,m1_in2,m1_out,
							m2_in1,m2_in2,m2_out,
							donehpr);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,starthpr;
			input [N-1:0] Wo_in,pmin,pmax,pstep,out_real,out_imag,m1_out,m2_out;
			input [9:0] L; 
			output reg [N-1:0] Wo_out,m1_in1,m1_in2,m2_in1,m2_in2;
			output reg [9:0] addr_real,addr_imag;
			output reg donehpr;
			

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 5'd4,
			 INIT_FOR = 5'd1,
			 PRE_CHECK_P = 5'd2,
          CHECK_P = 5'd5,
          START_FOR = 5'd6,
          CALC_WO_1 = 5'd7,
          CALC_WO_2 = 5'd8,
          CALC_WO_FINAL = 5'd9,
          INIT_FOR_2 = 5'd10,
          CHECK_M = 5'd11,
          CALC_B_1 = 5'd12,
          CALC_B_2 = 5'd13,
          CALC_B_3 = 5'd14,
          CALC_B_FINAL = 5'd15,
          SET_ADDR_SW = 5'd16,
          SET_DELAY_1 = 5'd17,
          SET_DELAY_2 = 5'd18,
          SET_DATA_SW = 5'd19,
          CALC_E_1 = 5'd20,
          CALC_E_2 = 5'd21,
          CALC_E_FINAL = 5'd22,
          INCR_M = 5'd23,
          SET_GT = 5'd24,
          CHECK_GT = 5'd25,
          INCR_P = 5'd26,
          SET_WO = 5'd27,
          DONE = 5'd28,
			 PRE_INCR_P = 5'd3;
			 

reg [4:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
parameter [N-1:0] 		POINT_FIVE = 32'b0_000000000000000_1000000000000000,
						ONE_ON_R = 32'b00000000010100010111110011000001,
						PI = 32'b00000000000000110010010000111111,
						TWO_PI = 32'b00000000000001100100100001111110;

						

reg 	[N-1:0] 	one_by_Wo,Wom,Wo,E;
reg 	[9:0]    m;
reg [9:0] b;
reg [N-1:0] Em,p;
reg 	[N-1:0] 	a1_in1,a1_in2,a2_in1,a2_in2;
wire 	[N-1:0] 	a1_out,a2_out;

reg 				startdiv;
reg 	[N-1:0] 	div_in,lt1_in1,lt1_in2,gt1_in1,gt1_in2;
wire	[N-1:0]	div_ans;
wire				donediv,lt1,gt1;

//qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1   	(a1_in1,a1_in2,a1_out);

//qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2   	(a2_in1,a2_in2,a2_out);

fpdiv_clk  	  						divider1	   (startdiv,clk,rst,div_in,div_ans,donediv);
fpgreaterthan	#(Q,N)    		fpgt1      	(gt1_in1,gt1_in2,gt1);
fplessthan 		#(Q,N)			fplt1			(lt1_in1,lt1_in2,lt1);	


//RAM_Sw_real   						swram			(addr_real,clk,,1,0,out_real);
//RAM_Sw_imag   						swimag		(addr_imag,clk,,1,0,out_imag);


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
		if(starthpr == 1'b1)
		begin
			NEXT_STATE = INIT;
		end
		else
		begin
			NEXT_STATE = START;
		end;

	end

	/* CALC_ONE_BY_WO:
	begin
		NEXT_STATE = START_DIV;
	end

	START_DIV:
	begin
		if(donediv == 1'b1)
		begin
			NEXT_STATE = CALC_ONE_BY_WO_FINAL;
		end
		else
		begin
			NEXT_STATE = START_DIV;
		end
	end

	CALC_ONE_BY_WO_FINAL:
	begin
		NEXT_STATE = INIT;
	end */

	INIT:
	begin
		NEXT_STATE = INIT_FOR;
	end
	
	INIT_FOR:
	begin
		NEXT_STATE = PRE_CHECK_P;
	end
	
	PRE_CHECK_P:
	begin
		NEXT_STATE = CHECK_P;
	end

	CHECK_P:
	begin
		if(lt1 || (p == pmax))
		begin
			NEXT_STATE = START_FOR;
		end
		else
		begin
			NEXT_STATE = SET_WO;
		end
	end

	START_FOR:
	begin
		NEXT_STATE = CALC_WO_1;
	end

	CALC_WO_1:
	begin
		if(donediv == 1'b1)
		begin
			NEXT_STATE = CALC_WO_2;
		end
		else
		begin
			NEXT_STATE = CALC_WO_1;
		end
	end

	CALC_WO_2:
	begin
		NEXT_STATE = CALC_WO_FINAL;
	end

	CALC_WO_FINAL:
	begin
		NEXT_STATE = INIT_FOR_2;
	end

	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_M;
	end
	

	CHECK_M:
	begin
		if(m <= L)
		begin
			NEXT_STATE = CALC_B_1;
		end
		else
		begin
			NEXT_STATE = SET_GT;
		end
	end

	CALC_B_1:
	begin
		NEXT_STATE = CALC_B_2;
	end

	CALC_B_2:
	begin
		NEXT_STATE = CALC_B_3;
	end

	CALC_B_3:
	begin
		NEXT_STATE = CALC_B_FINAL;
	end

	CALC_B_FINAL:
	begin
		NEXT_STATE = SET_ADDR_SW;
	end

	SET_ADDR_SW:
	begin
		NEXT_STATE = SET_DELAY_1;
	end

	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end

	SET_DELAY_2:
	begin
		NEXT_STATE = SET_DATA_SW;
	end

	SET_DATA_SW:
	begin
		NEXT_STATE = CALC_E_1;
	end

	CALC_E_1:
	begin
		NEXT_STATE = CALC_E_2;
	end

	CALC_E_2:
	begin
		NEXT_STATE = CALC_E_FINAL;
	end

	CALC_E_FINAL:
	begin
		NEXT_STATE = INCR_M;
	end

	INCR_M:
	begin
		NEXT_STATE = CHECK_M;
	end

	SET_GT:
	begin
		NEXT_STATE = CHECK_GT;
	end

	CHECK_GT:
	begin
		NEXT_STATE = PRE_INCR_P;
	end
	
	PRE_INCR_P:
	begin
		NEXT_STATE = INCR_P;
	end

	INCR_P:
	begin
		NEXT_STATE = PRE_CHECK_P;
	end

	SET_WO:
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
		donehpr <= 1'b0;
	end

	else
	begin
		case(STATE)

		START:
		begin
			donehpr <= 1'b0;
		end

		/* CALC_ONE_BY_WO:
		begin
			startdiv <= 1'b1;
		end

		START_DIV:
		begin
			div_in <= Wo;
		end

		CALC_ONE_BY_WO_FINAL:
		begin
			one_by_Wo <= div_ans;
			startdiv <= 1'b0;
		end */

		INIT:
		begin
			Wom <= Wo_in;
			Em  <= 32'b0; 
		end
		
		INIT_FOR:
		begin
			p <= pmin; 
		end
		
		PRE_CHECK_P:
		begin
			lt1_in1 <= p;
			lt1_in2 <= pmax;
		end

		CHECK_P:
		begin
			
		end

		START_FOR:
		begin
			E <= 32'b0;
			startdiv <= 1'b1;
		end

		CALC_WO_1:
		begin
			div_in <= p;
		end

		CALC_WO_2:
		begin
			m1_in1 <= div_ans;
			m1_in2 <= TWO_PI;
			startdiv <= 1'b0;
		end

		CALC_WO_FINAL:
		begin
			Wo <= m1_out;
		end

		INIT_FOR_2:
		begin
			m <= 9'b1;
		end

		CHECK_M:
		begin
			
		end

		CALC_B_1:
		begin
			m1_in1 <= {6'b0,m,16'b0};
			m1_in2 <= Wo;
		end

		CALC_B_2:
		begin
			m2_in1 <= ONE_ON_R;
			m2_in2 <= m1_out;
		end

		CALC_B_3:
		begin
			a1_in1 <= POINT_FIVE;
			a1_in2 <= m2_out;
		end

		CALC_B_FINAL:
		begin
			b <= a1_out[25:16];
		end

		SET_ADDR_SW:
		begin
			addr_real <= b;
			addr_imag <= b;
		end

		SET_DELAY_1:
		begin
			
		end

		SET_DELAY_2:
		begin
			
		end

		SET_DATA_SW:
		begin
			m1_in1 <= out_real;
			m1_in2 <= out_real;
			m2_in1 <= out_imag;
			m2_in2 <= out_imag;
		end

		CALC_E_1:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= m2_out;
		end

		CALC_E_2:
		begin
			a1_in1 <= a1_out;
			a1_in2 <= E;
		end

		CALC_E_FINAL:
		begin
			E <= a1_out;
			//check_E <= a1_out;
		end

		INCR_M:
		begin
			m <= m + 10'd1;
		end

		SET_GT:
		begin
			gt1_in1 <= E;
			gt1_in2 <= Em;
		end

		CHECK_GT:
		begin
			if(gt1)
			begin
				Em <= E;
				Wom <= Wo;
				//Wo_out <= Wo;
			end
			else
			begin
				Em <= Em;
				Wom <= Wom;
				//Wo_out <= Wom;
			end
		end
		
		PRE_INCR_P:
		begin
			a1_in1 <= p;
			a1_in2 <= pstep;
		end

		INCR_P:
		begin
			p <= a1_out;
		end

		SET_WO:
		begin
			Wo_out <= Wom;
		end

		DONE:
		begin
			donehpr <= 1'b1;
		end

		endcase
	end

end


endmodule