/*
* Module         - cossin_cordic
* Top module     - fft
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Sat May 11 18:34:58 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform60.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module cossin_cordic (startcossin,clk,rst,beta,cos,sin,donecossin,theta,c_theta,sig_check,c_fmod,c_in_1);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,startcossin;

			input [N-1:0] beta;
			output reg [N-1:0] cos,sin,c_theta,c_fmod,c_in_1;
			output reg donecossin;
			output reg [4:0] sig_check;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 6'd0,
          INIT = 6'd1,
          CHECK_IF = 6'd2,
          ANGLE_SHIFT_1 = 6'd3,
          ANGLE_SHIFT_2 = 6'd4,
          ANGLE_SHIFT_3 = 6'd5,
          ANGLE_SHIFT_4 = 6'd6,
          ANGLE_SHIFT_ELSE_1 = 6'd7,
          ANGLE_SHIFT_ELSE_2 = 6'd8,
          ANGLE_SHIFT_ELSE_3 = 6'd9,
          SET_THETA = 6'd10,
          CHECK_IF_2 = 6'd11,
          SET_THETA_1 = 6'd12,
          SET_THETA_2 = 6'd13,
          SET_THETA_3 = 6'd14,
          SET_THETA_4 = 6'd15,
          SET_THETA_5 = 6'd16,
          INIT_VAR = 6'd17,
          INIT_LOOP = 6'd18,
          CHECK_J = 6'd19,
          CHECK_IF_3 = 6'd20,
          SET_SIGMA = 6'd21,
          SET_FACTOR = 6'd22,
          SET_C2_S2 = 6'd23,
          CHECK_IF_2_STATES = 6'd24,
          SET_C_S = 6'd25,
          SET_C_S_FINAL = 6'd26,
          CALC_THETA_1 = 6'd27,
          CALC_THETA_2 = 6'd28,
          CHECK_IF_4 = 6'd29,
          INCR_J = 6'd30,
          CALC_C_S_1 = 6'd31,
          CALC_C_S_2 = 6'd32,
          CALC_C_S_3 = 6'd33,
          CALC_C_S_FINAL = 6'd34,
          DONE = 6'd35;

reg [5:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N-1:0] 		PI		 	= 32'b00000000000000110010010000111111,
						NEG_PI 		= 32'b10000000000000110010010000111111,
						TWO_PI 		= 32'b00000000000001100100100001111110,
						HALF_PI 	= 32'b00000000000000011001001000011111,
						NEG_HALF_PI = 32'b10000000000000011001001000011111,
						ONE 		= 32'b00000000000000010000000000000000,
						NEG_ONE 	= 32'b10000000000000010000000000000000;
						
parameter [N-1:0] 	angle0  = 32'b00000000000000001100100100001111,
					angle1  = 32'b00000000000000000111011010110001,
					angle2  = 32'b00000000000000000011111010110110,
					angle3  = 32'b00000000000000000001111111010101,
					angle4  = 32'b00000000000000000000111111111010,
					angle5  = 32'b00000000000000000000011111111111,
					angle6  = 32'b00000000000000000000001111111111,
					angle7  = 32'b00000000000000000000000111111111,
					angle8  = 32'b00000000000000000000000011111111,
					angle9  = 32'b00000000000000000000000001111111,
					angle10 = 32'b00000000000000000000000000111111,
					angle11 = 32'b00000000000000000000000000011111,
					angle12 = 32'b00000000000000000000000000010000,
					angle13 = 32'b00000000000000000000000000001000,
					angle14 = 32'b00000000000000000000000000000100,
					angle15 = 32'b00000000000000000000000000000010,
					angle16 = 32'b00000000000000000000000000000001;
						
parameter [9:0] count = 10'd16;

reg 			[N-1:0] 		m1_in1,m1_in2,a1_in1,a1_in2,a2_in1,a2_in2,
								lt1_in1,lt1_in2,lt2_in1,lt2_in2,
								m2_in1,m2_in2;
								
wire 			[N-1:0] 		m1_out,a1_out,m2_out,a2_out;
wire lt1,lt2;

reg startfmod;
reg  [N-1:0] in_1,in_2;
wire [N-1:0] rem;
wire  donefmod;

output reg [N-1:0] theta;
reg [N-1:0] sign;
reg [9:0] j;

reg [N-1:0] angle,sigma;
reg [N-1:0] c,s,poweroftwo;


qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2     (a2_in1,a2_in2,a2_out);

fplessthan		#(Q,N)	 		fplt1 	   (lt1_in1,lt1_in2,lt1);
fplessthan		#(Q,N)	 		fplt2 	   (lt2_in1,lt2_in2,lt2);

fpmod 							fmod	   (startfmod,clk,rst,in_1,in_2,rem,donefmod);

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
		if(startcossin == 1'b1)
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
		NEXT_STATE = CHECK_IF;
	end

	CHECK_IF:
	begin
		if(lt1)
		begin
			NEXT_STATE = ANGLE_SHIFT_1;
		end
		else
		begin
			NEXT_STATE = ANGLE_SHIFT_ELSE_1;
		end
		
	end

	ANGLE_SHIFT_1:
	begin
		NEXT_STATE = ANGLE_SHIFT_2;
	end

	ANGLE_SHIFT_2:
	begin
		if(donefmod)
		begin
			NEXT_STATE = ANGLE_SHIFT_3;
		end
		else
		begin
			NEXT_STATE = ANGLE_SHIFT_2;
		end
	end

	ANGLE_SHIFT_3:
	begin
		NEXT_STATE = ANGLE_SHIFT_4;
	end

	ANGLE_SHIFT_4:
	begin
		NEXT_STATE = SET_THETA;
	end

	ANGLE_SHIFT_ELSE_1:
	begin
		NEXT_STATE = ANGLE_SHIFT_ELSE_2;
	end

	ANGLE_SHIFT_ELSE_2:
	begin
		if(donefmod)
		begin
			NEXT_STATE = ANGLE_SHIFT_ELSE_3;
		end
		else
		begin
			NEXT_STATE = ANGLE_SHIFT_ELSE_2;
		end
	end

	ANGLE_SHIFT_ELSE_3:
	begin
		NEXT_STATE = SET_THETA;
	end

	SET_THETA:
	begin
		NEXT_STATE = CHECK_IF_2;
	end

	CHECK_IF_2:
	begin
		NEXT_STATE = CHECK_IF_2_STATES;
	end
	
	CHECK_IF_2_STATES:
	begin
		if(lt1)
		begin
			NEXT_STATE = SET_THETA_1;
		end
		else if (lt2)
		begin
			NEXT_STATE = SET_THETA_3;
		end
		else
		begin
			NEXT_STATE = SET_THETA_5;
		end
	end

	SET_THETA_1:
	begin
		NEXT_STATE = SET_THETA_2;
	end

	SET_THETA_2:
	begin
		NEXT_STATE = INIT_VAR;
	end

	SET_THETA_3:
	begin
		NEXT_STATE = SET_THETA_4;
	end

	SET_THETA_4:
	begin
		NEXT_STATE = INIT_VAR;
	end

	SET_THETA_5:
	begin
		NEXT_STATE = INIT_VAR;
	end

	INIT_VAR:
	begin
		NEXT_STATE = INIT_LOOP;
	end

	INIT_LOOP:
	begin
		NEXT_STATE = CHECK_J;
	end

	CHECK_J:
	begin
		if(j <= count)
		begin
			NEXT_STATE = CHECK_IF_3;
		end
		else
		begin
			NEXT_STATE = CALC_C_S_1;
		end
		
	end

	CHECK_IF_3:
	begin
		NEXT_STATE = SET_SIGMA;
	end

	SET_SIGMA:
	begin
		NEXT_STATE = SET_FACTOR;
	end

	SET_FACTOR:
	begin
		NEXT_STATE = SET_C2_S2;
	end

	SET_C2_S2:
	begin
		NEXT_STATE = SET_C_S;
	end

	SET_C_S:
	begin
		NEXT_STATE = SET_C_S_FINAL;
	end

	SET_C_S_FINAL:
	begin
		NEXT_STATE = CALC_THETA_1;
	end

	CALC_THETA_1:
	begin
		NEXT_STATE = CALC_THETA_2;
	end

	CALC_THETA_2:
	begin
		NEXT_STATE = CHECK_IF_4;
	end

	CHECK_IF_4:
	begin
		NEXT_STATE = INCR_J;
	end

	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end

	CALC_C_S_1:
	begin
		NEXT_STATE = CALC_C_S_2;
	end

	CALC_C_S_2:
	begin
		NEXT_STATE = CALC_C_S_3;
	end

	CALC_C_S_3:
	begin
		NEXT_STATE = CALC_C_S_FINAL;
	end

	CALC_C_S_FINAL:
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

		donecossin <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donecossin <= 1'b0;
			sig_check <= 5'd3;
		end

		INIT:
		begin
			lt1_in1 <= beta;
			lt1_in2 <= NEG_PI;
			sig_check <= 5'd4;
			donecossin <= 1'b0;
		end

		CHECK_IF:
		begin
			startfmod <= 1'b1;
			sig_check <= 5'd3;
		end

		ANGLE_SHIFT_1:
		begin
			a1_in1 <= NEG_PI;
			a1_in2 <= {(beta[N-1] == 0)?1'b1:1'b0,beta[N-2:0]};
		end

		ANGLE_SHIFT_2:
		begin
			in_1 <= a1_out;
			in_2 <= TWO_PI;
			startfmod <= 1'b0;
		end

		ANGLE_SHIFT_3:
		begin
			a1_in1 <= NEG_PI;
			a1_in2 <= {(rem[N-1] == 0)?1'b1:1'b0,rem[N-2:0]};
		end

		ANGLE_SHIFT_4:
		begin
			a1_in1 <= a1_out;
			a1_in2 <= TWO_PI;
		end

		ANGLE_SHIFT_ELSE_1:
		begin
			sig_check <= 5'd1;
			a1_in1 <= beta;
			a1_in2 <= PI;
			startfmod <= 1'b1;
		end

		ANGLE_SHIFT_ELSE_2:
		begin
			in_1 <= a1_out;
			in_2 <= TWO_PI;
			startfmod <= 1'b0;
			c_in_1 <= a1_out;
		end

		ANGLE_SHIFT_ELSE_3:
		begin
			a1_in1 <= NEG_PI;
			a1_in2 <= rem;
		end

		SET_THETA:
		begin
			theta <= a1_out;
			c_theta <= a1_out;
			c_fmod <= rem;
		end

		CHECK_IF_2:
		begin
			lt1_in1 <= theta;
			lt1_in2 <= NEG_HALF_PI;
			lt2_in1 <= HALF_PI;
			lt2_in2 <= theta;
		end
		
		CHECK_IF_2_STATES:
		begin
			
		end

		SET_THETA_1:
		begin
			a1_in1 <= theta;
			a1_in2 <= PI;
		end

		SET_THETA_2:
		begin
			theta <= a1_out;
			sign <= NEG_ONE;
		end

		SET_THETA_3:
		begin
			a1_in1 <= theta;
			a1_in2 <= NEG_PI;
		end

		SET_THETA_4:
		begin
			theta <= a1_out;
			sign <= NEG_ONE;
		end

		SET_THETA_5:
		begin
			sign <= ONE;
		end

		INIT_VAR:
		begin
			c <= ONE;
			s <= 32'b0;
			poweroftwo <= ONE;
			angle <= angle0;
		end

		INIT_LOOP:
		begin
			j <= 10'd1;
		end

		CHECK_J:
		begin
			
		end

		CHECK_IF_3:
		begin
			lt1_in1 <= theta;
			lt1_in2 <= 32'b0;
		end

		SET_SIGMA:
		begin
			if(lt1)
			begin
				sigma <= NEG_ONE;
			end
			else
			begin
				sigma <= ONE;
			end
		end

		SET_FACTOR:
		begin
			m1_in1 <= sigma;
			m1_in2 <= poweroftwo;
		end

		SET_C2_S2:
		begin
			
			m1_in1 <= m1_out;
			m1_in2 <= s;
			m2_in1 <= m1_out;
			m2_in2 <= c;
		end

		SET_C_S:
		begin
			a1_in1 <= c;
			a1_in2 <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
			a2_in1 <= m2_out;
			a2_in2 <= s;
		end

		SET_C_S_FINAL:
		begin
			c <= a1_out;
			s <= a2_out;
		end

		CALC_THETA_1:
		begin
			m1_in1 <= sigma;
			m1_in2 <= angle;
		end

		CALC_THETA_2:
		begin
			a1_in1 <= theta;
			a1_in2 <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
			poweroftwo <= poweroftwo >> 1;
		end

		CHECK_IF_4:
		begin
			theta <= a1_out;
			if(count < (j+10'd1))
			begin
				angle = angle >> 1;
			end
			else
			begin
				case (j)
					10'd1: angle <= angle1;
					10'd2: angle <= angle2;
					10'd3: angle <= angle3;
					10'd4: angle <= angle4;
					10'd5: angle <= angle5;
					10'd6: angle <= angle6;
					10'd7: angle <= angle7;
					10'd8: angle <= angle8;
					10'd9: angle <= angle9;
					10'd10: angle <= angle10;
					10'd11: angle <= angle11;
					10'd12: angle <= angle12;
					10'd13: angle <= angle13;
					10'd14: angle <= angle14;
					10'd15: angle <= angle15;
					10'd16: angle <= angle16;
				
					default : angle <= angle16;
				endcase
			end
		end

		INCR_J:
		begin
			j = j + 10'd1;
		end

		CALC_C_S_1:
		begin
			m1_in1 <= c;
			m1_in2 <= 32'b00000000000000001001101101110100;
			m2_in1 <= s;
			m2_in2 <= 32'b00000000000000001001101101110100;
		end

		CALC_C_S_2:
		begin
			c <= m1_out;
			s <= m2_out;
		end

		CALC_C_S_3:
		begin
			m1_in1 <= sign;
			m1_in2 <= c;
			m2_in1 <= sign;
			m2_in2 <= s;
		end

		CALC_C_S_FINAL:
		begin
			cos <= m1_out;
			sin <= m2_out;
		end

		DONE:
		begin
			donecossin <= 1'b1;
		end

		endcase
	end

end


endmodule