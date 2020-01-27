module check_fp_div_para (startcheck,clk,rst,in,ans,donecheck);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			
			parameter Q = 16;
			parameter N = 48;
			
			input clk, rst, startcheck;
			input [N-1:0] in;
			output reg donecheck;
			output reg [N-1:0] ans;
			

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          START_DIV = 3'd1,
          RUN_DIV = 3'd2,
          GET_DIV = 3'd3,
          DONE = 3'd4;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg startdiv;
reg [N-1:0] div_in;
wire [N-1:0] div_ans;
wire donediv;

fpdiv_clk_parameter  		  #(Q,N) 	 divider1   (startdiv,clk,rst,div_in,div_ans,donediv);

//fpdiv_clk_acc  divider1   (startdiv,clk,rst,div_in,div_ans,donediv);
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
		NEXT_STATE = START_DIV;
	end

	START_DIV:
	begin
		NEXT_STATE = RUN_DIV;
	end

	RUN_DIV:
	begin
		if(donediv)
		begin
			NEXT_STATE = GET_DIV;
		end
		else
		begin
			NEXT_STATE = RUN_DIV;
		end
	end

	GET_DIV:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = DONE;
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

		

	end

	else
	begin
		case(STATE)

		START:
		begin
			donecheck <= 1'b0;
		end

		START_DIV:
		begin
			startdiv <= 1'b1;
			div_in <= {32'b0,4'b0111,12'b0};
		end

		RUN_DIV:
		begin
			
		end

		GET_DIV:
		begin
			ans <= div_ans;
		end

		DONE:
		begin
			donecheck <= 1'b1;
		end

		endcase
	end

end


endmodule