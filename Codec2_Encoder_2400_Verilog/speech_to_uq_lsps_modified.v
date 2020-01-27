/*
* Module         - speech_to_uq_lsps_
* Top module     - codec2_encode_2400
* Project        - CODEC2_ENCODE_2400


* Developer      - Santhiya S
* Date           - Thu Mar 14 10:47:50 2019
*
* Description    -
* Inputs         -
* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module speech_to_uq_lsps_modified(	startspeech,clk,rst,out_sn,
							E,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9,addr_sn,
							donespeech
							// ,c_ak0,c_ak1,c_ak2,c_ak3,c_ak4,c_ak5,c_ak6,c_ak7,c_ak8,c_ak9,c_ak10
							 
							 );


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
		parameter N = 32;
		parameter Q = 16;
		
		parameter N1 = 80;
		parameter Q1 = 16;
		
		parameter N2 = 48;
		parameter Q2 = 32;
		
		parameter N3 = 50;
		parameter Q3 = 32;
		
		parameter N4 = 34;
		parameter Q4 = 16;
		
		input startspeech,clk,rst;
		input [N-1:0] out_sn;
		output reg [N-1:0] E;
		output reg [N-1:0] lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9;
		output reg [9:0] addr_sn;
		output reg donespeech;
		//output reg [8:0] c_sn_addr1;
		
		 reg [N-1:0] check_corr;
		 reg [N-1:0] check_ak0_lev,check_ak1_lev;
		
		 reg [N-1:0] c_ak0,c_ak1,c_ak2,c_ak3,c_ak4,c_ak5,c_ak6,c_ak7,c_ak8,c_ak9,c_ak10;
		
		/*  reg [9:0] addr_sn;
		wire [N-1:0] out_sn;
		RAM_c2_speech_sn c2_sn (addr_sn,clk,,1,0,out_sn);  // frame 0 - 160 samples  */
		  
		
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 7'd0,
          INIT = 7'd1,
          SET_READ_SN = 7'd2,
          SET_AUTOCORRELATE = 7'd3,
          SET_LEVINSON = 7'd4,
          INIT_LOOP = 7'd5,
          PRE_CALC_E = 7'd6,
          CALC_E = 7'd7,
          INCR_I = 7'd8,
          CHECK_I = 7'd9,
          READ_AK = 7'd10,
          SET_LPC_TO_LSP = 7'd11,
          DONE = 7'd12,
		 INIT_FOR_1 = 7'd13,
		 CHECK_I1 = 7'd14,
		 SET_ADDR_SN = 7'd15,
		 SET_DELAY1 = 7'd16,
		 MULT_SN_W = 7'd17,
		 SQUARE_WN = 7'd18,
		 SUM_SMALL_E = 7'd19,
		 SET_SMALL_E = 7'd20,
		 INCR_I1 = 7'd21,
		 RUN_LEVINSON = 7'd22,
		 GET_LEVINSON = 7'd23,
		 SET_DELAY2 = 7'd24,
		 INIT_FOR_AC = 7'd25,
		 CHECK_AC = 7'd26,
		 INIT_R = 7'd27,
		 INIT_FOR_AC1 = 7'd28,
		 CHECK_AC1 = 7'd29,
		 AUTO_CORR_WN = 7'd30,
		 SET_WN_CORR = 7'd31,
		 ADD_RN = 7'd32,
		 SET_RN = 7'd33,
		 INCR_AC1 = 7'd34,
		 INCR_AC = 7'd35,
		 SET_D_AC1 = 7'd36,
		 SET_D_AC2 = 7'd37,
		 SET_M1_AC = 7'd38,
		 SET_M2_AC_ADDR = 7'd39,
		 SET_D_AC3 = 7'd40,
		 SET_D_AC4 = 7'd41,
		 SET_M2_AC = 7'd42,
		 INIT_READ_LPC = 7'd43,
		 CHECK_LPC = 7'd44,
		 READ_LPC_ADDR = 7'd45,
		 SET_D_LPC1 = 7'd46,
		 SET_D_LPC2 = 7'd47,
		 GET_LPC_TO_AK = 7'd48,
		 INCR_LPC = 7'd49,
		 INIT_AK_UPDATE = 7'd50,
		 CHECK_AK = 7'd51,
		 UPDATE_AK = 7'd52,
		 SET_AK = 7'd53,
		 INCR_AK = 7'd54,
		 RUN_LTL = 7'd55,
		 GET_LTL = 7'd56,
		 SQUARE_WN_2 = 7'd57;
		 

