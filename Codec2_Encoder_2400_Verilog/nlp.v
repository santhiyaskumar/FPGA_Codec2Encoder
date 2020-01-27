/*
* Module         - nlp
* Top module     - analyse_one_frame
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue May 21 18:00:47 2019
*
* Description    -
* Inputs         -


* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module nlp (startnlp,clk,rst,out_sn,out_sq,out_mem_fir,nlp_mem_x,nlp_mem_y,prev_f0,
			best_f0,out_prev_f0,pitch,nlp_mem_x_out,nlp_mem_y_out,addr_sn,addr_mem_fir,in_mem_fir,read_fir,write_fir,addr_nlp_sq,read_sq,write_sq,in_sq,
			donenlp);
			
			//check_in_sq,check_gmax,check_gmax_bin,sig);//,sig,check_fft,);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,startnlp;
			input [N-1:0] nlp_mem_x,nlp_mem_y;
			
			output reg [9:0] addr_sn,addr_mem_fir,addr_nlp_sq;
			input [N-1:0] out_sn,out_mem_fir,out_sq;
			
			input [N-1:0] prev_f0;
			
			output reg [N-1:0] best_f0,out_prev_f0;

			output reg donenlp,read_fir,write_fir,read_sq,write_sq;
			output reg [N-1:0] pitch;
			output reg  [N-1:0] in_mem_fir,in_sq;
			output reg [N-1:0] nlp_mem_x_out,nlp_mem_y_out;
			
			 reg [N-1:0] check_in_sq,check_gmax,check_gmax_bin;
			
			 reg [N-1:0] sig;
			
			reg [9:0] i1;
			
		
			/* reg [9:0] addr_sn;
			wire [N-1:0] out_sn;
			RAM_c2_sn c2_sn (addr_sn,clk,,1,0,out_sn);  
	 */
			/* reg [9:0] addr_mem_fir;
			reg [N-1:0] in_mem_fir;
			reg read_fir,write_fir;
			wire [N-1:0] out_mem_fir;
			RAM_nlp_mem_fir_test  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);
			 */
			 
			// RAM_nlp_sq_test       nlp_sq	       (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 8'd0,
          INIT_FOR_1 = 8'd1,
          CHECK_I = 8'd2,
          READ_SN = 8'd3,
          SET_DELAY_1 = 8'd4,
          SET_DELAY_2 = 8'd5,
          CALC_SN_SQ = 8'd6,
          SET_NLP_SQ = 8'd7,
          INCR_I = 8'd8,
			 INIT_FOR_2 = 8'd9,
          CHECK_I_2 = 8'd10,
          SET_ADDR_SQ_2 = 8'd11,
          SET_DELAY_3 = 8'd12,
          SET_DELAY_4 = 8'd13,
          NOTCH_1 = 8'd14,
          NOTCH_2 = 8'd15,
          SET_MEM_X = 8'd16,
          SET_MEM_Y = 8'd17,
          SET_NEW_SQ_1 = 8'd18,
          SET_NEW_SQ_2 = 8'd19,
          INCR_I_2 = 8'd20,
		    INIT_FOR_3 = 8'd21,
          CHECK_I_3 = 8'd22,
          INNER_FOR_1 = 8'd23,
          CHECK_J = 8'd24,
          SET_ADDR_FIR = 8'd25,
          SET_DELAY_5 = 8'd26,
          SET_DELAY_6 = 8'd27,
          GET_FIR_1 = 8'd28,
          ADDR_WRITE_FIR = 8'd29,
          GET_FIR_2 = 8'd30,
          INCR_J = 8'd31,
          ADDR_LAST_FIR = 8'd32,
          SET_DELAY_7 = 8'd33,
          SET_DELAY_8 = 8'd34,
          SET_LAST_FIR = 8'd35,
          INNER_FOR_2 = 8'd36,
          CHECK_J_2 = 8'd37,
          READ_FIR1 = 8'd38,
          SET_DELAY_9 = 8'd39,
          SET_DELAY_10 = 8'd40,
          MULT_NLP_FIR = 8'd41,
          ADDR_FIR_SQ = 8'd42,
          SET_SQ_FIR = 8'd43,
          INCR_J_2 = 8'd44,
          INCR_I3 = 8'd45,
          DONE = 8'd46,
		    SET_SQ_0 = 8'd47,
		    SET_DELAY_11 = 8'd48,
		    SET_DELAY_12 = 8'd49,
		    FFT_INIT = 8'd50,
          FFT_ADDR = 8'd51,
          DELAY_FFT_1 = 8'd52,
          DELAY_FFT_2 = 8'd53,
          WRITE_FFT_INIT = 8'd54,
          INCR_I4 = 8'd55,
          CHECK_I4 = 8'd56,
          INIT_FOR_4 = 8'd57,
          CHECK_I5 = 8'd58,
          CALC_FFT_ADDR = 8'd59,
          FOR_DELAY_1 = 8'd60,
          FOR_DELAY_2 = 8'd61,
          CALC_FFT_SQ_W = 8'd62,
          WRITE_FFT_REAL1 = 8'd63,
          INCR_I_5 = 8'd64,
		    START_DFT = 8'd65,
		    RUN_DFT = 8'd66,
		    INIT_FOR_5 = 8'd67,
          CHECK_I_6 = 8'd68,
          SET_ADDR_FOR_5 = 8'd69,
          FOR_5_DELAY1 = 8'd70,
          FOR_5_DELAY2 = 8'd71,
          MULT_REAL_IMAGE_SQ = 8'd72,
          ADD_REAL_IMAG_SQ = 8'd73,
          SET_FW_REAL_ADD = 8'd74,
          INCR_I6 = 8'd75,
		    RUN_DFT_2 = 8'd76,
			 SET_GMAX_GMAX_BIN = 8'd77,
			 INIT_FOR_GMAX = 8'd78,
			 CHECK_I_GMAX = 8'd79,
			 SET_ADDR_FW_GMAX = 8'd80,
			 SET_DELAY_GMAX1 = 8'd81,
			 SET_DELAY_GMAX2 = 8'd82,
			 SET_IF_GMAX = 8'd83,
			 INCR_I_GMAX = 8'd84,
			 START_PPSM = 8'd85,
			 GET_BESTF0 = 8'd86,
			 INIT_FOR_SQ = 8'd87,
			 CHECK_FOR_SQ = 8'd88,
			 SET_ADDR_FOR_SQ = 8'd89,
			 FOR_SQ_DELAY1 = 8'd90,
			 FOR_SQ_DELAY2 = 8'd91,
			 GET_SQ_I_N = 8'd92,
			 SET_SQ_I_N = 8'd93,
			 INCR_SQ_I = 8'd94,
			 START_DIV_BEST0 = 8'd95,
			 CALC_DIV_BESTF0 = 8'd96,
			 SET_PITCH = 8'd97,
			 RUN_PPSM = 8'd98,
			 C_FFT1 = 8'd99,
			 C_FFT1D1 = 8'd100,
			 C_FFT1D2 = 8'd101,
			 C_FFT2  = 8'd102;
		  

