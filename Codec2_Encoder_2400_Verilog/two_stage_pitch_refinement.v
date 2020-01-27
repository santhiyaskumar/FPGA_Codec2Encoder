/*
* Module         - two_stage_pitch_refinement
* Top module     - analyse_one_frame
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Apr 17 14:06:36 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform57.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

/*
	Inputs :
	c2const->p_max :: 160
	c2const->p_min:: 20
	L_in :: 31
	Wo_in :: 0.100629
*/

  module two_stage_pitch_refinement (starttspr,clk,rst,Wo_in,L_in,out_real,out_imag,
								           Wo_out,L_out,addr_real,addr_imag,
										   //m1_in1,m1_in2,m1_out,
										   //m2_in1,m2_in2,m2_out,
										   donetspr,c_w0,c_w1);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,starttspr;
			input [N-1:0] Wo_in,out_real,out_imag;//m1_out,m2_out;
			input [9:0] L_in; 
			output reg [N-1:0] Wo_out,L_out,c_w0,c_w1;//m1_in1,m1_in2,m2_in1,m2_in2;
			output reg [9:0] addr_real,addr_imag;
			output reg donetspr;
			

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 5'd1,
          INIT_PMAX_PMIN = 5'd2,
          CALC_1_PMAX_1 = 5'd3,
          CALC_1_PMAX_2 = 5'd4,
          SET_PMAX_PMIN = 5'd5,
          SET_HPR_1 = 5'd6,
          CALC_ONE_BY_WO_2 = 5'd7,
          GET_ONE_BY_WO_2 = 5'd8,
          CALC_2_PMAX_1 = 5'd9,
          CALC_2_PMAX_2 = 5'd10,
          SET_2_PMAX_PMIN = 5'd11,
          SET_HPR_2 = 5'd12,
          START_DIV_12 = 5'd13,
          CALC_DIV_12 = 5'd14,
          SET_IF = 5'd15,
          CHECK_IF = 5'd16,
          SET_WO_OUT_FROM_IF = 5'd17,
          START_DIV_WO = 5'd18,
          CALC_ONE_BY_WO_3 = 5'd19,
          CALC_L_OUT = 5'd20,
          SET_L_OUT = 5'd21,
          CHECK_IF_1 = 5'd22,
          CHECK_IF_2 = 5'd23,
          SET_IF_2 = 5'd24,
          DONE = 5'd25;

reg [4:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N-1:0] 		POINT_FIVE = 32'b0_000000000000000_1000000000000000,
						PI = 32'b00000000000000110010010000111111,
						TWO_PI = 32'b00000000000001100100100001111110,
						FIVE = 32'b0_000000000000101_0000000000000000,
						NEG_FIVE = 32'b1_000000000000101_0000000000000000,
						ONE = 32'b0_000000000000001_0000000000000000,
						NEG_ONE = 32'b1_000000000000001_0000000000000000,
						POINT_TWO_FIVE = 32'b0_000000000000000_0100000000000000,
						K = 32'b00000000000000101111110000001001,
						ONE_BY_PMAX = 32'b00000000000000000000000110011001, // 1/160
						ONE_BY_PMIN = 32'b00000000000000000000110011001100; // 1/20
						
						
reg 	[N-1:0] 	one_by_Wo_1,one_by_Wo_2,one_by_Wo_3;
reg 	[N-1:0] 	pmax,pmin,pstep;

reg [N-1:0] div1_in,div2_in;
reg startdiv1,startdiv2;

wire donediv1,donediv2;
wire [N-1:0] div1_ans,div2_ans;

reg 	[N-1:0] 	a1_in1,a1_in2,a2_in1,a2_in2,lt1_in1,lt1_in2,gt1_in1,gt1_in2;
wire 	[N-1:0] 	a1_out,a2_out; 
wire 	lt1,gt1;

