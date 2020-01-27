
										
 module CODEC2_one_frame_encoder (	start_oneframe,clk, rst,
										
											out_mem_x,out_mem_y,out_prevf0, out_xq0, out_xq1,
											encoded_bits,
											
											done_oneframe,c_encode_model_wo,c_pitch1,c_pitch2,c_cmax1, c_cmax2,c_e,c_sn
											
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
				reg  [N-1:0] in_prevf0,in_xq0, in_xq1;
			
				output reg [BITS_WIDTH-1 : 0] encoded_bits;
				
				output reg [N1-1:0] out_mem_x,out_mem_y;
				output reg [N-1:0] out_prevf0, out_xq0, out_xq1;
				
				output  reg [9:0] c_cmax1, c_cmax2;

				output reg done_oneframe;
				
				reg [N-1:0] check_sum;
	
				reg [N-1:0] c_w0_1,c_w0_2,c_w0,c_w1;
	
				reg [N-1:0] check_pitch1, check_pitch2;
					
				output reg [N-1:0] c_encode_model_wo,c_pitch1,c_pitch2;
				
				output reg [N-1:0] c_e,c_sn;
				
				
				 
				reg [9:0] addr_speech;
				wire [N-1:0] out_speech;
				RAM_speech_0  r_speech_0(addr_speech,clk,,1,0,out_speech); 
			
//				----------- RAM_speech for one_frame - 320 size -------------------
				reg [9:0] addr_sn;
				reg [N-1:0] write_c2_sn;
				reg re_c2_sn,we_c2_sn;
				wire [N-1:0] read_c2_sn_out;
				 
				RAM_c2_sn_test_nlp c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   

//				----------- RAM_nlp_mem_fir - size 48 -------------------
				reg [9:0] addr_mem_fir;
				reg [N1-1:0] in_mem_fir;
				reg read_fir, write_fir;
				wire [N1-1:0] out_mem_fir;
											 
				RAM_nlp_mem_fir_80  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	

//				--------- RAM_nlp_sq - size 320 --------------------
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
			 INIT_FOR_2 = 7'd6,
			 CHECK_FOR2 = 7'd7,
			 READ_SN2 = 7'd8,
			 SET_DELAY_3 = 7'd9,
			 SET_DELAY_4 = 7'd10,
			 READ_DATA_SN2 = 7'd11,
			 INCR_FOR2 = 7'd12,
			 GET_AOF1 = 7'd13,
			 AA_SET_ADDR = 7'd14,
			 AA_SET_ADDR1 = 7'd15,
			 AA_SET_ADDR2 = 7'd16,
			 AA_SET_ADDR_GET = 7'd17,
			 INIT_FOR_4 = 7'd18,
			CHECK_FOR_4 = 7'd19,
			READ_SN4 = 7'd20,
			SET_DELAY_5 = 7'd21,
			SET_DELAY_6 = 7'd22,
			READ_DATA_SN4 = 7'd23,
			INCR_FOR_4 = 7'd24,
			GET_AOF2 = 7'd25,
			START_SPEECH = 7'd26,
			RUN_SPEECH = 7'd27,
			GET_SPEECH = 7'd28,
			START_ENCODEWOE = 7'd29,
			RUN_ENCODEWOE = 7'd30,
			GET_ENCODEWOE = 7'd31,
			INIT_FOR_LSP = 7'd32,
			CHECK_LSP = 7'd33,
			SET_DATA_LSP = 7'd34,
			INCR_LSP = 7'd35,
			START_ELSP1 = 7'd36,
			SET_INDEX = 7'd37,
			RUN_ELSP = 7'd38,
			GET_ELSP = 7'd39,
			INCR_INDEX = 7'd40,
			CHECK_INDEX = 7'd41,
			INDEX_TO_GRAY = 7'd42,
			SET_ENCODED_BITS = 7'd43;
			

reg [6:0] STATE, NEXT_STATE;

parameter [9:0] N_SAMP = 10'd80,
				M_PITCH = 10'd320;
//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
 reg [9:0] i;
 reg [N-1:0] sn_data;
 
 
 
 reg [N-1:0] a1_in1;
 reg [N-1:0] a1_in2;
 wire [N-1:0] a1_out;
 
 qadd   #(Q,N)			adder1    (a1_in1,a1_in2,a1_out);
 



/*----------------------------------analyse_one_frame--------------------------------------------------*/

reg startaof;
reg [N1-1:0] aof_mem_x_in,aof_mem_y_in, aof_out_mem_fir, aof_out_sq;
reg [N-1:0] aof_in_prev_f0, aof_out_sn;
wire [N1-1:0] aof_mem_x_out,aof_mem_y_out,aof_in_mem_fir,aof_in_sq;
wire [N-1:0] aof_out_prev_f0,out_best_f0,aof_w0_out,aof_nlp_pitch;
wire [9:0] aof_addr_sn,aof_addr_mem_fir,aof_addr_nlp_sq;
wire voiced_bit,doneaof,aof_read_fir,aof_write_fir,aof_read_sq,aof_write_sq;
wire [9:0] c_cmax;
wire [N-1:0] aof_check_i;
wire [N1-1:0] c_outreal,aof_check_in_real,aof_check_in_imag;

analyse_one_frame aof (	startaof,clk,rst,
							/*--- input------------------ */
							 aof_mem_x_in,aof_mem_y_in,aof_in_prev_f0,aof_out_sn,aof_out_mem_fir,aof_out_sq,
							/*--------------------------- */
							
							/*--- output----------------------------------------------------------- */
						     aof_mem_x_out,aof_mem_y_out,aof_out_prev_f0,out_best_f0,aof_w0_out,voiced_bit,aof_addr_sn,
							 aof_addr_mem_fir,aof_in_mem_fir,aof_nlp_pitch,aof_read_fir,aof_write_fir,
							 
							 aof_addr_nlp_sq,aof_in_sq,aof_read_sq,aof_write_sq,
							/*--------------------------------------------------------------------- */
							 doneaof ,c_cmax,aof_check_i// c_outreal, aof_check_in_real,aof_check_in_imag
							 
							 );
							 
wire [N-1:0] aof_c_w0,aof_c_w1;
reg aof_voiced1;			

reg [9:0] i1,j1;	

/*---------------------------------- speech_to_uq_lsps  ------------------------------------------------*/
reg startspeech;
reg [N-1:0] s_out_sn;
wire [N-1:0] E_speech,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9,check_corr;
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
		 
reg [3:0] lsp;
reg [7:0] toGray;

/*------------------------------------encode_lsps_scalar module--------------------------------------------*/

reg [3:0] clsp0,clsp1,clsp2,clsp3,clsp4,clsp5,clsp6,clsp7,clsp8,clsp9;
reg start_elsp;
reg [3:0] in_index;
reg [N-1:0] in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9;

wire [3:0] out_index;
wire done_elsp;

encode_lsp_scalar_index e_lsp_scalar(start_elsp,clk,rst,in_index,
									in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9,
									out_index,
									done_elsp);


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


always@(*)
begin
	case(STATE)
	
		 /* START:
		begin
			
		end */
		
		//for(i=0; i<m_pitch-n_samp; i++)
		//  c2->Sn[i] = c2->Sn[i+n_samp];
		//for(i=0; i<n_samp; i++)
	   //  c2->Sn[i+m_pitch-n_samp] = speech[i]; 
	   
	
	
		
		/*INIT_FOR_2:
		begin
			
		end 
			

		CHECK_FOR2:
		begin
			
		end */
		
		READ_SN2:
		begin
			addr_speech = i1;
			addr_sn = i1 + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
			
		end
		
		SET_DELAY_3:
		begin
			addr_speech = i1;
			addr_sn = i1 + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
			
		end
		
		SET_DELAY_4:
		begin
			addr_speech = i1;
			addr_sn = i1 + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
			
		end
		
		READ_DATA_SN2:
		begin
			//sn_data = out_speech;	
			write_c2_sn = out_speech;
			addr_speech = i1;
			addr_sn = i1 + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
			
		end
		
		/* INCR_FOR2:
		begin
			
		end */
		
		START_AOF1:
		begin
			
			/*  aof_out_sn = read_c2_sn_out;
			addr_sn = aof_addr_sn;  */
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
		
			 /* addr_mem_fir = aof_addr_mem_fir;
			aof_out_mem_fir = out_mem_fir;
			in_mem_fir = aof_in_mem_fir;
			read_fir = aof_read_fir;
			write_fir = aof_write_fir;
				
			addr_nlp_sq = aof_addr_nlp_sq;
			aof_out_sq = out_sq;
			in_sq = aof_in_sq;
			read_sq = aof_read_sq;
			write_sq = aof_write_sq; */  
		end
	
		RUN_AOF1:
		begin
			
			aof_out_sn = read_c2_sn_out;
			addr_sn = aof_addr_sn;
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
		
			addr_mem_fir = aof_addr_mem_fir;
			aof_out_mem_fir = out_mem_fir;
			in_mem_fir = aof_in_mem_fir;
			read_fir = aof_read_fir;
			write_fir = aof_write_fir;
				
			addr_nlp_sq = aof_addr_nlp_sq;
			aof_out_sq = out_sq;
			in_sq = aof_in_sq;
			read_sq = aof_read_sq;
			write_sq = aof_write_sq;	
		end
		
		/* GET_AOF1:
		begin
	
		end */
		
		/* INIT_FOR_4:
		begin
			
		end
		
		CHECK_FOR_4:
		begin
			
		end */
		
		READ_SN4:
		begin
			addr_speech = j1;
			addr_sn = j1 + 10'd160;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_5:
		begin
			addr_speech = j1;
			addr_sn = j1 + 10'd160;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_6:
		begin
			addr_speech = j1;
			addr_sn = j1 + 10'd160;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		READ_DATA_SN4:
		begin
			write_c2_sn = out_speech;
			addr_speech = j1;
			addr_sn = j1 + 10'd160;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
	   
		/* INCR_FOR_4:
		begin
			
		end */
		
		START_AOF2:
		begin
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
		end

		RUN_AOF2:
		begin
			aof_out_sn = read_c2_sn_out;
			addr_sn = aof_addr_sn;
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
		
			addr_mem_fir = aof_addr_mem_fir;
			aof_out_mem_fir = out_mem_fir;
			in_mem_fir = aof_in_mem_fir;
			read_fir = aof_read_fir;
			write_fir = aof_write_fir;
				
			addr_nlp_sq = aof_addr_nlp_sq;
			aof_out_sq = out_sq;
			in_sq = aof_in_sq;
			read_sq = aof_read_sq;
			write_sq = aof_write_sq;	
		end
		
		/* GET_AOF2:
		begin
			
		end */
		
		
		START_SPEECH:
		begin
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
			
		end

		RUN_SPEECH:
		begin
			s_out_sn = read_c2_sn_out;
			addr_sn = s_addr_sn; 
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
			
		end
		
		/* 
		GET_SPEECH:
		begin
		
		end */
		
		
	AA_SET_ADDR:
	begin
		addr_sn = 10'd248;
		we_c2_sn = 1'b0;
		re_c2_sn = 1'b1;
		
	end
	
	AA_SET_ADDR1:
	begin
			addr_sn = 10'd248;
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
			
	end
	
	AA_SET_ADDR2:
	begin
			addr_sn = 10'd248;
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;
		
	end
	
	AA_SET_ADDR_GET:
	begin
			addr_sn = 10'd248;
			we_c2_sn = 1'b0;
			re_c2_sn = 1'b1;

	end
	
	default:
	begin
		    addr_sn = 10'd0;
			re_c2_sn = 10'd0;
			we_c2_sn = 10'd0;
			addr_speech = 10'd0;
			//sn_data = 32'b0;
			//write_c2_sn = 32'b0; 
		
	end
	
	endcase



end 


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		if(start_oneframe)
		begin
			NEXT_STATE = INIT_FOR_2; //INIT_FOR_1;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end
	
	/* for(i=0; i<m_pitch-n_samp; i++)   					 i < 240
      c2->Sn[i] = c2->Sn[i+n_samp];
    for(i=0; i<n_samp; i++)   								i < 80
      c2->Sn[i+m_pitch-n_samp] = speech[i]; */
	
	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_FOR2;
	end
	
	CHECK_FOR2:
	begin
		if(i1 < N_SAMP)   
		begin
			NEXT_STATE = READ_SN2;
		end
		else
		begin
			NEXT_STATE = START_AOF1;   //AA_SET_ADDR; //
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
		NEXT_STATE = INCR_FOR2; //SET_ADDR_SN2;
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
		NEXT_STATE =  INIT_FOR_4; ///DONE;
	end
	
	INIT_FOR_4:
	begin
		NEXT_STATE = CHECK_FOR_4;
	end
	
	CHECK_FOR_4:
	begin
		if(j1 < 10'd160)   
		begin
			NEXT_STATE = READ_SN4;
		end
		else
		begin
			NEXT_STATE = START_AOF2;   //AA_SET_ADDR; //
		end
	end
	
	READ_SN4:
	begin
		NEXT_STATE = SET_DELAY_5;
	end
	
	SET_DELAY_5:
	begin
		NEXT_STATE = SET_DELAY_6;
	end
	
	SET_DELAY_6:
	begin
		NEXT_STATE = READ_DATA_SN4;
	end
	
	READ_DATA_SN4:
	begin
		NEXT_STATE = INCR_FOR_4; //SET_ADDR_SN2;
	end
   
	INCR_FOR_4:
	begin
		NEXT_STATE = CHECK_FOR_4;
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
		NEXT_STATE = START_SPEECH;
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
	
	AA_SET_ADDR:
	begin
		NEXT_STATE = AA_SET_ADDR1;
	end
	
	AA_SET_ADDR1:
	begin
		NEXT_STATE = AA_SET_ADDR2;
	end
	
	AA_SET_ADDR2:
	begin
		NEXT_STATE = AA_SET_ADDR_GET;
	end
	
	AA_SET_ADDR_GET:
	begin
		NEXT_STATE = DONE;
	end	
	
	DONE:
	begin
		NEXT_STATE = DONE;    //START;
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
			
			//done_elsp <= 1'b0;
		end
		
		/* for(i=0; i<m_pitch-n_samp; i++)
		  c2->Sn[i] = c2->Sn[i+n_samp];
		for(i=0; i<n_samp; i++)
		  c2->Sn[i+m_pitch-n_samp] = speech[i]; */
		
		INIT_FOR_2:
		begin
			i1 <= 10'd0;
			encoded_bits <= 48'd0;
			check_sum <= 32'b0;
		end
			

		CHECK_FOR2:
		begin
			
		end
		
		READ_SN2:
		begin
			//addr_speech <= i;
			//re_c2_sn <= 1'b0;
			//we_c2_sn <= 1'b1;
		end
		
		SET_DELAY_3:
		begin
			
		end
		
		SET_DELAY_4:
		begin
			
		end
		
		READ_DATA_SN2:
		begin
			//sn_data <= out_speech;	
			
		end
			
		
		INCR_FOR2:
		begin
			i1 <= i1 + 10'd1;
		end


		START_AOF1:
		begin
			startaof <= 1'b1;
				
		    aof_mem_x_in <= 32'b0;
			aof_mem_y_in <= 32'b0;
			aof_in_prev_f0 <= {16'd50,16'd0};   
			
			/* aof_mem_x_in <= in_mex_x;
			aof_mem_y_in <= in_mem_y;
			aof_in_prev_f0 <= in_prevf0;  */
			
		end

		RUN_AOF1:
		begin			
			startaof <= 1'b0;
		end
		
		GET_AOF1:
		begin
			
			aof_voiced1 <= voiced_bit;
			c_w0_1 <= aof_w0_out;
			
			check_pitch1 <= aof_nlp_pitch;
			c_cmax1 <= c_cmax;
			
			//check_sum <= aof_w0_out;
			
			//c_pitch1 <= aof_nlp_pitch;
			c_encode_model_wo <= aof_w0_out;
			//c_pitch2 <= aof_check_i;
			
			out_mem_x <= aof_mem_x_out;
			out_mem_y <= aof_mem_y_out;
			out_prevf0 <= aof_out_prev_f0;
			
			
			
		end
		
		
		INIT_FOR_4:
		begin
			j1 <= 10'd0;
		end
		
		CHECK_FOR_4:
		begin
			
		end
		
		READ_SN4:
		begin
			
		end
		
		SET_DELAY_5:
		begin
			
		end
		
		SET_DELAY_6:
		begin
			
		end
		
		READ_DATA_SN4:
		begin
			
		end
	   
		INCR_FOR_4:
		begin
			j1 <= j1 + 10'd1;
		end
		
		START_AOF2:
		begin
			startaof <= 1'b1;
				
		    aof_mem_x_in <= aof_mem_x_out;
			aof_mem_y_in <= aof_mem_y_out;
			aof_in_prev_f0 <= aof_out_prev_f0;   
		end

		RUN_AOF2:
		begin
			startaof <= 1'b0;
		end
		
		GET_AOF2:
		begin
			//c_pitch2 <= aof_nlp_pitch;
			c_encode_model_wo <= aof_w0_out;
			
			out_mem_x <= aof_mem_x_out;
			out_mem_y <= aof_mem_y_out;
			out_prevf0 <= aof_out_prev_f0;
			
			encoded_bits <= {aof_voiced1,voiced_bit,46'd0};
		end
		
		START_SPEECH:
		begin
			startspeech <= 1'b1;
			
		end

		RUN_SPEECH:
		begin
			//s_out_sn <= read_c2_sn_out;
			//addr_sn <= s_addr_sn; 
			
			startspeech <= 1'b0;
		end
		
		GET_SPEECH:
		begin
			c_e <= E_speech;
			//c_memy <= lsp9;
			//c_sn <= aof_w0_out;
			//nlp_pitch <= aof_nlp_pitch;
			//nlp_pitch1 <= aof_nlp_pitch1;
			c_pitch1 <= lsp0;
			c_pitch2 <= lsp1;
		end
		
		START_ENCODEWOE:
		begin
			startewoe <= 1'b1;
			encode_in_e <= E_speech;
			encode_model_wo <= aof_w0_out;
			c_encode_model_wo <= aof_w0_out;
		

			xq0 <= 32'b0;
			xq1 <= 32'b0; 
			
			/* xq0 <= in_xq0;
			xq1 <= in_xq1; */
		end

		RUN_ENCODEWOE:
		begin
			startewoe <= 1'b0;
		end
		
		GET_ENCODEWOE:
		begin
			c_sn <= encode_out_n1; 
			
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
		end
		
		INIT_FOR_LSP:
		begin
			lsp <= 4'd0;
			encoded_bits <= {encoded_bits[47:46],toGray,38'd0};
		end
		
		CHECK_LSP:
		begin
			
		end
		
		SET_DATA_LSP:
		begin
			
			
			case(lsp)
			
			4'd0:	
			begin
				in_lsp0 <= lsp0;
			end
			4'd1:
			begin
				in_lsp1 <= lsp1;
			end
			4'd2:
			begin
				in_lsp2 <= lsp2;
			end			
			4'd3:	
			begin
				in_lsp3 <= lsp3;
			end	
			4'd4:
			begin
				in_lsp4 <= lsp4;
			end				
			4'd5:	
			begin
				in_lsp5 <= lsp5;
			end	
			4'd6:
			begin
				in_lsp6 <= lsp6;
			end				
			4'd7:
			begin
				in_lsp7 <= lsp7;
			end				
			4'd8:
			begin
				in_lsp8 <= lsp8;
			end				
			4'd9:	
			begin
				in_lsp9 <= lsp9;
			end	
			
			endcase
			
		end
		
		INCR_LSP:
		begin
			lsp <= lsp + 4'd1;
		end
		
		START_ELSP1:
		begin
			in_index <= 4'd0;
		end
		
		SET_INDEX:
		begin
			start_elsp <= 1'b1;
		end

		RUN_ELSP:
		begin
			start_elsp <= 1'b0;		
		end
		
		GET_ELSP:
		begin
			case(in_index)
			4'd0:
				begin
				clsp0 <= out_index;
				end
			4'd1:	
				begin
				clsp1 <= out_index;
				end
			4'd2:	
				begin
				clsp2 <= out_index;
				end
			4'd3:	
				begin
				clsp3 <= out_index;
				end
			4'd4:
				begin
				clsp4 <= out_index;
				end
			4'd5:	
				begin
				clsp5 <= out_index;
				end
			4'd6:	
				begin
				clsp6 <= out_index;
				end
			4'd7:
				begin
				clsp7 <= out_index;
				end
			4'd8:
				begin
				clsp8 <= out_index;
				end
			4'd9:
				begin
				clsp9 <= out_index;
				end
			endcase 
									
		end
		
		INCR_INDEX:
		begin
			in_index <= in_index + 4'd1;
		end
		
		CHECK_INDEX:
		begin
		
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
			
			
		end
	
		SET_ENCODED_BITS:
		begin
			encoded_bits <= {encoded_bits[47:38],clsp0,clsp1,clsp2,clsp3,clsp4,
												clsp5,clsp6,clsp7[2:0],clsp8[2:0],clsp9[1:0],2'd0};
		end	
		
		
		
		AA_SET_ADDR:
		begin
		//	addr_sn <= 10'd240;
			//we_c2_sn <= 1'b0;
			//re_c2_sn <= 1'b1;
		end
		
		AA_SET_ADDR1:
		begin
		
		end
		
		AA_SET_ADDR2:
		begin
		
		end
		
		AA_SET_ADDR_GET:
		begin
			//c_pitch2 <= read_c2_sn_out;
		end	
		
		DONE:
		begin
			done_oneframe <= 1'b1;
					
		end

		endcase
	end

end


endmodule