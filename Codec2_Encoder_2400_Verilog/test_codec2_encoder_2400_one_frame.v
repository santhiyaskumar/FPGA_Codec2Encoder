/*

codec2_encoder_2400_one_frame
Description : TO process 20ms frame - 160 bytes.

*/


module test_codec2_encoder_2400_one_frame(	start_oneframe,clk, rst,
										/*  in_mex_x, in_mem_y ,   */in_prevf0, in_xq0, in_xq1,
											
									  
											// output
											out_mem_x,out_mem_y,out_prevf0, out_xq0, out_xq1,
											encoded_bits,
											
											done_oneframe,
											clk_count
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
				//input [N1-1:0] in_mex_x,in_mem_y;
				input [N-1:0] in_prevf0,in_xq0, in_xq1;
				

				output reg [BITS_WIDTH-1 : 0] encoded_bits;
				
				output reg [N1-1:0] out_mem_x,out_mem_y;
				output reg [N-1:0] out_prevf0, out_xq0, out_xq1;
			    
				output reg done_oneframe;
				
	
				reg [N-1:0] c_w0_1,c_w0_2,c_w0,c_w1;
				reg [N-1:0] c_lsp_check;//,c_sn, c_e;				 
				reg [3:0] clsp0,clsp1,clsp2,clsp3,clsp4,clsp5,clsp6,clsp7,clsp8,clsp9;
			
					
				reg [N-1:0] check_pitch1, check_best_fo1, check_pitch2, check_best_fo2;
				
				
				reg [N-1:0] c_e,c_sn,ch_lsp;
				
				output reg [N1-1:0] clk_count;
				
				 
				reg [9:0] addr_speech;
				wire [N-1:0] out_speech;
				RAM_speech_0  r_speech_0(addr_speech,clk,,1,0,out_speech); 
				
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
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 7'd0,
          START_AOF1 = 7'd1,
          RUN_AOF1 = 7'd2,
          START_AOF2 = 7'd3,
          RUN_AOF2 = 7'd4,
          DONE = 7'd5,
			 INIT_FOR_1 = 7'd6,
			 CHECK_FOR1 = 7'd7,
			 READ_SN1 = 7'd8,
			 SET_DELAY_1 = 7'd9,
			 SET_DELAY_2 = 7'd10,
			 READ_DATA_SN1 = 7'd11,
			 SET_ADDR_SN1 = 7'd12,
			 WRITE_SN1 = 7'd13,
			 INCR_FOR1 = 7'd14,
			 INIT_FOR_2 = 7'd15,
			 CHECK_FOR2 = 7'd16,
			 READ_SN2 = 7'd17,
			 SET_DELAY_3 = 7'd18,
			 SET_DELAY_4 = 7'd19,
			 READ_DATA_SN2 = 7'd20,
			 SET_ADDR_SN2 = 7'd21,
			 WRITE_SN2 = 7'd22,
			 INCR_FOR2 = 7'd23,
			 GET_AOF1 = 7'd24,
			 
			 INIT_FOR_3 = 7'd25,
			 CHECK_FOR3 = 7'd26,
			 READ_SN3 = 7'd27,
			 SET_DELAY_5 = 7'd28,
			 SET_DELAY_6 = 7'd29,
			 READ_DATA_SN3 = 7'd30,
			 SET_ADDR_SN3 = 7'd31,
			 WRITE_SN3 = 7'd32,
			 INCR_FOR3 = 7'd33,
			 INIT_FOR_4 = 7'd34,
			 CHECK_FOR4 = 7'd35,
			 READ_SN4 = 7'd36,
			 SET_DELAY_7 = 7'd37,
			 SET_DELAY_8 = 7'd38,
			 READ_DATA_SN4 = 7'd39,
			 SET_ADDR_SN4 = 7'd40,
			 WRITE_SN4 = 7'd41,
			 INCR_FOR4 = 7'd42,
			 GET_AOF2 = 7'd43,
			 GET_SPEECH = 7'd44,
			 RUN_SPEECH = 7'd45,
			 START_SPEECH = 7'd46,
			 START_ENCODEWOE = 7'd47,
			 RUN_ENCODEWOE = 7'd48,
			 GET_ENCODEWOE = 7'd49,
			 INIT_FOR_LSP = 7'd50,
			 CHECK_LSP = 7'd51,
			 SET_ADDR_LSP = 7'd52,
			 S_D_LSP1 = 7'd53,
			 S_D_LSP2 = 7'd54,
			 SET_DATA_LSP = 7'd55,
			 INCR_LSP = 7'd56,
			 START_ELSP1 = 7'd57,
			 RUN_ELSP = 7'd58,
			 GET_ELSP = 7'd59,
			 
			 C_FOR1 = 7'd60,
			 CHECK_C_FOR1 = 7'd61,
			 C_LSP_ADDR = 7'd62,
			 SD1 = 7'd63,
			 SD2 = 7'd64,
			 SET_DATA_CHECK_LSP = 7'd65,
			 INCR_C_LSP = 7'd66,
			 CHECK_INDEX = 7'd67,
			 INCR_INDEX = 7'd68,
			 SET_INDEX = 7'd69,
			 SET_ENCODED_BITS = 7'd70,
			 INDEX_TO_GRAY = 7'd71;
			 

reg [3:0] c_lsp;

reg [6:0] STATE, NEXT_STATE;

parameter [9:0] N_SAMP = 10'd80,
				M_PITCH = 10'd320;
//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
 reg [9:0] i;
 reg [N-1:0] sn_data;
 
// reg [9:0] addr_speech;
// wire [N-1:0] out_speech;
// /*----------- RAM_speech for one_frame - 160 samples ---------------------*/

// RAM_speech_samples r_speech (addr_speech, clk,,1,0,out_speech);    // this should go to main

// /* -----------------------RAM - c2-Sn - Sn[320] --------------------------*/
 // reg [9:0] addr_sn;
 // reg [N-1:0] write_c2_sn;
// reg re_c2_sn,we_c2_sn;
// wire [N-1:0] read_c2_sn_out;
 
// RAM_c2_speech_sn c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   // this should goto main


/* reg [9:0] addr_mem_fir;
reg [N-1:0] in_mem_fir;
reg read_fir, write_fir;
wire [N-1:0] out_mem_fir;
							 
RAM_nlp_mem_fir  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	
 */
/* reg [9:0] addr_nlp_sq;
reg [N-1:0] in_sq;
reg read_sq,write_sq;
wire [N-1:0] out_sq;
RAM_nlp_sq      nlp_sq	       (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);		 */		


/*----------------------------------analyse_one_frame--------------------------------------------------*/

reg startaof;
reg [N1-1:0] aof_mem_x_in,aof_mem_y_in, aof_out_mem_fir, aof_out_sq;
reg [N-1:0] aof_in_prev_f0, aof_out_sn;
wire [N1-1:0] aof_mem_x_out,aof_mem_y_out,aof_in_mem_fir,aof_in_sq;
wire [N-1:0] aof_out_prev_f0,out_best_f0,aof_w0_out,aof_nlp_pitch;
wire [9:0] aof_addr_sn,aof_addr_mem_fir,aof_addr_nlp_sq;
wire voiced_bit,doneaof,aof_read_fir,aof_write_fir,aof_read_sq,aof_write_sq;

analyse_one_frame aof (	startaof,clk,rst,
							/*--- input------------------ */
							 aof_mem_x_in,aof_mem_y_in,aof_in_prev_f0,aof_out_sn,aof_out_mem_fir,aof_out_sq,
							/*--------------------------- */
							
							/*--- output----------------------------------------------------------- */
						     aof_mem_x_out,aof_mem_y_out,aof_out_prev_f0,out_best_f0,aof_w0_out,voiced_bit,aof_addr_sn,
							 aof_addr_mem_fir,aof_in_mem_fir,aof_nlp_pitch,aof_read_fir,aof_write_fir,
							 
							 aof_addr_nlp_sq,aof_in_sq,aof_read_sq,aof_write_sq,
							/*--------------------------------------------------------------------- */
							 doneaof,aof_c_w0,aof_c_w1);
							 
wire [N-1:0] aof_c_w0,aof_c_w1;
reg aof_voiced1;							

		 

/*---------------------------------- speech_to_uq_lsps  ------------------------------------------------*/
reg startspeech;
reg [N-1:0] s_out_sn;
wire [N-1:0] E_speech,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9;
wire [9:0] s_addr_sn;
wire donespeech;

speech_to_uq_lsps_modified speech_module(startspeech,clk,rst,s_out_sn,
							E_speech,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9,s_addr_sn,
							donespeech);
							
							
/*---------------------------------encode_WoE-----------------------------------------------------------*/

reg startewoe;
reg [N-1:0] encode_model_wo,encode_in_e;
reg [N-1:0] xq0, xq1;
wire [N-1:0] encode_out_n1,e_out_xq0,e_out_xq1;
wire doneewoe;


encode_WoE encode_module(startewoe,clk,rst,encode_model_wo,encode_in_e,xq0,xq1,e_out_xq0,e_out_xq1,encode_out_n1,doneewoe);


/*-------------------------------RAM_encode_lsp ------------------------------------------------*/

reg [3:0] lsp;


/*------------------------------------encode_lsps_scalar module--------------------------------------------*/

reg start_elsp;
reg [3:0] in_index;
reg [N-1:0] in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9;

wire [3:0] out_index;
wire done_elsp;

encode_lsp_scalar_index e_lsp_scalar(start_elsp,clk,rst,in_index,
									in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9,
									out_index,
									done_elsp);
									
reg [7:0] toGray;

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
			NEXT_STATE = INIT_FOR_1;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end
	
	/* for(i=0; i<m_pitch-n_samp; i++)
      c2->Sn[i] = c2->Sn[i+n_samp];
    for(i=0; i<n_samp; i++)
      c2->Sn[i+m_pitch-n_samp] = speech[i]; */
	INIT_FOR_1:
	begin
		NEXT_STATE = CHECK_FOR1;
	end
	
	CHECK_FOR1:
	begin
		if(i < M_PITCH - N_SAMP)
		begin
			NEXT_STATE = READ_SN1;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_2;
		end
	end
	
	READ_SN1:
	begin
		NEXT_STATE = SET_DELAY_1;
	end
	
	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end
	
	SET_DELAY_2:
	begin
		NEXT_STATE = READ_DATA_SN1;
	end
	
	READ_DATA_SN1:
	begin
		NEXT_STATE = SET_ADDR_SN1;
	end
    
	SET_ADDR_SN1:
	begin
		NEXT_STATE = WRITE_SN1;
	end
	
	WRITE_SN1:
	begin
		NEXT_STATE = INCR_FOR1;
	end
	
	INCR_FOR1:
	begin
		NEXT_STATE = CHECK_FOR1;
	end
	
	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_FOR2;
	end
	
	CHECK_FOR2:
	begin
		if(i < N_SAMP)
		begin
			NEXT_STATE = READ_SN2;
		end
		else
		begin
			NEXT_STATE = START_AOF1;
		end
	end
	
	READ_SN2:
	begin
		NEXT_STATE = SET_DELAY_3;
	end
	
	SET_DELAY_3:
	begin
		NEXT_STATE = SET_DELAY_4;
	end
	
	SET_DELAY_4:
	begin
		NEXT_STATE = READ_DATA_SN2;
	end
	
	READ_DATA_SN2:
	begin
		NEXT_STATE = SET_ADDR_SN2;
	end
    
	SET_ADDR_SN2:
	begin
		NEXT_STATE = WRITE_SN2;
	end
	
	WRITE_SN2:
	begin
		NEXT_STATE = INCR_FOR2;
	end
	
	INCR_FOR2:
	begin
		NEXT_STATE = CHECK_FOR2;
	end
	

	START_AOF1:
	begin
		NEXT_STATE = RUN_AOF1;
	end

	RUN_AOF1:
	begin
		if(doneaof)
		begin
			NEXT_STATE = GET_AOF1;
		end
		else
		begin
			NEXT_STATE = RUN_AOF1;
		end
	end
	
	GET_AOF1:
	begin
		NEXT_STATE = INIT_FOR_3;
	end
	
	INIT_FOR_3:
	begin
		NEXT_STATE = CHECK_FOR3;
	end
	
	CHECK_FOR3:
	begin
		if(i < M_PITCH - N_SAMP)
		begin
			NEXT_STATE = READ_SN3;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_4;
		end
	end
	
	READ_SN3:
	begin
		NEXT_STATE = SET_DELAY_5;
	end
	
	SET_DELAY_5:
	begin
		NEXT_STATE = SET_DELAY_6;
	end
	
	SET_DELAY_6:
	begin
		NEXT_STATE = READ_DATA_SN3;
	end
	
	READ_DATA_SN3:
	begin
		NEXT_STATE = SET_ADDR_SN3;
	end
	
	SET_ADDR_SN3:
	begin
		NEXT_STATE = WRITE_SN3;
	end
	
	WRITE_SN3:
	begin
		NEXT_STATE = INCR_FOR3;
	end
	
	INCR_FOR3:
	begin
		NEXT_STATE = CHECK_FOR3;
	end
	
	INIT_FOR_4:
	begin
		NEXT_STATE = CHECK_FOR4;
	end
		
	CHECK_FOR4:
	begin
		if(i < N_SAMP)
		begin
			NEXT_STATE = READ_SN4;
		end
		else
		begin
			NEXT_STATE = START_AOF2;
		end
	end
	
	READ_SN4:
	begin
		NEXT_STATE = SET_DELAY_7;
	end
	
	SET_DELAY_7:
	begin
		NEXT_STATE = SET_DELAY_8;	
	end
	
	SET_DELAY_8:
	begin
		NEXT_STATE = READ_DATA_SN4;
	end
	
	READ_DATA_SN4:
	begin
		NEXT_STATE = SET_ADDR_SN4;
	end
		
	SET_ADDR_SN4:
	begin
		NEXT_STATE = WRITE_SN4;
	end
	
	WRITE_SN4:
	begin
		NEXT_STATE = INCR_FOR4;
	end
	
	INCR_FOR4:
	begin
		NEXT_STATE = CHECK_FOR4;
	end

	START_AOF2:
	begin
		NEXT_STATE = RUN_AOF2;
	end

	RUN_AOF2:
	begin
		if(doneaof)
		begin
			NEXT_STATE = GET_AOF2;
		end
		else
		begin
			NEXT_STATE = RUN_AOF2;
		end
	end
	
	GET_AOF2:
	begin
		NEXT_STATE = START_SPEECH; // DONE;//
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
		NEXT_STATE = START_ENCODEWOE;
	end
	
	START_ENCODEWOE:
	begin
		NEXT_STATE = RUN_ENCODEWOE;
	end

	RUN_ENCODEWOE:
	begin
		if(doneewoe)
		begin
			NEXT_STATE = GET_ENCODEWOE;
		end
		else
		begin
			NEXT_STATE = RUN_ENCODEWOE;
		end
	end
	
	GET_ENCODEWOE:
	begin
		NEXT_STATE = INIT_FOR_LSP;
	end
	
	INIT_FOR_LSP:
	begin
		NEXT_STATE = CHECK_LSP;
	end
	
	CHECK_LSP:
	begin
		if(lsp < 4'd10)
		begin
			NEXT_STATE = SET_DATA_LSP;
		end
		else
		begin
			NEXT_STATE = START_ELSP1;
		end
	end
	
	SET_DATA_LSP:
	begin
		NEXT_STATE = INCR_LSP;
	end
	
	INCR_LSP:
	begin
		NEXT_STATE = CHECK_LSP;
	end
	
	START_ELSP1:
	begin
		NEXT_STATE = SET_INDEX;
	end
	
	SET_INDEX:
	begin
		NEXT_STATE = RUN_ELSP;
	end

	RUN_ELSP:
	begin
		if(done_elsp)
		begin
			NEXT_STATE = GET_ELSP;
		end
		else
		begin
			NEXT_STATE = RUN_ELSP;
		end
	end
	
	GET_ELSP:
	begin
		NEXT_STATE = INCR_INDEX;
	end
	
	INCR_INDEX:
	begin
		NEXT_STATE = CHECK_INDEX;
	end
		
	CHECK_INDEX:
	begin	
		if(in_index < 4'd10)
		begin
			NEXT_STATE = SET_INDEX;
		end
		else
		begin
			NEXT_STATE = INDEX_TO_GRAY;
		end
		
	end
	
	INDEX_TO_GRAY:
	begin
		NEXT_STATE = SET_ENCODED_BITS;
	end
	
	SET_ENCODED_BITS:
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
		done_oneframe <= 1'b0;
			
	end

	else
	begin
		case(STATE)

		START:
		begin
			done_oneframe <= 1'b0;
			encoded_bits <= 48'd0;
			clk_count <= 80'b0;
			//done_elsp <= 1'b0;
		end
		
		/* for(i=0; i<m_pitch-n_samp; i++)
		  c2->Sn[i] = c2->Sn[i+n_samp];
		for(i=0; i<n_samp; i++)
		  c2->Sn[i+m_pitch-n_samp] = speech[i]; */
		INIT_FOR_1:
		begin
			i <= 10'd0;
			clk_count <= clk_count + 1'b1;
		end
		
		CHECK_FOR1:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		READ_SN1:
		begin
			addr_sn <= i + N_SAMP;
			re_c2_sn <= 1'b1;
			we_c2_sn <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_1:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_2:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		READ_DATA_SN1:
		begin
			sn_data <= read_c2_sn_out;
			clk_count <= clk_count + 1'b1;
		end
		
		SET_ADDR_SN1:
		begin
			addr_sn <= i;
			re_c2_sn <= 1'd0;
			we_c2_sn <= 1'd1;	
			clk_count <= clk_count + 1'b1;
		end
		
		WRITE_SN1:
		begin
			write_c2_sn <= sn_data;
			clk_count <= clk_count + 1'b1;
		end
		
		INCR_FOR1:
		begin
			i <= i + 10'd1;
			clk_count <= clk_count + 1'b1;
		end
		
		INIT_FOR_2:
		begin
			i <= 10'd0;
			clk_count <= clk_count + 1'b1;
		end
			

		CHECK_FOR2:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		READ_SN2:
		begin
			addr_speech <= i;
			//re_c2_sn <= 1'b1;
			//we_c2_sn <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_3:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_4:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		READ_DATA_SN2:
		begin
			sn_data <= out_speech;
			clk_count <= clk_count + 1'b1;
		end
			
		SET_ADDR_SN2:
		begin
			addr_sn <= i + M_PITCH - N_SAMP;
			re_c2_sn <= 1'b0;
			we_c2_sn <= 1'b1;
			clk_count <= clk_count + 1'b1;
		end
		
		WRITE_SN2:
		begin
			write_c2_sn <= sn_data;
			clk_count <= clk_count + 1'b1;
		end
		
		INCR_FOR2:
		begin
			i <= i + 10'd1;
			clk_count <= clk_count + 1'b1;
		end

		START_AOF1:
		begin
			startaof <= 1'b1;
			
			we_c2_sn <= 1'b0;
			re_c2_sn <= 1'b1;
			
		   aof_mem_x_in <= 32'b0;
			aof_mem_y_in <= 32'b0;
			aof_in_prev_f0 <= {16'd50,16'd0}; 
			
//			aof_mem_x_in <= in_mex_x;
//			aof_mem_y_in <= in_mem_y;
//			aof_in_prev_f0 <= in_prevf0;
			clk_count <= clk_count + 1'b1;
			
		end

		RUN_AOF1:
		begin
			aof_out_sn <= read_c2_sn_out;
			addr_sn <= aof_addr_sn;
			
			addr_mem_fir <= aof_addr_mem_fir;
			aof_out_mem_fir <= out_mem_fir;
			in_mem_fir <= aof_in_mem_fir;
			read_fir <= aof_read_fir;
			write_fir <= aof_write_fir;
			
			addr_nlp_sq <= aof_addr_nlp_sq;
			aof_out_sq <= out_sq;
			in_sq <= aof_in_sq;
			read_sq <= aof_read_sq;
			write_sq <= aof_write_sq;
			
			
	//		RAM_nlp_mem_fir  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);
	//RAM_nlp_sq      nlp_sq	       (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);		
			
			startaof <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		GET_AOF1:
		begin
			
			aof_voiced1 <= voiced_bit;
			c_w0_1 <= aof_w0_out;
			
			check_pitch1 <= aof_nlp_pitch;
			check_best_fo1 <= aof_out_prev_f0;
			
			clk_count <= clk_count + 1'b1;
			
		end
		
		
	/* 	for(i=0; i<m_pitch-n_samp; i++)
		  c2->Sn[i] = c2->Sn[i+n_samp];
		for(i=0; i<n_samp; i++)
		  c2->Sn[i+m_pitch-n_samp] = speech[i+80];  */
		INIT_FOR_3:
		begin
			i <= 10'd0;
			clk_count <= clk_count + 1'b1;
		end
		
		CHECK_FOR3:
		begin
			
		end
		
		READ_SN3:
		begin
			addr_sn <= i + N_SAMP;
			re_c2_sn <= 1'b1;
			we_c2_sn <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_5:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_6:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		READ_DATA_SN3:
		begin
			sn_data <= read_c2_sn_out;
				clk_count <= clk_count + 1'b1;
		end
		
		SET_ADDR_SN3:
		begin
			addr_sn <= i;
			re_c2_sn <= 1'd0;
			we_c2_sn <= 1'd1;	
				clk_count <= clk_count + 1'b1;
		end
		
		WRITE_SN3:
		begin
			write_c2_sn <= sn_data;
				clk_count <= clk_count + 1'b1;
		end
		
		INCR_FOR3:
		begin
			i <= i + 10'd1;
				clk_count <= clk_count + 1'b1;
		end
		
		INIT_FOR_4:
		begin
			i <= 10'd0;
				clk_count <= clk_count + 1'b1;
		end
			

		CHECK_FOR4:
		begin
				clk_count <= clk_count + 1'b1;
		end
		
		READ_SN4:
		begin
			addr_speech <= i + N_SAMP;
			//re_c2_sn <= 1'b1;
			//we_c2_sn <= 1'b0;
				clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_7:
		begin
				clk_count <= clk_count + 1'b1;
		end
		
		SET_DELAY_8:
		begin
			clk_count <= clk_count + 1'b1;	
		end
		
		READ_DATA_SN4:
		begin
			sn_data <= out_speech;
			clk_count <= clk_count + 1'b1;
		end
			
		SET_ADDR_SN4:
		begin
			addr_sn <= i + M_PITCH - N_SAMP;
			re_c2_sn <= 1'b0;
			we_c2_sn <= 1'b1;
			clk_count <= clk_count + 1'b1;
		end
		
		WRITE_SN4:
		begin
			write_c2_sn <= sn_data;
			clk_count <= clk_count + 1'b1;
		end
		
		INCR_FOR4:
		begin
			i <= i + 10'd1;
			clk_count <= clk_count + 1'b1;
		end
		

		START_AOF2:
		begin
		
			startaof <= 1'b1;
			
			we_c2_sn <= 1'b0;
			re_c2_sn <= 1'b1;
			
			aof_mem_x_in <= aof_mem_x_out;
			aof_mem_y_in <= aof_mem_y_out;
			aof_in_prev_f0 <= aof_out_prev_f0; 
			clk_count <= clk_count + 1'b1;
			
		end

		RUN_AOF2:
		begin
		
			aof_out_sn <= read_c2_sn_out;
			addr_sn <= aof_addr_sn;
			
			addr_mem_fir <= aof_addr_mem_fir;
			aof_out_mem_fir <= out_mem_fir;
			in_mem_fir <= aof_in_mem_fir;
			read_fir <= aof_read_fir;
			write_fir <= aof_write_fir;
			
			addr_nlp_sq <= aof_addr_nlp_sq;
			aof_out_sq <= out_sq;
			in_sq <= aof_in_sq;
			read_sq <= aof_read_sq;
			write_sq <= aof_write_sq;
			
			startaof <= 1'b0;
			clk_count <= clk_count + 1'b1;
			
		end
		
		GET_AOF2:
		begin
			
			encoded_bits <= {aof_voiced1,voiced_bit,46'd0};
			c_w0_2 <= aof_w0_out;
			c_w0 <= aof_c_w0;
			c_w1 <= aof_c_w1;
			
			check_pitch2 <= aof_nlp_pitch;
			check_best_fo2 <= aof_out_prev_f0;
			
			out_mem_x <= aof_mem_x_out;
			out_mem_y <= aof_mem_y_out;
			out_prevf0 <= aof_out_prev_f0;
			clk_count <= clk_count + 1'b1;
		end
		
		START_SPEECH:
		begin
			startspeech <= 1'b1;
			clk_count <= clk_count + 1'b1;
			
		end

		RUN_SPEECH:
		begin
			s_out_sn <= read_c2_sn_out;
			addr_sn <= s_addr_sn;
			
			startspeech <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		GET_SPEECH:
		begin
			c_e <= E_speech;
			//c_memy <= lsp9;
			//c_sn <= aof_w0_out;
			//nlp_pitch <= aof_nlp_pitch;
			//nlp_pitch1 <= aof_nlp_pitch1;
			clk_count <= clk_count + 1'b1;
		end
		
		
		START_ENCODEWOE:
		begin
			startewoe <= 1'b1;
			encode_in_e <= E_speech;
			encode_model_wo <= aof_w0_out;
			xq0 <= 32'b0;
			xq1 <= 32'b0; 
			
//			xq0 <= in_xq0;
//			xq1 <= in_xq1;	
			clk_count <= clk_count + 1'b1;
		end

		RUN_ENCODEWOE:
		begin
			startewoe <= 1'b0;
			clk_count <= clk_count + 1'b1;
		end
		
		GET_ENCODEWOE:
		begin
			c_sn <= encode_out_n1; 
			ch_lsp <= lsp0;
			
			out_xq0 <= e_out_xq0;
			out_xq1 <= e_out_xq1;
			//toGray[8] <= encode_out_n1[8];
			toGray[7] <= encode_out_n1[7];
			toGray[6] <= encode_out_n1[7] ^ encode_out_n1[6];
			toGray[5] <= encode_out_n1[6] ^ encode_out_n1[5];
			toGray[4] <= encode_out_n1[5] ^ encode_out_n1[4];
			toGray[3] <= encode_out_n1[4] ^ encode_out_n1[3];
			toGray[2] <= encode_out_n1[3] ^ encode_out_n1[2];
			toGray[1] <= encode_out_n1[2] ^ encode_out_n1[1];
			toGray[0] <= encode_out_n1[1] ^ encode_out_n1[0];
			
			clk_count <= clk_count + 1'b1;
		end
		
		INIT_FOR_LSP:
		begin
			lsp <= 4'd0;
			encoded_bits <= {encoded_bits[47:46],toGray,38'd0};
			
			clk_count <= clk_count + 1'b1;
		end
		
		CHECK_LSP:
		begin
		
			clk_count <= clk_count + 1'b1;
		end
		
		SET_DATA_LSP:
		begin
			
			
			case(lsp)
			
			4'd0:	in_lsp0 <= lsp0;
			4'd1:	in_lsp1 <= lsp1;
			4'd2:	in_lsp2 <= lsp2;
			4'd3:	in_lsp3 <= lsp3;
			4'd4:	in_lsp4 <= lsp4;
			4'd5:	in_lsp5 <= lsp5;
			4'd6:	in_lsp6 <= lsp6;
			4'd7:	in_lsp7 <= lsp7;
			4'd8:	in_lsp8 <= lsp8;
			4'd9:	in_lsp9 <= lsp9;
			
			endcase
			
			
			/* case(lsp)
			
			4'd0:	clsp0 <= lsp0;
			4'd1:	clsp1 <= lsp1;
			4'd2:	clsp2 <= lsp2;
			4'd3:	clsp3 <= lsp3;
			4'd4:	clsp4 <= lsp4;
			4'd5:	clsp5 <= lsp5;
			4'd6:	clsp6 <= lsp6;
			4'd7:	clsp7 <= lsp7;
			4'd8:	clsp8 <= lsp8;
			4'd9:	clsp9 <= lsp9;
			
			endcase */
			clk_count <= clk_count + 1'b1;
			
		end
		
		INCR_LSP:
		begin
			lsp <= lsp + 4'd1;
			clk_count <= clk_count + 1'b1;
		end
		
		START_ELSP1:
		begin
			in_index <= 4'd0;
			clk_count <= clk_count + 1'b1;
		end
		
		SET_INDEX:
		begin
			start_elsp <= 1'b1;
			clk_count <= clk_count + 1'b1;
		end

		RUN_ELSP:
		begin
			
			
			
			start_elsp <= 1'b0;
			clk_count <= clk_count + 1'b1;
			
		end
		
		GET_ELSP:
		begin
			
			
			case(in_index)
			
			4'd0:	clsp0 <= out_index;
			4'd1:	clsp1 <= out_index;
			4'd2:	clsp2 <= out_index;
			4'd3:	clsp3 <= out_index;
			4'd4:	clsp4 <= out_index;
			4'd5:	clsp5 <= out_index;
			4'd6:	clsp6 <= out_index;
			4'd7:	clsp7 <= out_index;
			4'd8:	clsp8 <= out_index;
			4'd9:	clsp9 <= out_index;
			
			endcase 
			
			clk_count <= clk_count + 1'b1;
									
		end
		
		INCR_INDEX:
		begin
			in_index <= in_index + 4'd1;
			
			clk_count <= clk_count + 1'b1;
		end
		
		CHECK_INDEX:
		begin
			clk_count <= clk_count + 1'b1;
		end
		
		INDEX_TO_GRAY:
		begin
			case(clsp0)
				4'd0 : clsp0 <= 4'd0;
				4'd1 : clsp0 <= 4'd1;
				4'd2 : clsp0 <= 4'd3;
				4'd3 : clsp0 <= 4'd2;
				4'd4 : clsp0 <= 4'd6;
				4'd5 : clsp0 <= 4'd7;
				4'd6 : clsp0 <= 4'd5;
				4'd7 : clsp0 <= 4'd4;
				4'd8 : clsp0 <= 4'd12;
				4'd9 : clsp0 <= 4'd13;
			endcase
			
			case(clsp1)
				4'd0 : clsp1 <= 4'd0;
				4'd1 : clsp1 <= 4'd1;
				4'd2 : clsp1 <= 4'd3;
				4'd3 : clsp1 <= 4'd2;
				4'd4 : clsp1 <= 4'd6;
				4'd5 : clsp1 <= 4'd7;
				4'd6 : clsp1 <= 4'd5;
				4'd7 : clsp1 <= 4'd4;
				4'd8 : clsp1 <= 4'd12;
				4'd9 : clsp1 <= 4'd13;
			endcase
			
			case(clsp2)
				4'd0 : clsp2 <= 4'd0;
				4'd1 : clsp2 <= 4'd1;
				4'd2 : clsp2 <= 4'd3;
				4'd3 : clsp2 <= 4'd2;
				4'd4 : clsp2 <= 4'd6;
				4'd5 : clsp2 <= 4'd7;
				4'd6 : clsp2 <= 4'd5;
				4'd7 : clsp2 <= 4'd4;
				4'd8 : clsp2 <= 4'd12;
				4'd9 : clsp2 <= 4'd13;
			endcase
			
			case(clsp3)
				4'd0 : clsp3 <= 4'd0;
				4'd1 : clsp3 <= 4'd1;
				4'd2 : clsp3 <= 4'd3;
				4'd3 : clsp3 <= 4'd2;
				4'd4 : clsp3 <= 4'd6;
				4'd5 : clsp3 <= 4'd7;
				4'd6 : clsp3 <= 4'd5;
				4'd7 : clsp3 <= 4'd4;
				4'd8 : clsp3 <= 4'd12;
				4'd9 : clsp3 <= 4'd13;
			endcase
			
			case(clsp4)
				4'd0 : clsp4 <= 4'd0;
				4'd1 : clsp4 <= 4'd1;
				4'd2 : clsp4 <= 4'd3;
				4'd3 : clsp4 <= 4'd2;
				4'd4 : clsp4 <= 4'd6;
				4'd5 : clsp4 <= 4'd7;
				4'd6 : clsp4 <= 4'd5;
				4'd7 : clsp4 <= 4'd4;
				4'd8 : clsp4 <= 4'd12;
				4'd9 : clsp4 <= 4'd13;
			endcase
			
			case(clsp5)
				4'd0 : clsp5 <= 4'd0;
				4'd1 : clsp5 <= 4'd1;
				4'd2 : clsp5 <= 4'd3;
				4'd3 : clsp5 <= 4'd2;
				4'd4 : clsp5 <= 4'd6;
				4'd5 : clsp5 <= 4'd7;
				4'd6 : clsp5 <= 4'd5;
				4'd7 : clsp5 <= 4'd4;
				4'd8 : clsp5 <= 4'd12;
				4'd9 : clsp5 <= 4'd13;
			endcase
			
			case(clsp6)
				4'd0 : clsp6 <= 4'd0;
				4'd1 : clsp6 <= 4'd1;
				4'd2 : clsp6 <= 4'd3;
				4'd3 : clsp6 <= 4'd2;
				4'd4 : clsp6 <= 4'd6;
				4'd5 : clsp6 <= 4'd7;
				4'd6 : clsp6 <= 4'd5;
				4'd7 : clsp6 <= 4'd4;
				4'd8 : clsp6 <= 4'd12;
				4'd9 : clsp6 <= 4'd13;
			endcase
			
			case(clsp7)
				4'd0 : clsp7 <= 3'd0;
				4'd1 : clsp7 <= 3'd1;
				4'd2 : clsp7 <= 3'd3;
				4'd3 : clsp7 <= 3'd2;
				4'd4 : clsp7 <= 3'd6;
				4'd5 : clsp7 <= 3'd7;
				4'd6 : clsp7 <= 3'd5;
				4'd7 : clsp7 <= 3'd4;
				4'd8 : clsp7 <= 3'd12;
				4'd9 : clsp7 <= 3'd13;
			endcase
			
			case(clsp8)
				4'd0 : clsp8 <= 3'd0;
				4'd1 : clsp8 <= 3'd1;
				4'd2 : clsp8 <= 3'd3;
				4'd3 : clsp8 <= 3'd2;
				4'd4 : clsp8 <= 3'd6;
				4'd5 : clsp8 <= 3'd7;
				4'd6 : clsp8 <= 3'd5;
				4'd7 : clsp8 <= 3'd4;
				4'd8 : clsp8 <= 3'd12;
				4'd9 : clsp8 <= 3'd13;

			endcase
			
			case(clsp9)
				4'd0 : clsp9 <= 2'd0;
				4'd1 : clsp9 <= 2'd1;
				4'd2 : clsp9 <= 2'd3;
				4'd3 : clsp9 <= 2'd2;
				4'd4 : clsp9 <= 2'd6;
				4'd5 : clsp9 <= 2'd7;
				4'd6 : clsp9 <= 2'd5;
				4'd7 : clsp9 <= 2'd4;
				4'd8 : clsp9 <= 2'd12;
				4'd9 : clsp9 <= 2'd13;
			endcase
			
			clk_count <= clk_count + 1'b1;
			
		end
	
		SET_ENCODED_BITS:
		begin
			encoded_bits <= {encoded_bits[47:38],clsp0,clsp1,clsp2,clsp3,clsp4,
												clsp5,clsp6,clsp7[2:0],clsp8[2:0],clsp9[1:0],2'd0};
												
			clk_count <= clk_count + 1'b1;
		end	
		
		DONE:
		begin
			done_oneframe <= 1'b1;
		end

		endcase
	end

end


endmodule