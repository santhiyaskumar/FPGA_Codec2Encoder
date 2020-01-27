module post_process_sub_multiples_calc (startppsm,clk,rst,
										out_fw_real,
										gmax,gmax_bin,prev_f0,
										best_f0,addr_fw_real,
										doneppsm,c_cmax,c_fw_real);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

		parameter N = 32;
		parameter Q = 16;
		
		parameter N1 = 80;
		parameter Q1 = 16;
		
		parameter N2 = 96;
		parameter Q2 = 16;
		
		input startppsm,clk,rst;
		input [N1-1:0] out_fw_real;
		input [N1-1:0] gmax;
		input [9:0] gmax_bin;
		input [N-1:0] prev_f0;
		
		output reg [N-1:0] best_f0;
		output reg [9:0] c_cmax;
		output reg [9:0] addr_fw_real;
		
		output reg doneppsm;
		output reg [N1-1:0] c_fw_real;
		

		






//----------------MODULE TEST-----------------------------------------//

/* module post_process_sub_multiples_calc (startppsm,clk,rst,
										//out_fw_real,
										//gmax,gmax_bin,prev_f0,
										best_f0,//addr_fw_real,
										doneppsm,c_cmax,c_fw_real);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

		parameter N = 32;
		parameter Q = 16;
		
		parameter N1 = 80;
		parameter Q1 = 16;
		
		parameter N2 = 96;
		parameter Q2 = 16;
		
		input startppsm,clk,rst;
		//input [N1-1:0] out_fw_real;
	//	input [N1-1:0] gmax;
	//	input [9:0] gmax_bin;
	//	input [N-1:0] prev_f0;
		
		output reg [N-1:0] best_f0;
		output reg [9:0] c_cmax;
		//output reg [9:0] addr_fw_real;
		
		output reg doneppsm;
		output reg [N1-1:0] c_fw_real;
		
		
			reg [N1-1:0] gmax;
			reg [9:0] gmax_bin;
			reg [N-1:0] prev_f0;
		
		reg [9:0] addr_fw_real;
		reg [N1-1:0] in_fw;
		wire [N1-1:0] out_fw_real;
		
		RAM_fw_ppsm_test    fw_ppsm	   (addr_fw_real,clk,in_fw,1'b1,1'b0,out_fw_real);   */  
		
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 6'd0,
          INIT_PPM = 6'd1,
          SET_PREV_F0_BIN = 6'd2,
          CALC_PREV_F0_BIN = 6'd3,
          START_DIV_MULT = 6'd4,
          CALC_MULT_DIV = 6'd5,
          SET_GT1 = 6'd6,
          SET_GT2 = 6'd7,
          CHECK_WHILE = 6'd8,
          SET_B = 6'd9,
          CALC_BMIN = 6'd10,
          CALC_BMAX = 6'd11,
          SET_BMAX = 6'd12,
          SET_BMIN = 6'd13,
          CHECK_IF_1 = 6'd14,
          SET_THRESH_1 = 6'd15,
          SET_THRESH_2 = 6'd16,
          SET_LMAX_LMAX_BIN = 6'd17,
          INIT_FOR = 6'd18,
          CHECK_FOR_B = 6'd19,
          SET_ADDR_FW = 6'd20,
          DELAY_1 = 6'd21,
          DELAY_2 = 6'd22,
          CHECK_IF_2 = 6'd23,
          INCR_B = 6'd24,
          CHECK_IF_3 = 6'd25,
          SET_ADDR_FW_1 = 6'd26,
          DELAY_3 = 6'd27,
          DELAY_4 = 6'd28,
          GET_FW_1 = 6'd29,
          SET_ADDR_FW_2 = 6'd30,
          DELAY_5 = 6'd31,
          DELAY_6 = 6'd32,
          GET_FW_2 = 6'd33,
          SET_CMX_BIN = 6'd34,
          INCR_MULT = 6'd35,
          CALC_MULT_CMAX_SR = 6'd36,
          SET_BEST_F0 = 6'd37,
          DONE = 6'd38,
		  PRESET_THRESH_1 = 6'd39,
		  PRESET_THRESH_2 = 6'd40;

reg [5:0] STATE, NEXT_STATE;
reg [9:0] mult,min_bin,cmax_bin,prev_f0_bin,gm_bin_by_mult;
reg [9:0] b,bmin,bmax,lmax_bin;
reg [N1-1:0] thresh,lmax,fw1,fw2;


reg [9:0] count;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
reg [N-1:0] m1_in1,m1_in2;
wire [N-1:0] m1_out;

qmult  #(Q,N) 			qmult1	  (m1_in1,m1_in2,m1_out);

