/*
* Module         - lpc_to_lsp
* Top module     - speech_to_uq_lsps
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Feb 27 14:24:00 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform43.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/



module lpc_to_lsp (startltl,clk,rst,ak_out,
				ak_0,ak_1,ak_2,ak_3,ak_4,ak_5,ak_6,ak_7,ak_8,ak_9,ak_10,
				freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9,
						 ak_addr,
					
						 doneltl,
						 c_psum,c_sig
						 
						 );



//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	parameter Q1 = 24;
	
	input startltl,clk,rst;
	input [N-1:0] ak_out;
	
	output reg [N-1:0] freq0,freq1,freq2,freq3,freq4,freq5,freq6,freq7,freq8,freq9;//c_ak1,c_ak2,c_ak3,c_ak4;
	reg [N-1:0] ak0,ak1,ak2,ak3,ak4,ak5,ak6,ak7,ak8,ak9,ak10;
	input [N-1:0] ak_0,ak_1,ak_2,ak_3,ak_4,ak_5,ak_6,ak_7,ak_8,ak_9,ak_10;
	
	reg [N-1:0]	 psumr,psum1;//check_xm,value0_check ;
						 
	output reg doneltl;
	wire donecp2c;
	output reg [3:0] ak_addr;
	
	reg [3:0] check_roots,i;
	reg [9:0] count;
	
	output reg [N-1:0] c_psum,c_sig;
	
	/* reg [3:0] ak_addr;
	wire [N-1:0] ak_out;
	RAM_ak         module_RAM_ak			   (ak_addr,clk,,1,0,ak_out); */  //frame 0
	

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 6'd1,
			 SET_AK_ADDR = 6'd2,
			 GET_AK = 6'd3,
			 INCR_J = 6'd4,
			 CHECK_J = 6'd5,
			 PRE_CALC_PQ = 6'd6 ,
			 CALC_PQ1 = 6'd7,
			 CALC_PQ2 = 6'd8,
			 CALC_PQ3 = 6'd9,
			 CALC_PQ4 = 6'd10,
			 CALC_PQ5 = 6'd11,
			 CALC_PQ = 6'd12,
			 PRE_GET_AK = 6'd13,
			 SET_COEFF = 6'd14,
			 CALC_PSUM1 = 6'd15,
			 SET_WHILE = 6'd16,
			 CHECK_WHILE = 6'd17,
			 CALC_XR = 6'd18,
			 OUT_XR = 6'd19,
			 SET_PSUMR = 6'd20,
			 SET_TEMPS = 6'd21,
			 DOUBLE_PQ = 6'd22,
			 CHECK_IF = 6'd23,
			 INIT_IF = 6'd24,
			 CHECK_K = 6'd25,
			 ADD_XM = 6'd26,
			 OUT_XM = 6'd27,
			 INIT_PSUMM = 6'd28,
			 OUT_PSUMM = 6'd29,
			 CHECK_IF_2 = 6'd30,
			 IF2_TRUE = 6'd31,
			 IF2_FALSE = 6'd32,
			 INCR_K = 6'd33,
			 SET_FREQ = 6'd34,
			 IF_FALSE = 6'd35,
			 INCR_I = 6'd36,
			 CHECK_I = 6'd37,
			 CALC_FREQ_ACOSF = 6'd38,
			 SET_FREQ_ACOSF = 6'd39,	
			INCR_ACOSF = 6'd40,
			CHECK_ACOSF = 6'd41,
			INIT_ACOSF = 6'd42,
			DONE = 6'd43,
			START_ACOSF = 6'd44,
			START_PSUMM = 6'd45,
			RUN_OUT_XR = 6'd46;

