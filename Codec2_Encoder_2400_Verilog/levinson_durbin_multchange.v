/*
* Module         - levinson_durbin
* Top module     - speech_to_uq_lsps
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Thu Mar 7 19:30:08 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform33.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

//
module levinson_durbin_multchange (startld,clk,rst,R0,R1,R2,R3,R4,R5,
								R6,R7,R8,R9,R10,in_lpc,addr_ld,
								doneld,
								check_ak0,check_ak1);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	parameter N1 = 80;
    parameter Q1 = 16;
	
	parameter N2 = 48;
    parameter Q2 = 16;

	input clk,rst,startld;
	input [N2-1:0] R0,R1,R2,R3,R4,R5,
								R6,R7,R8,R9,R10;
	//output reg [N-1:0]  check_e;
	output reg doneld;
	output reg [N-1:0] in_lpc;
	output reg [N2-1:0] check_ak0,check_ak1;
	output reg [3:0] addr_ld;
	// reg [N-1:0] lpc1,lpc2,lpc8,lpc9,lpc10;
	//reg [N-1:0] lpc0,lpc4,lpc5,lpc3,lpc6,lpc7;

	

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START 							= 8'd0,
          INIT 							= 8'd1,
          INIT_LOOP 						= 8'd2,
          CHECK_I 						= 8'd3,
          START_J1 						= 8'd4,
          CHECK_J1 						= 8'd5,
          SET_A_R 						= 8'd6,
          CALC_SUM 						= 8'd8,
          INCR_J1 						= 8'd9,
          PRE_CALC_K 					= 8'd10,
          CALC_K 							= 8'd11,
          SET_K 							= 8'd12,
          PRE_CALC_E 					= 8'd13,
          CALC1_E 						= 8'd14,
          CALC2_E 						= 8'd15,
          SET_E 							= 8'd16,
          INCR_I 							= 8'd17,
			 CHECK_GT 						= 8'd18,
			 CHECK_K 						= 8'd19,
			 SET_A 							= 8'd20,
			// CHECK_J2						= 8'd21,
			 CALC1_A 						= 8'd22,
			 CALC2_A 						= 8'd23,
			 FINAL_CALC_A 					= 8'd24,
			 INCR_J2 						= 8'd25,
			 SET_SUM 						= 8'd26,
          DONE 							= 8'd27,
			 START_DIV 						= 8'd28,
			 CALC_LPC 						= 8'd29,
			 PRE_CALC_A_I_2 				= 8'd30,
			 CALC_A_I_2 					= 8'd31,
			 FINAL_CALC_A_I_2 			= 8'd32,
			 PRE_CALC_A_I_3 				= 8'd33,
			 CALC_A_I_3 					= 8'd34,
			 FINAL_CALC_A_I_3 			= 8'd35,
			 PRE_CALC_A_I_4 				= 8'd36,
			 CALC_A_I_4 					= 8'd37,
			 FINAL_CALC_A_I_4 			= 8'd38,
			 PRE_CALC_A_I_5 				= 8'd39,
			 CALC_A_I_5 					= 8'd40,
			 FINAL_CALC_A_I_5 			= 8'd41,
			 PRE_CALC_A_I_6 				= 8'd42,
			 CALC_A_I_6 					= 8'd43,
			 FINAL_CALC_A_I_6 			= 8'd44,
			 PRE_CALC_A_I_7 				= 8'd45,
			 CALC_A_I_7						= 8'd46,
			 FINAL_CALC_A_I_7 			= 8'd47,
			 PRE_CALC_A_I_8 				= 8'd48,
			 CALC_A_I_8 					= 8'd49,
			 FINAL_CALC_A_I_8 			= 8'd50,
			 PRE_CALC_A_I_9 				= 8'd51,
			 CALC_A_I_9 					= 8'd52,
			 FINAL_CALC_A_I_9 			= 8'd53,
			 PRE_CALC_A_I_10 				= 8'd54,
			 CALC_A_I_10 					= 8'd55,
			 FINAL_CALC_A_I_10 			= 8'd7,
			 CHECK_WHICH_I_FOR_A			= 8'd56,
			 INIT_FOR_LPC 					= 8'd57,
			 CHECK_J 						= 8'd58,
			 SET_ADDR_LPC 					= 8'd59,
			 SET_LPC 						= 8'd60,
			 INCR_J							= 8'd61,
			 SET_DELAY1 = 8'd62,
			 SET_DELAY2 = 8'd63,
			 PRE_CALC_A_I_5_2 = 8'd64,
			 PRE_CALC_A_I_6_2 = 8'd65,
			 PRE_CALC_A_I_7_2 = 8'd66,
			 PRE_CALC_A_I_8_2 = 8'd67,
			 PRE_CALC_A_I_8_3 = 8'd68,
			 PRE_CALC_A_I_9_2 = 8'd69,
			 PRE_CALC_A_I_9_3 = 8'd70,
			 PRE_CALC_A_I_10_2 = 8'd71,
			 PRE_CALC_A_I_10_3 = 8'd72,
			 CALC_A_I_5_2 = 8'd73,
			 CALC_A_I_6_2 = 8'd74,
			 CALC_A_I_7_2 = 8'd75,
			 CALC_A_I_8_2 = 8'd76,
			 CALC_A_I_8_3 = 8'd77,
			 CALC_A_I_9_2 = 8'd78,
			 CALC_A_I_9_3 = 8'd79,
			 CALC_A_I_10_2 = 8'd80,
			 CALC_A_I_10_3 = 8'd81,
			 FINAL_CALC_A_I_5_2 = 8'd82,
			 FINAL_CALC_A_I_6_2 = 8'd83,
			 FINAL_CALC_A_I_7_2 = 8'd84,
			 FINAL_CALC_A_I_8_2 = 8'd85,
			 FINAL_CALC_A_I_8_3 = 8'd86,
			 FINAL_CALC_A_I_9_2 = 8'd87,
			 FINAL_CALC_A_I_9_3 = 8'd88,
			 FINAL_CALC_A_I_10_2 = 8'd89,
			 FINAL_CALC_A_I_10_3 = 8'd90; 
			 
			 

reg [7:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N2-1:0] NUMBER_ONE = {31'b0,1'b1,16'b0};

parameter [6:0] ORDER = 7'd10;

reg [N2-1:0] 	a0 = 48'b0,
					a1 = 48'b0,
					a2 = 48'b0,
					a3 = 48'b0,
					a4 = 48'b0,
					a5 = 48'b0,
					a6 = 48'b0,
					a7 = 48'b0,
					a8 = 48'b0,
					a9 = 48'b0,
					a10 = 48'b0,
					a11 = 48'b0,
					a12 = 48'b0,
					a13 = 48'b0,
					a14 = 48'b0,
					a15 = 48'b0,
					a16 = 48'b0,
					a17 = 48'b0,
					a18 = 48'b0,
					a19 = 48'b0,
					a20 = 48'b0,
					a21 = 48'b0,
					a22 = 48'b0,
					a23 = 48'b0,
					a24 = 48'b0,
					a25 = 48'b0,
					a26 = 48'b0,
					a27 = 48'b0,
					a28 = 48'b0,
					a29 = 48'b0,
					a30 = 48'b0,
					a31 = 48'b0,
					a32 = 48'b0,
					a33 = 48'b0,
					a34 = 48'b0,
					a35 = 48'b0,
					a36 = 48'b0,
					a37 = 48'b0,
					a38 = 48'b0,
					a39 = 48'b0,
					a40 = 48'b0,
					a41 = 48'b0,
					a42 = 48'b0,
					a43 = 48'b0,
					a44 = 48'b0,
					a45 = 48'b0,
					a46 = 48'b0,
					a47 = 48'b0,
					a48 = 48'b0,
					a49 = 48'b0,
					a50 = 48'b0,
					a51 = 48'b0,
					a52 = 48'b0,
					a53 = 48'b0,
					a54 = 48'b0,
					a55 = 48'b0,
					a56 = 48'b0,
					a57 = 48'b0,
					a58 = 48'b0,
					a59 = 48'b0,
					a60 = 48'b0,
					a61 = 48'b0,
					a62 = 48'b0,
					a63 = 48'b0,
					a64 = 48'b0,
					a65 = 48'b0,
					a66 = 48'b0,
					a67 = 48'b0,
					a68 = 48'b0,
					a69 = 48'b0,
					a70 = 48'b0,
					a71 = 48'b0,
					a72 = 48'b0,
					a73 = 48'b0,
					a74 = 48'b0,
					a75 = 48'b0,
					a76 = 48'b0,
					a77 = 48'b0,
					a78 = 48'b0,
					a79 = 48'b0,
					a80 = 48'b0,
					a81 = 48'b0,
					a82 = 48'b0,
					a83 = 48'b0,
					a84 = 48'b0,
					a85 = 48'b0,
					a86 = 48'b0,
					a87 = 48'b0,
					a88 = 48'b0,
					a89 = 48'b0,
					a90 = 48'b0,
					a91 = 48'b0,
					a92 = 48'b0,
					a93 = 48'b0,
					a94 = 48'b0,
					a95 = 48'b0,
					a96 = 48'b0,
					a97 = 48'b0,
					a98 = 48'b0,
					a99 = 48'b0,
					a100 = 48'b0,
					a101 = 48'b0,
					a102 = 48'b0,
					a103 = 48'b0,
					a104 = 48'b0,
					a105 = 48'b0,
					a106 = 48'b0,
					a107 = 48'b0,
					a108 = 48'b0,
					a109 = 48'b0,
					a110 = 48'b0,
					a111 = 48'b0,
					a112 = 48'b0,
					a113 = 48'b0,
					a114 = 48'b0,
					a115 = 48'b0,
					a116 = 48'b0,
					a117 = 48'b0,
					a118 = 48'b0,
					a119 = 48'b0,
					a120 = 48'b0;
									

reg [6:0] 			i;
reg [6:0]   		j1,j2;
reg [N2-1:0] 		k,e;
reg [N2-1:0]			sum;
reg [N2-1:0] 		m1_in1, m1_in2,
						m2_in1, m2_in2,
						m3_in1, m3_in2,
						m4_in1, m4_in2,
						m5_in1, m5_in2,
						m6_in1, m6_in2,
						m7_in1, m7_in2,
						m8_in1, m8_in2,
						m9_in1, m9_in2,
						
						a1_in1, a1_in2,
						a2_in1, a2_in2,
						a3_in1, a3_in2,
						a4_in1, a4_in2,
						a5_in1, a5_in2,
						a6_in1, a6_in2,
						a7_in1, a7_in2,
						a8_in1, a8_in2,
						a9_in1, a9_in2,
						
						gt1_in1, gt1_in2;
						
wire [N2-1:0]		m1_out, a1_out, 
						m2_out, a2_out, 
						m3_out, a3_out, 
						m4_out, a4_out, 
						m5_out, a5_out, 
						m6_out, a6_out, 
						m7_out, a7_out, 
						m8_out, a8_out, 
						m9_out, a9_out, 
						div_ans;
						
wire 					gt1;

wire donediv;
reg [3:0] j;
reg startdiv;
reg [N2-1:0] div_in;

//RAM_autocorrelate_Rn     ram1_rn		(addr_rn,clk,,1,0,out_rn);
//RAM_autocorrelate_Rn     ram1_rn2		(addr_rn2,clk,,1,0,out_rn2);
//fpdiv1  #(Q,N)				 divider1   (d1_in1,d1_in2,d1_out);

qmult			 	 #(Q2,N2) 			    qmult1	   (m1_in1,m1_in2,m1_out);
qmult			 	 #(Q2,N2) 			    qmult2	   (m2_in1,m2_in2,m2_out);
qmult			 	 #(Q2,N2) 			    qmult3	   (m3_in1,m3_in2,m3_out);
/* qmult			 	 #(Q2,N2) 			    qmult4	   (m4_in1,m4_in2,m4_out);
qmult			 	 #(Q2,N2) 			    qmult5	   (m5_in1,m5_in2,m5_out);
qmult			 	 #(Q2,N2) 			    qmult6	   (m6_in1,m6_in2,m6_out);
qmult			 	 #(Q2,N2) 			    qmult7	   (m7_in1,m7_in2,m7_out);
qmult			 	 #(Q2,N2) 			    qmult8	   (m8_in1,m8_in2,m8_out);
qmult			 	 #(Q2,N2) 			    qmult9	   (m9_in1,m9_in2,m9_out); */