//--------------------------------------------------------------------------
reg startdiv;
wire donediv;
reg [N-1:0] div_in;
wire [N-1:0] div_ans;
fpdiv_clk  	  	 divider	    (startdiv,clk,rst,div_in,div_ans,donediv);
//--------------------------------------------------------------------------
reg [N-1:0] gt1_in1,gt1_in2;
wire gt1; 
fpgreaterthan	#(Q,N)    		fpgt1      (gt1_in1,gt1_in2,gt1);
//--------------------------------------------------------------------------
reg [N2-1:0] ms1_in1,ms1_in2;
wire [N2-1:0] ms1_out;

qmult  			#(Q2,N2) 			qmult96_1	   (ms1_in1,ms1_in2,ms1_out);

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
		if(startppsm)
		begin
			NEXT_STATE = INIT_PPM;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_PPM:
	begin
		NEXT_STATE = SET_PREV_F0_BIN;
	end

	SET_PREV_F0_BIN:
	begin
		NEXT_STATE = CALC_PREV_F0_BIN;
	end

	CALC_PREV_F0_BIN:
	begin
		NEXT_STATE = START_DIV_MULT;
	end

	START_DIV_MULT:
	begin
		NEXT_STATE = CALC_MULT_DIV;
	end

	CALC_MULT_DIV:
	begin
		if(donediv)
		begin
			NEXT_STATE = SET_GT1;
		end
		else
		begin
			NEXT_STATE = CALC_MULT_DIV;
		end
	end

	SET_GT1:
	begin
		NEXT_STATE = SET_GT2;
	end

	SET_GT2:
	begin
		NEXT_STATE = CHECK_WHILE;
	end

	CHECK_WHILE:
	begin
		if(gt1 || gm_bin_by_mult == min_bin)
		begin
			NEXT_STATE = SET_B;
		end
		else
		begin
			NEXT_STATE = CALC_MULT_CMAX_SR;
		end
	end

	SET_B:
	begin
		NEXT_STATE = CALC_BMIN;
	end

	CALC_BMIN:
	begin
		NEXT_STATE = CALC_BMAX;
	end

	CALC_BMAX:
	begin
		NEXT_STATE = SET_BMAX;
	end

	SET_BMAX:
	begin
		NEXT_STATE = SET_BMIN;
	end

	SET_BMIN:
	begin
		NEXT_STATE = CHECK_IF_1;
	end

	CHECK_IF_1:
	begin
		if(prev_f0_bin > bmin && prev_f0_bin < bmax)
		begin
			NEXT_STATE = PRESET_THRESH_1;
		end
		else
		begin
			NEXT_STATE = PRESET_THRESH_2;
		end
	end
	
	PRESET_THRESH_1:
	begin
		NEXT_STATE = SET_THRESH_1;
	end
	
	PRESET_THRESH_2:
	begin
		NEXT_STATE = SET_THRESH_2;
	end

	SET_THRESH_1:
	begin
		NEXT_STATE = SET_LMAX_LMAX_BIN;
	end

	SET_THRESH_2:
	begin
		NEXT_STATE = SET_LMAX_LMAX_BIN;
	end

	SET_LMAX_LMAX_BIN:
	begin
		NEXT_STATE = INIT_FOR;
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_FOR_B;
	end

	CHECK_FOR_B:
	begin
		if(b <= bmax)
		begin
			NEXT_STATE = SET_ADDR_FW;
		end
		else
		begin
			NEXT_STATE = CHECK_IF_3;
		end
	end

	SET_ADDR_FW:
	begin
		NEXT_STATE = DELAY_1;
	end

	DELAY_1:
	begin
		NEXT_STATE = DELAY_2;
	end

	DELAY_2:
	begin
		NEXT_STATE = CHECK_IF_2;
	end

	CHECK_IF_2:
	begin
		NEXT_STATE = INCR_B;
	end

	INCR_B:
	begin
		NEXT_STATE = CHECK_FOR_B;
	end

	CHECK_IF_3:
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
		NEXT_STATE = DELAY_3;
	end

	DELAY_3:
	begin
		NEXT_STATE = DELAY_4;
	end

	DELAY_4:
	begin
		NEXT_STATE = GET_FW_1;
	end

	GET_FW_1:
	begin
		NEXT_STATE = SET_ADDR_FW_2;
	end

	SET_ADDR_FW_2:
	begin
		NEXT_STATE = DELAY_5;
	end

	DELAY_5:
	begin
		NEXT_STATE = DELAY_6;
	end

	DELAY_6:
	begin
		NEXT_STATE = GET_FW_2;
	end

	GET_FW_2:
	begin
		NEXT_STATE = SET_CMX_BIN;
	end

	SET_CMX_BIN:
	begin
		NEXT_STATE = INCR_MULT;
	end

	INCR_MULT:
	begin
		NEXT_STATE = START_DIV_MULT;
	end

	CALC_MULT_CMAX_SR:
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
//			gmax <= 80'h2DED36;
//			gmax_bin <= 10'h28;
//			prev_f0 <= {16'd50,16'd0};
		end

		INIT_PPM:
		begin
			mult <= 10'd2;
			min_bin <= 10'd16;
			cmax_bin <= gmax_bin;
			count <= 10'b0;
		
		end

		SET_PREV_F0_BIN:
		begin
			m1_in1 <= prev_f0;
			m1_in2 <= {16'b0,16'b0101000111101011}; // 512*5 / 8000
		end

		CALC_PREV_F0_BIN:
		begin
			prev_f0_bin <= m1_out[25:16];
		end

		START_DIV_MULT:
		begin
			div_in <= {6'b0,mult,16'b0};
			startdiv <= 1'b1;
		end

		CALC_MULT_DIV:
		begin
			startdiv <= 1'b0;
		end

		SET_GT1:
		begin
			m1_in1 <= {6'b0,gmax_bin,16'b0};
			m1_in2 <= div_ans;
			
		end

		SET_GT2:
		begin
			gt1_in1 <= m1_out;
			gt1_in2 <= {6'b0,min_bin,16'b0};
			gm_bin_by_mult <= m1_out[25:16];
		end

		CHECK_WHILE:
		begin
			
		end

		SET_B:
		begin
			b <= gm_bin_by_mult;
		//	count <= count + 10'b1;
		end

		CALC_BMIN:
		begin
			m1_in1 <= {16'b0,16'b1100110011001100};    //0.8
			m1_in2 <= {6'b0,b,16'b0};
		end

		CALC_BMAX:
		begin
			bmin <= m1_out[25:16];
			m1_in1 <= {16'b1,16'b0011001100110011};     //1.2
			m1_in2 <= {6'b0,b,16'b0};
		end

		SET_BMAX:
		begin
			if(m1_out[15:8] >= 8'b11111111)
			begin
				bmax <= m1_out[25:16] + 10'b1;
			end
			
		end

		SET_BMIN:
		begin
			if(bmin < min_bin)
			begin
				bmin <= min_bin;
			end
			
			
		end

		CHECK_IF_1:
		begin
			
		end
		
		PRESET_THRESH_1:
		begin
			ms1_in1 <= {80'b0,16'b0010011001100110}; //POINT_ONE_FIVE; 
			ms1_in2 <= {gmax,16'b0};
		end

		SET_THRESH_1:
		begin
			thresh <= ms1_out[95:16];
		end
		
		PRESET_THRESH_2:
		begin
			ms1_in1 <= {80'b0,16'b0100110011001100};  //POINT_THREE; 
			ms1_in2 <= {gmax,16'b0};
		end

		SET_THRESH_2:
		begin
			thresh <= ms1_out[95:16];
		end

		SET_LMAX_LMAX_BIN:
		begin
			lmax <= 80'b0;
			lmax_bin <= bmin;
		end

		INIT_FOR:
		begin
			b <= bmin;
			count <= bmin;
		end

		CHECK_FOR_B:
		begin
			
		end

		SET_ADDR_FW:
		begin
			addr_fw_real <= b;
			
		end

		DELAY_1:
		begin
			addr_fw_real <= b;
		end

		DELAY_2:
		begin
			addr_fw_real <= b;
		end

		CHECK_IF_2:
		begin
			if(out_fw_real > lmax)
			begin
				lmax <= out_fw_real;
				lmax_bin <= b;
				//c_fw_real <= out_fw_real;
			end
			
			/* if(b == bmax)
			begin
				//c_fw_real <= out_fw_real;
			end */
			
		end

		INCR_B:
		begin
			b <= b + 10'b1;
		end

		CHECK_IF_3:
		begin
			
		end

		SET_ADDR_FW_1:
		begin
			addr_fw_real <= lmax_bin - 10'b1;
		end

		DELAY_3:
		begin
			//addr_fw_real <= lmax_bin - 10'b1;
		end

		DELAY_4:
		begin
			//addr_fw_real <= lmax_bin - 10'b1;
		end

		GET_FW_1:
		begin
			fw1 <= out_fw_real;
		end

		SET_ADDR_FW_2:
		begin
			addr_fw_real <= lmax_bin + 10'b1;
		end

		DELAY_5:
		begin
			//addr_fw_real <= lmax_bin + 10'b1;
		end

		DELAY_6:
		begin
			//addr_fw_real <= lmax_bin + 10'b1;
		end

		GET_FW_2:
		begin
			fw2 <= out_fw_real;
		end

		SET_CMX_BIN:
		begin
			if(lmax > fw1 && lmax > fw2)
			begin
				cmax_bin <= lmax_bin;
			end
		end

		INCR_MULT:
		begin
			mult <= mult + 10'b1;
		end

		CALC_MULT_CMAX_SR:
		begin
			m1_in1 <= {6'b0,cmax_bin,16'b0};
			m1_in2 <= {16'd3,16'b0010000000000000};  //11.001   // 3.125
		end

		SET_BEST_F0:
		begin
			best_f0 <= m1_out;
			c_cmax <= cmax_bin;
			c_fw_real <= thresh;
		end

		DONE:
		begin
			doneppsm <= 1'b1;
		end

		endcase
	end

end


endmodule