reg [6:0] STATE, NEXT_STATE;


parameter [N-1:0] 	powf0  = {15'b0,1'b1,16'b0},
					powf1  = {16'b0,16'b1111111001110110},
					powf2  = {16'b0,16'b1111110011101111},
					powf3  = {16'b0,16'b1111101101101011},
					powf4  = {16'b0,16'b1111100111101001},
					powf5  = {16'b0,16'b1111100001101001},
					powf6  = {16'b0,16'b1111011011101011},
					powf7  = {16'b0,16'b1111010101110000},
					powf8  = {16'b0,16'b1111001111110111},
					powf9  = {16'b0,16'b1111001010000000},
					powf10 = {16'b0,16'b1111000100001100};
					

//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------


reg [3:0] i;
reg [9:0] i1,ac,ac1;
reg [N-1:0] m1_in1,m1_in2,a1_in1,a1_in2;
wire [N-1:0] m1_out,a1_out;
reg [N-1:0] ak0,ak1,ak2,ak3,ak4,ak5,ak6,ak7,ak8,ak9,ak10;

reg [N4-1:0] Rn0,Rn1,Rn2,Rn3,Rn4,Rn5,Rn6,Rn7,Rn8,Rn9,Rn10;

wire [9:0] sn_addr1;
reg [N-1:0] sn_read_data1;
reg startac;
wire doneac;

reg [9:0] lp,ak;

reg [N2-1:0] wn_corr;
reg [N3-1:0] e;

reg [N2-1:0] ms1_in1,ms1_in2,ms2_in1,ms2_in2,as1_in1,as1_in2;
wire [N2-1:0] ms1_out,ms2_out,as1_out;
reg [N3-1:0] as2_in1,as2_in2;
wire [N3-1:0] as2_out;

reg [N4-1:0] m2_in1,m2_in2;
wire [N4-1:0] m2_out;


qadd   #(Q,N)			adder1    (a1_in1,a1_in2,a1_out);

qmult  #(Q,N) 			qmult1	  (m1_in1,m1_in2,m1_out);
qmult  #(Q4,N4)			qmult_34  (m2_in1,m2_in2,m2_out);

qmult  #(Q2,N2) 	qmult_48_1	  (ms1_in1,ms1_in2,ms1_out);
//qmult  #(Q2,N2) 	qmult_48_2	  (ms2_in1,ms2_in2,ms2_out);
qadd   #(Q2,N2)		adder_48_1    (as1_in1,as1_in2,as1_out);
qadd   #(Q3,N3)		adder_50_1    (as2_in1,as2_in2,as2_out);

/* --------------------------------- autocorrelate module -------------------------------*/
//RAM_autocorrelate_Sn ram1_sn(sn_addr1,clk,,1,0,sn_read_data1);
//RAM_autocorrelate_Sn ram2_sn(sn_addr2,clk,,1,0,sn_read_data2);

reg [9:0] addr_wn;
reg [N2-1:0] write_wn;
reg we_wn, re_wn;
wire [N2-1:0] read_wn_out;

RAM_ac_Wn_48 RAM_ac_Wn_module (addr_wn, clk, write_wn, re_wn, we_wn, read_wn_out);
//
//autocorrelate_rn_ram auto_mod(startac,clk,rst,sn_read_data1,
//										Rn0,Rn1,Rn2,Rn3,Rn4,Rn5,
//										Rn6,Rn7,Rn8,Rn9,Rn10,sn_addr1,doneac);
//


/* --------------------------------- RAM_ld_lpcs module -------------------------------*/
/* --------------------------------- for storing lpc values from levinson durbin module------------*/

wire [3:0] ld_addr_ld,ld_in_lpc;
wire [N-1:0] in_lpc;
reg re_ld,we_ld;
wire [N-1:0] out_lpc;
reg [3:0] addr_ld;

RAM_ld_lpcs RAM_ld (addr_ld,clk,in_lpc,re_ld,we_ld,out_lpc);

/* --------------------------------- levinson_durbin module -------------------------------*/

reg startld;
reg [N3-1:0] R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10;
reg [N4-1:0] ld_R0,ld_R1,ld_R2,ld_R3,ld_R4,ld_R5,
								ld_R6,ld_R7,ld_R8,ld_R9,ld_R10;
wire doneld;
wire [N-1:0] check_ak0,check_ak1;


levinson_durbin_3mult lev_dur_module(startld,clk,rst,ld_R0,ld_R1,ld_R2,ld_R3,ld_R4,ld_R5,
								ld_R6,ld_R7,ld_R8,ld_R9,ld_R10,in_lpc,ld_addr_ld,doneld);
							//	check_ak0,check_ak1);
								
								

/* --------------------------------- dummy RAM for speech module -------------------------------*/

/* reg [9:0] addr_sn;
wire [N-1:0] out_sn;
							
RAM_speech ram_sn_module(addr_sn,clk,,1,0,out_sn); */

/* ----------------------RAM_ak-------------------------------------------------------*/
/* reg [3:0] ak_addr;
reg [N-1:0] write_ak;
reg re_ak,we_ak;
wire [N-1:0] read_ak_out;

RAM_ak         module_RAM_ak			   (ak_addr,clk,write_ak,re_ak,we_ak,read_ak_out); */

/* -------------------------lpc_to_lsp-------------------------------------------------- */

reg startltl;
wire [N-1:0] freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9;
wire [3:0] ltl_ak_addr;
reg [N-1:0] ltl_ak_out;
reg [N-1:0] ll_ak0,ll_ak1,ll_ak2,ll_ak3,ll_ak4,ll_ak5,ll_ak6,ll_ak7,ll_ak8,ll_ak9,ll_ak10;
wire doneltl;


lpc_to_lsp ltl_module	(startltl,clk,rst,ltl_ak_out,
						ll_ak0,ll_ak1,ll_ak2,ll_ak3,ll_ak4,ll_ak5,ll_ak6,ll_ak7,ll_ak8,ll_ak9,ll_ak10,
						freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9,
						 ltl_ak_addr,doneltl);
 
/* -------------------------------------ROM_w--------------------------------------------*/
reg [9:0] addr_speech_w;
wire [N2-1:0] data_out_speech_w;

ROM_speech_w_48    speech_w (addr_speech_w, data_out_speech_w);


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


/* always@(*)
begin
	case(STATE)
	RUN_LEVINSON:
	begin
		addr_ld = ld_addr_ld;
	end
	
	READ_LPC_ADDR:
	begin
		addr_ld = lp;
	end

	default:
	begin
	//	addr_ld = 4'd0; 
	end
	
	endcase

end  */ 


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		if(startspeech)
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
		NEXT_STATE = INIT_FOR_1;
	end
	
	INIT_FOR_1:
	begin
		NEXT_STATE = CHECK_I1;
	end
	
	CHECK_I1:
	begin
		if(i1 < 10'd320)    //fix this
		begin
			NEXT_STATE = SET_ADDR_SN;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_AC;
		end
	end
	
	SET_ADDR_SN:
	begin
		NEXT_STATE = SET_DELAY1;
	end
	
	SET_DELAY1:
	begin
		NEXT_STATE = SET_DELAY2;
	end
	
	SET_DELAY2:
	begin
		NEXT_STATE = MULT_SN_W;
	end
	
	MULT_SN_W:
	begin
		NEXT_STATE = SQUARE_WN;
	end
	
	SQUARE_WN:
	begin
		NEXT_STATE = SQUARE_WN_2;
	end
	
	SQUARE_WN_2:
	begin
		NEXT_STATE = SUM_SMALL_E;
	end
	
	SUM_SMALL_E:
	begin
		NEXT_STATE = SET_SMALL_E;
	end
	
	SET_SMALL_E:
	begin
		NEXT_STATE =  INCR_I1;
	end
	
	INCR_I1:
	begin
		NEXT_STATE = CHECK_I1;
	end
	
	INIT_FOR_AC:
	begin
		NEXT_STATE = CHECK_AC;
	end
	
	CHECK_AC:
	begin
		if(ac <= 10'd10)
		begin
			NEXT_STATE = INIT_R;
		end
		else
		begin
			NEXT_STATE = SET_LEVINSON;
		end
	end
	
	INIT_R:
	begin
		NEXT_STATE = INIT_FOR_AC1;
	end
	
	INIT_FOR_AC1:
	begin
		NEXT_STATE = CHECK_AC1;
	end
	
	CHECK_AC1:
	begin
		if(ac1 < 10'd320 - ac)
		begin
			NEXT_STATE = AUTO_CORR_WN;
		end
		else
		begin
			NEXT_STATE = INCR_AC;
		end
	end
	
	AUTO_CORR_WN:
	begin
		NEXT_STATE = SET_D_AC1;
	end
	
	SET_D_AC1:
	begin
		NEXT_STATE = SET_D_AC2;
	end
	
	SET_D_AC2:
	begin
		NEXT_STATE = SET_M1_AC;
	end
	
	SET_M1_AC:
	begin
		NEXT_STATE = SET_M2_AC_ADDR;
	end
	
	SET_M2_AC_ADDR:
	begin
		NEXT_STATE = SET_D_AC3;
	end
	
	SET_D_AC3:
	begin
		NEXT_STATE = SET_D_AC4;
	end
	
	SET_D_AC4:
	begin
		NEXT_STATE = SET_M2_AC;
	end
	
	SET_M2_AC:
	begin
		NEXT_STATE = SET_WN_CORR;
	end
	
	SET_WN_CORR:
	begin
		NEXT_STATE = ADD_RN;
	end
	
	ADD_RN:
	begin
		NEXT_STATE = SET_RN;
	end
	
	SET_RN:
	begin
		NEXT_STATE = INCR_AC1;
	end
	
	INCR_AC1:
	begin
		NEXT_STATE = CHECK_AC1;
	end
	
	INCR_AC:
	begin
		NEXT_STATE = CHECK_AC;
	end
	
	SET_LEVINSON:
	begin
		NEXT_STATE = RUN_LEVINSON;
	end
	
	RUN_LEVINSON:
	begin
		if(doneld)
		begin
			NEXT_STATE = GET_LEVINSON;
		end
		else
		begin
			NEXT_STATE = RUN_LEVINSON;
		end
	end

	GET_LEVINSON:
	begin
		NEXT_STATE = INIT_READ_LPC;
	end
	
	INIT_READ_LPC:
	begin
		NEXT_STATE = CHECK_LPC;
	end
	
	CHECK_LPC:
	begin
		if(lp <= 10'd10)
		begin
			NEXT_STATE = READ_LPC_ADDR;
		end
		else
		begin
			NEXT_STATE = INIT_LOOP;
		end
	end
	
	READ_LPC_ADDR:
	begin
		NEXT_STATE = SET_D_LPC1;
		
	end
	
	SET_D_LPC1:
	begin
		NEXT_STATE = SET_D_LPC2;
	end
	
	SET_D_LPC2:
	begin
		NEXT_STATE = GET_LPC_TO_AK;
	end
	
	GET_LPC_TO_AK:
	begin
		NEXT_STATE = INCR_LPC;
	end
	
	INCR_LPC:
	begin
		NEXT_STATE = CHECK_LPC;
	end

	INIT_LOOP:
	begin
		NEXT_STATE = PRE_CALC_E;
	end

	PRE_CALC_E:
	begin
		NEXT_STATE = CALC_E;
	end

	CALC_E:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i <= 4'd10)
		begin
			NEXT_STATE = PRE_CALC_E;
		end
		else
		begin
			NEXT_STATE = INIT_AK_UPDATE;
		end
	end
	
	INIT_AK_UPDATE:
	begin
		NEXT_STATE = CHECK_AK;
	end
	
	CHECK_AK:
	begin
		if(ak <= 10'd10)
		begin
			NEXT_STATE = UPDATE_AK;
		end
		else
		begin
			NEXT_STATE = SET_LPC_TO_LSP;
		end
	end
	
	UPDATE_AK:
	begin
		NEXT_STATE = SET_AK;
	end
	
	SET_AK:
	begin
		NEXT_STATE = INCR_AK;
	end
	
	INCR_AK:
	begin
		NEXT_STATE = CHECK_AK;
	end
	

	SET_LPC_TO_LSP:
	begin
		NEXT_STATE = RUN_LTL;
	end
	
	RUN_LTL: 
	begin
		if(doneltl)
		begin
			NEXT_STATE = GET_LTL;
		end
		else
		begin
			NEXT_STATE = RUN_LTL;
		end
	end
	
	GET_LTL: 
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

		donespeech <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donespeech <= 1'b0;
		end

		INIT:
		begin
			check_corr <= 32'b0;
		end
		
		// first for loop - calc of 'e'
		INIT_FOR_1:
		begin
			i1 <= 10'd0;
		end
		
		CHECK_I1:
		begin
			
		end
		
		SET_ADDR_SN:
		begin
			addr_sn <= i1;
		end
		
		SET_DELAY1:
		begin
		
		end
		
		SET_DELAY2:
		begin
			addr_speech_w <= i1;
		end
		
		MULT_SN_W:
		begin
			ms1_in1 <= {out_sn,16'b0};
			ms1_in2 <= data_out_speech_w;
			
			addr_wn <= i1;
			we_wn <= 1'd1;
			re_wn <= 1'd0;
		end
		
		SQUARE_WN:
		begin	
			write_wn <= ms1_out;
		end
		
		SQUARE_WN_2:
		begin
			ms1_in1 <= ms1_out;
			ms1_in2 <= ms1_out;
		end

		
		SUM_SMALL_E:
		begin
			as2_in1 <= {ms1_out[N2-1],2'b0,ms1_out[N2-2:0]};
			as2_in2 <= e;
		end
		
		SET_SMALL_E:
		begin
			e <= as2_out;
			//c_e <= Wn260;
		end
		
		INCR_I1:
		begin
			i1 <= i1 + 10'd1;
		end

		INIT_FOR_AC:
		begin
			ac <= 10'd0;
		end
		
		CHECK_AC:
		begin
			
		end
		
		INIT_R:
		begin
			case(ac)
			4'd0  :         R0	<= 32'd0;
			4'd1  :         R1	<= 32'd0;
			4'd2  :         R2	<= 32'd0;
			4'd3  :         R3	<= 32'd0;
			4'd4  :         R4	<= 32'd0;
			4'd5  :         R5	<= 32'd0;
			4'd6  :         R6	<= 32'd0;
			4'd7  :         R7	<= 32'd0;
			4'd8  :         R8	<= 32'd0;
			4'd9  :         R9	<= 32'd0;
			4'd10 :        R10	<= 32'd0;
			
			endcase
		end
		
		INIT_FOR_AC1:
		begin
			ac1 <= 10'd0;
		end
		
		CHECK_AC1:
		begin
		
		end
		
		AUTO_CORR_WN:
		begin	
			addr_wn <= ac1;
			re_wn <= 1'b1;
			we_wn <= 1'b0;
		end
		
		SET_D_AC1:
		begin
		
		end
		
		SET_D_AC2:
		begin
		
		end
		
		SET_M1_AC:
		begin
			ms1_in1 <= read_wn_out;
		end
		
		SET_M2_AC_ADDR:
		begin
			addr_wn <= ac + ac1;
		end
		
		SET_D_AC3:
		begin
		
		end
		
		SET_D_AC4:
		begin
		
		end
		
		SET_M2_AC:
		begin
			ms1_in2 <= read_wn_out;	
		end
		
		SET_WN_CORR:
		begin
			wn_corr <= ms1_out;
		end
		
		ADD_RN:
		begin
			as2_in1 <= {wn_corr[N2-1],2'b0,wn_corr[N2-2:0]};
			case(ac)
				10'd0  :         as2_in2 <= R0;
				10'd1  :         as2_in2 <= R1;
				10'd2  :         as2_in2 <= R2;
				10'd3  :         as2_in2 <= R3;
				10'd4  :         as2_in2 <= R4;
				10'd5  :         as2_in2 <= R5;
				10'd6  :         as2_in2 <= R6;
				10'd7  :         as2_in2 <= R7;
				10'd8  :         as2_in2 <= R8;
				10'd9  :         as2_in2 <= R9;
				10'd10  :        as2_in2 <= R10;

			endcase
		end
		
		SET_RN:
		begin
			case(ac)
			10'd0  	:  R0  <= as2_out;
			10'd1  	:  R1  <= as2_out;
			10'd2  	:  R2  <= as2_out;
			10'd3  	:  R3  <= as2_out;
			10'd4  	:  R4  <= as2_out;
			10'd5  	:  R5  <= as2_out;
			10'd6  	:  R6  <= as2_out;
			10'd7  	:  R7  <= as2_out;
			10'd8  	:  R8  <= as2_out;
			10'd9  	:  R9  <= as2_out;
			10'd10  :  R10 <= as2_out;
			endcase
		end
		
		INCR_AC1:
		begin
			ac1 <= ac1 + 10'd1;
		end
		
		INCR_AC:
		begin
			ac <= ac + 10'd1;
		end
		

		SET_LEVINSON:
		begin
			startld <= 1'b1;
			re_ld <= 1'b0;
			we_ld <= 1'b1;
			Rn0 <= R0[N3-1:16];
			Rn1 <= R1[N3-1:16];
			Rn2 <= R2[N3-1:16];
			Rn3 <= R3[N3-1:16];
			Rn4 <= R4[N3-1:16];
			Rn5 <= R5[N3-1:16];
			Rn6 <= R6[N3-1:16];
			Rn7 <= R7[N3-1:16];
			Rn8 <= R8[N3-1:16];
			Rn9 <= R9[N3-1:16];
			Rn10 <= R10[N3-1:16];
			
			
			
			ld_R0 <= R0[N3-1:16];
			ld_R1 <= R1[N3-1:16];
			ld_R2 <= R2[N3-1:16];
			ld_R3 <= R3[N3-1:16];
			ld_R4 <= R4[N3-1:16];
			ld_R5 <= R5[N3-1:16];
			ld_R6 <= R6[N3-1:16];
			ld_R7 <= R7[N3-1:16];
			ld_R8 <= R8[N3-1:16];
			ld_R9 <= R9[N3-1:16];
			ld_R10 <= R10[N3-1:16]; 
				
		end
		
		RUN_LEVINSON:
		begin
			 addr_ld <= ld_addr_ld;
			 startld <= 1'b0;
		end

		GET_LEVINSON:
		begin
				
		end
		
		INIT_READ_LPC:
		begin
			lp <= 10'd0;
		end
		
		CHECK_LPC:
		begin
			
		end
		
		READ_LPC_ADDR:
		begin
			addr_ld <= lp;
			we_ld <= 1'b0;
			re_ld <= 1'b1;
		end
		
		SET_D_LPC1:
		begin
		
		end
		
		SET_D_LPC2:
		begin
		
		end
		
		GET_LPC_TO_AK:
		begin
			case(lp)
			10'd0  : 
			begin
				ak0 <= out_lpc;
				//c_ak0 <= out_lpc;    // from levinson
			end
			10'd1  :
			begin	
				ak1 <= out_lpc;
				//c_ak1 <= out_lpc;
			end
			10'd2  :  
			begin
				ak2 <= out_lpc;
				//c_ak2 <= out_lpc;
			end
			10'd3  : 
			begin
				ak3 <= out_lpc;
				//c_ak3 <= out_lpc;
			end
			10'd4  :
			begin
				ak4 <= out_lpc;
				//c_ak4 <= out_lpc;
			end
			10'd5  :  
			begin
				ak5 <= out_lpc;
				//c_ak5 <= out_lpc;
			end
			10'd6  :  
			begin
				ak6 <= out_lpc;
				//c_ak6 <= out_lpc;
			end
			10'd7  :  
			begin
				ak7 <= out_lpc;
				//c_ak7 <= out_lpc;
			end
			10'd8  :  
			begin
				ak8 <= out_lpc;
				//c_ak8 <= out_lpc;
			end
			10'd9  :  
			begin
				ak9 <= out_lpc;
				//c_ak9 <= out_lpc;
			end
			10'd10  :  
			begin
				ak10 <= out_lpc;
				//c_ak10 <= out_lpc;
			end
			
			endcase
			
			
		end
		
		INCR_LPC:
		begin
			lp <= lp + 10'd1;
		end
			
		INIT_LOOP:
		begin
			E <= 32'b0;
			i <= 4'd0;
		end

		PRE_CALC_E:
		begin
			case(i)
			4'd0 : 
				begin
					m2_in1 <= {ak0[N-1],2'b0,ak0[N-2:0]};
					m2_in2 <= Rn0;
				end
			4'd1 :
				begin
					m2_in1 <=  {ak1[N-1],2'b0,ak1[N-2:0]};
					m2_in2 <= Rn1;
				end
			4'd2 :
				begin
					m2_in1 <=  {ak2[N-1],2'b0,ak2[N-2:0]};
					m2_in2 <= Rn2;
				end
			4'd3 :
				begin
					m2_in1 <=  {ak3[N-1],2'b0,ak3[N-2:0]};
					m2_in2 <= Rn3;
				end
			4'd4 :
				begin
					m2_in1 <=  {ak4[N-1],2'b0,ak4[N-2:0]};
					m2_in2 <= Rn4;
				end
			4'd5 :
				begin
					m2_in1 <=  {ak5[N-1],2'b0,ak5[N-2:0]};
					m2_in2 <= Rn5;
				end
			4'd6 :
				begin
					m2_in1 <=  {ak6[N-1],2'b0,ak6[N-2:0]};
					m2_in2 <= Rn6;
				end
			4'd7 :
				begin
					m2_in1 <=  {ak7[N-1],2'b0,ak7[N-2:0]};
					m2_in2 <= Rn7;
				end
			4'd8 :
				begin
					m2_in1 <=  {ak8[N-1],2'b0,ak8[N-2:0]};
					m2_in2 <= Rn8;
				end
			4'd9 :
				begin
					m2_in1 <=  {ak9[N-1],2'b0,ak9[N-2:0]};
					m2_in2 <= Rn9;
				end
			4'd10 :
				begin
					m2_in1 <=  {ak10[N-1],2'b0,ak10[N-2:0]};
					m2_in2 <= Rn10;
				end
			
			endcase
		end

		CALC_E:
		begin
			a1_in1 <= E;
			a1_in2 <= {m2_out[N4-1],m2_out[30:0]};
		end

		INCR_I:
		begin
			i <= i + 4'd1;
			E <= a1_out;
		end

		CHECK_I:
		begin
			
		end
		
		INIT_AK_UPDATE:
		begin
			ak <= 10'd0;
		end
		
		CHECK_AK:
		begin
			
		end
		
		UPDATE_AK:
		begin
		//	ak_addr <= ak;
		//	we_ak <= 1'b1;
		//	re_ak <= 1'b0;
			case(ak)
			10'd0  :
			   begin
				   m1_in1 <= ak0;
				   m1_in2 <= powf0;
			   end
			10'd1  :
			   begin
				   m1_in1 <= ak1;
				   m1_in2 <= powf1;
			   end
			10'd2  :
			   begin
				   m1_in1 <= ak2;
				   m1_in2 <= powf2;
			   end
			10'd3  :
			   begin
				   m1_in1 <= ak3;
				   m1_in2 <= powf3;
			   end
			10'd4  :
			   begin
				   m1_in1 <= ak4;
				   m1_in2 <= powf4;
			   end
			10'd5  :
			   begin
				   m1_in1 <= ak5;
				   m1_in2 <= powf5;
			   end
			10'd6  :
			   begin
				   m1_in1 <= ak6;
				   m1_in2 <= powf6;
			   end
			10'd7  :
			   begin
				   m1_in1 <= ak7;
				   m1_in2 <= powf7;
			   end
			10'd8  :
			   begin
				   m1_in1 <= ak8;
				   m1_in2 <= powf8;
			   end
			10'd9  :
			   begin
				   m1_in1 <= ak9;
				   m1_in2 <= powf9;
			   end
			10'd10  :
			   begin
				   m1_in1 <= ak10;
				   m1_in2 <= powf10;
			   end
			
			endcase
		end
		
		
		SET_AK:
		begin
			case(ak)
			10'd0  :    
				begin
					ak0 <= m1_out;
					check_ak0_lev <= m1_out;
				end
			10'd1  :         ak1 <= m1_out;
			10'd2  :         ak2 <= m1_out;
			10'd3  :         ak3 <= m1_out;
			10'd4  :         ak4 <= m1_out;
			10'd5  :         ak5 <= m1_out;
			10'd6  :         ak6 <= m1_out;
			10'd7  :         ak7 <= m1_out;
			10'd8  :         ak8 <= m1_out;
			10'd9  :         ak9 <= m1_out;
			10'd10 :         ak10 <= m1_out;
			
			endcase
			
			 
		end
		
		INCR_AK:
		begin
			ak <= ak + 10'd1;
			//write_ak <= m1_out;
		end

		SET_LPC_TO_LSP:
		begin
			startltl <= 1'b1;
			//we_ak <= 1'b0;
			//re_ak <= 1'b1;
			
			ll_ak0 <= ak0;
			ll_ak1 <= ak1;
			ll_ak2 <= ak2;
			ll_ak3 <= ak3;
			ll_ak4 <= ak4;
			ll_ak5 <= ak5;
			ll_ak6 <= ak6;
			ll_ak7 <= ak7;
			ll_ak8 <= ak8;
			ll_ak9 <= ak9;
			ll_ak10 <= ak10;
			
		end
		
		RUN_LTL:
		begin
			//ak_addr <= ltl_ak_addr;
			//ltl_ak_out <= read_ak_out;
			startltl <= 1'b0;
		end
		
		GET_LTL:
		begin
			
			lsp0 <= freq0;
			lsp1 <= freq1;
			lsp2 <= freq2;
			lsp3 <= freq3;
			lsp4 <= freq4;
			lsp5 <= freq5;
			lsp6 <= freq6;
			lsp7 <= freq7;
			lsp8 <= freq8;
			lsp9 <= freq9;
		end
		

		DONE:
		begin
			donespeech <= 1'b1;
		end

		endcase
	end

end


endmodule