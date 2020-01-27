/*
* Module         - estimate_voicing_mbe
* Top module     - analyse_one_frame
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Apr 24 14:28:59 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform58.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/
/*

	Inputs::
		L :: 79  -- 1001111
		W :: 


*/

module estimate_voicing_mbe (startevmbe, clk, rst, L_in, Wo_in, out_am,out_sw_real,out_sw_imag, snr, voiced , addr_am,addr_sw_real,addr_sw_imag,
							//m1_in1,m1_in2,m1_out,
							//m2_in1,m2_in2,m2_out,
							doneevmbe	);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,startevmbe;
			
			input [9:0] L_in; 
			input [N-1:0] Wo_in,out_am,out_sw_real,out_sw_imag;//m1_out,m2_out;
			output reg [N-1:0] snr;//m1_in1,m1_in2,m2_in1,m2_in2;
			output reg voiced;
			output reg [9:0] addr_am,addr_sw_real,addr_sw_imag;
			output reg doneevmbe;
			
			
			

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 7'd0,
          INIT = 7'd1,
          INIT_LOOP = 7'd2,
          CHECK_L = 7'd3,
          SET_ADDR_AM = 7'd4,
          SET_DELAY_1 = 7'd5,
          SET_DELAY_2 = 7'd6,
          GET_AM = 7'd7,
          ADD_SIG = 7'd8,
          SET_SIG = 7'd9,
          INCR_L = 7'd10,
		  CALC_L_1000HZ_1 = 7'd11,
		  CALC_L_1000HZ_2 = 7'd12,
		  SET_L1 = 7'd13,
		  CHECK_L1 = 7'd14,
		  INIT_MAIN_FOR = 7'd15,
		  CALC_AL_BL_1 = 7'd16,
		  CALC_AL_BL_2 = 7'd17,
		  CALC_AL_BL_3 = 7'd18,
		  SET_AL_BL = 7'd19,
		  CALC_OFFSET_1 = 7'd20,
		  CALC_OFFSET_2 = 7'd21,
		  CALC_OFFSET_3 = 7'd22,
		  SET_OFFSET_INIT_FOR_1 = 7'd23,
		  CHECK_M1 = 7'd24,
		  SET_ADDR_SW_W = 7'd25,
		  SET_DELAY_SW_1 = 7'd26,
		  SET_DELAY_SW_2 = 7'd27,
		  SET_SW_W = 7'd28,
		  CALC_AM_DEN = 7'd29,
		  INCR_M1 = 7'd30,
		  SET_AM_DEN = 7'd31,
		  CEIL_AL_BL_1 = 7'd32,
		  CEIL_AL_BL_2 = 7'd33,
		  INCR_L1 = 7'd34,
		  CALC_ONE_BY_DEN_1 = 7'd35,
		  CALC_ONE_BY_DEN_2 = 7'd36,
		  CALC_ONE_BY_DEN_3 = 7'd37,
		  SET_AM_REAL_IMAG_1 = 7'd38,
		  SET_AM_REAL_IMAG_2 = 7'd39,
		  INIT_FOR_2 = 7'd40,
		  CHECK_M2 = 7'd41,
		  SET_ADDR_SW_W_M2 = 7'd42,
		  SET_DELAY_3 = 7'd43,
		  SET_DELAY_4 = 7'd44,
		  SET_SW_W_M2 = 7'd45,
		  CALC_ERROR_1 = 7'd46,
		  CALC_ERROR_2 = 7'd47,
		  CALC_ERROR_3 = 7'd48,
		  CALC_ERROR_4 = 7'd49,
		  CALC_ERROR_5 = 7'd50,
		  SET_ERROR_FINAL = 7'd51,
		  INCR_M2 = 7'd52,
		  CALC_ONE_BY_ERROR_1 = 7'd53,
		  CALC_ONE_BY_ERROR_2 = 7'd54,
		  CALC_ONE_BY_ERROR_3 = 7'd55,
		  CALC_LOG_SNR_1 = 7'd56,
		  CALC_LOG_SNR_2 = 7'd57,
		  CALC_LOG_SNR_3 = 7'd58,
		  SET_LOG_SNR_1 = 7'd59,
		  SET_LOG_SNR_2 = 7'd60,
		  CHECK_SNR_V_THRESH = 7'd61,
		  SET_VOICED_BIT = 7'd62,
		  CALC_L2_L3 = 7'd63,
          SET_L2_L3 = 7'd64,
          INIT_FOR_L2 = 7'd65,
          CHECK_L2 = 7'd66,
          SET_ADDR_AM_2 = 7'd67,
          SET_DELAY_5 = 7'd68,
          SET_DELAY_6 = 7'd69,
          GET_AM_2 = 7'd70,
          ADD_ELOW = 7'd71,
          SET_ELOW = 7'd72,
          INCR_L2 = 7'd73,
          INIT_FOR_L3 = 7'd74,
          CHECK_L3 = 7'd75,
          SET_ADDR_AM_3 = 7'd76,
          SET_DELAY_7 = 7'd77,
          SET_DELAY_8 = 7'd78,
          GET_AM_3 = 7'd79,
          ADD_EHIGH = 7'd80,
          SET_EHIGH = 7'd81,
          INCR_L3 = 7'd82,
          CALC_ONE_BY_EHIGH_1 = 7'd83,
          CALC_ONE_BY_EHIGH_2 = 7'd84,
          CALC_ONE_BY_EHIGH_3 = 7'd85,
          CALC_E_BY_E_1 = 7'd86,
          CALC_E_BY_E_2 = 7'd87,
          LOG_E_BY_E_1 = 7'd88,
          LOG_E_BY_E_2 = 7'd89,
          LOG_E_BY_E_3 = 7'd90,
          SET_ERATIO = 7'd91,
          SET_IF_ERATIO = 7'd92,
          DET_VOICED_1 = 7'd93,
          SET_IF_SIXTY = 7'd94,
          DET_VOICED_FINAL = 7'd95,
          DONE = 7'd96;

