// Waveform52.vwf
module check_RAM (clk,rst,data,doneq,j);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
		input clk, rst;
		
		output reg [3:0] j;
		output reg [31:0] data;
		output reg doneq;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 4'd0,
			 INIT = 4'd1,
			 INCR_J = 4'd2,
			 CHECK_J = 4'd3,
          SET_ADDR = 4'd4,
          SET_OUTPUT = 4'd5,
          DONE = 4'd6,
			 PRE_GET = 4'd7;

reg [3:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [3:0] addr_rn;
wire [31:0] out_rn;



RAM_autocorrelate_Rn     ram1_rn		(addr_rn,clk,,1,0,out_rn);
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
		NEXT_STATE = INIT;
	end
	
	
	INIT:
	begin
		NEXT_STATE = SET_ADDR;
	end
		

	SET_ADDR:
	begin
		NEXT_STATE = PRE_GET;
	end
	
	PRE_GET:
	begin
		NEXT_STATE = SET_OUTPUT;
	end

	SET_OUTPUT:
	begin
		NEXT_STATE = INCR_J;
	end
	
	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end
	
	CHECK_J:
	begin
		if(j < 4'd12)
		begin
			NEXT_STATE = SET_ADDR;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end

	DONE:
	begin
		NEXT_STATE = DONE;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		

	end

	else
	begin
		case(STATE)

		START:
		begin
			j <= 4'd10;
		   doneq <= 1'b0;
		end
		
		INIT:
		begin
			j <= 4'd0;
		end
		
		SET_ADDR:
		begin
			addr_rn <= j;
				
		end
		
		PRE_GET:
		begin
			
		end

		SET_OUTPUT:
		begin
			data <= out_rn;
		end
		
		INCR_J:
		begin
			j <= j + 4'd1;
		end
		
		CHECK_J:
		begin

		end

		DONE:
		begin
			doneq <= 1'b1;
		end

		endcase
	end

end


endmodule