reg [7:0] STATE, NEXT_STATE;

parameter [9:0]// M = 10'd320,
				//N_SAMP = 10'd80,
				DEC = 10'd5;
				
parameter [N-1:0] COEFF 	= 32'b00000000000000001111001100110011,
						ONE   	= 32'b00000000000000010000000000000000,
						NLP_FS 	= {16'd8000,16'd0};
				  
parameter [N-1:0] 	nlp_fir0  = 32'b10000000000000000000000001000110,
					nlp_fir1  = 32'b10000000000000000000000001001000,
					nlp_fir2  = 32'b10000000000000000000000000111100,
					nlp_fir3  = 32'b10000000000000000000000000011011,
					nlp_fir4  = 32'b00000000000000000000000000100100,
					nlp_fir5  = 32'b00000000000000000000000010000011,
					nlp_fir6  = 32'b00000000000000000000000011110010,
					nlp_fir7  = 32'b00000000000000000000000101010001,
					nlp_fir8  = 32'b00000000000000000000000101101110,
					nlp_fir9  = 32'b00000000000000000000000100011010,
					nlp_fir10  = 32'b00000000000000000000000000110100,
					nlp_fir11  = 32'b10000000000000000000000100111011,
					nlp_fir12  = 32'b10000000000000000000001011111111,
					nlp_fir13  = 32'b10000000000000000000010010101000,
					nlp_fir14  = 32'b10000000000000000000010110100110,
					nlp_fir15  = 32'b10000000000000000000010101011011,
					nlp_fir16  = 32'b10000000000000000000001101000111,
					nlp_fir17  = 32'b00000000000000000000000011010011,
					nlp_fir18  = 32'b00000000000000000000011011010100,
					nlp_fir19  = 32'b00000000000000000000111000110110,
					nlp_fir20  = 32'b00000000000000000001011000011000,
					nlp_fir21  = 32'b00000000000000000001110101100011,
					nlp_fir22  = 32'b00000000000000000010001100000001,
					nlp_fir23  = 32'b00000000000000000010011000001111,
					nlp_fir24  = 32'b00000000000000000010011000001111,
					nlp_fir25  = 32'b00000000000000000010001100000001,
					nlp_fir26  = 32'b00000000000000000001110101100011,
					nlp_fir27  = 32'b00000000000000000001011000011000,
					nlp_fir28  = 32'b00000000000000000000111000110110,
					nlp_fir29  = 32'b00000000000000000000011011010100,
					nlp_fir30  = 32'b00000000000000000000000011010011,
					nlp_fir31  = 32'b10000000000000000000001101000111,
					nlp_fir32  = 32'b10000000000000000000010101011011,
					nlp_fir33  = 32'b10000000000000000000010110100110,
					nlp_fir34  = 32'b10000000000000000000010010101000,
					nlp_fir35  = 32'b10000000000000000000001011111111,
					nlp_fir36  = 32'b10000000000000000000000100111011,
					nlp_fir37  = 32'b00000000000000000000000000110100,
					nlp_fir38  = 32'b00000000000000000000000100011010,
					nlp_fir39  = 32'b00000000000000000000000101101110,
					nlp_fir40  = 32'b00000000000000000000000101010001,
					nlp_fir41  = 32'b00000000000000000000000011110010,
					nlp_fir42  = 32'b00000000000000000000000010000011,
					nlp_fir43  = 32'b00000000000000000000000000100100,
					nlp_fir44  = 32'b10000000000000000000000000011011,
					nlp_fir45  = 32'b10000000000000000000000000111100,
					nlp_fir46  = 32'b10000000000000000000000001001000,
					nlp_fir47  = 32'b10000000000000000000000001000110;
					
parameter [N-1:0] 	nlp_w0  = 32'b00000000000000000000000000000000,
					nlp_w1  = 32'b00000000000000000000000010100010,
					nlp_w2  = 32'b00000000000000000000001010001001,
					nlp_w3  = 32'b00000000000000000000010110101111,
					nlp_w4  = 32'b00000000000000000000101000001101,
					nlp_w5  = 32'b00000000000000000000111110010110,
					nlp_w6  = 32'b00000000000000000001011000111101,
					nlp_w7  = 32'b00000000000000000001110111110010,
					nlp_w8  = 32'b00000000000000000010011010100000,
					nlp_w9  = 32'b00000000000000000011000000110001,
					nlp_w10  = 32'b00000000000000000011101010001101,
					nlp_w11  = 32'b00000000000000000100010110011010,
					nlp_w12  = 32'b00000000000000000101000100111100,
					nlp_w13  = 32'b00000000000000000101110101010101,
					nlp_w14  = 32'b00000000000000000110100111000101,
					nlp_w15  = 32'b00000000000000000111011001101111,
					nlp_w16  = 32'b00000000000000001000001100110000,
					nlp_w17  = 32'b00000000000000001000111111101010,
					nlp_w18  = 32'b00000000000000001001110001111011,
					nlp_w19  = 32'b00000000000000001010100011000100,
					nlp_w20  = 32'b00000000000000001011010010100101,
					nlp_w21  = 32'b00000000000000001100000000000000,
					nlp_w22  = 32'b00000000000000001100101010111000,
					nlp_w23  = 32'b00000000000000001101010010110010,
					nlp_w24  = 32'b00000000000000001101110111010100,
					nlp_w25  = 32'b00000000000000001110011000001000,
					nlp_w26  = 32'b00000000000000001110110100111000,
					nlp_w27  = 32'b00000000000000001111001101010010,
					nlp_w28  = 32'b00000000000000001111100001000111,
					nlp_w29  = 32'b00000000000000001111110000001010,
					nlp_w30  = 32'b00000000000000001111111010010001,
					nlp_w31  = 32'b00000000000000001111111111010111,
					nlp_w32  = 32'b00000000000000001111111111010111,
					nlp_w33  = 32'b00000000000000001111111010010001,
					nlp_w34  = 32'b00000000000000001111110000001010,
					nlp_w35  = 32'b00000000000000001111100001000111,
					nlp_w36  = 32'b00000000000000001111001101010010,
					nlp_w37  = 32'b00000000000000001110110100111000,
					nlp_w38  = 32'b00000000000000001110011000001000,
					nlp_w39  = 32'b00000000000000001101110111010100,
					nlp_w40  = 32'b00000000000000001101010010110010,
					nlp_w41  = 32'b00000000000000001100101010111000,
					nlp_w42  = 32'b00000000000000001100000000000000,
					nlp_w43  = 32'b00000000000000001011010010100101,
					nlp_w44  = 32'b00000000000000001010100011000100,
					nlp_w45  = 32'b00000000000000001001110001111011,
					nlp_w46  = 32'b00000000000000001000111111101010,
					nlp_w47  = 32'b00000000000000001000001100110000,
					nlp_w48  = 32'b00000000000000000111011001101111,
					nlp_w49  = 32'b00000000000000000110100111000101,
					nlp_w50  = 32'b00000000000000000101110101010101,
					nlp_w51  = 32'b00000000000000000101000100111100,
					nlp_w52  = 32'b00000000000000000100010110011010,
					nlp_w53  = 32'b00000000000000000011101010001101,
					nlp_w54  = 32'b00000000000000000011000000110001,
					nlp_w55  = 32'b00000000000000000010011010100000,
					nlp_w56  = 32'b00000000000000000001110111110010,
					nlp_w57  = 32'b00000000000000000001011000111101,
					nlp_w58  = 32'b00000000000000000000111110010110,
					nlp_w59  = 32'b00000000000000000000101000001101,
					nlp_w60  = 32'b00000000000000000000010110101111,
					nlp_w61  = 32'b00000000000000000000001010001001,
					nlp_w62  = 32'b00000000000000000000000010100010,
					nlp_w63  = 32'b00000000000000000000000000000000;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
