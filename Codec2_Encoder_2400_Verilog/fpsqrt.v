/*
* Module         - fpsqrt
* Top module     - estimate_amplitudes
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue Mar 12 12:51:05 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform50.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module fpsqrt (startsqrt,clk,rst,x,sqrt,donesqrt);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
		parameter N = 32;
		parameter Q = 16;
		
		input clk,rst,startsqrt;
		input [N-1:0] x;
		output [N-1:0] sqrt;
		output reg donesqrt;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          INIT = 3'd1,
          CHECK_I = 3'd2,
          SET_G_1 = 3'd3,
          SET_G_2 = 3'd4,
          SET_GUESS = 3'd5,
          INCR_I = 3'd6,
          DONE = 3'd7;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
parameter [N-1:0] NUMBER_ONE = 32'b0_000000000000001_0000000000000000;					

reg [N-1:0] a1_in1,a1_in2,d1_in1,d1_in2,guess;
reg [3:0] i;
wire [N-1:0] a1_out,d1_out;

qadd   			#(Q,N)			adder1   	(a1_in1,a1_in2,a1_out);
fpdiv1		   #(Q,N)			divider1		(d1_in1,d1_in2,d1_out);

	

//------------------------------------------------------------------
//                 -- Begin Declarations & Coding --                  
//------------------------------------------------------------------

assign sqrt = guess;

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
		if(startsqrt == 1'b1)
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
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i <= 4'd5)
		begin
			NEXT_STATE = SET_G_1;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end

	SET_G_1:
	begin
		NEXT_STATE = SET_G_2;
	end

	SET_G_2:
	begin
		NEXT_STATE = SET_GUESS;
	end

	SET_GUESS:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
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

		donesqrt <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donesqrt <= 1'b0;
		end

		INIT:
		begin
			guess <= NUMBER_ONE;
			i <= 4'd0;
		end

		CHECK_I:
		begin
			
		end

		SET_G_1:
		begin
			d1_in1 <= x;
			d1_in2 <= guess;
		end

		SET_G_2:
		begin
			a1_in1 <= d1_out;
			a1_in2 <= guess;
		end

		SET_GUESS:
		begin
			guess <= a1_out >> 1;
		end

		INCR_I:
		begin
			i <= i + 4'd1;
		end

		DONE:
		begin
			donesqrt <= 1'b1;
		end

		endcase
	end

end


endmodule