reg [6:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
parameter POINT_0001		 = 32'b0_000000000000000_0000000000000110,
		    POINT_TWO_FIVE = 32'b0_000000000000000_0100000000000000,
			 POINT_FIVE		 = 32'b0_000000000000000_1000000000000000,
			 NEG_POINT_FIVE = 32'b1_000000000000000_1000000000000000,
			 ONE				 = 32'b0_000000000000001_0000000000000000,
			 TWO				 = 32'b0_000000000000010_0000000000000000,
			 FOUR 			 = 32'b0_000000000000100_0000000000000000,
			 TEN				 = 32'b0_000000000001010_0000000000000000,
			 NEG_TEN			 = 32'b1_000000000001010_0000000000000000,
			 NEG_FOUR		 = 32'b1_000000000000100_0000000000000000,
		    FFT_BY_2PI		 = 32'b0_000000001010001_0111110011000001,
			 FFT_BY_2		 = 32'b0_000000100000000_0000000000000000,
			 SIXTY			 = 32'b0_000000000000000_0000110000010000,
			 V_THRESH 		 = 32'b0_000000000000110_0000000000000000;

reg 	[N-1:0] 	a1_in1,a1_in2,a2_in1,a2_in2,
					m3_in1,m3_in2,a3_in1,a3_in2,
					gt1_in1, gt1_in2, lt1_in1, lt1_in2, lt2_in1, lt2_in2;
wire 	[N-1:0] 	a1_out,a2_out,m3_out,a3_out;//out_am; 
wire 				gt1, lt1, lt2;

reg 	[N-1:0] 	model_L;

//reg 	[9:0] addr_am;

reg  [9:0]  addr_w_real;
wire [N-1:0] out_w_real;

reg startdiv,startlog;
wire donediv,donelog;
reg [N-1:0] div_in,in_x;
wire [N-1:0] div_ans,out_y;

reg [N-1:0] one_by_error;


reg [N-1:0] m1_in1,m1_in2,m2_in1,m2_in2;
wire [N-1:0] m1_out,m2_out;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1      (a1_in1,a1_in2,a1_out);

qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2      (a2_in1,a2_in2,a2_out);

qmult  			#(Q,N) 			qmult3	   (m3_in1,m3_in2,m3_out); 	
qadd   			#(Q,N)			adder3      (a3_in1,a3_in2,a3_out);


//RAM_AM_evmbe     amram			(addr_am,clk,,1,0,out_am);
//RAM_Sw_real      swram			(addr_sw_real,clk,,1,0,out_sw_real);
//RAM_Sw_imag      swimag			(addr_sw_imag,clk,,1,0,out_sw_imag);
RAM_W_real       w_real			(addr_w_real,clk,,1,0,out_w_real);

fpdiv_clk  	  	 divider	    (startdiv,clk,rst,div_in,div_ans,donediv);
fp_log10 		 log10		 (startlog,clk,rst,in_x,out_y,donelog);

fpgreaterthan	#(Q,N)    fpgt1          (gt1_in1,gt1_in2,gt1);
fplessthan		#(Q,N)	 fplt1 			 (lt1_in1,lt1_in2,lt1);
fplessthan		#(Q,N)	 fplt2 			 (lt2_in1,lt2_in2,lt2);

reg [9:0] max_l;
reg [9:0] l,offset;
reg [9:0] l_1000hz;
reg [9:0] l_2000hz,l_4000hz;
reg [N-1:0]  Wo,one_by_ehigh,log_e,wo_fft_mul;
reg [N-1:0] Am_real, Am_imag, den, error,eratio,elow_by_ehigh;
reg [9:0] l1,m1,m2,l2,l3;
reg [N-1:0] elow,ehigh;
reg [N-1:0] al_temp,bl_temp,one_by_den,log_snr;

reg [9:0] al,bl;
reg [N-1:0] sig;

reg [N-1:0] ew_real,ew_imag; 

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
		if(startevmbe == 1'b1)
		begin
			NEXT_STATE = INIT;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT:
	begin
		NEXT_STATE = INIT_LOOP;
	end

	INIT_LOOP:
	begin
		NEXT_STATE = CHECK_L;
	end

	CHECK_L:
	begin
		if(l <= max_l)
		begin
			NEXT_STATE = SET_ADDR_AM;
		end
		else
		begin
			NEXT_STATE = CALC_L_1000HZ_1;
		end
	end

	SET_ADDR_AM:
	begin
		NEXT_STATE = SET_DELAY_1;
	end

	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end

	SET_DELAY_2:
	begin
		NEXT_STATE = GET_AM;
	end

	GET_AM:
	begin
		NEXT_STATE = ADD_SIG;
	end

	ADD_SIG:
	begin
		NEXT_STATE = SET_SIG;
	end

	SET_SIG:
	begin
		NEXT_STATE = INCR_L;
	end

	INCR_L:
	begin
		NEXT_STATE = CHECK_L;
	end
	
	CALC_L_1000HZ_1:
	begin
		NEXT_STATE = CALC_L_1000HZ_2;
	end

	CALC_L_1000HZ_2:
	begin
		NEXT_STATE = SET_L1;
	end
	
	SET_L1:
	begin
		NEXT_STATE = CHECK_L1;
	end
	
	CHECK_L1:
	begin
		if(l1 <= l_1000hz)
		begin
			NEXT_STATE = INIT_MAIN_FOR;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_ERROR_1;
		end
	end
	
	INIT_MAIN_FOR:
	begin
		NEXT_STATE = CALC_AL_BL_1;
	end
	
	CALC_AL_BL_1:
	begin
		NEXT_STATE = CALC_AL_BL_2;
	end
	
	CALC_AL_BL_2:
	begin
		NEXT_STATE = CALC_AL_BL_3;
	end	
	
	CALC_AL_BL_3: 
	begin
		NEXT_STATE = SET_AL_BL;
	end	
	
	SET_AL_BL :
	begin
		NEXT_STATE = CEIL_AL_BL_1;
	end	
	
	CEIL_AL_BL_1:
	begin
		NEXT_STATE = CEIL_AL_BL_2;
	end
		
	CEIL_AL_BL_2:
	begin
		NEXT_STATE = CALC_OFFSET_1;
	end
	
	CALC_OFFSET_1:
	begin
		NEXT_STATE = CALC_OFFSET_2;
	end
	
	CALC_OFFSET_2 :
	begin
		NEXT_STATE = CALC_OFFSET_3;
	end
	
	CALC_OFFSET_3:
	begin
		NEXT_STATE = SET_OFFSET_INIT_FOR_1;
	end
	
	SET_OFFSET_INIT_FOR_1:
	begin
		NEXT_STATE = CHECK_M1;
	end
	
	CHECK_M1:
	begin
		if(m1 < bl)
		begin
			NEXT_STATE = SET_ADDR_SW_W;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_DEN_1;
		end
	end
	
	SET_ADDR_SW_W :
	begin
		NEXT_STATE = SET_DELAY_SW_1;
	end
	
	SET_DELAY_SW_1 :
	begin
		NEXT_STATE = SET_DELAY_SW_2;
	end
	
	SET_DELAY_SW_2 :
	begin
		NEXT_STATE = SET_SW_W;
	end
	
	SET_SW_W :
	begin
		NEXT_STATE = CALC_AM_DEN;
	end
	
	CALC_AM_DEN :
	begin
		NEXT_STATE = SET_AM_DEN;
	end
	
	SET_AM_DEN:
	begin
		NEXT_STATE = INCR_M1;
	end
	
	INCR_M1 :
	begin
		NEXT_STATE = CHECK_M1;
	end
	
	INCR_L1:
	begin
		NEXT_STATE = CHECK_L1;
	end
	
	CALC_ONE_BY_DEN_1:
	begin
		NEXT_STATE = CALC_ONE_BY_DEN_2;
	end
	
	CALC_ONE_BY_DEN_2:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_ONE_BY_DEN_3;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_DEN_2;
		end
	end
	
	CALC_ONE_BY_DEN_3:
	begin
		NEXT_STATE = SET_AM_REAL_IMAG_1;
	end
	
	SET_AM_REAL_IMAG_1:
	begin
		NEXT_STATE = SET_AM_REAL_IMAG_2;
	end
	
	SET_AM_REAL_IMAG_2:
	begin
		NEXT_STATE = INIT_FOR_2;
	end
	
	INIT_FOR_2 :
	begin
		NEXT_STATE = CHECK_M2;
	end
	
	CHECK_M2 :
	begin
		if(m2 < bl)
		begin
			NEXT_STATE = SET_ADDR_SW_W_M2;
		end
		else
		begin
			NEXT_STATE = INCR_L1;
		end
	end
	
	SET_ADDR_SW_W_M2 :
	begin
		NEXT_STATE = SET_DELAY_3;
	end
	
	SET_DELAY_3 :
	begin
		NEXT_STATE = SET_DELAY_4;
	end
	
	SET_DELAY_4:
	begin
		NEXT_STATE = SET_SW_W_M2;
	end
	
	SET_SW_W_M2 :
	begin
		NEXT_STATE = CALC_ERROR_1;
	end
	
	CALC_ERROR_1: 
	begin
		NEXT_STATE = CALC_ERROR_2;
	end
	
	CALC_ERROR_2 :
	begin
		NEXT_STATE = CALC_ERROR_3;
	end
	
	CALC_ERROR_3 :
	begin
		NEXT_STATE = CALC_ERROR_4;
	end
	
	CALC_ERROR_4 :
	begin
		NEXT_STATE = CALC_ERROR_5;
	end
	
	CALC_ERROR_5 :
	begin
		NEXT_STATE = SET_ERROR_FINAL;
	end
	
	SET_ERROR_FINAL :
	begin
		NEXT_STATE = INCR_M2;
	end
	
	INCR_M2 :
	begin
		NEXT_STATE = CHECK_M2;
	end
	
	CALC_ONE_BY_ERROR_1:
	begin
		NEXT_STATE = CALC_ONE_BY_ERROR_2;
	end
	
	CALC_ONE_BY_ERROR_2:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_ONE_BY_ERROR_3;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_ERROR_2;
		end
	end
	
	CALC_ONE_BY_ERROR_3:
	begin
		NEXT_STATE = CALC_LOG_SNR_1;
	end
	
	CALC_LOG_SNR_1:
	begin
		NEXT_STATE = CALC_LOG_SNR_2;
	end
	
	CALC_LOG_SNR_2:
	begin
		if(donelog)
		begin
			NEXT_STATE = CALC_LOG_SNR_3;
		end
		else
		begin
			NEXT_STATE = CALC_LOG_SNR_2;
		end
		
	end
	
	CALC_LOG_SNR_3:
	begin
		NEXT_STATE = SET_LOG_SNR_1;
	end
	
	SET_LOG_SNR_1:
	begin
		NEXT_STATE = SET_LOG_SNR_2;
	end
	
	SET_LOG_SNR_2:
	begin
		NEXT_STATE = CHECK_SNR_V_THRESH;
	end
	
	CHECK_SNR_V_THRESH:
	begin
		NEXT_STATE = SET_VOICED_BIT;
	end
	
	SET_VOICED_BIT:
	begin
		NEXT_STATE = CALC_L2_L3;
	end
	
	CALC_L2_L3:
	begin
		NEXT_STATE = SET_L2_L3;
	end

	SET_L2_L3:
	begin
		NEXT_STATE = INIT_FOR_L2;
	end

	INIT_FOR_L2:
	begin
		NEXT_STATE = CHECK_L2;
	end

	CHECK_L2:
	begin
		if(l2 <= l_2000hz)
		begin
			NEXT_STATE = SET_ADDR_AM_2;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_L3;
		end
	end

	SET_ADDR_AM_2:
	begin
		NEXT_STATE = SET_DELAY_5;
	end

	SET_DELAY_5:
	begin
		NEXT_STATE = SET_DELAY_6;
	end

	SET_DELAY_6:
	begin
		NEXT_STATE = GET_AM_2;
	end

	GET_AM_2:
	begin
		NEXT_STATE = ADD_ELOW;
	end

	ADD_ELOW:
	begin
		NEXT_STATE = SET_ELOW;
	end

	SET_ELOW:
	begin
		NEXT_STATE = INCR_L2;
	end

	INCR_L2:
	begin
		NEXT_STATE = CHECK_L2;
	end

	INIT_FOR_L3:
	begin
		NEXT_STATE = CHECK_L3;
	end

	CHECK_L3:
	begin
		if(l3 <= l_4000hz)
		begin
			NEXT_STATE = SET_ADDR_AM_3;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_EHIGH_1;
		end
	end

	SET_ADDR_AM_3:
	begin
		NEXT_STATE = SET_DELAY_7;
	end

	SET_DELAY_7:
	begin
		NEXT_STATE = SET_DELAY_8;
	end

	SET_DELAY_8:
	begin
		NEXT_STATE = GET_AM_3;
	end

	GET_AM_3:
	begin
		NEXT_STATE = ADD_EHIGH;
	end

	ADD_EHIGH:
	begin
		NEXT_STATE = SET_EHIGH;
	end

	SET_EHIGH:
	begin
		NEXT_STATE = INCR_L3;
	end

	INCR_L3:
	begin
		NEXT_STATE = CHECK_L3;
	end

	CALC_ONE_BY_EHIGH_1:
	begin
		NEXT_STATE = CALC_ONE_BY_EHIGH_2;
	end

	CALC_ONE_BY_EHIGH_2:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_ONE_BY_EHIGH_3;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_EHIGH_2;
		end
	end

	CALC_ONE_BY_EHIGH_3:
	begin
		NEXT_STATE = CALC_E_BY_E_1;
	end

	CALC_E_BY_E_1:
	begin
		NEXT_STATE = CALC_E_BY_E_2;
	end

	CALC_E_BY_E_2:
	begin
		NEXT_STATE = LOG_E_BY_E_1;
	end

	LOG_E_BY_E_1:
	begin
		if(donelog)
		begin
			NEXT_STATE = LOG_E_BY_E_2;
		end
		else
		begin
			NEXT_STATE = LOG_E_BY_E_1;
		end
	end

	LOG_E_BY_E_2:
	begin
		NEXT_STATE = LOG_E_BY_E_3;
	end

	LOG_E_BY_E_3:
	begin
		NEXT_STATE = SET_ERATIO;
	end

	SET_ERATIO:
	begin
		NEXT_STATE = SET_IF_ERATIO;
	end

	SET_IF_ERATIO:
	begin
		NEXT_STATE = DET_VOICED_1;
	end

	DET_VOICED_1:
	begin
		NEXT_STATE = SET_IF_SIXTY;
	end

	SET_IF_SIXTY:
	begin
		NEXT_STATE = DET_VOICED_FINAL;
	end

	DET_VOICED_FINAL:
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

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		doneevmbe <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneevmbe <= 1'b0;
			voiced <= 1'b1;
		end

		INIT:
		begin
			sig <= POINT_0001;
			error <= POINT_0001;
			ehigh <= POINT_0001;
			elow  <= POINT_0001;
			m1_in1 <= {6'b0,L_in,16'b0};
			m1_in2 <= POINT_TWO_FIVE;
			model_L <= {6'b0,L_in,16'b0};
			Wo <= Wo_in;
		end

		INIT_LOOP:
		begin
			l <= 10'd1;
			max_l <= m1_out[25:16];
		end

		CHECK_L:
		begin 
			
		end

		SET_ADDR_AM:
		begin
			addr_am <= l;
		end

		SET_DELAY_1:
		begin
			
		end

		SET_DELAY_2:
		begin
			
		end

		GET_AM:
		begin
			m1_in1 <= out_am;
			m1_in2 <= out_am;
			//check_out_am <= out_am;
		end

		ADD_SIG:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= sig;
		end

		SET_SIG:
		begin
			sig <= a1_out;
		end

		INCR_L:
		begin
			l <= l + 10'd1;
		end
		
		CALC_L_1000HZ_1:
		begin
			m1_in1 <= model_L;
			m1_in2 <= POINT_TWO_FIVE;
		end

		CALC_L_1000HZ_2:
		begin
			l_1000hz <= m1_out[25:16];
		end
		
		SET_L1:
		begin
			l1 <= 10'd1;
		end
		
		CHECK_L1:
		begin
			
		end
		
		INIT_MAIN_FOR:
		begin
			Am_real <= 32'b0;
			Am_imag <= 32'b0;
			den		<= 32'b1;
		end	

		CALC_AL_BL_1:
		begin
			m1_in1 <= Wo;
			m1_in2 <= FFT_BY_2PI;
		end
		
		CALC_AL_BL_2:
		begin
			a1_in1 <= {6'b0,l1,16'b0};
			a1_in2 <= NEG_POINT_FIVE;
			a2_in1 <= {6'b0,l1,16'b0};
			a2_in2 <= POINT_FIVE;
			wo_fft_mul <= m1_out;
		end	
		
		CALC_AL_BL_3: 
		begin
			m1_in1 <= a1_out;
			m1_in2 <= m1_out;
			m2_in1 <= a2_out;
			m2_in2 <= m1_out;
		end	
		
		SET_AL_BL :
		begin
			al_temp <= m1_out;
			bl_temp <= m2_out;
		end	
		
		CEIL_AL_BL_1:
		begin
			a1_in1 <= al_temp;
			a1_in2 <= ONE;
			
			a2_in1 <= bl_temp;
			a2_in2 <= ONE;
		end
		
		CEIL_AL_BL_2:
		begin
			al <= a1_out[25:16];
			bl <= a2_out[25:16];
		end
		
		CALC_OFFSET_1:
		begin
			m1_in1 <= {6'b0,l1,16'b0};
			m1_in2 <= wo_fft_mul;
		end
		
		CALC_OFFSET_2 :
		begin
			a1_in1 <= {1'b1,m1_out[N-2:0]};
			a1_in2 <= POINT_FIVE;
		end
		
		CALC_OFFSET_3:
		begin
			
			a1_in1 <= a1_out;
			a1_in2 <= FFT_BY_2;
		end
		
		SET_OFFSET_INIT_FOR_1:
		begin
			offset <= a1_out[25:16];
			m1 <= al;
		end
		
		CHECK_M1:
		begin
			a1_in1 <=  {6'b0,offset,16'b0};
			a1_in2 <=  {6'b0,m1,16'b0};
		end
		
		SET_ADDR_SW_W :
		begin
			addr_sw_real <= m1;
			addr_sw_imag <= m1;
			
			addr_w_real <= a1_out[25:16];
		end
		
		SET_DELAY_SW_1 :
		begin
			
		end
		
		SET_DELAY_SW_2 :
		begin
			
		end
		
		SET_SW_W :
		begin
			m1_in1 <= out_sw_real;
			m1_in2 <= out_w_real;
			m2_in1 <= out_sw_imag;
			m2_in2 <= out_w_real;
			m3_in1 <= out_w_real;
			m3_in2 <= out_w_real;
		end
		
		CALC_AM_DEN :
		begin
			a1_in1 <= m1_out;
			a1_in2 <= Am_real;
			a2_in1 <= m2_out;
			a2_in2 <= Am_imag;
			a3_in1 <= den;
			a3_in2 <= m3_out;
			
		end
		
		SET_AM_DEN:
		begin
			Am_real <= a1_out;
			Am_imag <= a2_out;
			den <= a3_out;
		end
		
		INCR_M1 :
		begin
			m1 <= m1 + 10'd1;
		end
		
		INCR_L1:
		begin
			l1 <= l1 + 10'd1;
		end
		
		CALC_ONE_BY_DEN_1:
		begin
			startdiv <= 1'b1;
		end
		
		CALC_ONE_BY_DEN_2:
		begin
			div_in <= den;
			startdiv <= 1'b0;
		end
		
		CALC_ONE_BY_DEN_3:
		begin
			one_by_den <= div_ans;
		end
		
		SET_AM_REAL_IMAG_1:
		begin
			m1_in1 <= Am_real;
			m1_in2 <= one_by_den;
			m2_in1 <= Am_imag;
			m2_in2 <= one_by_den;
		end
		
		SET_AM_REAL_IMAG_2:
		begin
			Am_real <= m1_out;
			Am_imag <= m2_out;
		end
		
		INIT_FOR_2 :
		begin
			m2 <= al;
		end
		
		CHECK_M2 :
		begin
			a1_in1 <=  {6'b0,offset,16'b0};
			a1_in2 <=  {6'b0,m2,16'b0};
			
		end
		
		SET_ADDR_SW_W_M2 :
		begin
			addr_sw_real <= m2;
			addr_sw_imag <= m2;
			
			addr_w_real <= a1_out[25:16];
		end
		
		SET_DELAY_3 :
		begin
			
		end
		
		SET_DELAY_4 :
		begin
			
		end
		
		SET_SW_W_M2:
		begin
			m1_in1 <= Am_real;
			m1_in2 <= out_w_real;
			m2_in1 <= Am_imag;
			m2_in2 <= out_w_real;
		end
		
		CALC_ERROR_1 :
		begin
			a1_in1 <= out_sw_real;
			a1_in2 <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
			a2_in1 <= out_sw_imag;
			a2_in2 <= {(m2_out[N-1] == 0)?1'b1:1'b0,m2_out[N-2:0]};
		end
		
		CALC_ERROR_2: 
		begin
			ew_real <= a1_out;
			ew_imag <= a2_out;
		end
		
		CALC_ERROR_3 :
		begin
			m1_in1 <= ew_real;
			m1_in2 <= ew_real;
			m2_in1 <= ew_imag;
			m2_in2 <= ew_imag;
			
		end
		
		CALC_ERROR_4 :
		begin
			a1_in1 <= error;
			a1_in2 <= m1_out;
		end
		
		CALC_ERROR_5 :
		begin
			a1_in1 <= a1_out;
			a1_in2 <= m2_out;
		end
		
		SET_ERROR_FINAL :
		begin
			error <= a1_out;
		end
		
		INCR_M2 :
		begin
			m2 <= m2 + 10'd1;
		end
		
		CALC_ONE_BY_ERROR_1:
		begin
			startdiv <= 1'b1;
		end
		
		CALC_ONE_BY_ERROR_2:
		begin
			div_in <= error;
			startdiv <= 1'b0;
		end
		
		CALC_ONE_BY_ERROR_3:
		begin
			one_by_error <= div_ans;
		end
		
		CALC_LOG_SNR_1:
		begin
			m1_in1 <= sig;
			m1_in2 <= one_by_error;
			startlog <= 1'b1;
		end
		
		CALC_LOG_SNR_2:
		begin
			in_x <= m1_out;	
			startlog <= 1'b0;
		end
		
		CALC_LOG_SNR_3:
		begin
			log_snr <= out_y;
		end
		
		SET_LOG_SNR_1:
		begin
			m1_in1 <= log_snr;
			m1_in2 <= TEN;
		end
		
		SET_LOG_SNR_2:
		begin
			snr <= m1_out;
		end
		
		CHECK_SNR_V_THRESH:
		begin
			gt1_in1 <= snr;
			gt1_in2 <= V_THRESH;
		end
		
		SET_VOICED_BIT:
		begin
			if(gt1)
			begin
				voiced <= 1'b1;
			end
			else
			begin
				voiced <= 1'b0;
			end
			
		end
		
		CALC_L2_L3:
		begin
			m1_in1 <= {6'b0,l_1000hz,16'b0};
			m1_in2 <= TWO;
			m2_in1 <= {6'b0,l_1000hz,16'b0};
			m2_in2 <= FOUR;
		end

		SET_L2_L3:
		begin
			l_2000hz <= m1_out[25:16];
			l_4000hz <= m2_out[25:16];
		end

		INIT_FOR_L2:
		begin
			l2 <= 10'd1;
		end

		CHECK_L2:
		begin
			
		end

		SET_ADDR_AM_2:
		begin
			addr_am <= l2;
		end

		SET_DELAY_5:
		begin
			
		end

		SET_DELAY_6:
		begin
			
		end

		GET_AM_2:
		begin
			m1_in1 <= out_am;
			m1_in2 <= out_am;
		end

		ADD_ELOW:
		begin
			a1_in1 <= elow;
			a1_in2 <= m1_out;
			
		end

		SET_ELOW:
		begin
			elow <= a1_out;
		end

		INCR_L2:
		begin
			l2 <= l2 + 10'd1;
		end

		INIT_FOR_L3:
		begin
			l3 <= l_2000hz;
		end

		CHECK_L3:
		begin
			
		end

		SET_ADDR_AM_3:
		begin
			addr_am <= l3;
		end

		SET_DELAY_7:
		begin
			
		end

		SET_DELAY_8:
		begin
			
		end

		GET_AM_3:
		begin
			m1_in1 <= out_am;
			m1_in2 <= out_am;
		end

		ADD_EHIGH:
		begin
			a1_in1 <= ehigh;
			a1_in2 <= m1_out;
		end

		SET_EHIGH:
		begin
			ehigh <= a1_out;
		end

		INCR_L3:
		begin
			l3 <= l3 + 10'd1;
		end

		CALC_ONE_BY_EHIGH_1:
		begin
			startdiv <= 1'b1;
		end

		CALC_ONE_BY_EHIGH_2:
		begin
			div_in <= ehigh;
			startdiv <= 1'b0;
		end

		CALC_ONE_BY_EHIGH_3:
		begin
			one_by_ehigh <= div_ans;
		end

		CALC_E_BY_E_1:
		begin
			m1_in1 <= elow;
			m1_in2 <= one_by_ehigh;
		end

		CALC_E_BY_E_2:
		begin
			elow_by_ehigh <= m1_out;
			startlog <= 1'b1;
		end

		LOG_E_BY_E_1:
		begin
			in_x <= elow_by_ehigh;
			startlog <= 1'b0;
		end

		LOG_E_BY_E_2:
		begin
			log_e <= out_y;
		end

		LOG_E_BY_E_3:
		begin
			m1_in1 <= log_e;
			m1_in2 <= TEN;
		end

		SET_ERATIO:
		begin
			eratio <= m1_out;
		end

		SET_IF_ERATIO:
		begin
			gt1_in1 <= eratio;
			gt1_in2 <= TEN;
			lt1_in1 <= eratio;
			lt1_in2 <= NEG_TEN;
		end

		DET_VOICED_1:
		begin
			if(!voiced)
			begin
				if(gt1)
				begin
					voiced <= 1'b1;
				end
				else
				begin
					voiced <= 1'b0;
				end
				
			end
			else
			begin
				if(lt1)
				begin
					voiced <= 1'b0;
				end
				else
				begin
					voiced <= 1'b1;
				end
			end
			
		end

		SET_IF_SIXTY:
		begin
			lt1_in1 <= eratio;
			lt1_in2 <= NEG_FOUR;
			lt2_in1 <= Wo;
			lt2_in2 <= SIXTY;
		end

		DET_VOICED_FINAL:
		begin
			if(lt1 && (lt2 || (Wo == SIXTY)))
			begin
				voiced <= 1'b0;
			end
			else
			begin
				voiced <= 1'b1;
			end
		end
	
		DONE:
		begin
			doneevmbe <= 1'b1;
		end

		endcase
	end

end


endmodule