reg [9:0] i,j;
reg 			[N-1:0] 		m1_in1,m1_in2,a1_in1,a1_in2,m2_in1,m2_in2,a2_in1,a2_in2;
wire 			[N-1:0] 		m1_out,a1_out,m2_out,a2_out;

//reg [9:0] addr_nlp_sq;//addr_mem_fir;
//reg [N-1:0] in_sq;//in_mem_fir;
//wire [N-1:0] out_sq;//out_mem_fir;

reg [N-1:0] m1,m2,m3,m4,a1,a2;

//reg read_sq,write_sq;//read_fir,write_fir;

reg [N-1:0] notch,mem_x,mem_y;

reg [N-1:0] mem_fir_j_1;
reg startdiv;
reg [N-1:0] div_in;
wire [N-1:0] div_ans;
wire donediv;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);

qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2     (a2_in1,a2_in2,a2_out);

fpdiv_clk  	  	 				divider	   (startdiv,clk,rst,div_in,div_ans,donediv);

// reg [9:0] addr_sn;
// wire [N-1:0] out_sn;
// RAM_c2_sn    in_sn	   (addr_sn,clk,,1,0,out_sn); 

//RAM_nlp_sq_test       nlp_sq	       (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);

//RAM_nlp_mem_fir  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);


reg [9:0] 		addr_in_imag,addr_in_real,addr_out_real,addr_out_imag;
wire   [N-1:0]		in_imag_data,in_real_data;
		
wire [9:0] fft_addr_in_imag,fft_addr_in_real,fft_addr_out_real,fft_addr_out_imag;
 reg [N-1:0] write_fft_real;
 reg [N-1:0] write_fft_imag; 

reg [9:0] addr_out_real_gmax,gmax_bin;
reg [N-1:0] write_fft_real_gmax;
 reg [N-1:0] gmax;



wire [N-1:0] out_fft_real, out_fft_imag,fft_write_fft_real,fft_write_fft_imag,out_fft_real_gmax;

reg read_in_fftr,read_in_ffti,write_in_fftr,write_in_ffti,re_out_fftr_gmax,we_out_fftr_gmax,
			re_fftr,re_ffti,we_fftr,we_ffti,re_out_fftr,re_out_ffti,we_out_fftr,we_out_ffti,startfft;
reg [N-1:0] write_in_fft_real,write_in_fft_imag;
wire donefft,doneppsm;

RAM_in_fft_real            in_real	   (addr_in_real,clk,write_in_fft_real,re_fftr,we_fftr,in_real_data);
RAM_in_fft_imag      		in_imag	   (addr_in_imag,clk,write_in_fft_imag,re_ffti,we_ffti,in_imag_data);

RAM_out_fft_real         fft_out_real	   (addr_out_real,clk,write_fft_real,re_out_fftr,we_out_fftr,out_fft_real);
RAM_out_fft_imag      	 fft_out_imag	   (addr_out_imag,clk,write_fft_imag,re_out_ffti,we_out_ffti,out_fft_imag);

RAM_out_fft_real_gmax    fft_out_real_gmax	   (addr_out_real_gmax,clk,write_fft_real_gmax,re_out_fftr_gmax,
														we_out_fftr_gmax,out_fft_real_gmax);

reg [N-1:0] fft_in_imag_data,fft_in_real_data;
fft_nlp fft_nlp_module (startfft,clk,rst,fft_in_imag_data,fft_in_real_data,
					fft_addr_in_imag,fft_addr_in_real,fft_addr_out_real,fft_addr_out_imag,
								fft_write_fft_real,fft_write_fft_imag,donefft);
								
post_process_sub_multiples ppsm (startppsm,clk,rst,out_fw_real,
							pp_gmax,pp_gmax_bin,pp_prev_f0,pp_best_f0,addr_fw_real,doneppsm,check_sig);
							
reg startppsm;
reg [N-1:0] out_fw_real,pp_gmax;
reg [9:0] pp_gmax_bin;
reg [N-1:0] pp_prev_f0;
wire [N-1:0] pp_best_f0;
wire [9:0] addr_fw_real;
reg [N-1:0] out_sq_i_n;

