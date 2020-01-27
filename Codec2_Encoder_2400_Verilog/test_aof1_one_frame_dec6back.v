
										
 module test_aof1_one_frame_dec6back (	start_oneframe,clk, rst,
										//  in_mex_x, in_mem_y ,   in_prevf0, in_xq0, in_xq1,
										 // out_speech,read_c2_sn_out,out_mem_fir,out_sq, 		
									  
											// output
											out_mem_x,out_mem_y,out_prevf0, out_xq0, out_xq1,
											encoded_bits,
											// addr_speech,addr_sn,write_c2_sn,
											//re_c2_sn,we_c2_sn,		
											//addr_mem_fir, in_mem_fir ,read_fir,write_fir,
//addr_nlp_sq, in_sq ,read_sq,write_sq, 
											done_oneframe,c_encode_model_wo,c_pitch1,c_pitch2,c_cmax1, c_cmax2
											// clsp9,,c_sn,
											//c_lsp0,c_lsp1,c_lsp2,c_lsp3,c_lsp4,c_lsp5,c_lsp6,c_lsp7,c_lsp8,c_lsp9,
											/* c_speech_lsp0,c_speech_lsp1,c_speech_lsp2,c_speech_lsp3,c_speech_lsp4,
								   c_speech_lsp5,c_speech_lsp6,c_speech_lsp7,c_speech_lsp8,c_speech_lsp9, c_e */
								  // , //  c_outreal1, c_outreal2,c_check_in_real,c_check_in_imag //
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
				reg [N-1:0] c_lsp_check;//,c_sn, ;				 
				reg [3:0] clsp0,clsp1,clsp2,clsp3,clsp4,clsp5,clsp6,clsp7,clsp8;
				 reg [3:0] clsp9;
				 reg [N1-1:0] c_outreal1, c_outreal2, c_check_in_real,c_check_in_imag;
			
					
				reg [N-1:0] check_pitch1, check_pitch2;
				reg [N-1:0] check_best_fo1, check_best_fo2;
				
				
				reg [N-1:0] ch_lsp;
		    		
				output reg [N-1:0] c_encode_model_wo,c_pitch1,c_pitch2;
				
				  reg [N-1:0] c_sn;
				
				 reg [4:0] c_lsp0,c_lsp1,c_lsp2,c_lsp3,c_lsp4,c_lsp5,c_lsp6,c_lsp7,c_lsp8,c_lsp9;
				  reg [N-1:0] c_speech_lsp0,c_speech_lsp1,c_speech_lsp2,c_speech_lsp3,c_speech_lsp4,
								   c_speech_lsp5,c_speech_lsp6,c_speech_lsp7,c_speech_lsp8,c_speech_lsp9,c_e;
				 
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
			 
			 SET_DELAY_111 = 7'd25,
			 AA_SET_ADDR = 7'd26,
			 AA_SET_ADDR1 = 7'd27,
			 AA_SET_ADDR2 = 7'd28,
			 AA_SET_ADDR_GET = 7'd29,
			 SET_DELAY_112 = 7'd30,
			 SET_DELAY_113 = 7'd31,
			 SET_DELAY_11 = 7'd32,
			 SET_DELAY_12 = 7'd33;
			
			 



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

reg [9:0] i1;				

		 

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
	
		 START:
		begin
			
		end
		
		//for(i=0; i<m_pitch-n_samp; i++)
		//  c2->Sn[i] = c2->Sn[i+n_samp];
		//for(i=0; i<n_samp; i++)
		//  c2->Sn[i+m_pitch-n_samp] = speech[i]; 
		
		INIT_FOR_2:
		begin
			
		end 
			

		CHECK_FOR2:
		begin
			
		end
		
		READ_SN2:
		begin
			addr_speech = i1;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_3:
		begin
			addr_speech = i1;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_4:
		begin
			addr_speech = i1;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		READ_DATA_SN2:
		begin
			sn_data = out_speech;	
			addr_speech = i1;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
			
		SET_ADDR_SN2:
		begin
			addr_sn = i1 + 10'd240;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_111:
		begin
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_112:
		begin
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		SET_DELAY_113:
		begin
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		WRITE_SN2:
		begin
			write_c2_sn = sn_data;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;		
		end
		
		INCR_FOR2:
		begin
			
		end
		
		START_AOF1:
		begin
			
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
		
		INIT_FOR_4:
		begin
			
		end
			

		CHECK_FOR4:
		begin
			
		end
		
		READ_SN4:
		begin
			addr_speech = i2;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end
		
		SET_DELAY_7:
		begin
			addr_speech = i2;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end
		
		SET_DELAY_8:
		begin
			addr_speech = i2;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end
		
		READ_DATA_SN4:
		begin
			sn_data = out_speech;
			addr_speech = i2;
			re_c2_sn = 1'b1;
			we_c2_sn = 1'b0;
		end
			
		SET_ADDR_SN4:
		begin
			addr_sn = i2 + 10'd160;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		WRITE_SN4:
		begin
			write_c2_sn <= sn_data;
			re_c2_sn = 1'b0;
			we_c2_sn = 1'b1;
		end
		
		INCR_FOR4:
		begin
			i2 <= i2 + 10'd1;
		end
		

		START_AOF2:
		begin
		
			startaof <= 1'b1;
			
			we_c2_sn <= 1'b0;
			re_c2_sn <= 1'b1;
			
			aof_mem_x_in <= aof_mem_x_out;
			aof_mem_y_in <= aof_mem_y_out;
			aof_in_prev_f0 <= aof_out_prev_f0; 
			
		end

		RUN_AOF2:
		begin
		
		/* 	aof_out_sn <= read_c2_sn_out;
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
			write_sq <= aof_write_sq; */
			
			startaof <= 1'b0;
			
		end
		
		GET_AOF2:
		begin
			
			encoded_bits <= {aof_voiced1,voiced_bit,46'd0};
			c_w0_2 <= aof_w0_out;
			c_w0 <= aof_c_w0;
			c_w1 <= aof_c_w1;
			
			check_pitch2 <= aof_nlp_pitch;
			check_best_fo2 <= aof_out_prev_f0;
			
			c_cmax2 <= c_cmax;
			c_outreal2 <= c_outreal;
			
			
			out_prevf0 <= aof_out_prev_f0;

			
		end
		
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
		if(i1 < N_SAMP)    //dec5
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
		NEXT_STATE = SET_ADDR_SN2;
	end
    
	SET_ADDR_SN2:
	begin
		NEXT_STATE = SET_DELAY_111;
		//addr_sn = i + M_PITCH - N_SAMP;
	end
	
	SET_DELAY_111:
	begin
		NEXT_STATE = SET_DELAY_112;
	end
	
	SET_DELAY_112:
	begin
		NEXT_STATE = SET_DELAY_113;
	end
	
	SET_DELAY_113:
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
		NEXT_STATE = INIT_FOR_4; // AA_SET_ADDR ; ///DONE;
	end
	
	INIT_FOR_4:
	begin
		NEXT_STATE = CHECK_FOR4;
	end
		
	CHECK_FOR4:
	begin
		if(i2 < 10'd160)
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
		NEXT_STATE =  AA_SET_ADDR;
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
			
		SET_ADDR_SN2:
		begin
			//addr_sn <= i + M_PITCH - N_SAMP;

		end
		
		SET_DELAY_111:
		begin
		
		end
		
		SET_DELAY_112:
		begin
		
		end
		
		SET_DELAY_113:
		begin
		
		end
		
		WRITE_SN2:
		begin
			//write_c2_sn <= sn_data;
			
			if(i1 == 10'd0)
			begin
				//c_pitch2 <= sn_data;
			end
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
			check_best_fo1 <= aof_out_prev_f0;
			c_outreal1 <= c_outreal;
			
			c_check_in_real <= aof_check_in_real;
			c_check_in_imag <= aof_check_in_imag;
			
			//check_sum <= aof_w0_out;
			
			c_pitch1 <= check_pitch1;
			c_encode_model_wo <= aof_w0_out;
			//c_pitch2 <= aof_check_i;
			
			out_mem_x <= aof_mem_x_out;
			out_mem_y <= aof_mem_y_out;
			out_prevf0 <= aof_out_prev_f0;
			
			
			
		end
		
		
		/* 	for(i=0; i<m_pitch-n_samp; i++)
		  c2->Sn[i] = c2->Sn[i+n_samp];
		for(i=0; i<n_samp; i++)
		  c2->Sn[i+m_pitch-n_samp] = speech[i+80];  */
		
		INIT_FOR_4:
		begin
			i2 <= 10'd0;
		end
			

		CHECK_FOR4:
		begin
			
		end
		
		READ_SN4:
		begin
			//addr_speech <= i2;
			//re_c2_sn <= 1'b1;
			//we_c2_sn <= 1'b0;
		end
		
		SET_DELAY_7:
		begin
			
		end
		
		SET_DELAY_8:
		begin
			
		end
		
		READ_DATA_SN4:
		begin
			sn_data <= out_speech;
		end
			
		SET_ADDR_SN4:
		begin
		//	addr_sn <= i2 + 10'd160;
			re_c2_sn <= 1'b0;
			we_c2_sn <= 1'b1;
		end
		
		WRITE_SN4:
		begin
			write_c2_sn <= sn_data;
		end
		
		INCR_FOR4:
		begin
			i2 <= i2 + 10'd1;
		end
		

		START_AOF2:
		begin
		
			startaof <= 1'b1;
			
			we_c2_sn <= 1'b0;
			re_c2_sn <= 1'b1;
			
			aof_mem_x_in <= aof_mem_x_out;
			aof_mem_y_in <= aof_mem_y_out;
			aof_in_prev_f0 <= aof_out_prev_f0; 
			
		end

		RUN_AOF2:
		begin
		
		/* 	aof_out_sn <= read_c2_sn_out;
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
			write_sq <= aof_write_sq; */
			
			startaof <= 1'b0;
			
		end
		
		GET_AOF2:
		begin
			
			encoded_bits <= {aof_voiced1,voiced_bit,46'd0};
			c_w0_2 <= aof_w0_out;
			c_w0 <= aof_c_w0;
			c_w1 <= aof_c_w1;
			
			check_pitch2 <= aof_nlp_pitch;
			check_best_fo2 <= aof_out_prev_f0;
			
			c_cmax2 <= c_cmax;
			c_outreal2 <= c_outreal;
			
			
			out_prevf0 <= aof_out_prev_f0;

			
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
			c_pitch2 <= read_c2_sn_out;
		end	
		
		DONE:
		begin
			done_oneframe <= 1'b1;
					
		end

		endcase
	end

end


endmodule