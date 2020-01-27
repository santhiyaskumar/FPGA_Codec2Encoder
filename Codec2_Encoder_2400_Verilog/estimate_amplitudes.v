/*
* Module         - estimate_amplitudes
* Top module     - analyse_one_frame
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue Mar 12 16:37:29 2019
*
* Description    -
* Inputs         -
* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module estimate_amplitudes (startea,clk,rst,Wo,L,out_real,out_imag,addr_real,addr_imag,addr_a,write_data_a,
							//m1_in1,m1_in2,m1_out,
							//m2_in1,m2_in2,m2_out,
							doneea);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

			parameter N = 32;
			parameter Q = 16;

			input clk,rst,startea;
			input [N-1:0] Wo,out_real,out_imag;// m1_out, m2_out;
			input [9:0] L;
			output reg doneea;
			output reg [9:0] addr_a,addr_real,addr_imag;
			output reg [N-1:0] write_data_a;// m1_in1, m1_in2, m2_in1, m2_in2;
			//output reg [N-1:0] c;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 7'd0,
          INIT_LOOP = 7'd1,
          SET_DEN = 7'd2,
          AM_BM_1 = 7'd3,
          AM_BM_2 = 7'd4,
          AM_BM_3 = 7'd5,
          SET_AM_BM = 7'd6,
          INCR_M = 7'd7,
          CHECK_M = 7'd8,
          DONE = 7'd9,
			 SET_I = 7'd10,
			 CHECK_I = 7'd11,
			 SET_ADDR_SW = 7'd12,
			 SET_SQRT = 7'd13,
			 SET_DELAY = 7'd14,
			 SET_DATA_SW = 7'd15,
			 CALC1_DEN = 7'd16,
			 CALC2_DEN = 7'd17,
			 INCR_I = 7'd18,
			 SET_AMP = 7'd19,
			 SET_DEN_ADD = 7'd20,
			 SET_DELAY_1 = 7'd21,
			 WRITE_AMP = 7'd22;
			 

reg [6:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N-1:0] NEG_POINT_FIVE = 32'b1_000000000000000_1000000000000000,
						POINT_FIVE = 32'b0_000000000000000_1000000000000000,
						ONE_ON_R = 32'b00000000010100010111110011000001;
						
reg [N-1:0] a1_in1,a1_in2,a2_in1,a2_in2,den;
wire [N-1:0] a1_out,a2_out;
reg [9:0] m;
reg [9:0] am,bm,i;
reg startsqrt;
reg [N-1:0] x;
//output reg [N-1:0] A1,A2,A3,A4,A5,A10;
wire [N-1:0] sqrt;
wire donesqrt;

reg [N-1:0] m1_in1,m1_in2,m2_in1,m2_in2;
wire [N-1:0] m1_out,m2_out;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1   	(a1_in1,a1_in2,a1_out);

qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2   	(a2_in1,a2_in2,a2_out);


//RAM_Sw_real   swram		(addr_real,clk,,1,0,out_real);
//RAM_Sw_imag   swimag	(addr_imag,clk,,1,0,out_imag);
fpsqrt 		  sqrtmod	(startsqrt,clk,rst,x,sqrt,donesqrt);


//wire [N-1:0] out_a;

//RAM_model_A modelram (addr_a,clk,write_data_a,0,1,out_a);

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
		if(startea == 1'b1)
		begin
			NEXT_STATE = INIT_LOOP;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_LOOP:
	begin
		NEXT_STATE = SET_DEN;
	end

	SET_DEN:
	begin
		NEXT_STATE = AM_BM_1;
	end

	AM_BM_1:
	begin
		NEXT_STATE = AM_BM_2;
	end

	AM_BM_2:
	begin
		NEXT_STATE = AM_BM_3;
	end

	AM_BM_3:
	begin
		NEXT_STATE = SET_AM_BM;
	end

	SET_AM_BM:
	begin
		NEXT_STATE = SET_I;
	end
	
	SET_I:
	begin
		NEXT_STATE = CHECK_I;
	end
	
	CHECK_I:
	begin
		if(i < bm)
		begin
			NEXT_STATE = SET_ADDR_SW;
		end
		else
		begin
			NEXT_STATE = SET_SQRT;
		end
	end
	
	SET_ADDR_SW:
	begin
		NEXT_STATE = SET_DELAY;
	end
	
	SET_DELAY:
	begin
		NEXT_STATE = SET_DELAY_1;
	end
	
	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DATA_SW;
	end
	
	SET_DATA_SW:
	begin
		NEXT_STATE = CALC1_DEN;
	end
	
	CALC1_DEN:
	begin
		NEXT_STATE = CALC2_DEN;
	end
	
	CALC2_DEN:
	begin
		NEXT_STATE = SET_DEN_ADD;
	end
	
	SET_DEN_ADD:
	begin
		NEXT_STATE = INCR_I;
	end
	
	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end
	
	SET_SQRT:
	begin
		if(donesqrt == 1'b1)
		begin
			NEXT_STATE = SET_AMP;
		end
		else
		begin
			NEXT_STATE = SET_SQRT;
		end
	end
	
	SET_AMP:
	begin
		NEXT_STATE = WRITE_AMP;
	end
	
	WRITE_AMP:
	begin
		NEXT_STATE = INCR_M;
	end
	
	INCR_M:
	begin
		NEXT_STATE = CHECK_M;
	end

	CHECK_M:
	begin
		if(m <= L)
		begin
			NEXT_STATE = SET_DEN;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
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

		doneea <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneea <= 1'b0;
		end

		INIT_LOOP:
		begin
			m <= 10'd1;
			startsqrt <= 1'b0;
		end

		SET_DEN:
		begin
			a1_in1 <= {6'b0,m,16'b0};
			a1_in2 <= NEG_POINT_FIVE;
			a2_in1  <= {6'b0,m,16'b0};
			a2_in2 <= POINT_FIVE;
			den <= 32'b0;
		end

		AM_BM_1:
		begin

			m1_in1 <= a1_out;
			m1_in2 <= Wo; //32'b00000000000000000000100110110000;//
			m2_in1 <= a2_out;
			m2_in2 <= Wo; //32'b00000000000000000000100110110000;//
			
		end

		AM_BM_2:
		begin
			
			m1_in1 <= ONE_ON_R;
			m1_in2 <= m1_out;
			m2_in1 <= ONE_ON_R;
			m2_in2 <= m2_out;
		end

		AM_BM_3:
		begin
		
			a1_in1 <= POINT_FIVE;
			a1_in2 <= m1_out;
			a2_in1 <= POINT_FIVE;
			a2_in2 <= m2_out;
		end

		SET_AM_BM:
		begin
		
			am <= a1_out[25:16];
			bm <= a2_out[25:16];
		end
		
		SET_I:
		begin
			i <= am;
		end
		
		CHECK_I:
		begin

		end
		
		SET_ADDR_SW:
		begin
			addr_real <= i;
			addr_imag <= i;
		end
		
		SET_DELAY:
		begin
			
		end
		
		SET_DELAY_1:
		begin
			
		end
		
		
		SET_DATA_SW:
		begin
			m1_in1 <= out_real;
			m1_in2 <= out_real;
			m2_in1 <= out_imag;
			m2_in2 <= out_imag;
		end
		
		CALC1_DEN:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= m2_out;
			
			//c <= m1_out;
		end
		
		CALC2_DEN:
		begin
			a1_in1 <= a1_out;
			a1_in2 <= den;
		end
		
		SET_DEN_ADD:
		begin
			den <= a1_out;
		end
		
		INCR_I:
		begin
			i <= i + 10'd1;
		end
		
		SET_SQRT:
		begin
			startsqrt <= 1'b1;
			x <= den;
			addr_a <= m;
		end
		
		SET_AMP:
		begin
			 /* case(m)
			10'd1 : A1 <= sqrt;
			10'd2 : A2 <= sqrt;
			10'd3 : A3 <= sqrt;
			10'd4 : A4 <= sqrt;
			10'd5 : A5 <= sqrt;
			endcase  */
			/* if(m == 10'd10)
			begin
				A10 <= sqrt;
			end */
			
			startsqrt <= 1'b0;
			write_data_a <= sqrt;
			
		end
		
		WRITE_AMP:
		begin
			
			//A10 <= write_data_a;
			
			
		end

		INCR_M:
		begin
			//A <= A1;
			m <= m + 10'd1;
			//startsqrt <= 1'b0;
		end

		CHECK_M:
		begin
			
		end

		DONE:
		begin
			doneea <= 1'b1;
		end

		endcase
	end

end


endmodule