reg [9:0] hp_L,hp_L_2;
reg [N-1:0]  hp_Wo_in,hp_pmin,hp_pmax,hp_pstep,hp_Wo_out_2,
				 hp_Wo_in_2,hp_pmin_2,hp_pmax_2,hp_pstep_2,hp_Wo_out_2_in;
wire [N-1:0] hp_Wo_out,hp2_Wo_out;
reg starthpr,starthpr2;
wire donehpr,donehpr2;

wire [9:0] hs_addr_real,hs_addr_imag,hs2_addr_real,hs2_addr_imag;

//reg [N-1:0] one_by_pmax, one_by_pmin;

reg [N-1:0] m1_in1,m1_in2,m2_in1,m2_in2;
wire [N-1:0] m1_out,m2_out;

fpdiv_clk  	  					divider1	   (startdiv1,clk,rst,div1_in,div1_ans,donediv1);
fpdiv_clk  	  					divider2	   (startdiv2,clk,rst,div2_in,div2_ans,donediv2);

qmult  			#(Q,N) 			qmult1	 	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1   	   (a1_in1,a1_in2,a1_out);

qmult  			#(Q,N) 			qmult2	   	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2   	   (a2_in1,a2_in2,a2_out);

fpgreaterthan	#(Q,N)    		fpgt1          (gt1_in1,gt1_in2,gt1);
fplessthan 		#(Q,N)			fplt1		   (lt1_in1,lt1_in2,lt1);	

hs_pitch_refinement hpr1 (starthpr,clk,rst,hp_Wo_in,hp_L,hp_pmin,hp_pmax,hp_pstep,out_real,out_imag,hp_Wo_out,hs_addr_real,hs_addr_imag,
							hp1_m1_in1,hp1_m1_in2,hp1_m1_out,
							hp1_m2_in1,hp1_m2_in2,hp1_m2_out,
							donehpr);
hs_pitch_refinement hpr2 (starthpr2,clk,rst,hp_Wo_in_2,hp_L_2,hp_pmin_2,hp_pmax_2,hp_pstep_2,out_real,out_imag,hp2_Wo_out,hs2_addr_real,hs2_addr_imag,
							hp2_m1_in1,hp2_m1_in2,hp2_m1_out,
							hp2_m2_in1,hp2_m2_in2,hp2_m2_out,
							donehpr2);