qadd  			 #(Q2,N2)				 adder1    	(a1_in1,a1_in2,a1_out);
qadd  			 #(Q2,N2)				 adder2    	(a2_in1,a2_in2,a2_out);
qadd  			 #(Q2,N2)				 adder3    	(a3_in1,a3_in2,a3_out);
/* qadd  			 #(Q2,N2)				 adder4    	(a4_in1,a4_in2,a4_out);
qadd  			 #(Q2,N2)				 adder5    	(a5_in1,a5_in2,a5_out);
qadd  			 #(Q2,N2)				 adder6    	(a6_in1,a6_in2,a6_out);
qadd  			 #(Q2,N2)				 adder7    	(a7_in1,a7_in2,a7_out);
qadd  			 #(Q2,N2)				 adder8    	(a8_in1,a8_in2,a8_out);
qadd  			 #(Q2,N2)				 adder9    	(a9_in1,a9_in2,a9_out); */

fpgreaterthan	 			  #(Q2,N2)    			 fpgt1      (gt1_in1,gt1_in2,gt1);
fpdiv_clk_parameter  		  #(Q2,N2) 	 divider1   (startdiv,clk,rst,div_in,div_ans,donediv);
 
/* reg [3:0] addr_ld;
reg [N-1:0] in_lpc;
reg re_ld,we_ld;
wire [N-1:0] out_lpc;

RAM_ld_lpcs RAM_ld (addr_ld,clk,in_lpc,re_ld,we_ld,out_lpc); */
  
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
		if(startld == 1'b1)
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
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i <= ORDER)
		begin
			NEXT_STATE = START_J1;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_LPC;
		end
	end

	START_J1:
	begin
		NEXT_STATE = CHECK_J1;
	end

	CHECK_J1:
	begin
		if(j1 <= (i-1))
		begin
			NEXT_STATE = SET_A_R;
		end
		else
		begin
			NEXT_STATE = START_DIV;
		end
	end

	SET_A_R:
	begin
		NEXT_STATE = CALC_SUM;
	end
