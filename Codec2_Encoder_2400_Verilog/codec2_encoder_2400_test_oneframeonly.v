/*
* Module         - codec2_encoder_2400
* Top module     - N/A -- Final Module
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Jul 03 19:25:02 2019
*
* Description    - 
* Input(s)       - 
* Output(s)      - 
* Simulation 	  - 
* 32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module codec2_encoder_2400_test_oneframeonly (start_codec2,clk,rst,

							encoded_bits_0,//encoded_bits_1,encoded_bits_2,
						//	encoded_bits_3,encoded_bits_4,encoded_bits_5,
						//	encoded_bits_6,
							
							done_codec2,
							
							
							check_sig,clk_count);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
				parameter N = 32;
				parameter Q = 16;
				parameter BITS_WIDTH = 48;
				parameter N1 = 80;
				parameter Q1 = 16;
	
				input clk,rst,start_codec2;
				
				
				
				output reg [BITS_WIDTH-1 :0] 	encoded_bits_0;//encoded_bits_1,encoded_bits_2;
											//	encoded_bits_3,encoded_bits_4,encoded_bits_5,
											//	encoded_bits_6;
				output reg done_codec2;
				
				output reg [N1-1:0] check_sig;
				
				output reg [N1-1:0] clk_count;
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
         
          START_CODEC_ONE_FRAME = 3'd1,
          RUN_CODEC_ONE_FRAME = 3'd2,
          GET_CODEC_ONE_FRAME = 3'd3,
          
          DONE = 3'd4;

reg [2:0] STATE, NEXT_STATE;

//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg start_oneframe;
reg [N-1:0] in_prevf0,in_xq0,in_xq1,c_out_speech,c_read_c2_sn_out;
reg [N1-1:0] in_mem_x,in_mem_y,c_out_mem_fir,c_out_sq;

wire [N1-1:0] out_mem_x,out_mem_y,c_in_mem_fir,c_in_sq;
wire [N-1:0] out_prevf0, out_xq0, out_xq1,c_write_c2_sn;
wire [BITS_WIDTH-1 : 0] c_encoded_bits;
wire done_oneframe,c_re_c2_sn,c_we_c2_sn, c_read_fir,c_write_fir;

wire [9:0] c_addr_speech,c_addr_sn,c_addr_mem_fir,c_addr_nlp_sq;
wire  c_read_sq,c_write_sq;

codec2_encoder_2400_one_frame codec2_one_frame	(start_oneframe,clk, rst,

												in_mem_x, in_mem_y , in_prevf0, in_xq0, in_xq1,
												c_out_speech,c_read_c2_sn_out,c_out_mem_fir,c_out_sq,
												
												out_mem_x,out_mem_y, out_prevf0, out_xq0, out_xq1,
												c_encoded_bits,c_addr_speech,c_addr_sn,c_write_c2_sn,
												
												c_re_c2_sn,c_we_c2_sn,
												
												c_addr_mem_fir,c_in_mem_fir,c_read_fir,c_write_fir,
												c_addr_nlp_sq,c_in_sq,c_read_sq,c_write_sq,
												done_oneframe);
												
												
				

/*----------- RAM_speech for one_frame - 160 samples ---------------------*/

reg [9:0] addr_speech_0;
wire [N-1:0] out_speech_0;
RAM_speech_0  r_speech_0(addr_speech_0,clk,,1,0,out_speech_0);

/*----------- RAM_speech for one_frame - 320 size ---------------------*/
reg [9:0] addr_sn;
reg [N-1:0] write_c2_sn;
reg re_c2_sn,we_c2_sn;
wire [N-1:0] read_c2_sn_out;
 
RAM_c2_speech_sn c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   

/*----------- RAM_nlp_mem_fir - size 48 ---------------------*/
reg [9:0] addr_mem_fir;
reg [N1-1:0] in_mem_fir;
reg read_fir, write_fir;
wire [N1-1:0] out_mem_fir;
							 
RAM_nlp_mem_fir_80  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	

/*----------- RAM_nlp_sq - size 320 ---------------------*/
reg [9:0] addr_nlp_sq;
reg [N1-1:0] in_sq;
reg read_sq,write_sq;
wire [N1-1:0] out_sq;

RAM_nlp_sq_80    nlp_sq	   (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);						 


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
		if(start_codec2)
		begin
			NEXT_STATE = START_CODEC_ONE_FRAME;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end

	START_CODEC_ONE_FRAME:
	begin
		NEXT_STATE = RUN_CODEC_ONE_FRAME;
	end

	RUN_CODEC_ONE_FRAME:
	begin
		if(done_oneframe)
		begin
			NEXT_STATE = GET_CODEC_ONE_FRAME;
		end
		else
		begin
			NEXT_STATE = RUN_CODEC_ONE_FRAME;
		end
	end

	GET_CODEC_ONE_FRAME:
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

		done_codec2 <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			done_codec2 <= 1'b0;
			clk_count <= 80'b1;
		end

		START_CODEC_ONE_FRAME:
		begin
			start_oneframe <= 1'b1;
			/* in_mem_x <= 32'b0;
				in_mem_y <= 32'b0;
				in_prevf0 <= {16'd50,16'd0};
				in_xq0 <= 32'b0;
				in_xq1 <= 32'b0; */
				
			
				in_mem_x <= 32'b0;
				in_mem_y <= 32'b0;
				in_prevf0 <= {16'd50,16'd0};
				in_xq0 <= 32'b0;
				in_xq1 <= 32'b0;
		
			
		end

		RUN_CODEC_ONE_FRAME:
		begin
			start_oneframe <= 1'b0;
			clk_count <= clk_count+1'b1; 
			
						//Sn[320]
						addr_sn <= c_addr_sn;
						c_read_c2_sn_out <= read_c2_sn_out;
						re_c2_sn <= c_re_c2_sn;
						we_c2_sn <= c_we_c2_sn;
						write_c2_sn <= c_write_c2_sn;
						
						
						//mem_fir[48]
						addr_mem_fir <= c_addr_mem_fir;
						c_out_mem_fir <= out_mem_fir;
						read_fir <= c_read_fir;
						write_fir <= c_write_fir;
						in_mem_fir <= c_in_mem_fir;
						
						//sq[320]
						addr_nlp_sq <= c_addr_nlp_sq;
						c_out_sq <= out_sq;
						read_sq <= c_read_sq;
						write_sq <= c_write_sq;
						in_sq <= c_in_sq;
						

					    addr_speech_0 <= c_addr_speech;
					    c_out_speech  <= out_speech_0;
						

		end

		GET_CODEC_ONE_FRAME:
		begin
			start_oneframe <= 1'b0;

			 encoded_bits_0 <= c_encoded_bits;
			 check_sig <= out_mem_x;
		end

		DONE:
		begin
			done_codec2 <= 1'b1;
		end

		endcase
	end

end


endmodule