reg [N-1:0] hp1_m1_out, hp1_m2_out,hp2_m1_out,hp2_m2_out;
wire [N-1:0] hp1_m1_in1,hp1_m1_in2,hp1_m2_in1,hp1_m2_in2,hp2_m1_in1,hp2_m1_in2,hp2_m2_in1,hp2_m2_in2;
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
		if(starttspr == 1'b1)
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
		if(donediv1 == 1'b1)
		begin
			NEXT_STATE = INIT_PMAX_PMIN;
		end
		else
		begin
			NEXT_STATE = INIT;
		end	
		
	end

	INIT_PMAX_PMIN:
	begin
		NEXT_STATE = CALC_1_PMAX_1;
	end

	CALC_1_PMAX_1:
	begin
		NEXT_STATE = CALC_1_PMAX_2;
	end

	CALC_1_PMAX_2:
	begin
		NEXT_STATE = SET_PMAX_PMIN;
	end

	SET_PMAX_PMIN:
	begin
		NEXT_STATE = SET_HPR_1;
	end

	SET_HPR_1:
	begin
		if(donehpr == 1'b1)
		begin
				NEXT_STATE = CALC_ONE_BY_WO_2;
		end
		else
		begin
				NEXT_STATE = SET_HPR_1;
		end
		
	end

	CALC_ONE_BY_WO_2:
	begin
		if(donediv1)
		begin
			NEXT_STATE = GET_ONE_BY_WO_2;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_WO_2;
		end
	end

	GET_ONE_BY_WO_2:
	begin
		NEXT_STATE = CALC_2_PMAX_1;
	end

	CALC_2_PMAX_1:
	begin
		NEXT_STATE = CALC_2_PMAX_2;
	end

	CALC_2_PMAX_2:
	begin
		NEXT_STATE = SET_2_PMAX_PMIN;
	end

	SET_2_PMAX_PMIN:
	begin
		NEXT_STATE = SET_HPR_2;
	end

	SET_HPR_2:
	begin
		if(donehpr2 == 1'b1)
		begin
				NEXT_STATE = SET_IF;
		end
		else
		begin
				NEXT_STATE = SET_HPR_2;
		end
	end

//	START_DIV_12:
//	begin
//		if(donediv1 && donediv2)
//		begin
//			NEXT_STATE = DONE;
//		end
//		else
//		begin
//			NEXT_STATE = START_DIV_12;
//		end
//	end
//
//	CALC_DIV_12:
//	begin
//		NEXT_STATE = SET_IF;
//	end

	SET_IF:
	begin
		NEXT_STATE = CHECK_IF;
	end

	CHECK_IF:
	begin
		NEXT_STATE = SET_WO_OUT_FROM_IF;
	end

	SET_WO_OUT_FROM_IF:
	begin
		NEXT_STATE = START_DIV_WO;
	end

	START_DIV_WO:
	begin
		if(donediv1)
		begin
			NEXT_STATE = CALC_ONE_BY_WO_3;
		end
		else
		begin
			NEXT_STATE = START_DIV_WO;
		end
		
	end

	CALC_ONE_BY_WO_3:
	begin
		NEXT_STATE = CALC_L_OUT;
	end

	CALC_L_OUT:
	begin
		NEXT_STATE = SET_L_OUT;
	end

	SET_L_OUT:
	begin
		NEXT_STATE = CHECK_IF_1;
	end

	CHECK_IF_1:
	begin
		NEXT_STATE = CHECK_IF_2;
	end

	CHECK_IF_2:
	begin
		NEXT_STATE = SET_IF_2;
	end

	SET_IF_2:
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

		donetspr <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donetspr <= 1'b0;
			
		end

		INIT:
		begin
			startdiv1 <= 1'b1;
			div1_in   <=  Wo_in;	
		end

		INIT_PMAX_PMIN:
		begin
			one_by_Wo_1 <= div1_ans;
			startdiv1 <= 1'b0;
		end

		CALC_1_PMAX_1:
		begin
			m1_in1 <= TWO_PI;
			m1_in2 <= one_by_Wo_1;
		end

		CALC_1_PMAX_2:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= FIVE;
			a2_in1 <= m1_out;
			a2_in2 <= NEG_FIVE;
		end

		SET_PMAX_PMIN:
		begin
			pmax <= a1_out;
			pmin <= a2_out;
			pstep <= ONE;
			starthpr <= 1'b1;
			m1_in1 <= hp1_m1_in1;
			m1_in2 <= hp1_m1_in2;
			m2_in1 <= hp1_m2_in1;
			m2_in2 <= hp1_m2_in2;
		end

		SET_HPR_1:
		begin
			
			hp_Wo_in <= Wo_in;
			hp_L <= L_in;
			hp_pmin <= pmin;
			hp_pmax <= pmax;
			hp_pstep <= pstep;
			addr_real <= hs_addr_real;
			addr_imag <= hs_addr_imag;
			starthpr <= 1'b0;
			startdiv1 <= 1'b1;
			hp1_m1_out <= m1_out;
			hp1_m2_out <= m2_out;
			
		end

		CALC_ONE_BY_WO_2:
		begin
			startdiv1 <= 1'b0;
			div1_in <= hp_Wo_out;
			hp_Wo_out_2_in <= hp_Wo_out;
			starthpr <= 1'b0;
		end

		GET_ONE_BY_WO_2:
		begin
			one_by_Wo_2 <= div1_ans;
			
		end

		CALC_2_PMAX_1:
		begin
			m1_in1 <= TWO_PI;
			m1_in2 <= one_by_Wo_2;
		end

		CALC_2_PMAX_2:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= FIVE;
			a2_in1 <= m1_out;
			a2_in2 <= NEG_FIVE;
		end

		SET_2_PMAX_PMIN:
		begin
			pmax <= a1_out;
			pmin <= a2_out;
			pstep <= POINT_TWO_FIVE;
			starthpr2 <= 1'b1;
			m1_in1 <= hp2_m1_in1;
			m1_in2 <= hp2_m1_in2;
			m2_in1 <= hp2_m2_in1;
			m2_in2 <= hp2_m2_in2;
		end

		SET_HPR_2:
		begin
			
			hp_Wo_in_2 <= hp_Wo_out_2_in;
			hp_L_2 <= L_in;
			hp_pmax_2 <= pmax;
			hp_pmin_2 <= pmin;
			hp_pstep_2 <= pstep;
			addr_real <= hs2_addr_real;
			addr_imag <= hs2_addr_imag;
			starthpr2 <= 1'b0;
			
			hp2_m1_out <= m1_out;
			hp2_m2_out <= m2_out;
			
		end

//		START_DIV_12:
//		begin
//			starthpr <= 1'b0;
//			startdiv1 <= 1'b1;
//			startdiv2 <= 1'b1;
//			div1_in <= c2_const_pmax;
//			div2_in <= c2_const_pmin;
//			check_hp2_Wo_out <= hp_Wo_out;
//			check_sig <= 4'd5;
//		end
//
//		CALC_DIV_12:
//		begin
//			one_by_pmax <= div1_ans;
//			one_by_pmin <= div2_ans;
//			startdiv1 <= 1'b0;
//			startdiv2 <= 1'b0;
//		end

		SET_IF:
		begin
			m1_in1 <= TWO_PI;
			m1_in2 <= ONE_BY_PMAX;
			m2_in1 <= TWO_PI;
			m2_in2 <= ONE_BY_PMIN;
			
			hp_Wo_out_2 <= hp2_Wo_out;
			
		end

		CHECK_IF:
		begin
			lt1_in1 <= hp_Wo_out_2;
			lt1_in2 <= m1_out;
			
			gt1_in1 <= hp_Wo_out_2;
			gt1_in2 <= m2_out;
			c_w0 <= m1_out;
			c_w1 <= m2_out;
		end

		SET_WO_OUT_FROM_IF:
		begin
			if(lt1)
			begin
				Wo_out <= m1_out;
			end
			else
			begin
				Wo_out <= hp_Wo_out_2;
			end
			
			if(gt1)
			begin
				Wo_out <= m2_out;
			end
			else
			begin
				Wo_out <= hp_Wo_out_2;
			end
			startdiv1 <= 1'b1;
		end

		START_DIV_WO:
		begin
			startdiv1 <= 1'b0;
			div1_in <= Wo_out;
		end

		CALC_ONE_BY_WO_3:
		begin
			one_by_Wo_3 <= div1_ans;
			
		end

		CALC_L_OUT:
		begin
			m1_in1 <= PI;
			m1_in2 <= one_by_Wo_3;
		end

		SET_L_OUT:
		begin
			L_out <= {m1_out[31:16],16'b0};
		end

		CHECK_IF_1:
		begin
			m1_in1 <= Wo_out;
			m1_in2 <= L_out;
		end

		CHECK_IF_2:
		begin
			gt1_in1 <= m1_out;
			gt1_in2 <= K;
			
			a1_in1 <=  L_out;
			a1_in2 <= NEG_ONE;
		end

		SET_IF_2:
		begin
			if(gt1 || (m1_out == K))
			begin
				L_out <= a1_out;
			end
			else
			begin
				L_out <= L_out;
			end
		end

		DONE:
		begin
			donetspr <= 1'b1;
			
		end

		endcase
	end

end


endmodule