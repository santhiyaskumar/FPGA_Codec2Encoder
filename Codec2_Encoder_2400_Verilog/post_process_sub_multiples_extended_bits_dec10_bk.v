/*
* Module         - post_process_sub_multiples
* Top module     - nlp
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Thu May 02 10:39:44 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform59.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module post_process_sub_multiples_extended_bits_dec10_bk
										(startppsm,clk,rst,out_fw_real,gmax,gmax_bin,prev_f0,best_f0,addr_fw_real,
									
										doneppsm,
										check_sig);
	
			

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;
			
			parameter N1 = 80;
			parameter Q1 = 16;
			

			input clk,rst,startppsm;
			
			input [9:0] gmax_bin;
			input [N1-1:0] gmax;
			input [N-1:0] prev_f0;
			wire [N-1:0] m1_out;
			output reg [N-1:0] best_f0;
			 reg [N-1:0] m1_in1,m1_in2; //c_m1_in1,c_m1_in2,c_lt1_in1,c_lt1_in2;
			//output reg [9:0] sig;
			output reg doneppsm;  
			
			output reg [9:0] addr_fw_real;
			input [N1-1:0] out_fw_real;
			
			output reg [9:0] check_sig;
			

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 6'd0,
          INIT = 6'd1,
          INIT_CMAX = 6'd2,
          CALC_PREV_F0 = 6'd3,
          START_WHILE = 6'd4,
          CHECK_WHILE_1 = 6'd5,
          CHECK_WHILE_2 = 6'd6,
          CHECK_WHILE = 6'd7,
          INIT_WHILE = 6'd8,
          CALC_ONE_BY_MULT1 = 6'd9,
          CALC_ONE_BY_MULT2 = 6'd10,
          SET_B_1 = 6'd11,
          SET_B_2 = 6'd12,
          CALC_BMIN_BMAX = 6'd13,
          SET_BMIN_BMAX = 6'd14,
          SET_IF_1 = 6'd15,
          CHECK_IF_1 = 6'd16,
          SET_IF_2 = 6'd17,
          CHECK_IF_2 = 6'd18,
          IF_2 = 6'd19,
          CALC_THRESH_1 = 6'd20,
          ELSE_2 = 6'd21,
          CALC_THRESH_2 = 6'd22,
          SET_LMAX_BMIN = 6'd23,
          INIT_FOR = 6'd24,
          CHECK_B = 6'd25,
          SET_ADDR_FW = 6'd26,
          SET_DELAY_1 = 6'd27,
          SET_DELAY_2 = 6'd28,
          CHECK_IF_3 = 6'd29,
          SET_IF_3 = 6'd30,
          INCR_B = 6'd31,
          CHECK_IF_4 = 6'd32,
          SET_IF_4 = 6'd33,
          SET_ADDR_FW_1 = 6'd34,
          SET_DELAY_3 = 6'd35,
          SET_DELAY_4 = 6'd36,
          GET_FW_1 = 6'd37,
          SET_ADDR_FW_2 = 6'd38,
          SET_DELAY_5 = 6'd39,
          SET_DELAY_6 = 6'd40,
          GET_FW_2 = 6'd41,
          CHECK_IF_5 = 6'd42,
          SET_IF_5 = 6'd43,
          INCR_MULT = 6'd44,
          CALC_BEST_F0 = 6'd45,
          SET_BEST_F0 = 6'd46,
          DONE = 6'd47;

reg [5:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter 	[N-1:0] FFT_BY_SR = 32'b00000000000000000101000111101011,
						  POINT_EIGHT = 32'b00000000000000001100110011001100,
						  ONE_POINT_TWO = 32'b00000000000000010011001100110011,
						  POINT_THREE = 32'b00000000000000000100110011001100,
						  POINT_ONE_FIVE = 32'b00000000000000000010011001100110,
						  SR_BY_FFT = 32'b00000000000000110010000000000000;

reg 			[N-1:0] 		a1_in1,a1_in2,
								lt1_in1,lt1_in2,gt1_in1,gt1_in2,
								div_in,m2_in1,m2_in2;

reg 							startdiv;

					
wire 			[N-1:0] 		a1_out,div_ans,m2_out;
wire							lt1,gt1,donediv;

reg 			[9:0] 		min_bin,cmax_bin;
reg 			[9:0] 		bmin,lmax_bin; //addr_fw_real;
reg 			[N-1:0] 		one_by_mult,thresh;
reg [N-1:0] min_mult;
reg 			[N-1:0]     lmax,fw1,fw2;
//wire 			[N-1:0] 		out_fw_real;
reg [9:0] prev_f0_bin,mult,bmax,b;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);

fpgreaterthan	#(Q,N)    		fpgt1      (gt1_in1,gt1_in2,gt1);
fplessthan		#(Q,N)	 		fplt1 	   (lt1_in1,lt1_in2,lt1);

fpdiv_clk  	  	 divider	    (startdiv,clk,rst,div_in,div_ans,donediv);

//RAM_Fw_real      Fwram			(addr_fw_real,clk,,1,0,out_fw_real);

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
		if(startppsm == 1'b1)
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
		NEXT_STATE = INIT_CMAX;
	end

	INIT_CMAX:
	begin
		NEXT_STATE = CALC_PREV_F0;
	end

	CALC_PREV_F0:
	begin
		NEXT_STATE = START_WHILE;
	end

	START_WHILE:
	begin
		NEXT_STATE = CHECK_WHILE_1;
	end

	CHECK_WHILE_1:
	begin
		NEXT_STATE = CHECK_WHILE_2;
	end

	CHECK_WHILE_2:
	begin
		NEXT_STATE = CHECK_WHILE;
	end

	CHECK_WHILE:
	begin
		if(gt1 || gmax_bin == min_mult[25:16])
		begin
			NEXT_STATE = INIT_WHILE;
		end
		else
		begin
			NEXT_STATE = CALC_BEST_F0;
		end
		
	end

	INIT_WHILE:
	begin
		NEXT_STATE = CALC_BEST_F0;   //CALC_ONE_BY_MULT1; // fix this 
	end

	CALC_ONE_BY_MULT1:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_ONE_BY_MULT2;
		end
		else
		begin
			NEXT_STATE = CALC_ONE_BY_MULT1;
		end
	end

	CALC_ONE_BY_MULT2:
	begin
		NEXT_STATE = SET_B_1;
	end

	SET_B_1:
	begin
		NEXT_STATE = SET_B_2;
	end

	SET_B_2:
	begin
		NEXT_STATE = CALC_BMIN_BMAX;
	end

	CALC_BMIN_BMAX:
	begin
		NEXT_STATE = SET_BMIN_BMAX;
	end

	SET_BMIN_BMAX:
	begin
		NEXT_STATE = SET_IF_1;
	end

	SET_IF_1:
	begin
		NEXT_STATE = SET_IF_2;
	end

	SET_IF_2:
	begin
		if((prev_f0_bin > bmin) && (prev_f0_bin < bmax))
		begin
			NEXT_STATE = IF_2;
		end
		else
		begin
			NEXT_STATE = ELSE_2;
		end
	end

	IF_2:
	begin
		NEXT_STATE = CALC_THRESH_1;
	end

	CALC_THRESH_1:
	begin
		NEXT_STATE = SET_LMAX_BMIN;
	end

	ELSE_2:
	begin
		NEXT_STATE = CALC_THRESH_2;
	end

	CALC_THRESH_2:
	begin
		NEXT_STATE = SET_LMAX_BMIN;
	end

	SET_LMAX_BMIN:
	begin
		NEXT_STATE = INIT_FOR;
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_B;
	end

	CHECK_B:
	begin
		if(b <= bmax)
		begin
			NEXT_STATE = SET_ADDR_FW;
		end
		else
		begin
			NEXT_STATE = SET_IF_4;
		end
	end

	SET_ADDR_FW:
	begin
		NEXT_STATE = SET_DELAY_1;
	end

	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end

	SET_DELAY_2:
	begin
		NEXT_STATE = SET_IF_3;
	end
	
	SET_IF_3:
	begin
		NEXT_STATE = INCR_B;
	end

	INCR_B:
	begin
		NEXT_STATE = CHECK_B;
	end
	
	CHECK_IF_4:
	begin
		if(lmax > thresh)
		begin
			NEXT_STATE = SET_ADDR_FW_1;
		end
		else
		begin
			NEXT_STATE = INCR_MULT;
		end
	end

	SET_ADDR_FW_1:
	begin
		NEXT_STATE = SET_DELAY_3;
	end

	SET_DELAY_3:
	begin
		NEXT_STATE = SET_DELAY_4;
	end

	SET_DELAY_4:
	begin
		NEXT_STATE = GET_FW_1;
	end

	GET_FW_1:
	begin
		NEXT_STATE = SET_ADDR_FW_2;
	end

	SET_ADDR_FW_2:
	begin
		NEXT_STATE = SET_DELAY_5;
	end

	SET_DELAY_5:
	begin
		NEXT_STATE = SET_DELAY_6;
	end

	SET_DELAY_6:
	begin
		NEXT_STATE = GET_FW_2;
	end

	GET_FW_2:
	begin
		NEXT_STATE = CHECK_IF_5;
	end
	
	CHECK_IF_5:
	begin
		NEXT_STATE = INCR_MULT;
	end

	INCR_MULT:
	begin
		NEXT_STATE = START_WHILE;
	end

	CALC_BEST_F0:
	begin
		NEXT_STATE = SET_BEST_F0;
	end

	SET_BEST_F0:
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

		doneppsm <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneppsm <= 1'b0;
		end

		INIT:
		begin
			//sig <= 10'b1;
			mult <= 10'd2;
			min_bin <= 10'd16;
		end

		INIT_CMAX:
		begin
			//sig <= sig + 10'd1;
			cmax_bin <= gmax_bin;
			m1_in1 <= prev_f0;
			m1_in2 <= FFT_BY_SR;
		end

		CALC_PREV_F0:
		begin
			//sig <= sig+ 10'd1;
			prev_f0_bin <= m1_out[25:16];
		end

		START_WHILE:
		begin
			//sig <= sig+ 10'd1;
			m1_in1 <= {6'b0,min_bin,16'b0};
			m1_in2 <= {6'b0,mult,16'b0};
		end

		CHECK_WHILE_1:
		begin
			//sig <= sig+ 10'd1;
			min_mult <= m1_out;
		end

		CHECK_WHILE_2:
		begin
			//sig <= sig+ 10'd1;
			gt1_in1 <= {6'b0,gmax_bin,16'b0};
			gt1_in2 <= min_mult;
			
			//c_lt1_in1 <= {6'b0,gmax_bin,16'b0};
			//c_lt1_in2 <= min_mult;
		end

		CHECK_WHILE:
		begin
			//sig <= sig+ 10'd1;
		end

		INIT_WHILE:
		begin
			lmax <= 16'b0;
			
			//check_sig <= 12'd10;
		end

		CALC_ONE_BY_MULT1:
		begin
			startdiv <= 1'b1;
			div_in <= {6'b0,mult,16'b0};
		end

		CALC_ONE_BY_MULT2:
		begin
			one_by_mult <= div_ans;
			startdiv <= 1'b0;
		end

		SET_B_1:
		begin
			m1_in1 <= {6'b0,gmax_bin,16'b0};
			m1_in2 <= one_by_mult;
		end

		SET_B_2:
		begin
			b <= m1_out[25:16];
			//check_sig <= one_by_mult;
		end

		CALC_BMIN_BMAX:
		begin
			m1_in1 <= {6'b0,b,16'b0};
			m1_in2 <= POINT_EIGHT;
			m2_in1 <= {6'b0,b,16'b0};
			m2_in2 <= ONE_POINT_TWO;
			
		end

		SET_BMIN_BMAX:
		begin
			bmin <= m1_out[25:16];
			bmax <= m2_out[25:16];
		end

		SET_IF_1:
		begin
			if(bmin < min_bin)
			begin
				bmin <= min_bin;
			end
			
		end

		SET_IF_2:
		begin
			
		end

		IF_2:
		begin
			//m1_in1 <= POINT_THREE;
			//m1_in2 <= gmax;
			
		
		end

		CALC_THRESH_1:
		begin
			thresh <= gmax >> 1;
		end

		ELSE_2:
		begin
			//m1_in1 <= POINT_ONE_FIVE;
			//m1_in2 <= gmax;
		end

		CALC_THRESH_2:
		begin
			thresh <= gmax >> 2;
		end

		SET_LMAX_BMIN:
		begin
			lmax_bin <= bmin;
			//	check_sig <= 12'd12;
		end

		INIT_FOR:
		begin
			b <= bmin;
		end

		CHECK_B:
		begin
			
		end

		SET_ADDR_FW:
		begin
			addr_fw_real <= b;
			//check_sig <= cmax_bin;
		end

		SET_DELAY_1:
		begin
			
		end

		SET_DELAY_2:
		begin
			
		end

		SET_IF_3:
		begin
			if(out_fw_real > lmax)
			begin
				lmax <= out_fw_real;
				lmax_bin <= b;
			end
			
		end

		INCR_B:
		begin
			b <= b + 10'd1;
		end

		CHECK_IF_4:
		begin
			
		end

		SET_ADDR_FW_1:
		begin
			addr_fw_real <= lmax_bin - 10'd1;
		end

		SET_DELAY_3:
		begin
			
		end

		SET_DELAY_4:
		begin
			
		end

		GET_FW_1:
		begin
			fw1 <= out_fw_real;
		end

		SET_ADDR_FW_2:
		begin
			addr_fw_real <= lmax_bin + 10'd1;
		end

		SET_DELAY_5:
		begin
			
		end

		SET_DELAY_6:
		begin
			
		end

		GET_FW_2:
		begin
			fw2 <= out_fw_real;
		end

		CHECK_IF_5:
		begin
			if(lmax > fw1 && lmax > fw2)
			begin
			   // cmax_bin <= lmax_bin;  // you have to fix this
			end
		end

		INCR_MULT:
		begin
			//sig <= 10'd20;
			mult <= mult + 10'd1;
			
		end

		CALC_BEST_F0:
		begin
			m1_in1 <= {6'b0,cmax_bin,16'b0};
			m1_in2 <= SR_BY_FFT;
			
			//check_sig <= 12'd11;
		end

		SET_BEST_F0:
		begin
			best_f0 <= m1_out;
			check_sig <= cmax_bin;
			//c_m1_in1 <=  m1_in1;
			//c_m1_in2 <= m1_in2;
		end

		DONE:
		begin
			doneppsm <= 1'b1;
		end

		endcase
	end

end


endmodule