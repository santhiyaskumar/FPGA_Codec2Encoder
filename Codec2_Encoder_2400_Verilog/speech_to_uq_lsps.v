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


module speech_to_uq_lsps (	startspeech,clk,rst,//out_sn,
							E,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9,//addr_sn,
							donespeech,check_corr,
							check_ak0_lev,check_ak1_lev);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
		parameter N = 32;
		parameter Q = 16;
		
		parameter N1 = 80;
		parameter Q1 = 16;
		
		parameter N2 = 48;
		parameter Q2 = 16;
		
		input startspeech,clk,rst;
		//input [N-1:0] out_sn;
		output reg [N-1:0] E,lsp0,lsp1,lsp2,lsp3,lsp4,lsp5,lsp6,lsp7,lsp8,lsp9;
		//output reg [9:0] addr_sn;
		output reg donespeech;
		//output reg [8:0] c_sn_addr1;
		
		output reg [N-1:0] check_corr;
		output reg [N2-1:0] check_ak0_lev,check_ak1_lev;
		
		reg [9:0] addr_sn;
		wire [N-1:0] out_sn;
		RAM_c2_sn_test_nlp c2_sn (addr_sn,clk,,1,0,out_sn);
		

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
		 GET_LTL = 7'd56;
		 

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
reg [N-1:0] m1_in1,m1_in2,a1_in1,a1_in2,m2_in1,m2_in2;
wire [N-1:0] m1_out,a1_out,m2_out;
reg [N-1:0] ak0,ak1,ak2,ak3,ak4,ak5,ak6,ak7,ak8,ak9,ak10;

reg [N2-1:0] Rn0,Rn1,Rn2,Rn3,Rn4,Rn5,Rn6,Rn7,Rn8,Rn9,Rn10;

wire [9:0] sn_addr1;
reg [N-1:0] sn_read_data1;
reg startac;
wire doneac;

reg [9:0] lp,ak;

reg [N-1:0] e,wn_corr;

reg [N2-1:0] as1_in1,as1_in2;
wire [N2-1:0] as1_out;



qadd   #(Q,N)			adder1    (a1_in1,a1_in2,a1_out);

qmult  #(Q,N) 			qmult1	  (m1_in1,m1_in2,m1_out);
qmult  #(Q,N) 			qmult2	  (m2_in1,m2_in2,m2_out);


qadd   			#(Q2,N2)			adder96_1      (as1_in1,as1_in2,as1_out);


/* --------------------------------- autocorrelate module -------------------------------*/
//RAM_autocorrelate_Sn ram1_sn(sn_addr1,clk,,1,0,sn_read_data1);
//RAM_autocorrelate_Sn ram2_sn(sn_addr2,clk,,1,0,sn_read_data2);

reg [9:0] addr_wn;
reg [N-1:0] write_wn;
reg we_wn, re_wn;
wire [N-1:0] read_wn_out;

RAM_ac_Wn RAM_ac_Wn_module (addr_wn, clk, write_wn, re_wn, we_wn, read_wn_out);
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
reg [N2-1:0] R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10;
wire doneld;
wire [N-1:0] check_ak0,check_ak1;


levinson_durbin_multchange lev_dur_module(startld,clk,rst,R0,R1,R2,R3,R4,R5,
								R6,R7,R8,R9,R10,in_lpc,ld_addr_ld,doneld,
								check_ak0,check_ak1);
								
								

/* --------------------------------- dummy RAM for speech module -------------------------------*/

/* reg [9:0] addr_sn;
wire [N-1:0] out_sn;
							
RAM_speech ram_sn_module(addr_sn,clk,,1,0,out_sn); */

/* ----------------------RAM_ak-------------------------------------------------------*/
reg [3:0] ak_addr;
reg [N-1:0] write_ak;
reg re_ak,we_ak;
wire [N-1:0] read_ak_out;

RAM_ak         module_RAM_ak			   (ak_addr,clk,write_ak,re_ak,we_ak,read_ak_out);