wire [N-1:0] check_sig;
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
		if(startnlp == 1'b1)
		begin
			NEXT_STATE = INIT_FOR_1;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_FOR_1:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i1 < 10'd321)
		begin
			NEXT_STATE = READ_SN;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_2;
		end
	end

	READ_SN:
	begin
		NEXT_STATE = SET_DELAY_1;
	end

	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end

	SET_DELAY_2:
	begin
		NEXT_STATE = CALC_SN_SQ;
	end

	CALC_SN_SQ:
	begin
		NEXT_STATE = SET_NLP_SQ;
	end

	SET_NLP_SQ:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end
	
	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_I_2;
	end

	CHECK_I_2:
	begin
		if(i < 10'd320)
		begin
			NEXT_STATE = SET_ADDR_SQ_2;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_3;
		end
	end

	SET_ADDR_SQ_2:
	begin
		NEXT_STATE = SET_DELAY_3;
	end

	SET_DELAY_3:
	begin
		NEXT_STATE = SET_DELAY_4;
	end

	SET_DELAY_4:
	begin
		NEXT_STATE = NOTCH_1;
	end

	NOTCH_1:
	begin
		NEXT_STATE = NOTCH_2;
	end

	NOTCH_2:
	begin
		NEXT_STATE = SET_MEM_X;
	end

	SET_MEM_X:
	begin
		NEXT_STATE = SET_MEM_Y;
	end

	SET_MEM_Y:
	begin
		NEXT_STATE = SET_NEW_SQ_1;
	end

	SET_NEW_SQ_1:
	begin
		NEXT_STATE = SET_NEW_SQ_2;
	end

	SET_NEW_SQ_2:
	begin
		NEXT_STATE = INCR_I_2;
	end

	INCR_I_2:
	begin
		NEXT_STATE = CHECK_I_2;
	end
	
	INIT_FOR_3:
	begin
		NEXT_STATE = CHECK_I_3;
	end

	CHECK_I_3:
	begin
		if(i < 10'd320)
		begin
			NEXT_STATE = INNER_FOR_1;
		end
		else
		begin
			NEXT_STATE = FFT_INIT;
		end
	end

	INNER_FOR_1:
	begin
		NEXT_STATE = CHECK_J;
	end

	CHECK_J:
	begin
		if(j < 10'd48)   //fix this 
		begin
			NEXT_STATE = SET_ADDR_FIR;
		end
		else
		begin
			NEXT_STATE = ADDR_LAST_FIR;
		end
	end

	SET_ADDR_FIR:
	begin
		NEXT_STATE = SET_DELAY_5;
	end

	SET_DELAY_5:
	begin
		NEXT_STATE = SET_DELAY_6;
	end

	SET_DELAY_6:
	begin
		NEXT_STATE = GET_FIR_1;
	end

	GET_FIR_1:
	begin
		NEXT_STATE = ADDR_WRITE_FIR;
	end

	ADDR_WRITE_FIR:
	begin
		NEXT_STATE = GET_FIR_2;
	end

	GET_FIR_2:
	begin
		NEXT_STATE = INCR_J;
	end

	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end

	ADDR_LAST_FIR:
	begin
		NEXT_STATE = SET_DELAY_7;
	end

	SET_DELAY_7:
	begin
		NEXT_STATE = SET_DELAY_8;
	end

	SET_DELAY_8:
	begin
		NEXT_STATE = SET_LAST_FIR;
	end

	SET_LAST_FIR:
	begin
		NEXT_STATE = SET_SQ_0;
	end
	
	SET_SQ_0:
	begin
		NEXT_STATE = INNER_FOR_2;
	end

	INNER_FOR_2:
	begin
		NEXT_STATE = CHECK_J_2;
	end

	CHECK_J_2:
	begin
		if(j < 10'd48)
		begin
			NEXT_STATE = READ_FIR1;
		end
		else
		begin
			NEXT_STATE = INCR_I3;
		end
	end

	READ_FIR1:
	begin
		NEXT_STATE = SET_DELAY_9;
	end

	SET_DELAY_9:
	begin
		NEXT_STATE = SET_DELAY_10;
	end

	SET_DELAY_10:
	begin
		NEXT_STATE = MULT_NLP_FIR;
	end

	MULT_NLP_FIR:
	begin
		NEXT_STATE = SET_DELAY_11;
	end
	
	SET_DELAY_11:
	begin
		NEXT_STATE = SET_DELAY_12;
	end
		
	SET_DELAY_12:
	begin
		NEXT_STATE = ADDR_FIR_SQ;
	end

	ADDR_FIR_SQ:
	begin
		NEXT_STATE = SET_SQ_FIR;
	end

	SET_SQ_FIR:
	begin
		NEXT_STATE = INCR_J_2;
	end

	INCR_J_2:
	begin
		NEXT_STATE = CHECK_J_2;
	end

	INCR_I3:
	begin
		NEXT_STATE = CHECK_I_3;
	end
	
	FFT_INIT:
	begin
		NEXT_STATE = FFT_ADDR;
	end

	FFT_ADDR:
	begin
		NEXT_STATE = DELAY_FFT_1;
	end

	DELAY_FFT_1:
	begin
		NEXT_STATE = DELAY_FFT_2;
	end

	DELAY_FFT_2:
	begin
		NEXT_STATE = WRITE_FFT_INIT;
	end

	WRITE_FFT_INIT:
	begin
		NEXT_STATE = INCR_I4;
	end

	INCR_I4:
	begin
		NEXT_STATE = CHECK_I4;
	end

	CHECK_I4:
	begin
		if(i < 10'd512)
		begin
			NEXT_STATE = FFT_ADDR;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_4;
		end
		
	end

	INIT_FOR_4:
	begin
		NEXT_STATE = CHECK_I5;
	end

	CHECK_I5:
	begin
		if(i < 10'd64)
		begin
			NEXT_STATE = CALC_FFT_ADDR;
		end
		else
		begin
			NEXT_STATE = START_DFT;  // C_FFT1;//
		end
		
	end

	CALC_FFT_ADDR:
	begin
		NEXT_STATE = FOR_DELAY_1;
	end

	FOR_DELAY_1:
	begin
		NEXT_STATE = FOR_DELAY_2;
	end

	FOR_DELAY_2:
	begin
		NEXT_STATE = CALC_FFT_SQ_W;
	end

	CALC_FFT_SQ_W:
	begin
		NEXT_STATE = WRITE_FFT_REAL1;
	end

	WRITE_FFT_REAL1:
	begin
		NEXT_STATE = INCR_I_5;
	end

	INCR_I_5:
	begin
		NEXT_STATE = CHECK_I5;
	end
	
	START_DFT:
	begin
		NEXT_STATE = RUN_DFT;
	end
	
	RUN_DFT:
	begin
		if(donefft)
		begin
			NEXT_STATE = INIT_FOR_5; //C_FFT1;//
		end
		else
		begin
			NEXT_STATE = RUN_DFT;
		end
	end
	
	//RUN_DFT_2:
	//begin
	//	NEXT_STATE = RUN_DFT;
	//end
	
	INIT_FOR_5:
	begin
		NEXT_STATE = CHECK_I_6; //C_FFT1;//
	end

	CHECK_I_6:
	begin
		if(i < 10'd512)
		begin
			NEXT_STATE = SET_ADDR_FOR_5;
		end
		else
		begin
			NEXT_STATE = SET_GMAX_GMAX_BIN; //DONE;//
		end
	end

	SET_ADDR_FOR_5:
	begin
		NEXT_STATE = FOR_5_DELAY1;
	end

	FOR_5_DELAY1:
	begin
		NEXT_STATE = FOR_5_DELAY2;
	end

	FOR_5_DELAY2:
	begin
		NEXT_STATE = MULT_REAL_IMAGE_SQ;
	end

	MULT_REAL_IMAGE_SQ:
	begin
		NEXT_STATE = ADD_REAL_IMAG_SQ;
	end

	ADD_REAL_IMAG_SQ:
	begin
		NEXT_STATE = SET_FW_REAL_ADD;
	end

	SET_FW_REAL_ADD:
	begin
		NEXT_STATE = INCR_I6;
	end

	INCR_I6:
	begin
		NEXT_STATE = CHECK_I_6;
	end
	
	SET_GMAX_GMAX_BIN:
	begin
		NEXT_STATE = INIT_FOR_GMAX;
	end
	
	INIT_FOR_GMAX:
	begin
		NEXT_STATE = CHECK_I_GMAX;
	end
	
	CHECK_I_GMAX:
	begin
		if(i <= 10'd128)
		begin
			NEXT_STATE = SET_ADDR_FW_GMAX;
		end
		else
		begin
			NEXT_STATE = START_PPSM;
		end
	end
	
	SET_ADDR_FW_GMAX:
	begin
		NEXT_STATE = SET_DELAY_GMAX1;
	end
	
	SET_DELAY_GMAX1:
	begin
		NEXT_STATE = SET_DELAY_GMAX2;
	end
	
	SET_DELAY_GMAX2:
	begin
		NEXT_STATE = SET_IF_GMAX;
	end
	
	SET_IF_GMAX:
	begin
		NEXT_STATE = INCR_I_GMAX;
	end
	
	INCR_I_GMAX:
	begin
		NEXT_STATE = CHECK_I_GMAX;
	end
	
	START_PPSM:
	begin
		NEXT_STATE = RUN_PPSM;
	end
	
	RUN_PPSM:
	begin
		if(doneppsm)
		begin
			NEXT_STATE = GET_BESTF0;
		end
		else
		begin
			NEXT_STATE = RUN_PPSM;
		end
	end
	
	GET_BESTF0:
	begin
		NEXT_STATE = INIT_FOR_SQ;
	end
	
	INIT_FOR_SQ:
	begin
		NEXT_STATE = CHECK_FOR_SQ;
	end
	
	CHECK_FOR_SQ:
	begin
		if(i < 10'd240)
		begin
			NEXT_STATE = SET_ADDR_FOR_SQ;
		end
		else
		begin
			NEXT_STATE = START_DIV_BEST0;
		end
		
	end
	
	SET_ADDR_FOR_SQ:
	begin
		NEXT_STATE = FOR_SQ_DELAY1;
	end
	
	FOR_SQ_DELAY1:
	begin
		NEXT_STATE = FOR_SQ_DELAY2;
	end
	
	FOR_SQ_DELAY2:
	begin
		NEXT_STATE = GET_SQ_I_N;
	end
	
	GET_SQ_I_N:
	begin
		NEXT_STATE = SET_SQ_I_N;
	end
	
	SET_SQ_I_N:
	begin
		NEXT_STATE = INCR_SQ_I;
	end
	
	INCR_SQ_I:
	begin
		NEXT_STATE = CHECK_FOR_SQ;
	end
	
	START_DIV_BEST0:
	begin
		NEXT_STATE = CALC_DIV_BESTF0;
	end
	
	CALC_DIV_BESTF0:
	begin
		if(donediv)
		begin
			NEXT_STATE = SET_PITCH;
		end
		else
		begin
			NEXT_STATE = CALC_DIV_BESTF0;
		end
	end
	
	SET_PITCH:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = START;
	end

	default:
	begin
		NEXT_STATE = DONE;
	end
	
	C_FFT1:
	begin
		NEXT_STATE = C_FFT1D1;
	end
	
	C_FFT1D1:
	begin
		NEXT_STATE = C_FFT1D2;
	end
	
	C_FFT1D2:
	begin
		NEXT_STATE = C_FFT2;
	end
	
	C_FFT2:
	begin
		NEXT_STATE = DONE;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		donenlp <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donenlp <= 1'b0;
		end

		INIT_FOR_1:
		begin
			i1 <= 10'd240;
			write_sq <= 1'b1;
			read_sq <= 1'b0;
		end

		CHECK_I:
		begin
			
		end

		READ_SN:
		begin
			addr_sn <= i1;
			addr_nlp_sq <= i1;
		end

		SET_DELAY_1:
		begin
			
		end

		SET_DELAY_2:
		begin
			
		end

		CALC_SN_SQ:
		begin
			m1_in1 <= out_sn;
			m1_in2 <= out_sn;
			//addr_nlp_sq <= i;
		end

		SET_NLP_SQ:
		begin
			in_sq <= m1_out;
			if(i1 == 10'd319)
			begin
				//check_in_sq <= m1_out;
			end
		end

		INCR_I:
		begin
			i1 <= i1 + 10'd1;
		end
		
		INIT_FOR_2:
		begin
			i <= 10'd240;
			// mem_x <=  32'd0;
			//mem_y <=   32'd0;  
			
			 mem_x <= nlp_mem_x;
			 mem_y <= nlp_mem_y; 
			
			//mem_x <=  32'b00000010101001000000000000000000;
		//	mem_y <=  32'b00000000110010111110000111110010;
			
		
		end

		CHECK_I_2:
		begin
			
		end

		SET_ADDR_SQ_2:
		begin
			addr_nlp_sq <= i;
			read_sq <= 1'b1;
			write_sq <= 1'b0;
		end

		SET_DELAY_3:
		begin
			
		end

		SET_DELAY_4:
		begin
			
		end

		NOTCH_1:
		begin
			a1_in1 <= out_sq;
			a1_in2 <= {(mem_x[N-1] == 0)?1'b1:1'b0,mem_x[N-2:0]};
		end

		NOTCH_2:
		begin
			m1_in1 <= COEFF;
			m1_in2 <= mem_y;
			notch <= a1_out;
		//	c_notch <= a1_out;
		end

		SET_MEM_X:
		begin
			a1_in1 <= notch;
			a1_in2 <= m1_out;
			mem_x <= out_sq;
			write_sq <= 1'b1;
			read_sq <= 1'b0;
		end

		SET_MEM_Y:
		begin
			mem_y <= a1_out;
			notch <= a1_out;
		//	c_notch_1 <= a1_out;
		end

		SET_NEW_SQ_1:
		begin
			a1_in1 <= notch;
			a1_in2 <= ONE;
		end

		SET_NEW_SQ_2:
		begin
			in_sq <= a1_out;
			//check_in_sq <= a1_out;
		end

		INCR_I_2:
		begin
			i <= i + 10'd1;
		end
		
		INIT_FOR_3:
		begin
			i <= 10'd240;
			nlp_mem_x_out <= mem_x;
			nlp_mem_y_out <= mem_y;
		end

		CHECK_I_3:
		begin
			
		end

		INNER_FOR_1:
		begin
			j <= 10'd0;
		end

		CHECK_J:
		begin
			
		end

		SET_ADDR_FIR:
		begin
			addr_mem_fir <= j + 10'd1;
			read_fir <= 1'b1;
			write_fir <= 1'b0;
		end

		SET_DELAY_5:
		begin
			
		end

		SET_DELAY_6:
		begin
			
		end

		GET_FIR_1:
		begin
			mem_fir_j_1 <= out_mem_fir;
		end

		ADDR_WRITE_FIR:
		begin
			addr_mem_fir <= j;
			read_fir <= 1'b0;
			write_fir <= 1'b1;
		end

		GET_FIR_2:
		begin
			in_mem_fir <= mem_fir_j_1;
		end

		INCR_J:
		begin
			j <= j + 10'd1;
		end

		ADDR_LAST_FIR:
		begin
			addr_mem_fir <= 10'd47;
			read_fir <= 1'b0;
			write_fir <= 1'b1;
			addr_nlp_sq <= i;
			read_sq <= 1'b1;
			write_sq <= 1'b0;
		end

		SET_DELAY_7:
		begin
			
		end

		SET_DELAY_8:
		begin
			
		end

		SET_LAST_FIR:
		begin
			in_mem_fir <= out_sq;
			write_sq <= 1'b1;
			read_sq <= 1'b0;
		end
		
		SET_SQ_0:
		begin
			in_sq <= 32'b0;
		end

		INNER_FOR_2:
		begin
			j <= 10'd0;
		end

		CHECK_J_2:
		begin
			
		end

		READ_FIR1:
		begin
			addr_mem_fir <= j;
			read_fir <= 1'b1;
			write_fir <= 1'b0;
		end

		SET_DELAY_9:
		begin
			
		end

		SET_DELAY_10:
		begin
			
		end

		MULT_NLP_FIR:
		begin
			case (j)
			10'd0  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir0;
			   end
			10'd1  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir1;
			   end
			10'd2  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir2;
			   end
			10'd3  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir3;
			   end
			10'd4  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir4;
			   end
			10'd5  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir5;
			   end
			10'd6  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir6;
			   end
			10'd7  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir7;
			   end
			10'd8  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir8;
			   end
			10'd9  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir9;
			   end
			10'd10  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir10;
			   end
			10'd11  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir11;
			   end
			10'd12  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir12;
			   end
			10'd13  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir13;
			   end
			10'd14  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir14;
			   end
			10'd15  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir15;
			   end
			10'd16  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir16;
			   end
			10'd17  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir17;
			   end
			10'd18  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir18;
			   end
			10'd19  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir19;
			   end
			10'd20  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir20;
			   end
			10'd21  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir21;
			   end
			10'd22  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir22;
			   end
			10'd23  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir23;
			   end
			10'd24  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir24;
			   end
			10'd25  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir25;
			   end
			10'd26  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir26;
			   end
			10'd27  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir27;
			   end
			10'd28  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir28;
			   end
			10'd29  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir29;
			   end
			10'd30  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir30;
			   end
			10'd31  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir31;
			   end
			10'd32  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir32;
			   end
			10'd33  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir33;
			   end
			10'd34  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir34;
			   end
			10'd35  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir35;
			   end
			10'd36  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir36;
			   end
			10'd37  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir37;
			   end
			10'd38  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir38;
			   end
			10'd39  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir39;
			   end
			10'd40  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir40;
			   end
			10'd41  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir41;
			   end
			10'd42  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir42;
			   end
			10'd43  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir43;
			   end
			10'd44  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir44;
			   end
			10'd45  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir45;
			   end
			10'd46  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir46;
			   end
			10'd47  :
			   begin
				   m1_in1 <= out_mem_fir;
				   m1_in2 <= nlp_fir47;
			   end
			
			endcase
			write_sq <= 1'b0;
			read_sq <= 1'b1;
			
		end
		
		SET_DELAY_11:
		begin
		
		end
		
		SET_DELAY_12:
		begin
		
		end

		ADDR_FIR_SQ:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= out_sq;
			write_sq <= 1'b1;
			read_sq <= 1'b0;
		end

		SET_SQ_FIR:
		begin
			in_sq <= a1_out;
			//check_in_sq <= a1_out;
		end

		INCR_J_2:
		begin
			j <= j + 10'd1;
		end

		INCR_I3:
		begin
			i <= i + 10'd1;
		end
		
		FFT_INIT:
		begin
			i <= 10'd0;
		end

		FFT_ADDR:
		begin
			addr_in_real <= i;
			addr_in_imag <= i;
			re_fftr <= 1'b0;
			re_ffti <= 1'b0;
			we_fftr <= 1'b1;
			we_ffti <= 1'b1;
			
		end

		DELAY_FFT_1:
		begin
			
		end

		DELAY_FFT_2:
		begin
			
		end

		WRITE_FFT_INIT:
		begin
			write_in_fft_real <= 32'b0;
			write_in_fft_imag <= 32'b0;
		end

		INCR_I4:
		begin
			i <= i + 10'd1;
		end

		CHECK_I4:
		begin
			
		end

		INIT_FOR_4:
		begin
			i <= 10'd0;
		end

		CHECK_I5:
		begin
			
		end

		CALC_FFT_ADDR:
		begin
			addr_nlp_sq <= i * DEC;
			read_sq <= 1'b1;
			write_sq <= 1'b0;
			
			
			addr_in_real <= i;
			re_fftr <= 1'b0;
			we_fftr <= 1'b1;
			
			
		end

		FOR_DELAY_1:
		begin
			
		end

		FOR_DELAY_2:
		begin
			
		end

		CALC_FFT_SQ_W:
		begin
			m1_in1 <= out_sq;
			case (i)
				10'd0  :
				   begin
					   m1_in2 <= nlp_w0;
				   end
				10'd1  :
				   begin
					   m1_in2 <= nlp_w1;
				   end
				10'd2  :
				   begin
					   m1_in2 <= nlp_w2;
				   end
				10'd3  :
				   begin
					   m1_in2 <= nlp_w3;
				   end
				10'd4  :
				   begin
					   m1_in2 <= nlp_w4;
				   end
				10'd5  :
				   begin
					   m1_in2 <= nlp_w5;
				   end
				10'd6  :
				   begin
					   m1_in2 <= nlp_w6;
				   end
				10'd7  :
				   begin
					   m1_in2 <= nlp_w7;
				   end
				10'd8  :
				   begin
					   m1_in2 <= nlp_w8;
				   end
				10'd9  :
				   begin
					   m1_in2 <= nlp_w9;
				   end
				10'd10  :
				   begin
					   m1_in2 <= nlp_w10;
				   end
				10'd11  :
				   begin
					   m1_in2 <= nlp_w11;
				   end
				10'd12  :
				   begin
					   m1_in2 <= nlp_w12;
				   end
				10'd13  :
				   begin
					   m1_in2 <= nlp_w13;
				   end
				10'd14  :
				   begin
					   m1_in2 <= nlp_w14;
				   end
				10'd15  :
				   begin
					   m1_in2 <= nlp_w15;
				   end
				10'd16  :
				   begin
					   m1_in2 <= nlp_w16;
				   end
				10'd17  :
				   begin
					   m1_in2 <= nlp_w17;
				   end
				10'd18  :
				   begin
					   m1_in2 <= nlp_w18;
				   end
				10'd19  :
				   begin
					   m1_in2 <= nlp_w19;
				   end
				10'd20  :
				   begin
					   m1_in2 <= nlp_w20;
				   end
				10'd21  :
				   begin
					   m1_in2 <= nlp_w21;
				   end
				10'd22  :
				   begin
					   m1_in2 <= nlp_w22;
				   end
				10'd23  :
				   begin
					   m1_in2 <= nlp_w23;
				   end
				10'd24  :
				   begin
					   m1_in2 <= nlp_w24;
				   end
				10'd25  :
				   begin
					   m1_in2 <= nlp_w25;
				   end
				10'd26  :
				   begin
					   m1_in2 <= nlp_w26;
				   end
				10'd27  :
				   begin
					   m1_in2 <= nlp_w27;
				   end
				10'd28  :
				   begin
					   m1_in2 <= nlp_w28;
				   end
				10'd29  :
				   begin
					   m1_in2 <= nlp_w29;
				   end
				10'd30  :
				   begin
					   m1_in2 <= nlp_w30;
				   end
				10'd31  :
				   begin
					   m1_in2 <= nlp_w31;
				   end
				10'd32  :
				   begin
					   m1_in2 <= nlp_w32;
				   end
				10'd33  :
				   begin
					   m1_in2 <= nlp_w33;
				   end
				10'd34  :
				   begin
					   m1_in2 <= nlp_w34;
				   end
				10'd35  :
				   begin
					   m1_in2 <= nlp_w35;
				   end
				10'd36  :
				   begin
					   m1_in2 <= nlp_w36;
				   end
				10'd37  :
				   begin
					   m1_in2 <= nlp_w37;
				   end
				10'd38  :
				   begin
					   m1_in2 <= nlp_w38;
				   end
				10'd39  :
				   begin
					   m1_in2 <= nlp_w39;
				   end
				10'd40  :
				   begin
					   m1_in2 <= nlp_w40;
				   end
				10'd41  :
				   begin
					   m1_in2 <= nlp_w41;
				   end
				10'd42  :
				   begin
					   m1_in2 <= nlp_w42;
				   end
				10'd43  :
				   begin
					   m1_in2 <= nlp_w43;
				   end
				10'd44  :
				   begin
					   m1_in2 <= nlp_w44;
				   end
				10'd45  :
				   begin
					   m1_in2 <= nlp_w45;
				   end
				10'd46  :
				   begin
					   m1_in2 <= nlp_w46;
				   end
				10'd47  :
				   begin
					   m1_in2 <= nlp_w47;
				   end
				10'd48  :
				   begin
					   m1_in2 <= nlp_w48;
				   end
				10'd49  :
				   begin
					   m1_in2 <= nlp_w49;
				   end
				10'd50  :
				   begin
					   m1_in2 <= nlp_w50;
				   end
				10'd51  :
				   begin
					   m1_in2 <= nlp_w51;
				   end
				10'd52  :
				   begin
					   m1_in2 <= nlp_w52;
				   end
				10'd53  :
				   begin
					   m1_in2 <= nlp_w53;
				   end
				10'd54  :
				   begin
					   m1_in2 <= nlp_w54;
				   end
				10'd55  :
				   begin
					   m1_in2 <= nlp_w55;
				   end
				10'd56  :
				   begin
					   m1_in2 <= nlp_w56;
				   end
				10'd57  :
				   begin
					   m1_in2 <= nlp_w57;
				   end
				10'd58  :
				   begin
					   m1_in2 <= nlp_w58;
				   end
				10'd59  :
				   begin
					   m1_in2 <= nlp_w59;
				   end
				10'd60  :
				   begin
					   m1_in2 <= nlp_w60;
				   end
				10'd61  :
				   begin
					   m1_in2 <= nlp_w61;
				   end
				10'd62  :
				   begin
					   m1_in2 <= nlp_w62;
				   end
				10'd63  :
				   begin
					   m1_in2 <= nlp_w63;
				   end
			endcase
		end

		WRITE_FFT_REAL1:
		begin
			write_in_fft_real <= m1_out;
			if(i == 10'd32)
			begin
				check_in_sq <= out_sq;  //CHECKED RIGHT
			end
			
		end

		INCR_I_5:
		begin
			i <= i + 10'd1;
		end
		
			
		START_DFT:
		begin
			startfft <= 1'b1;
			
			re_fftr <= 1'b1;
			we_fftr <= 1'b0;
			re_ffti <= 1'b1;
			we_ffti <= 1'b0;
			
			re_out_fftr <= 1'b0;
			we_out_fftr <= 1'b1;
			re_out_ffti <= 1'b0;
			we_out_ffti <= 1'b1;
			
		end
		
		RUN_DFT:
		begin
			startfft <= 1'b0;
			addr_in_real <= fft_addr_in_real;
			addr_in_imag <= fft_addr_in_imag;
			
			addr_out_real <= fft_addr_out_real;
			addr_out_imag <= fft_addr_out_imag;
		//end
		
		//RUN_DFT_2:
		//begin
			write_fft_real <= fft_write_fft_real;
			write_fft_imag <= fft_write_fft_imag;
			
			fft_in_imag_data <= in_imag_data;
			fft_in_real_data <= in_real_data;
		end
		
		INIT_FOR_5:
		begin
			i <= 10'd0;
			//check_in_sq <= fft_write_fft_real;
		end

		CHECK_I_6:
		begin
			
		end

		SET_ADDR_FOR_5:
		begin
			addr_out_real <= i;
			addr_out_imag <= i;
			re_out_fftr <= 1'b1;
			we_out_fftr <= 1'b0;
			re_out_ffti <= 1'b1;
			we_out_ffti <= 1'b0; 
		end

		FOR_5_DELAY1:
		begin
			
		end

		FOR_5_DELAY2:
		begin
			
		end

		MULT_REAL_IMAGE_SQ:
		begin
			/* m1_in1 <= out_fft_real;
			m1_in2 <= out_fft_real;
			
			m2_in1 <= out_fft_imag;
			m2_in2 <= out_fft_imag; */
			
			m1 <= {17'b0,out_fft_real[N-2:16]};
			m2 <= {17'b0,out_fft_real[N-2:16]};
			m3 <= {17'b0,out_fft_imag[N-2:16]};
			m4 <= {17'b0,out_fft_imag[N-2:16]};
			
		end

		ADD_REAL_IMAG_SQ:
		begin
			/* a1_in1 <= m1_out;
			a1_in2 <= m2_out; */
			
			a1 <= m1 * m2;
			a2 <= m3 * m4;
			
			we_out_fftr_gmax <= 1'b1;
			re_out_fftr_gmax <= 1'b0;
			addr_out_real_gmax <= i;
			
		
			
			
		end

		SET_FW_REAL_ADD:
		begin
			write_fft_real_gmax <= a1 + a2;;
			if(i == 10'd1)
			begin
				//check_in_sq <= m1;
			end
		end

		INCR_I6:
		begin
			i <= i + 10'd1;
		end 
		
		SET_GMAX_GMAX_BIN:
		begin
			gmax = 32'b0;
			gmax_bin <= 10'd16;
		end
		
		INIT_FOR_GMAX:
		begin
			i <= 10'd16; // min 10'd16, max 10'128
		end
		
		CHECK_I_GMAX:
		begin
			
		end
		
		SET_ADDR_FW_GMAX:
		begin
			addr_out_real_gmax <= i;
			re_out_fftr_gmax <= 1'b1;
			we_out_fftr_gmax <= 1'b0;
		end
		
		SET_DELAY_GMAX1:
		begin
		
		end
		
		SET_DELAY_GMAX2:
		begin
		
		end
		
		SET_IF_GMAX:
		begin
			if(out_fft_real_gmax > gmax)
			begin
				gmax <= out_fft_real_gmax;
				gmax_bin <= i;   // fix this
			end
		end
		
		INCR_I_GMAX:
		begin
			i <= i + 10'd1;
		end
		
		START_PPSM:
		begin
			startppsm <= 1'b1;
			
			pp_gmax <= gmax;
			pp_gmax_bin <= gmax_bin;
			
			pp_prev_f0 <= prev_f0;
		//	pp_prev_f0 <= {16'd50,16'd0};
			
			check_gmax <= gmax;
			check_gmax_bin <= gmax_bin;
			sig <= 12'd4;
			
		end
		
		RUN_PPSM:
		begin
			out_fw_real <= out_fft_real_gmax;
			addr_out_real_gmax <= addr_fw_real;
			
			startppsm <= 1'b0;
			sig <= 12'd5;
		end
		
		GET_BESTF0:
		begin
			best_f0 <= pp_best_f0;
			sig <= check_sig;
		end
		
		//RAM_nlp_sq       nlp_sq	       (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);
			/* for(i=0; i<m-n; i++)
				nlp->sq[i] = nlp->sq[i+n]; */
		// m = 320 :: n = 80
		INIT_FOR_SQ:
		begin
			i <= 10'd0;
		end
		
		CHECK_FOR_SQ:
		begin
			
		end
		
		SET_ADDR_FOR_SQ:
		begin
			addr_nlp_sq <= i + 10'd80;
			read_sq <= 1'b1;
			write_sq <= 1'b0;
		end
		
		FOR_SQ_DELAY1:
		begin
		
		end
		
		FOR_SQ_DELAY2:
		begin
		
		end
		
		GET_SQ_I_N:
		begin
			out_sq_i_n <= out_sq;
			addr_nlp_sq <= i;
			read_sq <= 1'b0;
			write_sq <= 1'b1;
		end
		
		SET_SQ_I_N:
		begin
			in_sq <= out_sq_i_n;
		end
		
		INCR_SQ_I:
		begin
			i <= i + 10'd1;
		end
		
		START_DIV_BEST0:
		begin
			startdiv <= 1'b1;
			div_in <= best_f0;
			//sig <= 12'd7;
			
		end
		
		CALC_DIV_BESTF0:
		begin
			m1_in1 <= div_ans;
			m1_in2 <= NLP_FS;
			startdiv <= 1'b0; 
			//sig <= 12'd8;
		end
		
		SET_PITCH:
		begin
			pitch <= m1_out;
		
			out_prev_f0 <= best_f0;
			
			//	nlp_mem_x_out <= mem_x;
			//	nlp_mem_y_out <= mem_y;

				sig <= 12'd9;
		end
		
		DONE:
		begin
			donenlp <= 1'b1;
		end
		
		C_FFT1:
		begin
			addr_in_real <= 10'd32;
			re_fftr <= 1'b1;
			we_fftr <= 1'b0;
		end
		
		C_FFT1D1:
		begin
		
		end
		
		C_FFT1D2:
		begin
		
		end
		
		C_FFT2:
		begin
			//check_fft <= in_real_data;
		end

		endcase
	end

end


endmodule