/*
* Module         - cheb_poly_eva
* Top module     - lpc_to_lsp
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue Feb 19 21:03:11 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform35.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module cheb_poly_eva(clk,rst,startcp,x,coeff0,coeff1,coeff2,coeff3,coeff4,coeff5,
					sum,donecp);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	parameter Q1 = 24;
	
	input clk, rst, startcp;
	input [N-1:0] x,coeff0,coeff1,coeff2,coeff3,coeff4,coeff5;
	
	output reg donecp;
	
	output reg [N-1:0] sum;
	

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 6'd0,
          INIT = 6'd1,
          PRE_CALC1_T2 = 6'd2,
          PRE_CALC2_T2 = 6'd3,
          CALC_T2 = 6'd4,
          PRE_CALC1_T3 = 6'd5,
          PRE_CALC2_T3 = 6'd6,
          CALC_T3 = 6'd7,
          PRE_CALC1_T4 = 6'd8,
          PRE_CALC2_T4 = 6'd9,
          CALC_T4 = 6'd10,
          PRE_CALC1_T5 = 6'd11,
          PRE_CALC2_T5 = 6'd12,
          CALC_T5 = 6'd13,
          PRE_CALC1_SUM0 = 6'd14,
          PRE_CALC2_SUM0 = 6'd15,
          CALC_SUM0 = 6'd16,
          PRE_CALC1_SUM1 = 6'd17,
          PRE_CALC2_SUM1 = 6'd18,
          CALC_SUM1 = 6'd19,
          PRE_CALC1_SUM2 = 6'd20,
          PRE_CALC2_SUM2 = 6'd21,
          CALC_SUM2 = 6'd22,
          PRE_CALC1_SUM3 = 6'd23,
          PRE_CALC2_SUM3 = 6'd24,
          CALC_SUM3 = 6'd25,
          PRE_CALC1_SUM4 = 6'd26,
          PRE_CALC2_SUM4 = 6'd27,
          CALC_SUM4 = 6'd28,
			 PRE_CALC1_SUM5 = 6'd29,
          PRE_CALC2_SUM5 = 6'd30,
          CALC_SUM5 = 6'd31,
			 DONE = 6'd32;

reg [5:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [N-1:0] t0,t1,t2,t3,t4,t5;
reg [N-1:0] x2;

reg [N-1:0] mult1,mult2,add1,add2;
wire [N-1:0] out_mult,out_add;


qmult #(Q1,N) multiplier1(mult1,mult2,out_mult);
qadd  #(Q1,N)      adder1(add1,add2,out_add);


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
		if(startcp == 1'b1)
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
		NEXT_STATE = PRE_CALC1_T2;
	end

	PRE_CALC1_T2:
	begin
		NEXT_STATE = PRE_CALC2_T2;
	end

	PRE_CALC2_T2:
	begin
		NEXT_STATE = CALC_T2;
	end

	CALC_T2:
	begin
		NEXT_STATE = PRE_CALC1_T3;
	end

	PRE_CALC1_T3:
	begin
		NEXT_STATE = PRE_CALC2_T3;
	end

	PRE_CALC2_T3:
	begin
		NEXT_STATE = CALC_T3;
	end

	CALC_T3:
	begin
		NEXT_STATE = PRE_CALC1_T4;
	end

	PRE_CALC1_T4:
	begin
		NEXT_STATE = PRE_CALC2_T4;
	end

	PRE_CALC2_T4:
	begin
		NEXT_STATE = CALC_T4;
	end

	CALC_T4:
	begin
		NEXT_STATE = PRE_CALC1_T5;
	end

	PRE_CALC1_T5:
	begin
		NEXT_STATE = PRE_CALC2_T5;
	end

	PRE_CALC2_T5:
	begin
		NEXT_STATE = CALC_T5;
	end

	CALC_T5:
	begin
		NEXT_STATE = PRE_CALC1_SUM0;
	end

	PRE_CALC1_SUM0:
	begin
		NEXT_STATE = PRE_CALC2_SUM0;
	end

	PRE_CALC2_SUM0:
	begin
		NEXT_STATE = CALC_SUM0;
	end

	CALC_SUM0:
	begin
		NEXT_STATE = PRE_CALC1_SUM1;
	end

	PRE_CALC1_SUM1:
	begin
		NEXT_STATE = PRE_CALC2_SUM1;
	end

	PRE_CALC2_SUM1:
	begin
		NEXT_STATE = CALC_SUM1;
	end

	CALC_SUM1:
	begin
		NEXT_STATE = PRE_CALC1_SUM2;
	end

	PRE_CALC1_SUM2:
	begin
		NEXT_STATE = PRE_CALC2_SUM2;
	end

	PRE_CALC2_SUM2:
	begin
		NEXT_STATE = CALC_SUM2;
	end

	CALC_SUM2:
	begin
		NEXT_STATE = PRE_CALC1_SUM3;
	end

	PRE_CALC1_SUM3:
	begin
		NEXT_STATE = PRE_CALC2_SUM3;
	end

	PRE_CALC2_SUM3:
	begin
		NEXT_STATE = CALC_SUM3;
	end

	CALC_SUM3:
	begin
		NEXT_STATE = PRE_CALC1_SUM4;
	end

	PRE_CALC1_SUM4:
	begin
		NEXT_STATE = PRE_CALC2_SUM4;
	end

	PRE_CALC2_SUM4:
	begin
		NEXT_STATE = CALC_SUM4;
	end

	CALC_SUM4:
	begin
		NEXT_STATE = PRE_CALC1_SUM5;
	end
	
	PRE_CALC1_SUM5:
	begin
		NEXT_STATE = PRE_CALC2_SUM5;
	end

	PRE_CALC2_SUM5:
	begin
		NEXT_STATE = CALC_SUM5;
	end

	CALC_SUM5:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = START;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		donecp <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donecp <= 1'b0;
			
			/* x = 32'h00FF5C29;
			coeff0 <= 32'h02_000000;
			coeff1 <= 32'h83_E8D1FA;
			coeff2 <= 32'h04_423E07;
			coeff3 <= 32'h84_4010F9;
			coeff4 <= 32'h04_1640FA;
			coeff5 <= 32'h82_26CFFA;  */                     // for testing x = 0.9975
			
		end

		INIT:
		begin
			/* x2 <= {x[N-1],x[N-2:0] << 1};
			t0 <= 32'b0_000000000000001_0000000000000000;
			t1 <= x; */
			
			x2 <= {x[N-1],x[N-2:0] << 1};
			t0 <= {8'h01,24'b0};
			t1 <= x;
			
			
			sum <= 32'b0;
			
		end

		PRE_CALC1_T2:
		begin
			mult1 <= t1;
			mult2 <= x2;
		end

		PRE_CALC2_T2:
		begin
			add1 <= out_mult;
			add2 <= {(t0[N-1] == 0)?1'b1:1'b0,t0[N-2:0]};
		end

		CALC_T2:
		begin
			t2 <= out_add;
		end

		PRE_CALC1_T3:
		begin
			mult1 <= t2;
			mult2 <= x2;
		end

		PRE_CALC2_T3:
		begin
			add1 <= out_mult;
			add2 <= {(t1[N-1] == 0)?1'b1:1'b0,t1[N-2:0]};
		end

		CALC_T3:
		begin
			t3 <= out_add;
		end

		PRE_CALC1_T4:
		begin
			mult1 <= t3;
			mult2 <= x2;
		end

		PRE_CALC2_T4:
		begin
			add1 <= out_mult;
			add2 <= {(t2[N-1] == 0)?1'b1:1'b0,t2[N-2:0]};
		end

		CALC_T4:
		begin
			t4 <= out_add;
		end

		PRE_CALC1_T5:
		begin
			mult1 <= t4;
			mult2 <= x2;
		end

		PRE_CALC2_T5:
		begin
			add1 <= out_mult;
			add2 <= {(t3[N-1] == 0)?1'b1:1'b0,t3[N-2:0]};
		end

		CALC_T5:
		begin
			t5 <= out_add;
		end

		PRE_CALC1_SUM0:
		begin
			mult1 <= coeff5;
			mult2 <= t0;
		end

		PRE_CALC2_SUM0:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM0:
		begin
			sum <= out_add;
		end

		PRE_CALC1_SUM1:
		begin
			mult1 <= coeff4;
			mult2 <= t1;
		end

		PRE_CALC2_SUM1:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM1:
		begin
			sum <= out_add;
		end

		PRE_CALC1_SUM2:
		begin
			mult1 <= coeff3;
			mult2 <= t2;
		end

		PRE_CALC2_SUM2:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM2:
		begin
			sum <= out_add;
		end

		PRE_CALC1_SUM3:
		begin
			mult1 <= coeff2;
			mult2 <= t3;
		end

		PRE_CALC2_SUM3:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM3:
		begin
			sum <= out_add;
		end

		PRE_CALC1_SUM4:
		begin
			mult1 <= coeff1;
			mult2 <= t4;
		end

		PRE_CALC2_SUM4:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM4:
		begin
			sum <= out_add;
		end
		
		PRE_CALC1_SUM5:
		begin
			mult1 <= coeff0;
			mult2 <= t5;
		end

		PRE_CALC2_SUM5:
		begin
			add1 <= out_mult;
			add2 <= sum;
		end

		CALC_SUM5:
		begin
			sum <= out_add;
			donecp <= 1'b0;
		end
		
		DONE:
		begin
			donecp <= 1'b1;
		end

		endcase
	end

end


endmodule	

