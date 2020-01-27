module Check_RAM_read_write (start_oneframe,clk,rst,check_sn_data,done_oneframe);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
	parameter N = 32;
	parameter Q = 16;
	
	input clk,rst,start_oneframe;
	output reg [N-1:0] check_sn_data;
	output reg done_oneframe;
	
	
				reg [9:0] addr_speech;
				wire [N-1:0] out_speech;
				RAM_speech_0  r_speech_0(addr_speech,clk,,1,0,out_speech); 
			
//				----------- RAM_speech for one_frame - 320 size -------------------
				reg [9:0] addr_sn;
				reg [N-1:0] write_c2_sn;
				reg re_c2_sn,we_c2_sn;
				wire [N-1:0] read_c2_sn_out;
				 
				RAM_c2_sn_test_nlp c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT_FOR = 5'd1,
          CHECK_FOR = 5'd2,
          READ_SPEECH = 5'd3,
          DELAY_1 = 5'd4,
          DELAY_2 = 5'd5,
          READ_DATA_SN = 5'd6,
          SET_ADDR_SN = 5'd7,
          DELAY_3 = 5'd8,
          DELAY_4 = 5'd9,
          WRITE_SN = 5'd10,
          INCR_FOR = 5'd11,
          CHECK_ADDR = 5'd12,
          DELAY_5 = 5'd13,
          DELAY_6 = 5'd14,
          CHECK_DATA = 5'd15,
          DONE = 5'd16;

reg [4:0] STATE, NEXT_STATE;
reg [N-1:0] sn_data;
reg [9:0] i ;


parameter [9:0] N_SAMP = 10'd80,
				M_PITCH = 10'd320;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------


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
		if(start_oneframe)
		begin
			NEXT_STATE = INIT_FOR;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_FOR;
	end

	CHECK_FOR:
	begin
		if(i < N_SAMP)   
		begin
			NEXT_STATE = READ_SPEECH;
		end
		else
		begin
			NEXT_STATE = CHECK_ADDR;
		end
	end

	READ_SPEECH:
	begin
		NEXT_STATE = DELAY_1;
	end

	DELAY_1:
	begin
		NEXT_STATE = DELAY_2;
	end

	DELAY_2:
	begin
		NEXT_STATE = READ_DATA_SN;
	end

	READ_DATA_SN:
	begin
		NEXT_STATE = SET_ADDR_SN;
	end

	SET_ADDR_SN:
	begin
		NEXT_STATE = DELAY_3;
	end

	DELAY_3:
	begin
		NEXT_STATE = DELAY_4;
	end

	DELAY_4:
	begin
		NEXT_STATE = WRITE_SN;
	end

	WRITE_SN:
	begin
		NEXT_STATE = INCR_FOR;
	end

	INCR_FOR:
	begin
		NEXT_STATE = CHECK_FOR;
	end

	CHECK_ADDR:
	begin
		NEXT_STATE = DELAY_5;
	end

	DELAY_5:
	begin
		NEXT_STATE = DELAY_6;
	end

	DELAY_6:
	begin
		NEXT_STATE = CHECK_DATA;
	end

	CHECK_DATA:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = DONE;
	end

	default:
	begin
		NEXT_STATE = DONE;;
	end

	endcase
end


always@(*)
begin
		case(STATE)

		START:
		begin
			
		end

		INIT_FOR:
		begin
			
		end

		CHECK_FOR:
		begin
			
		end

		READ_SPEECH:
		begin
			addr_speech = i;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		DELAY_1:
		begin
			addr_speech = i;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		DELAY_2:
		begin
			addr_speech = i;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		READ_DATA_SN:
		begin
			sn_data = out_speech;
			addr_speech = i;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		SET_ADDR_SN:
		begin
			addr_sn = i + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		DELAY_3:
		begin
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		DELAY_4:
		begin
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		WRITE_SN:
		begin
			write_c2_sn = sn_data;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end

		INCR_FOR:
		begin
			
		end

		CHECK_ADDR:
		begin
			addr_sn = 10'd242;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end

		DELAY_5:
		begin
			addr_sn = 10'd242;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end

		DELAY_6:
		begin
			addr_sn = 10'd242;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end

		CHECK_DATA:
		begin
			addr_sn = 10'd242;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end

		default:
		begin
			addr_sn = 10'd0;
			re_c2_sn = 10'd0;
			we_c2_sn = 10'd0;
			addr_speech = 10'd0;
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
			done_oneframe <= 1'b0;
		end

		INIT_FOR:
		begin
			i <= 10'd0;
		end

		CHECK_FOR:
		begin
			
		end

		READ_SPEECH:
		begin
			/* addr_speech <= i;
			re_c2_sn <= 1'b0;
			we_c2_sn <= 1'b1; */
		end

		DELAY_1:
		begin
			
		end

		DELAY_2:
		begin
			
		end

		READ_DATA_SN:
		begin
			//sn_data <= out_speech;
		end

		SET_ADDR_SN:
		begin
			//addr_sn <= i + 10'd240;
		end

		DELAY_3:
		begin
			
		end

		DELAY_4:
		begin
			
		end

		WRITE_SN:
		begin
			//write_c2_sn <= sn_data;
		end

		INCR_FOR:
		begin
			i <= i + 10'd1;
		end

		CHECK_ADDR:
		begin
			/* addr_sn <= 10'd240;
			re_c2_sn <= 1'b1;
			we_c2_sn <= 1'b0; */
		end

		DELAY_5:
		begin
			
		end

		DELAY_6:
		begin
			
		end

		CHECK_DATA:
		begin
			check_sn_data <= read_c2_sn_out;
		end

		DONE:
		begin
			done_oneframe <= 1'b1;
		end

		endcase
	end

end


endmodule