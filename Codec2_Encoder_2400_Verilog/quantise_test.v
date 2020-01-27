// testing quantise in encode_lsps_scalar
// simulation : Waveform23.vwf

module quantise_test (clk,rst,indexes0,done_elsp,in_lsp_hz0_check,startq);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

		parameter N = 32;
		parameter Q = 16;
		parameter [N-1:0] RADTOHZ = 32'b00000100111110010011110101010010; 
		input clk, rst;
		output reg [4:0] indexes0;
		output reg done_elsp;
		//output reg [N-1:0] beste;
		output reg [N-1:0] in_lsp_hz0_check;
 
 
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          INIT = 3'd1,
          CLAC_LSPHZ = 3'd2,
			 START_QUANTISE = 3'd3,
          INIT_QUANTISE = 3'd4,
          CALC_INDEX = 3'd5,
          DONE = 3'd6;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------


wire [N-1:0] lsp_hz0;
wire [N-1:0] lsp0;
wire [4:0] 	 besti0;
//wire [N-1:0] out_beste0;
reg [N-1:0] in_lsp_hz0;
reg [N-1:0] in_lsp0;
output reg startq;

parameter [4:0] m0 = 5'd16;
parameter [3:0] orderi0 = 4'd0;
wire doneq0;
reg in_clk;

reg [3:0] in_addr;

// 32'b0000000001011100_1100111011011001

quantise quantise0(clk,1,startq,m0,orderi0,in_lsp_hz0,besti0,doneq0);

qmult #(Q,N) mult0(RADTOHZ, in_lsp0, lsp_hz0);

RAM_encode_lsp ramlsp(in_addr,clk,,1,0,lsp0);

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
		NEXT_STATE = CLAC_LSPHZ;
	end

	CLAC_LSPHZ:
	begin
		NEXT_STATE = START_QUANTISE;
	end

	START_QUANTISE:
	begin
		NEXT_STATE = INIT_QUANTISE;
	end
	
	INIT_QUANTISE:
	begin
		NEXT_STATE = CALC_INDEX;
	end


	
	CALC_INDEX:
	begin
		if(doneq0)
		begin
			NEXT_STATE = DONE;
		end
		else
		begin
			NEXT_STATE = CALC_INDEX;
		end
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
			done_elsp <= 1'b0;
			startq <= 1'b0;
			
		end

		INIT:
		begin
			//i <= 0;
			in_clk <= clk;
			in_addr <= 4'b0;
		
		end

		CLAC_LSPHZ:
		begin
				in_lsp0 <= lsp0;
				
		end
		
		START_QUANTISE:
		begin
		   
					
			in_lsp_hz0 <= lsp_hz0;
			in_lsp_hz0_check <= lsp_hz0;
			
		end

		INIT_QUANTISE:
		begin
			
			startq <= 1'b1;
		end

		CALC_INDEX:
		begin
		//	beste <= out_beste0;
			indexes0 <= besti0;
		//	in_lsp_hz0_check <= in_lsp_hz0;

		end

		DONE:
		begin
			done_elsp <= 1'b1;
		end

		endcase
	end

end


endmodule