//
//	SET_R:
//	begin
//		NEXT_STATE = CALC_SUM;
//	end

	CALC_SUM:
	begin
		NEXT_STATE = SET_SUM;
	end
	
	SET_SUM:
	begin
		NEXT_STATE = INCR_J1;
	end

	INCR_J1:
	begin
		NEXT_STATE = CHECK_J1;
	end
	
//	CALC_K_SET_RN:
//	begin
//		NEXT_STATE = PRE_CALC_K;
//	end

	START_DIV:
	begin
		NEXT_STATE = PRE_CALC_K;
	end
	
	PRE_CALC_K:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_K;
		end
		else
		begin
			NEXT_STATE = PRE_CALC_K;
		end
		
	end

	CALC_K:
	begin
		NEXT_STATE = SET_K;
	end

	SET_K:
	begin
		NEXT_STATE = CHECK_GT;
	end
	
	CHECK_GT:
	begin
		NEXT_STATE = CHECK_K;
	end
	
	CHECK_K:
	begin
		NEXT_STATE = SET_A;
	end
	
	SET_A:
	begin
		NEXT_STATE = CHECK_WHICH_I_FOR_A;
	end
	
	/* CHECK_J2:
	begin
		if(j2 < (i-7'd1))
		begin
			NEXT_STATE = CHECK_WHICH_I_FOR_A;
		end
		else
		begin
			NEXT_STATE = PRE_CALC_E;
		end
	end */
	
	CHECK_WHICH_I_FOR_A:
	begin
		if(i == 7'd1)
		begin
			NEXT_STATE = PRE_CALC_E;
		end
		else if (i == 7'd2)
		begin
			NEXT_STATE = PRE_CALC_A_I_2;
		end
		else if (i == 7'd3)
		begin
			NEXT_STATE = PRE_CALC_A_I_3;
		end
		else if (i == 7'd4)
		begin
			NEXT_STATE = PRE_CALC_A_I_4;
		end
		else if (i == 7'd5)
		begin
			NEXT_STATE = PRE_CALC_A_I_5;
		end
		else if (i == 7'd6)
		begin
			NEXT_STATE = PRE_CALC_A_I_6;
		end
		else if (i == 7'd7)
		begin
			NEXT_STATE = PRE_CALC_A_I_7;
		end
		else if (i == 7'd8)
		begin
			NEXT_STATE = PRE_CALC_A_I_8;
		end
		else if (i == 7'd9)
		begin
			NEXT_STATE = PRE_CALC_A_I_9;
		end
		else if (i == 7'd10)
		begin
			NEXT_STATE = PRE_CALC_A_I_10;
		end
		
	end
	
	PRE_CALC_A_I_2:
	begin
		NEXT_STATE = CALC_A_I_2;
	end
	
	CALC_A_I_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_2;
	end
	
	FINAL_CALC_A_I_2:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_3:
	begin
		NEXT_STATE = CALC_A_I_3;
	end
	
	CALC_A_I_3:
	begin
		NEXT_STATE = FINAL_CALC_A_I_3;
	end
	
	FINAL_CALC_A_I_3:
	begin
		NEXT_STATE = PRE_CALC_E;
	end

	PRE_CALC_A_I_4:
	begin
		NEXT_STATE = CALC_A_I_4;
	end
	
	CALC_A_I_4:
	begin
		NEXT_STATE = FINAL_CALC_A_I_4;
	end
	
	FINAL_CALC_A_I_4:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_5:
	begin
		NEXT_STATE = CALC_A_I_5;
	end
	
	CALC_A_I_5:
	begin
		NEXT_STATE = FINAL_CALC_A_I_5;
	end
	
	FINAL_CALC_A_I_5:
	begin
		NEXT_STATE = PRE_CALC_A_I_5_2;
	end
	
	PRE_CALC_A_I_5_2:
	begin
		NEXT_STATE = CALC_A_I_5_2;
	end
	
	CALC_A_I_5_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_5_2;
	end
	
	FINAL_CALC_A_I_5_2:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_6:
	begin
		NEXT_STATE = CALC_A_I_6;
	end
	
	CALC_A_I_6:
	begin
		NEXT_STATE = FINAL_CALC_A_I_6;
	end
	
	FINAL_CALC_A_I_6:
	begin
		NEXT_STATE = PRE_CALC_A_I_6_2;
	end
	
	PRE_CALC_A_I_6_2:
	begin
		NEXT_STATE = CALC_A_I_6_2;
	end
	
	CALC_A_I_6_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_6_2;
	end
	
	FINAL_CALC_A_I_6_2:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_7:
	begin
		NEXT_STATE = CALC_A_I_7;
	end
	
	CALC_A_I_7:
	begin
		NEXT_STATE = FINAL_CALC_A_I_7;
	end
	
	FINAL_CALC_A_I_7:
	begin
		NEXT_STATE = PRE_CALC_A_I_7_2;
	end
	
	PRE_CALC_A_I_7_2:
	begin
		NEXT_STATE = CALC_A_I_7_2;
	end
	
	CALC_A_I_7_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_7_2;
	end
	
	FINAL_CALC_A_I_7_2:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_8:
	begin
		NEXT_STATE = CALC_A_I_8;
	end
	
	CALC_A_I_8:
	begin
		NEXT_STATE = FINAL_CALC_A_I_8;
	end
	
	FINAL_CALC_A_I_8:
	begin
		NEXT_STATE = PRE_CALC_A_I_8_2;
	end
	
	PRE_CALC_A_I_8_2:
	begin
		NEXT_STATE = CALC_A_I_8_2;
	end
	
	CALC_A_I_8_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_8_2;	
	end
	
	FINAL_CALC_A_I_8_2:
	begin
		NEXT_STATE = PRE_CALC_A_I_8_3;
	end
	
	PRE_CALC_A_I_8_3:
	begin
		NEXT_STATE = CALC_A_I_8_3;
	end
	
	CALC_A_I_8_3:
	begin
		NEXT_STATE = FINAL_CALC_A_I_8_3;
	end
	
	FINAL_CALC_A_I_8_3:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_9:
	begin
		NEXT_STATE = CALC_A_I_9;
	end
	
	CALC_A_I_9:
	begin
		NEXT_STATE = FINAL_CALC_A_I_9;
	end
	
	FINAL_CALC_A_I_9:
	begin
		NEXT_STATE = PRE_CALC_A_I_9_2;
	end
	
	PRE_CALC_A_I_9_2:
	begin
		NEXT_STATE = CALC_A_I_9_2;
	end
	
	CALC_A_I_9_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_9_2;
	end
	
	FINAL_CALC_A_I_9_2:
	begin
		NEXT_STATE = PRE_CALC_A_I_9_3;
	end
	
	PRE_CALC_A_I_9_3:
	begin
		NEXT_STATE = CALC_A_I_9_3;
	end
	
	CALC_A_I_9_3:
	begin
		NEXT_STATE = FINAL_CALC_A_I_9_3;
	end
	
	FINAL_CALC_A_I_9_3:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_A_I_10:
	begin
		NEXT_STATE = CALC_A_I_10;
	end
	
	CALC_A_I_10:
	begin
		NEXT_STATE = FINAL_CALC_A_I_10;
	end
	
	FINAL_CALC_A_I_10:
	begin
		NEXT_STATE = PRE_CALC_A_I_10_2;
	end
	
	PRE_CALC_A_I_10_2:
	begin
		NEXT_STATE = CALC_A_I_10_2;
	end
	
	CALC_A_I_10_2:
	begin
		NEXT_STATE = FINAL_CALC_A_I_10_2;
	end
	
	FINAL_CALC_A_I_10_2:
	begin
		NEXT_STATE = PRE_CALC_A_I_10_3;
	end
	
	PRE_CALC_A_I_10_3:
	begin
		NEXT_STATE = CALC_A_I_10_3;
	end
	
	CALC_A_I_10_3:
	begin
		NEXT_STATE = FINAL_CALC_A_I_10_3;
	end
	
	FINAL_CALC_A_I_10_3:
	begin
		NEXT_STATE = PRE_CALC_E;
	end
	
	PRE_CALC_E:
	begin
		NEXT_STATE = CALC1_E;
	end

	CALC1_E:
	begin
		NEXT_STATE = CALC2_E;
	end

	CALC2_E:
	begin
		NEXT_STATE = SET_E;
	end

	SET_E:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end
	
	INIT_FOR_LPC:
	begin
		NEXT_STATE = CHECK_J;
	end
	
	CHECK_J:
	begin
		if(j <= 10'd10)
		begin
			NEXT_STATE = SET_ADDR_LPC;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end
	
	SET_ADDR_LPC:
	begin
		NEXT_STATE = SET_DELAY1;
	end
	
	SET_DELAY1:
	begin
		NEXT_STATE = SET_DELAY2;
	end
	
	SET_DELAY2:
	begin
		NEXT_STATE = SET_LPC;
	end
	
	SET_LPC:
	begin
		NEXT_STATE = INCR_J;
	end
				
	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end 
	
	/* CALC_LPC:
	begin
		NEXT_STATE = DONE;
	end */

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

		doneld <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneld <= 1'b0;
			startdiv <= 1'b0;
			sum <= 48'b0;
			
				/* R0  <= {48'h5666,16'hE9FF};
				R1  <= {48'h3DE8,16'h8F00};
				R2  <= {48'h1706,16'h20C0};
				R3  <= {1'b1,47'h11BC,16'h8E5F};
				R4  <= {1'b1,47'h2A1C,16'hDB80};
				R5  <= {1'b1,47'h2317,16'hE6BF};
				R6  <= {1'b1,47'h1A93,16'h24};
				R7  <= {1'b1,47'hC4F,16'h138F};
				R8  <= {1'b1,47'hC0C,16'hEFAF};
				R9  <= {1'b1,47'h141B,16'hADDF};
				R10 <= {1'b1,47'h11F4,16'h6D5F}; */ //frame no : 89 
		end

		INIT:
		begin
			
		end

		INIT_LOOP:
		begin
			e <= R0;
			i <= 7'b1;
			
		end

		CHECK_I:
		begin
			//check_sum <= sum;
		end

		START_J1:
		begin
			sum <= 48'b0;
			j1 <= 7'b1;
		end

		CHECK_J1:
		begin
		
		end

		SET_A_R:
		begin
			case ((7'd11*(i-7'd1)) + j1)
				7'd0 : m1_in1 <= a0;
				7'd1 : m1_in1 <= a1;
				7'd2 : m1_in1 <= a2;
				7'd3 : m1_in1 <= a3;
				7'd4 : m1_in1 <= a4;
				7'd5 : m1_in1 <= a5;
				7'd6 : m1_in1 <= a6;
				7'd7 : m1_in1 <= a7;
				7'd8 : m1_in1 <= a8;
				7'd9 : m1_in1 <= a9;
				7'd10 : m1_in1 <= a10;
				7'd11 : m1_in1 <= a11;
				7'd12 : m1_in1 <= a12;
				7'd13 : m1_in1 <= a13;
				7'd14 : m1_in1 <= a14;
				7'd15 : m1_in1 <= a15;
				7'd16 : m1_in1 <= a16;
				7'd17 : m1_in1 <= a17;
				7'd18 : m1_in1 <= a18;
				7'd19 : m1_in1 <= a19;
				7'd20 : m1_in1 <= a20;
				7'd21 : m1_in1 <= a21;
				7'd22 : m1_in1 <= a22;
				7'd23 : m1_in1 <= a23;
				7'd24 : m1_in1 <= a24;
				7'd25 : m1_in1 <= a25;
				7'd26 : m1_in1 <= a26;
				7'd27 : m1_in1 <= a27;
				7'd28 : m1_in1 <= a28;
				7'd29 : m1_in1 <= a29;
				7'd30 : m1_in1 <= a30;
				7'd31 : m1_in1 <= a31;
				7'd32 : m1_in1 <= a32;
				7'd33 : m1_in1 <= a33;
				7'd34 : m1_in1 <= a34;
				7'd35 : m1_in1 <= a35;
				7'd36 : m1_in1 <= a36;
				7'd37 : m1_in1 <= a37;
				7'd38 : m1_in1 <= a38;
				7'd39 : m1_in1 <= a39;
				7'd40 : m1_in1 <= a40;
				7'd41 : m1_in1 <= a41;
				7'd42 : m1_in1 <= a42;
				7'd43 : m1_in1 <= a43;
				7'd44 : m1_in1 <= a44;
				7'd45 : m1_in1 <= a45;
				7'd46 : m1_in1 <= a46;
				7'd47 : m1_in1 <= a47;
				7'd48 : m1_in1 <= a48;
				7'd49 : m1_in1 <= a49;
				7'd50 : m1_in1 <= a50;
				7'd51 : m1_in1 <= a51;
				7'd52 : m1_in1 <= a52;
				7'd53 : m1_in1 <= a53;
				7'd54 : m1_in1 <= a54;
				7'd55 : m1_in1 <= a55;
				7'd56 : m1_in1 <= a56;
				7'd57 : m1_in1 <= a57;
				7'd58 : m1_in1 <= a58;
				7'd59 : m1_in1 <= a59;
				7'd60 : m1_in1 <= a60;
				7'd61 : m1_in1 <= a61;
				7'd62 : m1_in1 <= a62;
				7'd63 : m1_in1 <= a63;
				7'd64 : m1_in1 <= a64;
				7'd65 : m1_in1 <= a65;
				7'd66 : m1_in1 <= a66;
				7'd67 : m1_in1 <= a67;
				7'd68 : m1_in1 <= a68;
				7'd69 : m1_in1 <= a69;
				7'd70 : m1_in1 <= a70;
				7'd71 : m1_in1 <= a71;
				7'd72 : m1_in1 <= a72;
				7'd73 : m1_in1 <= a73;
				7'd74 : m1_in1 <= a74;
				7'd75 : m1_in1 <= a75;
				7'd76 : m1_in1 <= a76;
				7'd77 : m1_in1 <= a77;
				7'd78 : m1_in1 <= a78;
				7'd79 : m1_in1 <= a79;
				7'd80 : m1_in1 <= a80;
				7'd81 : m1_in1 <= a81;
				7'd82 : m1_in1 <= a82;
				7'd83 : m1_in1 <= a83;
				7'd84 : m1_in1 <= a84;
				7'd85 : m1_in1 <= a85;
				7'd86 : m1_in1 <= a86;
				7'd87 : m1_in1 <= a87;
				7'd88 : m1_in1 <= a88;
				7'd89 : m1_in1 <= a89;
				7'd90 : m1_in1 <= a90;
				7'd91 : m1_in1 <= a91;
				7'd92 : m1_in1 <= a92;
				7'd93 : m1_in1 <= a93;
				7'd94 : m1_in1 <= a94;
				7'd95 : m1_in1 <= a95;
				7'd96 : m1_in1 <= a96;
				7'd97 : m1_in1 <= a97;
				7'd98 : m1_in1 <= a98;
				7'd99 : m1_in1 <= a99;
				7'd100 : m1_in1 <= a100;
				7'd101 : m1_in1 <= a101;
				7'd102 : m1_in1 <= a102;
				7'd103 : m1_in1 <= a103;
				7'd104 : m1_in1 <= a104;
				7'd105 : m1_in1 <= a105;
				7'd106 : m1_in1 <= a106;
				7'd107 : m1_in1 <= a107;
				7'd108 : m1_in1 <= a108;
				7'd109 : m1_in1 <= a109;
				7'd110 : m1_in1 <= a110;
				7'd111 : m1_in1 <= a111;
				7'd112 : m1_in1 <= a112;
				7'd113 : m1_in1 <= a113;
				7'd114 : m1_in1 <= a114;
				7'd115 : m1_in1 <= a115;
				7'd116 : m1_in1 <= a116;
				7'd117 : m1_in1 <= a117;
				7'd118 : m1_in1 <= a118;
				7'd119 : m1_in1 <= a119;
				7'd120 : m1_in1 <= a120;
			endcase
			case (i-j1)
				4'd0 : m1_in2 <= R0;
				4'd1 : m1_in2 <= R1;
				4'd2 : m1_in2 <= R2;
				4'd3 : m1_in2 <= R3;
				4'd4 : m1_in2 <= R4;
				4'd5 : m1_in2 <= R5;
				4'd6 : m1_in2 <= R6;
				4'd7 : m1_in2 <= R7;
				4'd8 : m1_in2 <= R8;
				4'd9 : m1_in2 <= R9;
				4'd10: m1_in2 <= R10;
			endcase
			
			
			
		end

//		SET_R:
//		begin
//			//m1_in2 <= out_rn;
//		end

		CALC_SUM:
		begin

			a1_in1 <= sum;
			a1_in2 <= m1_out;
			
			/* if(i == 7'd2)
			begin
				check_ak0 <= m1_in1;
				//check_ak1 <= m1_in2;
			end */
			
			
		end
		
		SET_SUM:
		begin
			sum <= a1_out;
			
		end

		INCR_J1:
		begin
			j1 <= j1 + 7'd1;
			
		end
		
//		CALC_K_SET_RN:
//		begin
//
//		end

		START_DIV:
		begin
			startdiv <= 1'b1;
		end

		PRE_CALC_K:
		begin
			case (i)
				4'd0 : 
				begin
					a1_in1 <= R0;
					//check_ak0 <= sum;
				end
				
				4'd1 :
				begin
					a1_in1 <= R1;
					
				end
				4'd2 : 
				begin
					a1_in1 <= R2;
					//check_ak1 <= sum;
				end
				4'd3 : a1_in1 <= R3;
				4'd4 : a1_in1 <= R4;
				4'd5 : a1_in1 <= R5;
				4'd6 : a1_in1 <= R6;
				4'd7 : a1_in1 <= R7;
				4'd8 : a1_in1 <= R8;
				4'd9 : a1_in1 <= R9;
				4'd10: a1_in1 <= R10;
			endcase
			a1_in2 <= sum;	
			
			 div_in <= e;
			 startdiv <= 1'b0;
			
		end

		CALC_K:
		begin
			m1_in1 <= a1_out;
			m1_in2 <= div_ans;
			
			
		end

		SET_K:
		begin
		  
		
			k <= {(m1_out[N2-1] == 0)?1'b1:1'b0,m1_out[N2-2:0]};
			//check_k <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
		end
		
		CHECK_GT:
		begin
			gt1_in1 <= {(k[N2-1] == 1)?1'b0:1'b0,k[N2-2:0]};
			gt1_in2 <= NUMBER_ONE;
			//check_k <= k;
		end
		
		CHECK_K:
		begin
			if(gt1)
			begin
				k <= 48'b0;
			end
			else
			begin
				k <= k;
			end
		end
		
		SET_A:
		begin
			case (i)
			7'd1  : a12  <= k;
			7'd2  : a24  <= k;
			7'd3  : a36  <= k;
			7'd4  : a48  <= k;
			7'd5  : a60  <= k;
			7'd6  : a72  <= k;
			7'd7  : a84  <= k;
			7'd8  : a96  <= k;
			7'd9  : a108 <= k;
			7'd10 : a120 <= k;
			
			endcase
			
			/* if(i == 7'd1)
			begin
				check_ak1 <= k;
				//check_ak1 <= m1_in2;
			end */
			
		end
		
		CHECK_WHICH_I_FOR_A:
		begin
			j2 <= 7'b1;
		end
		
		// i =2
		//  a23 = a12+ k* a12
		PRE_CALC_A_I_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a12;
			a1_in1 <= a12;
		end
		
		CALC_A_I_2:
		begin
			a1_in2 <= m1_out;
		end
		
		FINAL_CALC_A_I_2:
		begin
			a23 <= a1_out;
		end

		/* i = 3
		 a34 = a23+ k* a24
       a35 = a24+ k* a23 */
		PRE_CALC_A_I_3:
		begin
			m1_in1 <= k;
			m1_in2 <= a24;
			m2_in1 <= k;
			m2_in2  <= a23;
			a1_in1 <= a23;
			a2_in1 <= a24;
		end
		
		CALC_A_I_3:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
		end
		
		FINAL_CALC_A_I_3:
		begin
			a34 <= a1_out;
			a35 <= a2_out;
		end

		/* i = 4
			a45 = a34+ k* a36
			a46 = a35+ k* a35
			a47 = a36+ k* a34 */
		PRE_CALC_A_I_4:
		begin
			m1_in1 <= k;
			m1_in2 <= a36;
			m2_in1 <= k;
			m2_in2 <= a35;
			m3_in1 <= k;
			m3_in2 <= a34;
			a1_in1 <= a34;
			a2_in1 <= a35;
			a3_in1 <= a36;
		end
		
		CALC_A_I_4:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
			
		end
		
		FINAL_CALC_A_I_4:
		begin
			a45 <= a1_out;
			a46 <= a2_out;
			a47 <= a3_out;
		end
		
		/* i = 5
		a56 = a45+ k* a48
        a57 = a46+ k* a47
        a58 = a47+ k* a46
        a59 = a48+ k* a45 */
		PRE_CALC_A_I_5:
		begin
			m1_in1 <= k;
			m1_in2 <= a48;
			a1_in1 <= a45;
			m2_in1 <= k;
			m2_in2 <= a47;
			a2_in1 <= a46;
			
		end
				
		CALC_A_I_5:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;			
		end
		
		FINAL_CALC_A_I_5:
		begin
			a56 <= a1_out;
			a57 <= a2_out;
			a58 <= a3_out;
			a59 <= a4_out;
		end
		
		PRE_CALC_A_I_5_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a46;
			a1_in1 <= a47;
			m2_in1 <= k;
			m2_in2 <= a45;
			a2_in1 <= a48;
		end
		
		CALC_A_I_5_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
		end
		
		FINAL_CALC_A_I_5_2:
		begin
			a58 <= a1_out;
			a59 <= a2_out;
		end
		
		
		/* i = 6
	  a67 = a56+ k* a60
      a68 = a57+ k* a59
      a69 = a58+ k* a58
      a70 = a59+ k* a57
      a71 = a60+ k* a56*/
		PRE_CALC_A_I_6:
		begin
			m1_in1 <= k;
			m1_in2 <= a60;
			a1_in1 <= a56;
			m2_in1 <= k;
			m2_in2 <= a59;
			a2_in1 <= a57;
			m3_in1 <= k;
			m3_in2 <= a58;
			a3_in1 <= a58;
			
		end
		
		CALC_A_I_6:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
			
			
		end
		
		FINAL_CALC_A_I_6:
		begin
			a67 <= a1_out;
			a68 <= a2_out;
			a69 <= a3_out;
			
		end
		
		PRE_CALC_A_I_6_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a57;
			a1_in1 <= a59;
			m2_in1 <= k;
			m2_in2 <= a56;
			a2_in1 <= a60;
		end
		
		CALC_A_I_6_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
		end
		
		FINAL_CALC_A_I_6_2:
		begin
			a70 <= a1_out;
			a71 <= a2_out;
		end
		
		/* i = 7
		a78 = a67+ k* a72
      a79 = a68+ k* a71
      a80 = a69+ k* a70
      a81 = a70+ k* a69
      a82 = a71+ k* a68
      a83 = a72+ k* a67*/
		PRE_CALC_A_I_7:
		begin
			m1_in1 <= k;
			m1_in2 <= a72;
			a1_in1 <= a67;
			m2_in1 <= k;
			m2_in2 <= a71;
			a2_in1 <= a68;
			m3_in1 <= k;
			m3_in2 <= a70;
			a3_in1 <= a69;
			
		end
		
		CALC_A_I_7:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
			
		end
		
		FINAL_CALC_A_I_7:
		begin
			a78 <= a1_out;
			a79 <= a2_out;
			a80 <= a3_out;
		end
		
		PRE_CALC_A_I_7_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a69;
			a1_in1 <= a70;
			m2_in1 <= k;
			m2_in2 <= a68;
			a2_in1 <= a71;
			m3_in1 <= k;
			m3_in2 <= a67;
			a3_in1 <= a72;
		end
		
		CALC_A_I_7_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
		end
		
		FINAL_CALC_A_I_7_2:
		begin
			a81 <= a1_out;
			a82 <= a2_out;
			a83 <= a3_out;
		end
		
		/* i = 8
		a89 = a78+ k* a84
      a90 = a79+ k* a83
      a91 = a80+ k* a82
      a92 = a81+ k* a81
      a93 = a82+ k* a80
      a94 = a83+ k* a79
      a95 = a84+ k* a78*/
		PRE_CALC_A_I_8:
		begin
			m1_in1 <= k;
			m1_in2 <= a84;
			a1_in1 <= a78;
			m2_in1 <= k;
			m2_in2 <= a83;
			a2_in1 <= a79;
			m3_in1 <= k;
			m3_in2 <= a82;
			a3_in1 <= a80;
		end
		
		CALC_A_I_8:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
		end
		
		FINAL_CALC_A_I_8:
		begin
			a89 <= a1_out;
			a90 <= a2_out;
			a91 <= a3_out;
		end
		
		PRE_CALC_A_I_8_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a81;
			a1_in1 <= a81;
			m2_in1 <= k;
			m2_in2 <= a80;
			a2_in1 <= a82;
			m3_in1 <= k;
			m3_in2 <= a79;
			a3_in1 <= a83;
		end
		
		CALC_A_I_8_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;			
		end
		
		FINAL_CALC_A_I_8_2:
		begin
			a92 <= a1_out;
			a93 <= a2_out;
			a94 <= a3_out;
		end
		
		PRE_CALC_A_I_8_3:
		begin
			m1_in1 <= k;
			m1_in2 <= a78;
			a1_in1 <= a84;
		end
		
		CALC_A_I_8_3:
		begin
			a1_in2 <= m1_out;
		end
		
		FINAL_CALC_A_I_8_3:
		begin
			a95 <= a1_out;
		end
		
		
		/* i = 9
		a100 = a89+ k* a96
      a101 = a90+ k* a95
      a102 = a91+ k* a94
      a103 = a92+ k* a93
      a104 = a93+ k* a92
      a105 = a94+ k* a91
      a106 = a95+ k* a90
      a107 = a96+ k* a89*/
		PRE_CALC_A_I_9:
		begin
			m1_in1 <= k;
			m1_in2 <= a96;
			a1_in1 <= a89;
			m2_in1 <= k;
			m2_in2 <= a95;
			a2_in1 <= a90;
			m3_in1 <= k;
			m3_in2 <= a94;
			a3_in1 <= a91;
		end
		
		CALC_A_I_9:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;			
		end
		
		FINAL_CALC_A_I_9:
		begin
			a100 <= a1_out;
			a101 <= a2_out;
			a102 <= a3_out;
		end
		
		PRE_CALC_A_I_9_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a93;
			a1_in1 <= a92;
			m2_in1 <= k;
			m2_in2 <= a92;
			a2_in1 <= a93;
			m3_in1 <= k;
			m3_in2 <= a91;
			a3_in1 <= a94;
		end
		
		CALC_A_I_9_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
		end
		
		FINAL_CALC_A_I_9_2:
		begin
			a103 <= a1_out;
			a104 <= a2_out;
			a105 <= a3_out;
		end
		
		PRE_CALC_A_I_9_3:
		begin
			m1_in1 <= k;
			m1_in2 <= a90;
			a1_in1 <= a95;
			m2_in1 <= k;
			m2_in2 <= a89;
			a2_in1 <= a96;
		end
		
		CALC_A_I_9_3:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
		end
		
		FINAL_CALC_A_I_9_3:
		begin
			a106 <= a1_out;
			a107 <= a2_out;
		end
		
		
		/* i = 10
		a111 = a100+ k* a108
      a112 = a101+ k* a107
      a113 = a102+ k* a106
      a114 = a103+ k* a105
      a115 = a104+ k* a104
      a116 = a105+ k* a103
      a117 = a106+ k* a102
      a118 = a107+ k* a101
      a119 = a108+ k* a100*/
		PRE_CALC_A_I_10:
		begin
			m1_in1 <= k;
			m1_in2 <= a108;
			a1_in1 <= a100;
			m2_in1 <= k;
			m2_in2 <= a107;
			a2_in1 <= a101;
			m3_in1 <= k;
			m3_in2 <= a106;
			a3_in1 <= a102;
		end
		
		CALC_A_I_10:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;			
		end
		
		FINAL_CALC_A_I_10:
		begin
			a111 <= a1_out;
			a112 <= a2_out;
			a113 <= a3_out;
		end
		
		PRE_CALC_A_I_10_2:
		begin
			m1_in1 <= k;
			m1_in2 <= a105;
			a1_in1 <= a103;
			m2_in1 <= k;
			m2_in2 <= a104;
			a2_in1 <= a104;
			m3_in1 <= k;
			m3_in2 <= a103;
			a3_in1 <= a105;
		end
		
		CALC_A_I_10_2:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
		end
		
		FINAL_CALC_A_I_10_2:
		begin
			a114 <= a1_out;
			a115 <= a2_out;
			a116 <= a3_out;
		end
		
		PRE_CALC_A_I_10_3:
		begin
			m1_in1 <= k;
			m1_in2 <= a102;
			a1_in1 <= a106;
			m2_in1 <= k;
			m2_in2 <= a101;
			a2_in1 <= a107;
			m3_in1 <= k;
			m3_in2 <= a100;
			a3_in1 <= a108;
		end
		
		CALC_A_I_10_3:
		begin
			a1_in2 <= m1_out;
			a2_in2 <= m2_out;
			a3_in2 <= m3_out;
		end
		
		FINAL_CALC_A_I_10_3:
		begin
			a117 <= a7_out;
			a118 <= a8_out;
			a119 <= a9_out;
		end
		
		// Calculations for e:
		PRE_CALC_E:
		begin
			m1_in1 <= k;
			m1_in2 <= k;
		//	check_k <= k;
		end

		CALC1_E:
		begin
			a1_in1 <= NUMBER_ONE;
			a1_in2 <= {(m1_out[N2-1] == 0)?1'b1:1'b0,m1_out[N2-2:0]};
			//c_m1_out <= m1_out;
						
		end

		CALC2_E:
		begin
			m1_in1 <= e;
			m1_in2 <= a1_out;
		end

		SET_E:
		begin
			e <= m1_out;
		end

		INCR_I:
		begin
			i <= i + 7'd1;
		end
		
		INIT_FOR_LPC:
		begin
			j <= 4'd0;
		end
		
		CHECK_J:
		begin
			
		end
		
		SET_ADDR_LPC:
		begin
			addr_ld <= j;
		end
		
		SET_DELAY1:
		begin
		
		end
		
		SET_DELAY2:
		begin
		
		end
		
		SET_LPC:
		begin
			case (j)
				4'd0 : in_lpc <= {15'b0,1'b1,16'b0}; // one
				4'd1 : in_lpc <= {a111[N2-1],a111[N-2:0]};
				4'd2 : in_lpc <= {a112[N2-1],a112[N-2:0]};
				4'd3 : in_lpc <= {a113[N2-1],a113[N-2:0]};
				4'd4 : in_lpc <= {a114[N2-1],a114[N-2:0]};
				4'd5 : in_lpc <= {a115[N2-1],a115[N-2:0]};
				4'd6 : in_lpc <= {a116[N2-1],a116[N-2:0]};
				4'd7 : in_lpc <= {a117[N2-1],a117[N-2:0]};
				4'd8 : in_lpc <= {a118[N2-1],a118[N-2:0]};
				4'd9 : 
					begin
						in_lpc <= {a119[N2-1],a119[N-1:0]};
						check_ak1 <= a119;
					end
				4'd10:
					begin
						in_lpc <= {a120[N2-1],a120[N-1:0]};
						check_ak0 <= a120;
					end
			endcase
		
		end
		
		INCR_J:
		begin
			j <= j + 4'd1;
		end
				
		
		/* CALC_LPC:
		begin
			lpc0 <= NUMBER_ONE;
			lpc1 <= a111;
			lpc2 <= a112;
			lpc3 <= a113;
			lpc4 <= a114;
			lpc5 <= a115;
			lpc6 <= a116;
			lpc7 <= a117;
			lpc8 <= a118;
			lpc9 <= a119;
			lpc10 <= a120;
			
			
		end */
		
		

		DONE:
		begin
			doneld <= 1'd1;
		end

		endcase
	end

end




endmodule