/* -------------------------lpc_to_lsp-------------------------------------------------- */

reg startltl;
wire [N-1:0] freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9;
wire [3:0] ltl_ak_addr;
reg [N-1:0] ltl_ak_out;
wire doneltl;


lpc_to_lsp ltl_module(startltl,clk,rst,ltl_ak_out,freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9,
						 ltl_ak_addr,doneltl);
 
/* -------------------------------------ROM_w--------------------------------------------*/
reg [9:0] addr_speech_w;
wire [N-1:0] data_out_speech_w;

ROM_speech_w    speech_w (addr_speech_w, data_out_speech_w);


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
		if(i1 < 10'd321)    //fix this
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
		NEXT_STATE = SUM_SMALL_E;
	end
	
	SUM_SMALL_E:
	begin
		NEXT_STATE = SET_SMALL_E;
	end
	
	SET_SMALL_E:
	begin
		NEXT_STATE = INCR_I1;
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
		if(i <= 10)
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
		NEXT_STATE = DONE;//START;
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
			m1_in1 <= out_sn;
			m1_in2 <= data_out_speech_w;
			
			addr_wn <= i1;
			we_wn <= 1'd1;
			re_wn <= 1'd0;
		end
		
		SQUARE_WN:
		begin
			m2_in1 <= m1_out;
			m2_in2 <= m1_out;
			
			/* case(i1)
				10'd0  :         Wn0 <= m1_out;
				10'd1  :         Wn1 <= m1_out;
				10'd2  :         Wn2 <= m1_out;
				10'd3  :         Wn3 <= m1_out;
				10'd4  :         Wn4 <= m1_out;
				10'd5  :         Wn5 <= m1_out;
				10'd6  :         Wn6 <= m1_out;
				10'd7  :         Wn7 <= m1_out;
				10'd8  :         Wn8 <= m1_out;
				10'd9  :         Wn9 <= m1_out;
				10'd10  :         Wn10 <= m1_out;
				10'd11  :         Wn11 <= m1_out;
				10'd12  :         Wn12 <= m1_out;
				10'd13  :         Wn13 <= m1_out;
				10'd14  :         Wn14 <= m1_out;
				10'd15  :         Wn15 <= m1_out;
				10'd16  :         Wn16 <= m1_out;
				10'd17  :         Wn17 <= m1_out;
				10'd18  :         Wn18 <= m1_out;
				10'd19  :         Wn19 <= m1_out;
				10'd20  :         Wn20 <= m1_out;
				10'd21  :         Wn21 <= m1_out;
				10'd22  :         Wn22 <= m1_out;
				10'd23  :         Wn23 <= m1_out;
				10'd24  :         Wn24 <= m1_out;
				10'd25  :         Wn25 <= m1_out;
				10'd26  :         Wn26 <= m1_out;
				10'd27  :         Wn27 <= m1_out;
				10'd28  :         Wn28 <= m1_out;
				10'd29  :         Wn29 <= m1_out;
				10'd30  :         Wn30 <= m1_out;
				10'd31  :         Wn31 <= m1_out;
				10'd32  :         Wn32 <= m1_out;
				10'd33  :         Wn33 <= m1_out;
				10'd34  :         Wn34 <= m1_out;
				10'd35  :         Wn35 <= m1_out;
				10'd36  :         Wn36 <= m1_out;
				10'd37  :         Wn37 <= m1_out;
				10'd38  :         Wn38 <= m1_out;
				10'd39  :         Wn39 <= m1_out;
				10'd40  :         Wn40 <= m1_out;
				10'd41  :         Wn41 <= m1_out;
				10'd42  :         Wn42 <= m1_out;
				10'd43  :         Wn43 <= m1_out;
				10'd44  :         Wn44 <= m1_out;
				10'd45  :         Wn45 <= m1_out;
				10'd46  :         Wn46 <= m1_out;
				10'd47  :         Wn47 <= m1_out;
				10'd48  :         Wn48 <= m1_out;
				10'd49  :         Wn49 <= m1_out;
				10'd50  :         Wn50 <= m1_out;
				10'd51  :         Wn51 <= m1_out;
				10'd52  :         Wn52 <= m1_out;
				10'd53  :         Wn53 <= m1_out;
				10'd54  :         Wn54 <= m1_out;
				10'd55  :         Wn55 <= m1_out;
				10'd56  :         Wn56 <= m1_out;
				10'd57  :         Wn57 <= m1_out;
				10'd58  :         Wn58 <= m1_out;
				10'd59  :         Wn59 <= m1_out;
				10'd60  :         Wn60 <= m1_out;
				10'd61  :         Wn61 <= m1_out;
				10'd62  :         Wn62 <= m1_out;
				10'd63  :         Wn63 <= m1_out;
				10'd64  :         Wn64 <= m1_out;
				10'd65  :         Wn65 <= m1_out;
				10'd66  :         Wn66 <= m1_out;
				10'd67  :         Wn67 <= m1_out;
				10'd68  :         Wn68 <= m1_out;
				10'd69  :         Wn69 <= m1_out;
				10'd70  :         Wn70 <= m1_out;
				10'd71  :         Wn71 <= m1_out;
				10'd72  :         Wn72 <= m1_out;
				10'd73  :         Wn73 <= m1_out;
				10'd74  :         Wn74 <= m1_out;
				10'd75  :         Wn75 <= m1_out;
				10'd76  :         Wn76 <= m1_out;
				10'd77  :         Wn77 <= m1_out;
				10'd78  :         Wn78 <= m1_out;
				10'd79  :         Wn79 <= m1_out;
				10'd80  :         Wn80 <= m1_out;
				10'd81  :         Wn81 <= m1_out;
				10'd82  :         Wn82 <= m1_out;
				10'd83  :         Wn83 <= m1_out;
				10'd84  :         Wn84 <= m1_out;
				10'd85  :         Wn85 <= m1_out;
				10'd86  :         Wn86 <= m1_out;
				10'd87  :         Wn87 <= m1_out;
				10'd88  :         Wn88 <= m1_out;
				10'd89  :         Wn89 <= m1_out;
				10'd90  :         Wn90 <= m1_out;
				10'd91  :         Wn91 <= m1_out;
				10'd92  :         Wn92 <= m1_out;
				10'd93  :         Wn93 <= m1_out;
				10'd94  :         Wn94 <= m1_out;
				10'd95  :         Wn95 <= m1_out;
				10'd96  :         Wn96 <= m1_out;
				10'd97  :         Wn97 <= m1_out;
				10'd98  :         Wn98 <= m1_out;
				10'd99  :         Wn99 <= m1_out;
				10'd100  :         Wn100 <= m1_out;
				10'd101  :         Wn101 <= m1_out;
				10'd102  :         Wn102 <= m1_out;
				10'd103  :         Wn103 <= m1_out;
				10'd104  :         Wn104 <= m1_out;
				10'd105  :         Wn105 <= m1_out;
				10'd106  :         Wn106 <= m1_out;
				10'd107  :         Wn107 <= m1_out;
				10'd108  :         Wn108 <= m1_out;
				10'd109  :         Wn109 <= m1_out;
				10'd110  :         Wn110 <= m1_out;
				10'd111  :         Wn111 <= m1_out;
				10'd112  :         Wn112 <= m1_out;
				10'd113  :         Wn113 <= m1_out;
				10'd114  :         Wn114 <= m1_out;
				10'd115  :         Wn115 <= m1_out;
				10'd116  :         Wn116 <= m1_out;
				10'd117  :         Wn117 <= m1_out;
				10'd118  :         Wn118 <= m1_out;
				10'd119  :         Wn119 <= m1_out;
				10'd120  :         Wn120 <= m1_out;
				10'd121  :         Wn121 <= m1_out;
				10'd122  :         Wn122 <= m1_out;
				10'd123  :         Wn123 <= m1_out;
				10'd124  :         Wn124 <= m1_out;
				10'd125  :         Wn125 <= m1_out;
				10'd126  :         Wn126 <= m1_out;
				10'd127  :         Wn127 <= m1_out;
				10'd128  :         Wn128 <= m1_out;
				10'd129  :         Wn129 <= m1_out;
				10'd130  :         Wn130 <= m1_out;
				10'd131  :         Wn131 <= m1_out;
				10'd132  :         Wn132 <= m1_out;
				10'd133  :         Wn133 <= m1_out;
				10'd134  :         Wn134 <= m1_out;
				10'd135  :         Wn135 <= m1_out;
				10'd136  :         Wn136 <= m1_out;
				10'd137  :         Wn137 <= m1_out;
				10'd138  :         Wn138 <= m1_out;
				10'd139  :         Wn139 <= m1_out;
				10'd140  :         Wn140 <= m1_out;
				10'd141  :         Wn141 <= m1_out;
				10'd142  :         Wn142 <= m1_out;
				10'd143  :         Wn143 <= m1_out;
				10'd144  :         Wn144 <= m1_out;
				10'd145  :         Wn145 <= m1_out;
				10'd146  :         Wn146 <= m1_out;
				10'd147  :         Wn147 <= m1_out;
				10'd148  :         Wn148 <= m1_out;
				10'd149  :         Wn149 <= m1_out;
				10'd150  :         Wn150 <= m1_out;
				10'd151  :         Wn151 <= m1_out;
				10'd152  :         Wn152 <= m1_out;
				10'd153  :         Wn153 <= m1_out;
				10'd154  :         Wn154 <= m1_out;
				10'd155  :         Wn155 <= m1_out;
				10'd156  :         Wn156 <= m1_out;
				10'd157  :         Wn157 <= m1_out;
				10'd158  :         Wn158 <= m1_out;
				10'd159  :         Wn159 <= m1_out;
				10'd160  :         Wn160 <= m1_out;
				10'd161  :         Wn161 <= m1_out;
				10'd162  :         Wn162 <= m1_out;
				10'd163  :         Wn163 <= m1_out;
				10'd164  :         Wn164 <= m1_out;
				10'd165  :         Wn165 <= m1_out;
				10'd166  :         Wn166 <= m1_out;
				10'd167  :         Wn167 <= m1_out;
				10'd168  :         Wn168 <= m1_out;
				10'd169  :         Wn169 <= m1_out;
				10'd170  :         Wn170 <= m1_out;
				10'd171  :         Wn171 <= m1_out;
				10'd172  :         Wn172 <= m1_out;
				10'd173  :         Wn173 <= m1_out;
				10'd174  :         Wn174 <= m1_out;
				10'd175  :         Wn175 <= m1_out;
				10'd176  :         Wn176 <= m1_out;
				10'd177  :         Wn177 <= m1_out;
				10'd178  :         Wn178 <= m1_out;
				10'd179  :         Wn179 <= m1_out;
				10'd180  :         Wn180 <= m1_out;
				10'd181  :         Wn181 <= m1_out;
				10'd182  :         Wn182 <= m1_out;
				10'd183  :         Wn183 <= m1_out;
				10'd184  :         Wn184 <= m1_out;
				10'd185  :         Wn185 <= m1_out;
				10'd186  :         Wn186 <= m1_out;
				10'd187  :         Wn187 <= m1_out;
				10'd188  :         Wn188 <= m1_out;
				10'd189  :         Wn189 <= m1_out;
				10'd190  :         Wn190 <= m1_out;
				10'd191  :         Wn191 <= m1_out;
				10'd192  :         Wn192 <= m1_out;
				10'd193  :         Wn193 <= m1_out;
				10'd194  :         Wn194 <= m1_out;
				10'd195  :         Wn195 <= m1_out;
				10'd196  :         Wn196 <= m1_out;
				10'd197  :         Wn197 <= m1_out;
				10'd198  :         Wn198 <= m1_out;
				10'd199  :         Wn199 <= m1_out;
				10'd200  :         Wn200 <= m1_out;
				10'd201  :         Wn201 <= m1_out;
				10'd202  :         Wn202 <= m1_out;
				10'd203  :         Wn203 <= m1_out;
				10'd204  :         Wn204 <= m1_out;
				10'd205  :         Wn205 <= m1_out;
				10'd206  :         Wn206 <= m1_out;
				10'd207  :         Wn207 <= m1_out;
				10'd208  :         Wn208 <= m1_out;
				10'd209  :         Wn209 <= m1_out;
				10'd210  :         Wn210 <= m1_out;
				10'd211  :         Wn211 <= m1_out;
				10'd212  :         Wn212 <= m1_out;
				10'd213  :         Wn213 <= m1_out;
				10'd214  :         Wn214 <= m1_out;
				10'd215  :         Wn215 <= m1_out;
				10'd216  :         Wn216 <= m1_out;
				10'd217  :         Wn217 <= m1_out;
				10'd218  :         Wn218 <= m1_out;
				10'd219  :         Wn219 <= m1_out;
				10'd220  :         Wn220 <= m1_out;
				10'd221  :         Wn221 <= m1_out;
				10'd222  :         Wn222 <= m1_out;
				10'd223  :         Wn223 <= m1_out;
				10'd224  :         Wn224 <= m1_out;
				10'd225  :         Wn225 <= m1_out;
				10'd226  :         Wn226 <= m1_out;
				10'd227  :         Wn227 <= m1_out;
				10'd228  :         Wn228 <= m1_out;
				10'd229  :         Wn229 <= m1_out;
				10'd230  :         Wn230 <= m1_out;
				10'd231  :         Wn231 <= m1_out;
				10'd232  :         Wn232 <= m1_out;
				10'd233  :         Wn233 <= m1_out;
				10'd234  :         Wn234 <= m1_out;
				10'd235  :         Wn235 <= m1_out;
				10'd236  :         Wn236 <= m1_out;
				10'd237  :         Wn237 <= m1_out;
				10'd238  :         Wn238 <= m1_out;
				10'd239  :         Wn239 <= m1_out;
				10'd240  :         Wn240 <= m1_out;
				10'd241  :         Wn241 <= m1_out;
				10'd242  :         Wn242 <= m1_out;
				10'd243  :         Wn243 <= m1_out;
				10'd244  :         Wn244 <= m1_out;
				10'd245  :         Wn245 <= m1_out;
				10'd246  :         Wn246 <= m1_out;
				10'd247  :         Wn247 <= m1_out;
				10'd248  :         Wn248 <= m1_out;
				10'd249  :         Wn249 <= m1_out;
				10'd250  :         Wn250 <= m1_out;
				10'd251  :         Wn251 <= m1_out;
				10'd252  :         Wn252 <= m1_out;
				10'd253  :         Wn253 <= m1_out;
				10'd254  :         Wn254 <= m1_out;
				10'd255  :         Wn255 <= m1_out;
				10'd256  :         Wn256 <= m1_out;
				10'd257  :         Wn257 <= m1_out;
				10'd258  :         Wn258 <= m1_out;
				10'd259  :         Wn259 <= m1_out;
				10'd260  :         Wn260 <= m1_out;
				10'd261  :         Wn261 <= m1_out;
				10'd262  :         Wn262 <= m1_out;
				10'd263  :         Wn263 <= m1_out;
				10'd264  :         Wn264 <= m1_out;
				10'd265  :         Wn265 <= m1_out;
				10'd266  :         Wn266 <= m1_out;
				10'd267  :         Wn267 <= m1_out;
				10'd268  :         Wn268 <= m1_out;
				10'd269  :         Wn269 <= m1_out;
				10'd270  :         Wn270 <= m1_out;
				10'd271  :         Wn271 <= m1_out;
				10'd272  :         Wn272 <= m1_out;
				10'd273  :         Wn273 <= m1_out;
				10'd274  :         Wn274 <= m1_out;
				10'd275  :         Wn275 <= m1_out;
				10'd276  :         Wn276 <= m1_out;
				10'd277  :         Wn277 <= m1_out;
				10'd278  :         Wn278 <= m1_out;
				10'd279  :         Wn279 <= m1_out;
				10'd280  :         Wn280 <= m1_out;
				10'd281  :         Wn281 <= m1_out;
				10'd282  :         Wn282 <= m1_out;
				10'd283  :         Wn283 <= m1_out;
				10'd284  :         Wn284 <= m1_out;
				10'd285  :         Wn285 <= m1_out;
				10'd286  :         Wn286 <= m1_out;
				10'd287  :         Wn287 <= m1_out;
				10'd288  :         Wn288 <= m1_out;
				10'd289  :         Wn289 <= m1_out;
				10'd290  :         Wn290 <= m1_out;
				10'd291  :         Wn291 <= m1_out;
				10'd292  :         Wn292 <= m1_out;
				10'd293  :         Wn293 <= m1_out;
				10'd294  :         Wn294 <= m1_out;
				10'd295  :         Wn295 <= m1_out;
				10'd296  :         Wn296 <= m1_out;
				10'd297  :         Wn297 <= m1_out;
				10'd298  :         Wn298 <= m1_out;
				10'd299  :         Wn299 <= m1_out;
				10'd300  :         Wn300 <= m1_out;
				10'd301  :         Wn301 <= m1_out;
				10'd302  :         Wn302 <= m1_out;
				10'd303  :         Wn303 <= m1_out;
				10'd304  :         Wn304 <= m1_out;
				10'd305  :         Wn305 <= m1_out;
				10'd306  :         Wn306 <= m1_out;
				10'd307  :         Wn307 <= m1_out;
				10'd308  :         Wn308 <= m1_out;
				10'd309  :         Wn309 <= m1_out;
				10'd310  :         Wn310 <= m1_out;
				10'd311  :         Wn311 <= m1_out;
				10'd312  :         Wn312 <= m1_out;
				10'd313  :         Wn313 <= m1_out;
				10'd314  :         Wn314 <= m1_out;
				10'd315  :         Wn315 <= m1_out;
				10'd316  :         Wn316 <= m1_out;
				10'd317  :         Wn317 <= m1_out;
				10'd318  :         Wn318 <= m1_out;
				10'd319  :         Wn319 <= m1_out;
			endcase */
			write_wn <= m1_out;
		end
		
		SUM_SMALL_E:
		begin
			a1_in1 <= m2_out;
			a1_in2 <= e;
		end
		
		SET_SMALL_E:
		begin
			e <= a1_out;
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
			4'd0  :         R0	<= 80'd0;
			4'd1  :         R1	<= 80'd0;
			4'd2  :         R2	<= 80'd0;
			4'd3  :         R3	<= 80'd0;
			4'd4  :         R4	<= 80'd0;
			4'd5  :         R5	<= 80'd0;
			4'd6  :         R6	<= 80'd0;
			4'd7  :         R7	<= 80'd0;
			4'd8  :         R8	<= 80'd0;
			4'd9  :         R9	<= 80'd0;
			4'd10 :        R10	<= 80'd0;
			
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
			m1_in1 <= read_wn_out;
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
			m1_in2 <= read_wn_out;
			
		end
		
		
		SET_WN_CORR:
		begin
			wn_corr <= m1_out;
			if(ac == 10'd0 && ac1 == 10'd22)
			begin
				check_corr <= m1_out;
			end
			
		end
		
		ADD_RN:
		begin
			as1_in1 <= {wn_corr[N-1],16'b0,wn_corr[N-2:0]};
			case(ac)
				10'd0  :         as1_in2 <= R0;
				10'd1  :         as1_in2 <= R1;
				10'd2  :         as1_in2 <= R2;
				10'd3  :         as1_in2 <= R3;
				10'd4  :         as1_in2 <= R4;
				10'd5  :         as1_in2 <= R5;
				10'd6  :         as1_in2 <= R6;
				10'd7  :         as1_in2 <= R7;
				10'd8  :         as1_in2 <= R8;
				10'd9  :         as1_in2 <= R9;
				10'd10  :        as1_in2 <= R10;

			endcase
		end
		
		SET_RN:
		begin
			case(ac)
			10'd0  	:  R0  <= as1_out;
			10'd1  	:  R1  <= as1_out;
			10'd2  	:  R2  <= as1_out;
			10'd3  	:  R3  <= as1_out;
			10'd4  	:  R4  <= as1_out;
			10'd5  	:  R5  <= as1_out;
			10'd6  	:  R6  <= as1_out;
			10'd7  	:  R7  <= as1_out;
			10'd8  	:  R8  <= as1_out;
			10'd9  	:  R9  <= as1_out;
			10'd10  :  R10 <= as1_out;
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
			Rn0 <= R0;
			Rn1 <= R1;
			Rn2 <= R2;
			Rn3 <= R3;
			Rn4 <= R4;
			Rn5 <= R5;
			Rn6 <= R6;
			Rn7 <= R7;
			Rn8 <= R8;
			Rn9 <= R9;
			Rn10 <= R10;
			
			
			
		end
		
		RUN_LEVINSON:
		begin
			 addr_ld <= ld_addr_ld;
			
		end

		GET_LEVINSON:
		begin
			startld <= 1'b0;
			//check_ak0_lev <= check_ak0;
			//check_ak1_lev <= check_ak1;
			//c_l <= in_lpc;
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
				
			end
			10'd1  :
			begin	
				ak1 <= out_lpc;
				check_corr <= out_lpc;
			end
			10'd2  :  
			begin
				ak2 <= out_lpc;
				check_ak0_lev <= out_lpc;
			end
			10'd3  : 
			begin
				ak3 <= out_lpc;
				check_ak1_lev <= out_lpc;
			end
			10'd4  :  ak4 <= out_lpc;
			10'd5  :  ak5 <= out_lpc;
			10'd6  :  ak6 <= out_lpc;
			10'd7  :  ak7 <= out_lpc;
			10'd8  :  ak8 <= out_lpc;
			10'd9  :  ak9 <= out_lpc;
			10'd10  :  ak10 <= out_lpc;
			
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
					m1_in1 <= ak0;
					m1_in2 <= Rn0;
				end
			4'd1 :
				begin
					m1_in1 <= ak1;
					m1_in2 <= Rn1;
				end
			4'd2 :
				begin
					m1_in1 <= ak2;
					m1_in2 <= Rn2;
				end
			4'd3 :
				begin
					m1_in1 <= ak3;
					m1_in2 <= Rn3;
				end
			4'd4 :
				begin
					m1_in1 <= ak4;
					m1_in2 <= Rn4;
				end
			4'd5 :
				begin
					m1_in1 <= ak5;
					m1_in2 <= Rn5;
				end
			4'd6 :
				begin
					m1_in1 <= ak6;
					m1_in2 <= Rn6;
				end
			4'd7 :
				begin
					m1_in1 <= ak7;
					m1_in2 <= Rn7;
				end
			4'd8 :
				begin
					m1_in1 <= ak8;
					m1_in2 <= Rn8;
				end
			4'd9 :
				begin
					m1_in1 <= ak9;
					m1_in2 <= Rn9;
				end
			4'd10 :
				begin
					m1_in1 <= ak10;
					m1_in2 <= Rn10;
				end
			
			endcase
		end

		CALC_E:
		begin
			a1_in1 <= E;
			a1_in2 <= m1_out;
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
			ak_addr <= ak;
			we_ak <= 1'b1;
			re_ak <= 1'b0;
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
			write_ak <= m1_out;
		end

		SET_LPC_TO_LSP:
		begin
			startltl <= 1'b1;
			we_ak <= 1'b0;
			re_ak <= 1'b1;
			
		end
		
		RUN_LTL:
		begin
			ak_addr <= ltl_ak_addr;
			ltl_ak_out <= read_ak_out;
		end
		
		GET_LTL:
		begin
			startltl <= 1'b0;
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