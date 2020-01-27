/*
* Module         - fpmod
* Top module     - cossin_cordic
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Thu May 09 10:59:51 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform60.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module fpmod (startfmod,clk,rst,in_1,in_2,rem,donefmod);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
	parameter N = 32;
	parameter Q = 16;
	
	input clk, rst, startfmod;
	input [N-1:0] in_1;
	input [N-1:0] in_2;
	
	output reg [N-1:0] rem;
	output reg donefmod;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          START_DIV = 3'd1,
          GET_DIVISOR = 3'd2,
          MULT_1 = 3'd3,
          MULT_2 = 3'd4,
          GET_REM = 3'd5,
          SET_REM = 3'd6,
          DONE = 3'd7;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
reg 	[N-1:0] m1_in1,m1_in2,a1_in1,a1_in2,div_in;
wire	[N-1:0] m1_out,a1_out,div_ans;

reg startdiv;
wire donediv;

reg [N-1:0] divisor;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);

fpdiv_clk  	  	 divider	    (startdiv,clk,rst,div_in,div_ans,donediv);

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
		if(startfmod)
		begin
			NEXT_STATE = START_DIV;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
		
	end

	START_DIV:
	begin
		if(donediv)
		begin
			NEXT_STATE = GET_DIVISOR;
		end
		else
		begin
			NEXT_STATE = START_DIV;
		end
	end

	GET_DIVISOR:
	begin
		NEXT_STATE = MULT_1;
	end

	MULT_1:
	begin
		NEXT_STATE = MULT_2;
	end

	MULT_2:
	begin
		NEXT_STATE = GET_REM;
	end

	GET_REM:
	begin
		NEXT_STATE = SET_REM;
	end

	SET_REM:
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

		donefmod <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donefmod <= 1'b0;
		end

		START_DIV:
		begin
			startdiv <= 1'b1;
			div_in <= in_2;
		end

		GET_DIVISOR:
		begin
			divisor <= div_ans;
			startdiv <= 1'b0;
		end

		MULT_1:
		begin
			m1_in1 <= in_1;
			m1_in2 <= divisor;
		end

		MULT_2:
		begin
			m1_in1 <= {m1_out[31:16],16'b0};
			m1_in2 <= in_2;
		end

		GET_REM:
		begin
			a1_in1 <= in_1;
			a1_in2 <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
		end

		SET_REM:
		begin
			rem <= a1_out;
		end

		DONE:
		begin
			donefmod <= 1'b1;
		end

		endcase
	end

end


endmodule