reg [5:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

/* parameter [N-1:0] NUMBER_TWO = 32'b00000000000000100000000000000000,
				  NUMBER_ONE = 32'b00000000000000010000000000000000,
				  NUMBER_POINT_FIVE = 32'b00000000000000001000000000000000,
				  NUMBER_NEG_ONE = 32'b10000000000000010000000000000000,
				  DELTA = 32'b00000000000000000000001010011111; */
				  
parameter [N-1:0] NUMBER_TWO = {8'h02,24'b0},
				  NUMBER_ONE = {8'h01,24'b0},
				  NUMBER_POINT_FIVE = {8'h00,1'b1,23'b0},
				  NUMBER_NEG_ONE = {8'h81,24'b0},
				  DELTA = {8'h00,24'h028F5C};

parameter [3:0] NB = 4'd5, ORDER = 4'd10; 				  
				  
reg 	[N-1:0] xr,x1,p0,p1,p2,p3,p4,p5,q0,q1,q2,q3,q4,q5;


reg 	[3:0]   j,k,roots;

reg 	[N-1:0] a1_in1,a1_in2,a2_in1,a2_in2,a3_in1,a3_in2,a4_in1,a4_in2,x_1,x_2,x_3,
				  value;
wire 	[N-1:0] a1_out,a2_out,a3_out,a4_out,sum1,sum2,sum3,
				  theta;
wire 	donecp1,donecp2,donecp3,gt1,doneacosf;
reg 	startcp1,startcp2,startcp3,flag,startacosf;
reg 	[N-1:0] coeff0,coeff1,coeff2,coeff3,coeff4,coeff5,temp_psumr,temp_xr,x,gt1_in1,gt1_in2;

reg [N-1:0] psumm,xm;
reg [3:0] ac;
//reg donecp2_c;


/* RAM_ak         module_RAM_ak			   (ak_addr,clk,,1,0,ak_out); */
/* cheb_poly_eva_shared_mult  module_cheb_poly_eva1  	(clk,rst,startcp1,x_1,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum1,out_mult_1,mult1_1,mult2_1,
													 donecp1); */

/* cheb_poly_eva_shared_mult  module_cheb_poly_eva2  	(clk,rst,startcp2,x_2,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum2,out_mult_2,mult1_2,mult2_2,donecp2);
cheb_poly_eva_shared_mult  module_cheb_poly_eva3  	(clk,rst,startcp3,x_3,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum3,out_mult,mult1,mult2,donecp3);
													
	 */												
cheb_poly_eva  module_cheb_poly_eva1  	(clk,rst,startcp1,x_1,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum1,
													 donecp1);													 
cheb_poly_eva  module_cheb_poly_eva2  	(clk,rst,startcp2,x_2,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum2,donecp2);
cheb_poly_eva  module_cheb_poly_eva3  	(clk,rst,startcp3,x_3,coeff0,coeff1,coeff2,coeff3,
													 coeff4,coeff5,sum3,donecp3);
													

qadd #(Q1,N) add1(a1_in1, a1_in2, a1_out);
qadd #(Q1,N) add2(a2_in1, a2_in2, a2_out);
qadd #(Q1,N) add3(a3_in1, a3_in2, a3_out);
qadd #(Q1,N) add4(a4_in1, a4_in2, a4_out);
fpgreaterthan #(Q1,N) fpgt1(gt1_in1,gt1_in2,gt1);



acosf acosf0(startacosf,clk,rst,value,theta,doneacosf);
/* acosf acosf1(startacosf,clk,rst,value1,theta1,doneacosf1);
acosf acosf2(startacosf,clk,rst,value2,theta2,doneacosf2);
acosf acosf3(startacosf,clk,rst,value3,theta3,doneacosf3);
acosf acosf4(startacosf,clk,rst,value4,theta4,doneacosf4);
acosf acosf5(startacosf,clk,rst,value5,theta5,doneacosf5);
acosf acosf6(startacosf,clk,rst,value6,theta6,doneacosf6);
acosf acosf7(startacosf,clk,rst,value7,theta7,doneacosf7);
acosf acosf8(startacosf,clk,rst,value8,theta8,doneacosf8);
acosf acosf9(startacosf,clk,rst,value9,theta9,doneacosf9); */


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
		if(startltl)
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
		NEXT_STATE = PRE_CALC_PQ;//SET_AK_ADDR;
	end
	
	SET_AK_ADDR:
	begin
		NEXT_STATE = PRE_GET_AK;
	end
	
			
	PRE_GET_AK:
	begin
		NEXT_STATE = GET_AK;	
	end

	GET_AK:
	begin
		NEXT_STATE = INCR_J;
	end
	
	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end
	
	CHECK_J:
	begin
		if(j <= 4'd11)
		begin
			NEXT_STATE = SET_AK_ADDR;
		end
		else
		begin
			NEXT_STATE = PRE_CALC_PQ;
		end
	end
	
	PRE_CALC_PQ:
	begin
		NEXT_STATE = CALC_PQ1;
	end
	
	CALC_PQ1:
	begin
		NEXT_STATE = CALC_PQ2;
	end
	
	CALC_PQ2:
	begin
		NEXT_STATE = CALC_PQ3;
	end
	
	CALC_PQ3:
	begin
		NEXT_STATE = CALC_PQ4;
	end
	
	CALC_PQ4:
	begin
		NEXT_STATE = CALC_PQ5;
	end
	
	CALC_PQ5:
	begin
		NEXT_STATE = CALC_PQ;
	end
	
	CALC_PQ:
	begin
		NEXT_STATE = DOUBLE_PQ;
	end
	
	DOUBLE_PQ:
	begin
		NEXT_STATE = SET_COEFF;
	end
	
	SET_COEFF:
	begin
		if(donecp1)
		begin
			NEXT_STATE = CALC_PSUM1;
		end
		else
		begin
			NEXT_STATE = SET_COEFF;
		end
	end
	
	CALC_PSUM1:
	begin
		NEXT_STATE = SET_WHILE;
	end

	SET_WHILE:
	begin
		NEXT_STATE = CHECK_WHILE;
	end	

	CHECK_WHILE:
	begin
		if(flag && (gt1 || (xr == NUMBER_NEG_ONE)))
		begin
			NEXT_STATE = CALC_XR;
		end
		else
		begin
			NEXT_STATE = INCR_I;
		end
	end	
	
	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end
	
	CHECK_I:
	begin
		if(i < ORDER)
		begin
			NEXT_STATE = SET_COEFF;
		end
		else
		begin
			NEXT_STATE = INIT_ACOSF;
		end
	
	end

	CALC_XR:
	begin
		NEXT_STATE = OUT_XR;
	end
	
	OUT_XR:
	begin
		NEXT_STATE = RUN_OUT_XR;
	end
	
	RUN_OUT_XR:
	begin
		if(donecp2)
		begin
			NEXT_STATE = SET_PSUMR;
		end
		else
		begin
			NEXT_STATE = RUN_OUT_XR;
		end
	end
	
	SET_PSUMR:
	begin
		NEXT_STATE = SET_TEMPS;
	end
	
	SET_TEMPS:
	begin
		NEXT_STATE = CHECK_IF;
	end
	
	CHECK_IF:
	begin
		if((psumr[N-1] ==  1 && psum1[N-1] == 0) || 
			(psumr[N-1] ==  0 && psum1[N-1] == 1) ||
			(psumr == 32'b0))
		begin
			NEXT_STATE = INIT_IF;
		end
		else
		begin
		   NEXT_STATE = IF_FALSE;
		end
	end
	
	INIT_IF:
	begin
		NEXT_STATE = CHECK_K;
	end

	CHECK_K:
	begin
		if(k <= NB)
		begin
			NEXT_STATE = ADD_XM;
		end
		else
		begin
			NEXT_STATE = SET_FREQ;
		end
	end
	
	ADD_XM:
	begin
		NEXT_STATE = OUT_XM;
	end

	OUT_XM:
	begin
		NEXT_STATE = INIT_PSUMM;
	end
 
	 INIT_PSUMM:
	begin
		NEXT_STATE = START_PSUMM;
	end 
	
	START_PSUMM:
	begin
		if(donecp3)
		begin
			NEXT_STATE = OUT_PSUMM;
		end
		else
		begin
			NEXT_STATE = START_PSUMM;
		end
	end

	OUT_PSUMM:
	begin
		NEXT_STATE = CHECK_IF_2;
	end
	
	CHECK_IF_2:
	begin
		if((psumm[N-1] == 1 && psum1[N-1] == 1) || (psumm[N-1] == 0 && psum1[N-1] == 0))
		begin
			NEXT_STATE = IF2_TRUE;
		end
		else
		begin
			NEXT_STATE = IF2_FALSE;
		end
	end
	
	IF2_TRUE:
	begin
		NEXT_STATE = INCR_K;
	end
	
	IF2_FALSE:
	begin
		NEXT_STATE = INCR_K;
	end
	
	INCR_K:
	begin
		NEXT_STATE = CHECK_K;
	end
	
	SET_FREQ:
	begin
		NEXT_STATE = SET_WHILE;
	end
	
	IF_FALSE:
	begin
		NEXT_STATE = SET_WHILE;
	end
	
	INIT_ACOSF:
	begin
		NEXT_STATE = START_ACOSF;
	end
	
	START_ACOSF:
	begin
		NEXT_STATE = CALC_FREQ_ACOSF;
	end
	
	CALC_FREQ_ACOSF:
	begin
		if(doneacosf)
			begin
				NEXT_STATE = SET_FREQ_ACOSF;
			end
		else 
			begin
				NEXT_STATE = CALC_FREQ_ACOSF;
			end
	end
	
	SET_FREQ_ACOSF:
	begin
		NEXT_STATE = INCR_ACOSF;
	end
	
	INCR_ACOSF:
	begin
		NEXT_STATE = CHECK_ACOSF;
	end
	
	CHECK_ACOSF:
	begin
		if(ac >= 4'd10)
		begin
			NEXT_STATE = DONE;
		end
		else
		begin
			NEXT_STATE = START_ACOSF;
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

		doneltl <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			startcp1 <= 1'b0;
			startcp2 <= 1'b0;
			startcp3 <= 1'b0;
			startacosf <= 1'b0;
			count <= 6'd0;
			xm <= 32'b0;
			doneltl <= 1'd0;
			
		   /*  ak0 <= {8'h01,24'b0};
			ak1 <= {8'h81,24'h0A0770}; 		// -1.03917599
			ak2 <= {8'h00,24'h2F2221};		// 0.18411452
			ak3 <= {8'h00,24'h028892};		// 0.00989642
			ak4 <= {8'h80,24'h0CC9BC};      // -0.04995328
			ak5 <= {8'h80,24'h17DEE0};		// -0.9324459
			ak6 <= {8'h80,24'h03D0BB};		// -0.14903373
			ak7 <= {8'h80,24'h081E89};		// -0.03171593
			ak8 <= {8'h80,24'h01723A};		// -0.00564925
			ak9 <= {8'h80,24'h026C1E};		// -0.00946227
			ak10 <= {8'h00,24'h159E3E};     // 0.08444589   */         // Actual from c code base; 
			
			
			/* ak0 <= 32'h10000;
			ak1 <= 32'h8010B05;
			ak2 <= 32'h2F71;
			ak3 <= 32'h028B;
			ak4 <= 32'h80000D0D;
			ak5 <= 32'h800018EA;
			ak6 <= 32'h80000349;
			ak7 <= 32'h8000093F;
			ak8 <= 32'h80000116;
			ak9 <= 32'h800002CD;
			ak10 <= 32'h1724;                  // from verilog levinson
			 */
			// -- Fixed this module lpc_to_lsp for accuracy upto 3 digits after the decimal point.
			
			ak0 <= {ak_0[N-1],ak_0[22:16],ak_0[15:0],8'b0};
			ak1 <= {ak_1[N-1],ak_1[22:16],ak_1[15:0],8'b0};
			ak2 <= {ak_2[N-1],ak_2[22:16],ak_2[15:0],8'b0};
			ak3 <= {ak_3[N-1],ak_3[22:16],ak_3[15:0],8'b0};
			ak4 <= {ak_4[N-1],ak_4[22:16],ak_4[15:0],8'b0};
			ak5 <= {ak_5[N-1],ak_5[22:16],ak_5[15:0],8'b0};
			ak6 <= {ak_6[N-1],ak_6[22:16],ak_6[15:0],8'b0};
			ak7 <= {ak_7[N-1],ak_7[22:16],ak_7[15:0],8'b0};
			ak8 <= {ak_8[N-1],ak_8[22:16],ak_8[15:0],8'b0};
			ak9 <= {ak_9[N-1],ak_9[22:16],ak_9[15:0],8'b0};
			ak10 <= {ak_10[N-1],ak_10[22:16],ak_10[15:0],8'b0};  
			
			
		end

		INIT:
		begin
			doneltl <= 1'b0;
			xr <= 32'b0;
			x1 <= NUMBER_ONE;
			j <= 4'd0;
			roots <= 4'd0;
		end
		
		SET_AK_ADDR:
		begin
			ak_addr <= j;
		end
		
		PRE_GET_AK:
		begin
			
		end

		GET_AK:
		begin
			/* case(ak_addr)
		//	4'd0 	: ak0 	<= ak_out;
			4'd1 	: ak0 	<= ak_out;
			4'd2 	: ak1 	<= ak_out;
			4'd3 	: ak2 	<= ak_out;
			4'd4 	: ak3 	<= ak_out;
			4'd5	: ak4 	<= ak_out;
			4'd6 	: ak5 	<= ak_out;
			4'd7 	: ak6 	<= ak_out;
			4'd8 	: ak7 	<= ak_out;
			4'd9 	: ak8 	<= ak_out;
			4'd10 : ak9 	<= ak_out;
			4'd11 : ak10   <= ak_out;
			endcase */
		end
		
		INCR_J:
		begin
			j <= j + 4'd1;

		end
		
		CHECK_J:
		begin
		
		end
		
		PRE_CALC_PQ:
		begin
			p0 <= NUMBER_ONE;			
			q0 <= NUMBER_ONE;
			
			a1_in1 <= ak1;
			a1_in2 <= ak10;
			
			a2_in1 <= ak1;
			a2_in2 <= {(ak10[N-1] == 0)?1'b1:1'b0,ak10[N-2:0]};
			
		end
		
		CALC_PQ1:
		begin

			a3_in1 <= a1_out;
			a3_in2 <= NUMBER_NEG_ONE;
			 
			a4_in1 <= a2_out;
			a4_in2 <= NUMBER_ONE;
				 
			a1_in1 <= ak2;
			a1_in2 <= ak9;
				
			a2_in1 <= ak2;
			a2_in2 <= {(ak9[N-1] == 0)?1'b1:1'b0,ak9[N-2:0]};
			 
			 
		end
		
		CALC_PQ2:
		begin
		
			p1 <= a3_out;
			q1 <= a4_out;
			
			
			a3_in1 <= a1_out;
			a3_in2 <= {(a3_out[N-1] == 0)?1'b1:1'b0,a3_out[N-2:0]};
			 
			a4_in1 <= a2_out;
			a4_in2 <= a4_out;
			
			a1_in1 <= ak3;
			a1_in2 <= ak8;
				
			a2_in1 <= ak3;
			a2_in2 <= {(ak8[N-1] == 0)?1'b1:1'b0,ak8[N-2:0]};
						
		end
		
		CALC_PQ3:
		begin
		
			p2 <= a3_out;
			q2 <= a4_out;
			
			a3_in1 <= a1_out;
			a3_in2 <= {(a3_out[N-1] == 0)?1'b1:1'b0,a3_out[N-2:0]};
			 
			a4_in1 <= a2_out;
			a4_in2 <= a4_out;
			
			a1_in1 <= ak4;
			a1_in2 <= ak7;
				
			a2_in1 <= ak4;
			a2_in2 <= {(ak7[N-1] == 0)?1'b1:1'b0,ak7[N-2:0]};
						
		end
		
		CALC_PQ4:
		begin
		
			p3 <= a3_out;
			q3 <= a4_out;
			
			a3_in1 <= a1_out;
			a3_in2 <= {(a3_out[N-1] == 0)?1'b1:1'b0,a3_out[N-2:0]};
			 
			a4_in1 <= a2_out;
			a4_in2 <= a4_out;
			
			a1_in1 <= ak5;
			a1_in2 <= ak6;
				
			a2_in1 <= ak5;
			a2_in2 <= {(ak6[N-1] == 0)?1'b1:1'b0,ak6[N-2:0]};
						
		end
		
		CALC_PQ5:
		begin
		
			p4 <= a3_out;
			q4 <= a4_out;
			
			a3_in1 <= a1_out;
			a3_in2 <= {(a3_out[N-1] == 0)?1'b1:1'b0,a3_out[N-2:0]};
			 
			a4_in1 <= a2_out;
			a4_in2 <= a4_out;
						
		end
		
		CALC_PQ:
		begin
		
			p5 <= a3_out;
			q5 <= a4_out;
			
			i <= 4'd0;
						
		end
		
		DOUBLE_PQ:
		begin
			p0 <= {p0[N-1], p0[N-2 : 0] << 1};
			p1 <= {p1[N-1], p1[N-2 : 0] << 1};
			p2 <= {p2[N-1], p2[N-2 : 0] << 1};
			p3 <= {p3[N-1], p3[N-2 : 0] << 1};
			p4 <= {p4[N-1], p4[N-2 : 0] << 1};
			
			q0 <= {q0[N-1], q0[N-2 : 0] << 1};
			q1 <= {q1[N-1], q1[N-2 : 0] << 1};
			q2 <= {q2[N-1], q2[N-2 : 0] << 1};
			q3 <= {q3[N-1], q3[N-2 : 0] << 1};
			q4 <= {q4[N-1], q4[N-2 : 0] << 1};
		end
		
		INCR_I:
		begin
			i <= i + 4'd1;
		end
		
		CHECK_I:
		begin
			
		end

		SET_COEFF:
		begin
		
		
			startcp1 <= 1'b1;
			
			x_1 <= x1;
			if(!(i % 4'd2))
			begin
				coeff0 <= p0;
				coeff1 <= p1;
				coeff2 <= p2;
				coeff3 <= p3;
				coeff4 <= p4;
				coeff5 <= p5;
					
			end
			else
			begin
				coeff0 <= q0;
				coeff1 <= q1;
				coeff2 <= q2;
				coeff3 <= q3;
				coeff4 <= q4;
				coeff5 <= q5;
			
			end
		end
		
		
		
		CALC_PSUM1:
		begin
			
			psum1 <= sum1;		
			flag <= 1'b1;
			startcp1 <= 1'b0;
			
			
			
		end

		SET_WHILE:
		begin
			gt1_in1 <= xr;
			gt1_in2 <= NUMBER_NEG_ONE;
		end	

		CHECK_WHILE:
		begin
			
		end	

		CALC_XR:
		begin
			a1_in1 <= x1;
			a1_in2 <= {(DELTA[N-1] == 0)?1'b1:1'b0,DELTA[N-2:0]};
			
			count <= count + 6'd1;
			
		end
		
		OUT_XR:
		begin
			xr <= a1_out;
			x_2 <= a1_out;
			startcp2 <= 1'b1;
			//donecp2_c <= donecp2;
		end
		
		RUN_OUT_XR:
		begin
			startcp2 <= 1'b0;
		end
		

		SET_PSUMR:
		begin
			psumr <= sum2;
	
		end
		
		SET_TEMPS:
		begin
			temp_psumr <= psumr;
			temp_xr <= xr;		
		end
		
		CHECK_IF:
		begin

		end
		
		INIT_IF:
		begin
			roots <= roots + 4'd1;
			psumm <= psum1;
			k <= 4'd0;
		end

		CHECK_K:
		begin
			//check_roots <= roots;
		end
		
		ADD_XM:
		begin
			a1_in1 <= x1;
			a1_in2 <= xr;
		end

		OUT_XM:
		begin

			xm <= {a1_out[N-1],a1_out[N-2:0] >> 1};
			
		end
	 
		INIT_PSUMM:
		begin

			x_3 <= xm;
			startcp3 <= 1'b1;
	
		end
		
		START_PSUMM:
		begin
			startcp3 <= 1'b0;
		end 

		OUT_PSUMM:
		begin
			psumm <= sum3;

		end
		
		CHECK_IF_2:
		begin
			if(i == 4'd0 && k == 4'd1)
			begin
				c_psum <= psumm;
				c_sig <= xm ;
			end
		end
		
		IF2_TRUE:
		begin
			psum1 <= psumm;
			x1 	<= xm;
		end
		
		IF2_FALSE:
		begin
			psumr <= psumm;
			xr    <= xm;
			
			
		end
		
		INCR_K:
		begin
			k <= k + 4'd1;
		end
		
		SET_FREQ:
		begin
			case(i)
			4'd0: freq0 <= xm;
			4'd1: freq1 <= xm;
			4'd2: freq2 <= xm;
			4'd3: freq3 <= xm;
			4'd4: freq4 <= xm;
			4'd5: freq5 <= xm;
			4'd6: freq6 <= xm;
			4'd7: freq7 <= xm;
			4'd8: freq8 <= xm;
			4'd9: freq9 <= xm;
			endcase
			
			x1 <= xm;
			flag = 1'b0;
			
		end
		
		IF_FALSE:
		begin
			psum1 <= temp_psumr;
			x1 	<= temp_xr;
		end
		
		INIT_ACOSF:
		begin
			ac <= 4'd0;
			
		end
		
		START_ACOSF:
		begin
			startacosf <= 1'b1;
			
			case(ac)
			4'd0: 
			begin
				value <= {freq0[N-1],8'b0,freq0[30:24],freq0[23:8]};
			end
			4'd1: 
			begin
				value <= {freq1[N-1],8'b0,freq1[30:24],freq1[23:8]};
			end
			4'd2: 
			begin
				value <= {freq2[N-1],8'b0,freq2[30:24],freq2[23:8]};
			end
			4'd3: 
			begin
				value <= {freq3[N-1],8'b0,freq3[30:24],freq3[23:8]};
			end
			4'd4: 
			begin
				value <= {freq4[N-1],8'b0,freq4[30:24],freq4[23:8]};
			end
			4'd5: 
			begin
				value <= {freq5[N-1],8'b0,freq5[30:24],freq5[23:8]};
			end
			4'd6: 
			begin
				value <= {freq6[N-1],8'b0,freq6[30:24],freq6[23:8]};
			end
			4'd7: 
			begin
				value <= {freq7[N-1],8'b0,freq7[30:24],freq7[23:8]};
			end
			4'd8: 
			begin
				value <= {freq8[N-1],8'b0,freq8[30:24],freq8[23:8]};
			end
			4'd9: 
			begin
				value <= {freq9[N-1],8'b0,freq9[30:24],freq9[23:8]};
			end
			endcase
		end
		
		CALC_FREQ_ACOSF:
		begin
			startacosf <= 1'b0;
			
			
		end
		
		SET_FREQ_ACOSF:
		begin
		
			case(ac)
			4'd0: 
			begin
				freq0  <=  theta;
			end
			4'd1: 
			begin
				freq1  <=  theta;
			end
			4'd2: 
			begin
				freq2  <=  theta;
			end
			4'd3: 
			begin
				freq3  <=  theta;
			end
			4'd4: 
			begin
				freq4  <=  theta;
			end
			4'd5: 
			begin
				freq5  <=  theta;
			end
			4'd6: 
			begin
				freq6  <=  theta;
			end
			4'd7: 
			begin
				freq7  <=  theta;
			end
			4'd8: 
			begin
				freq8  <=  theta;
			end
			4'd9: 
			begin
				freq9  <=  theta;
			end
			endcase
		end
		
		INCR_ACOSF:
		begin
			ac <= ac + 4'd1;
		end
		
		CHECK_ACOSF:
		begin
			
		end
	

		DONE:
		begin
			doneltl <= 1'b1;
		end

		endcase
	end

end


endmodule