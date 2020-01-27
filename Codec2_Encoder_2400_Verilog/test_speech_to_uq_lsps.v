module test_speech_to_uq_lsps (start_tspeech,clk,rst,

								check_E,
								done_tspeech);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
				parameter N = 32;
				parameter Q = 16;
				
				input clk,rst,start_tspeech;
				output reg done_tspeech;
				output reg [N-1:0] check_E;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          START_SPEECH = 3'd1,
          RUN_SPEECH = 3'd2,
          GET_SPEECH = 3'd3,
          DONE = 3'd4;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [9:0] addr_sn;
reg [N-1:0] write_c2_sn;
reg re_c2_sn,we_c2_sn;
wire [N-1:0] read_c2_sn_out;
 
RAM_c2_speech_sn_test c2_sn (addr_sn,clk,write_c2_sn,
						re_c2_sn,we_c2_sn,read_c2_sn_out);   


reg startspeech;
reg [N-1:0] s_out_sn;
wire [N-1:0] E_speech,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9;
wire [9:0] s_addr_sn;
wire donespeech;

speech_to_uq_lsps speech_module(startspeech,clk,rst,s_out_sn,
							E_speech,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,
							    lsp6,lsp7,lsp8,lsp9,s_addr_sn,
							donespeech);
							



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
		if(start_tspeech == 1'b1)
		begin
			NEXT_STATE = START_SPEECH;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end

	START_SPEECH:
	begin
		NEXT_STATE = RUN_SPEECH;
	end

	RUN_SPEECH:
	begin
		if(donespeech)
		begin
			NEXT_STATE = GET_SPEECH;
		end
		else
		begin
			NEXT_STATE = RUN_SPEECH;
		end
		
	end

	GET_SPEECH:
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

		done_tspeech <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			done_tspeech <= 1'b0;
		end

		START_SPEECH:
		begin
			startspeech <= 1'b1;
		end

		RUN_SPEECH:
		begin
			s_out_sn <= read_c2_sn_out;
			addr_sn <= s_addr_sn;
			
			startspeech <= 1'b0;
		end

		GET_SPEECH:
		begin
			check_E <= E_speech;
		end

		DONE:
		begin
			done_tspeech <= 1'b1;
		end

		endcase
	end

end


endmodule