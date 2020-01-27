module test_RAM_rn (clk,rst);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

input clk,rst;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          SET_ADDR = 3'd1,
          SET_RN = 3'd2,
          CHECK_RN = 3'd3,
          DONE = 3'd4;

reg [2:0]STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [8:0] rn_addr;
reg rn_clk;
reg [31:0] rn_write_data;
wire [31:0] ram_out;

RAM_autocorrelate_Rn ram1_rn(rn_addr,rn_clk,rn_write_data,0,1,ram_out);



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
		NEXT_STATE = SET_ADDR;
	end

	SET_ADDR:
	begin
		NEXT_STATE = SET_RN;
	end

	SET_RN:
	begin
		NEXT_STATE = CHECK_RN;
	end

	CHECK_RN:
	begin
		NEXT_STATE = DONE;
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
			
		end

		SET_ADDR:
		begin
			rn_addr <= 4'b0;
			rn_clk <= clk;
		end

		SET_RN:
		begin
			rn_write_data <= 4'b1111;
		end

		CHECK_RN:
		begin
			 
		end

		DONE:
		begin
			
		end

		endcase
	end

end


endmodule