/*

codec2_encoder_2400_one_frame
Description : TO process 20ms frame - 160 bytes.

*/


module codec2_encoder_2400_one_frame_test (start_oneframe,clk, rst,
														in_mex_x, in_mem_y ,  in_prevf0, in_xq0, in_xq1,
														out_speech,read_c2_sn_out,out_mem_fir,out_sq,		
									  
											// output
											out_mem_x,out_mem_y,out_prevf0, out_xq0, out_xq1,
											encoded_bits,
											addr_speech,addr_sn,write_c2_sn,
											re_c2_sn,we_c2_sn,		
											addr_mem_fir,in_mem_fir,read_fir,write_fir,
											addr_nlp_sq,in_sq,read_sq,write_sq,
											done_oneframe		
								    	);

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
				parameter N = 32;
				parameter Q = 16;
				parameter BITS_WIDTH = 48;
				
				parameter N1 = 80;
				parameter Q1 = 16;

				input clk,rst,start_oneframe;
				input  [N1-1:0] in_mex_x,in_mem_y;
				input [N-1:0] in_prevf0,in_xq0, in_xq1;
				input [N-1:0] out_speech,read_c2_sn_out;
				input [N1-1:0] out_mem_fir,out_sq;

				output  reg [BITS_WIDTH-1 : 0] encoded_bits;
				
				output  reg [N1-1:0] out_mem_x,out_mem_y;
				output reg [N-1:0] out_prevf0, out_xq0, out_xq1;
			   output reg [9:0] addr_speech, addr_sn, addr_mem_fir, addr_nlp_sq;
				output reg [N-1:0] write_c2_sn;
				output reg [N1-1:0] in_mem_fir, in_sq;

				output reg done_oneframe,re_c2_sn, we_c2_sn, read_fir, 
									    write_fir, read_sq,write_sq;
				
	
				reg [N-1:0] c_w0_1,c_w0_2,c_w0,c_w1;
				reg [N-1:0] c_lsp_check;//,c_sn, c_e;				 
				reg [3:0] clsp0,clsp1,clsp2,clsp3,clsp4,clsp5,clsp6,clsp7,clsp8,clsp9;
			
					
				reg [N-1:0] check_pitch1, check_best_fo1, check_pitch2, check_best_fo2;
				
				
				reg [N-1:0] c_e,c_sn,ch_lsp;
				
//				 
//				reg [9:0] addr_speech;
//				wire [N-1:0] out_speech;
//				RAM_speech_0  r_speech_0(addr_speech,clk,,1,0,out_speech); 
//				
//				/*----------- RAM_speech for one_frame - 320 size ---------------------*/
//				reg [9:0] addr_sn;
//				reg [N-1:0] write_c2_sn;
//				reg re_c2_sn,we_c2_sn;
//				wire [N-1:0] read_c2_sn_out;
//				 
//				RAM_c2_speech_sn c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   
//
//				/*----------- RAM_nlp_mem_fir - size 48 ---------------------*/
//				reg [9:0] addr_mem_fir;
//				reg [N1-1:0] in_mem_fir;
//				reg read_fir, write_fir;
//				wire [N1-1:0] out_mem_fir;
//											 
//				RAM_nlp_mem_fir_80  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	
//
//				/*----------- RAM_nlp_sq - size 320 ---------------------*/
//				reg [9:0] addr_nlp_sq;
//				reg [N1-1:0] in_sq;
//				reg read_sq,write_sq;
//				wire [N1-1:0] out_sq;
//
//				RAM_nlp_sq_80    nlp_sq	   (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);	
				

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 7'd0,
          DONE = 7'd1;
			 

reg [3:0] c_lsp;

reg [6:0] STATE, NEXT_STATE;

parameter [9:0] N_SAMP = 10'd80,
				M_PITCH = 10'd320;
//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
 reg [9:0] i;
 reg [N-1:0] sn_data;
 


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
			NEXT_STATE = DONE;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end
	
	
	DONE:
	begin
		NEXT_STATE = START;
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
		done_oneframe <= 1'b0;
			
	end

	else
	begin
		case(STATE)

		START:
		begin
			done_oneframe <= 1'b0;
			encoded_bits <= 48'd0;
			
		end
		
		/* for(i=0; i<m_pitch-n_samp; i++)
		  c2->Sn[i] = c2->Sn[i+n_samp];
		for(i=0; i<n_samp; i++)
		  c2->Sn[i+m_pitch-n_samp] = speech[i]; */
		
		
		DONE:
		begin
			done_oneframe <= 1'b1;
		end

		endcase
	end

end


endmodule