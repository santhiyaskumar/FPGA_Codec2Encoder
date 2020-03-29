module fft_80_bits_nlp (startfft,clk,rst,out_fft_imag,out_fft_real,
						addr_fft_imag,addr_fft_real,addr_func_fft_real_out,addr_func_fft_imag_out,
						in_func_fft_real_out,in_func_fft_imag_out,
						donefft,
						
						out_real,out_imag);

			
/* fft_nlp fft_nlp_module (startfft,clk,rst,out_sw_imag,out_sw_real,
						fft_addr_in_imag,fft_addr_in_real,fft_addr_out_real,fft_addr_out_imag,
						fft_write_fft_real,fft_write_fft_imag,
						
						donefft); */
						
						

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

			parameter N = 80;
			parameter Q = 16;

			input clk,rst,startfft;
			output reg donefft;
			
			input 			[N-1:0] 		out_fft_real,out_fft_imag;
			output reg 		[8:0] 			addr_fft_imag,addr_fft_real,addr_func_fft_real_out,addr_func_fft_imag_out;
			output reg 		[N-1:0] 		in_func_fft_real_out,in_func_fft_imag_out;
			
			  output reg [N-1:0] out_real,out_imag;
			 reg [N-1:0] clk_count_fft;
			
			
			
/* 			// -------------------- in_fft RAM -----------------------------------------//
reg 	[8:0] 		addr_fft_imag,addr_fft_real;
reg 	[N-1:0] 	in_fft_imag,in_fft_real;
wire 	[N-1:0] 	out_fft_real,out_fft_imag;

RAM_fft_real_32 	ram_fft_real	(addr_fft_real,clk,in_fft_real,1'b1,1'b0,out_fft_real);
RAM_fft_imag_32 	ram_fft_imag	(addr_fft_imag,clk,in_fft_imag,1'b1,1'b0,out_fft_imag); */



//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 6'd0,
          FOR_REV = 6'd1,
          CHECK_REV = 6'd2,
          SET_REV_ADDR = 6'd3,
          SET_REV_DATA = 6'd4,
          INCR_REV = 6'd5,
          INIT_FOR1 = 6'd6,
          CHECK_SIZE = 6'd7,
          INIT_FOR1_DATA = 6'd8,
          CHECK_I1 = 6'd9,
          INIT_FOR_J = 6'd10,
          CHECK_FOR_J = 6'd11,
          SET_ADDR_J_HALFSIZE = 6'd12,
          SET_MULT_REAL_IMAG = 6'd13,
          SET_SUM_REAL_IMAG = 6'd14,
          CALC_TEMP_1 = 6'd15,
          CALC_SUM_J_HALFSIZE = 6'd16,
          SET_DATA_J_HALFSIZE = 6'd17,
          SET_ADDR_J = 6'd18,
          SET_SUM_J_TEMP = 6'd19,
          SET_DATA_J = 6'd20,
          INCR_J_K = 6'd21,
          INCR_I1 = 6'd22,
          CHECK_SIZE_EQ_N = 6'd23,
          DOUBLE_SIZE = 6'd24,
          DONE = 6'd25,
		  SET_D1 = 6'd26,
		  SET_D2 = 6'd27,
		  SET_D3 = 6'd28,
		  SET_D4 = 6'd29,
		  SET_D5 = 6'd30,
		  SET_D6 = 6'd31,
		  SET_D7 = 6'd32,
		  SET_D8 = 6'd33,
		  SET_D9 = 6'd34,
		  SET_D10 = 6'd35,
		  FF1 = 6'd36,
		  FF2 = 6'd37,
		  FF3 = 6'd38,
		  FF4 = 6'd39,
		  SET_D11 = 6'd40,
		  SET_D12 = 6'd41,
		  FOR_OUT_I = 6'd42,
		CHECK_OUT_I = 6'd43,
		SET_OUT_ADDR = 6'd44,
		OUT_DELAY1 = 6'd45,
		OUT_DELAY2 = 6'd46,
		COPY_FUNC_TO_OUT_FFT = 6'd47,
		INCR_OUT_I = 6'd48;
		  

reg [5:0] STATE, NEXT_STATE;
reg [9:0] i,j,k,i1,size,halfsize,tablestep,out_i;
reg [N-1:0] temp_real, temp_imag;

parameter [9:0] n1 = 10'd512;

//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg 	[N-1:0] 		a1_in1,a1_in2,a2_in1,a2_in2;
wire 	[N-1:0] 		a1_out,a2_out;

reg 	[N-1:0] 		m1_in1,m1_in2,m2_in1,m2_in2,m3_in1,m3_in2,m4_in1,m4_in2;
wire 	[N-1:0] 		m1_out,m2_out,m3_out,m4_out;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qmult  			#(Q,N) 			qmult3	   (m3_in1,m3_in2,m3_out);
qmult  			#(Q,N) 			qmult4	   (m4_in1,m4_in2,m4_out);

qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
qadd   			#(Q,N)			adder2     (a2_in1,a2_in2,a2_out);

//---------------------- sin cos ROM --------------------------------------//
reg 	[7:0] 			addr_sin,addr_cos;
wire 	[15:0]			sin_data,cos_data;

RAM_sin_256 					ram_sin	   (addr_sin,clk,1'b1,sin_data);
RAM_cos_256 					ram_cos	   (addr_cos,clk,1'b1,cos_data);

/* // -------------------- in_fft RAM -----------------------------------------//
reg 	[8:0] 		addr_fft_imag,addr_fft_real;
reg 	[N-1:0] 	in_fft_imag,in_fft_real;
wire 	[N-1:0] 	out_fft_real,out_fft_imag;

RAM_fft_real_32 	ram_fft_real	(addr_fft_real,clk,in_fft_real,1'b1,1'b0,out_fft_real);
RAM_fft_imag_32 	ram_fft_imag	(addr_fft_imag,clk,in_fft_imag,1'b1,1'b0,out_fft_imag);   */

// ------------------------ fft used in func - output also -----------------------//
reg 	[8:0] 		addr_func_fft_real,addr_func_fft_imag;
reg 	[N-1:0] 	in_func_fft_imag,in_func_fft_real;
reg 				rden,wren;
wire 	[N-1:0] 	out_func_fft_imag,out_func_fft_real;

RAM_func_fft_real80 ram_fft_func_real  (addr_func_fft_real,clk,in_func_fft_real,rden,wren,out_func_fft_real);
RAM_func_fft_imag80 ram_fft_func_imag  (addr_func_fft_imag,clk,in_func_fft_imag,rden,wren,out_func_fft_imag);
 



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
		if(startfft)
		begin
			NEXT_STATE = FOR_REV;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	FOR_REV:
	begin
		NEXT_STATE = CHECK_REV;
	end

	CHECK_REV:
	begin
		if(i < n1)
		begin
			NEXT_STATE = SET_REV_ADDR;
		end
		else
		begin
			NEXT_STATE = INIT_FOR1;
		end
	end

	SET_REV_ADDR:
	begin
		NEXT_STATE = SET_D1;
	end
	
	SET_D1:
	begin
		NEXT_STATE = SET_D2;
	end
	
	SET_D2:
	begin
		NEXT_STATE = SET_REV_DATA;
	end

	SET_REV_DATA:
	begin
		NEXT_STATE = INCR_REV;
	end

	INCR_REV:
	begin
		NEXT_STATE = CHECK_REV;
	end

	INIT_FOR1:
	begin
		NEXT_STATE = CHECK_SIZE;
	end

	CHECK_SIZE:
	begin
		if(size <= n1)
		begin
			NEXT_STATE = INIT_FOR1_DATA;
		end
		else
		begin
			NEXT_STATE = FOR_OUT_I;// DONE;
		end
	end

	INIT_FOR1_DATA:
	begin
		NEXT_STATE = CHECK_I1;
	end

	CHECK_I1:
	begin
		if(i1 < n1)
		begin
			NEXT_STATE = INIT_FOR_J;
		end
		else
		begin
			NEXT_STATE = CHECK_SIZE_EQ_N;
		end
	end

	INIT_FOR_J:
	begin
		NEXT_STATE = CHECK_FOR_J;
	end

	CHECK_FOR_J:
	begin
		if(j < i1 + halfsize)
		begin
			NEXT_STATE = SET_ADDR_J_HALFSIZE;
		end
		else
		begin
			NEXT_STATE = INCR_I1;
		end
	end

	SET_ADDR_J_HALFSIZE:
	begin
		NEXT_STATE = SET_D3;
	end
	
	SET_D3:
	begin
		NEXT_STATE = SET_D4;
	end
	
	SET_D4:
	begin
		NEXT_STATE = SET_MULT_REAL_IMAG;
	end

	SET_MULT_REAL_IMAG:
	begin
		NEXT_STATE = SET_SUM_REAL_IMAG;
	end

	SET_SUM_REAL_IMAG:
	begin
		NEXT_STATE = CALC_TEMP_1;
	end

	CALC_TEMP_1:
	begin
		NEXT_STATE = SET_D5;
	end
	
	SET_D5:
	begin
		NEXT_STATE = SET_D6;
	end
	
	SET_D6:
	begin
		NEXT_STATE = CALC_SUM_J_HALFSIZE;
	end

	CALC_SUM_J_HALFSIZE:
	begin
		NEXT_STATE = SET_D7;
	end
	
	SET_D7:
	begin
		NEXT_STATE = SET_D8;	
	end
	
	SET_D8:
	begin
		NEXT_STATE = SET_DATA_J_HALFSIZE;
	end
		
	SET_DATA_J_HALFSIZE:
	begin
		NEXT_STATE = SET_ADDR_J;
	end

	SET_ADDR_J:
	begin
		NEXT_STATE = SET_D9;
	end
	
	SET_D9:
	begin
		NEXT_STATE = SET_D10;
	end
	
	SET_D10:
	begin
		NEXT_STATE = SET_SUM_J_TEMP;
	end
		
	SET_SUM_J_TEMP:
	begin
		NEXT_STATE = SET_D11;
	end
	
	SET_D11:
	begin
		NEXT_STATE = SET_D12;
	end
	
	SET_D12:
	begin
		NEXT_STATE = SET_DATA_J;
	end

	SET_DATA_J:
	begin
		NEXT_STATE = INCR_J_K;
	end

	INCR_J_K:
	begin
		NEXT_STATE = CHECK_FOR_J;
	end

	INCR_I1:
	begin
		NEXT_STATE = CHECK_I1;
	end

	CHECK_SIZE_EQ_N:
	begin
		if(size == n1)
		begin
			NEXT_STATE = FOR_OUT_I; //DONE;
		end
		else
		begin
			NEXT_STATE = DOUBLE_SIZE;
		end
	end

	DOUBLE_SIZE:
	begin
		NEXT_STATE = CHECK_SIZE;
	end
	
	FOR_OUT_I:
	begin
		NEXT_STATE = CHECK_OUT_I;
	end

	CHECK_OUT_I:
	begin
		if(out_i < 10'd512)
		begin
			NEXT_STATE = SET_OUT_ADDR;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end
	
	SET_OUT_ADDR:
	begin
		NEXT_STATE = OUT_DELAY1;
	end
	
	OUT_DELAY1:
	begin
		NEXT_STATE = OUT_DELAY2;
	end
	
	OUT_DELAY2:
	begin
		NEXT_STATE = COPY_FUNC_TO_OUT_FFT;
	end
	
	COPY_FUNC_TO_OUT_FFT:
	begin
		NEXT_STATE = INCR_OUT_I;
	end
	
	INCR_OUT_I:
	begin
		NEXT_STATE = CHECK_OUT_I;
	end
	
	DONE:
	begin
		NEXT_STATE = FF1; //START; //DONE; //;
	end
	
	FF1:
	begin
		NEXT_STATE = FF2;
	end
	
	FF2:
	begin
		NEXT_STATE = FF3;
	end
	
	FF3:
	begin
		NEXT_STATE = FF4;
	end
	
	FF4:
	begin
		NEXT_STATE = START;//FF4;
	end
	
	

	default:
	begin
		NEXT_STATE =START; // DONE;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		donefft <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			clk_count_fft <= 32'b1;
			donefft <= 1'b0;
		end

		FOR_REV:
		begin
			i <= 10'd0;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CHECK_REV:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		SET_REV_ADDR:
		begin
			addr_fft_real <= i;
			addr_fft_imag <= i;
			addr_func_fft_real <= {i[0],i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8]};
			addr_func_fft_imag <= {i[0],i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8]};
			rden <= 1'b0;
			wren <= 1'b1;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

	//delay
	
		SET_D1:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D2:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_REV_DATA:
		begin
			in_func_fft_real <= out_fft_real;
			in_func_fft_imag <= out_fft_imag;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		INCR_REV:
		begin
			i <= i + 10'd1;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		INIT_FOR1:
		begin
			//level <= 10'd9;
			size <= 10'd2;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CHECK_SIZE:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
			
		end

		INIT_FOR1_DATA:
		begin
			halfsize <= size >> 1;
		//	tablestep <= n1 >> size;
			case (size)
			
			10'd2:	tablestep <= 10'd256;
			10'd4:	tablestep <= 10'd128;
			10'd8:	tablestep <= 10'd64;
			10'd16:	tablestep <= 10'd32;
			10'd32: tablestep <= 10'd16;
			10'd64: tablestep <= 10'd8;
			10'd128: tablestep <= 10'd4;
			10'd256: tablestep <= 10'd2;
			default: tablestep <= 10'd1;
			
			endcase
			i1 <= 10'd0;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CHECK_I1:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		INIT_FOR_J:
		begin
			j <= i1;
			k <= 10'd0;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CHECK_FOR_J:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		SET_ADDR_J_HALFSIZE:
		begin
			addr_func_fft_real <= j + halfsize;
			addr_func_fft_imag <= j + halfsize;
			rden <= 1'b1;
			wren <= 1'b0;
			
			addr_cos <= k;
			addr_sin <= k;
			
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end


		//delay
		
		SET_D3:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D4:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_MULT_REAL_IMAG:
		begin
			m1_in1 <= out_func_fft_real;
			m1_in2 <= {cos_data[15],62'b0,cos_data[14:0],2'b0};
			m2_in1 <= out_func_fft_imag;
			m2_in2 <= {sin_data[15],62'b0,sin_data[14:0],2'b0};
			
			m3_in1 <= out_func_fft_real;
			m3_in2 <= {sin_data[15],62'b0,sin_data[14:0],2'b0};
			m4_in1 <= out_func_fft_imag;
			m4_in2 <= {cos_data[15],62'b0,cos_data[14:0],2'b0};
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		SET_SUM_REAL_IMAG:
		begin
			a1_in1 <= m1_out;
			a1_in2 <= {(m2_out[N-1] == 0)?1'b1:1'b0,m2_out[N-2:0]};
			
			a2_in1 <= m3_out;
			a2_in2 <= m4_out;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CALC_TEMP_1:
		begin
			temp_real <= a1_out;
			temp_imag <= a2_out;
			
			addr_func_fft_real <= j;
			addr_func_fft_imag <= j;
			rden <= 1'b1;
			wren <= 1'b0;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		//delay
		
		SET_D5:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D6:
		begin	
			clk_count_fft <= clk_count_fft + 32'b1;
		end	
		
		CALC_SUM_J_HALFSIZE:
		begin
			a1_in1 <= out_func_fft_real;
			a1_in2 <= {(temp_real[N-1] == 0)?1'b1:1'b0,temp_real[N-2:0]};
			
			a2_in1 <= out_func_fft_imag;
			a2_in2 <= {(temp_imag[N-1] == 0)?1'b1:1'b0,temp_imag[N-2:0]};
			
			addr_func_fft_real <= j + halfsize;
			addr_func_fft_imag <= j + halfsize;
			wren <= 1'b1;
			rden <= 1'b0;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		//delay
		
		SET_D7:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D8:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_DATA_J_HALFSIZE:
		begin
			in_func_fft_real <= a1_out;
			in_func_fft_imag <= a2_out;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		SET_ADDR_J:
		begin
			addr_func_fft_real <= j;
			addr_func_fft_imag <= j;
			rden <= 1'b1;
			wren <= 1'b0;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		//delay
		
		SET_D9:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D10:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		
		SET_SUM_J_TEMP:
		begin
			a1_in1 <= out_func_fft_real;
			a1_in2 <= temp_real;
			
			a2_in1 <= out_func_fft_imag;
			a2_in2 <= temp_imag;
			wren <= 1'b1;
			rden <= 1'b0;
			
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D11:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_D12:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		SET_DATA_J:
		begin
			in_func_fft_real <= a1_out;
			in_func_fft_imag <= a2_out;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		INCR_J_K:
		begin
			j <= j + 10'd1;
			k <= k + tablestep;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		INCR_I1:
		begin
			i1 <= i1 + size;
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		CHECK_SIZE_EQ_N:
		begin
			clk_count_fft <= clk_count_fft + 32'b1;
		end

		DOUBLE_SIZE:
		begin
			size <= size << 1;
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		FOR_OUT_I:
		begin
			out_i <= 10'b0;
		end

		CHECK_OUT_I:
		begin
			
		end
		
		SET_OUT_ADDR:
		begin
			addr_func_fft_real_out <= out_i;
			addr_func_fft_imag_out <= out_i;
			
			addr_func_fft_real <= out_i;
			addr_func_fft_imag <= out_i;
			rden <= 1'b1;
			wren <= 1'b0;
			
			
		end
		
		OUT_DELAY1:
		begin
		
		end
		
		OUT_DELAY2:
		begin
		
		end
				
		COPY_FUNC_TO_OUT_FFT:
		begin
			in_func_fft_real_out <= out_func_fft_real;
			in_func_fft_imag_out <= out_func_fft_imag;
		end
		
		INCR_OUT_I:
		begin
			out_i <= out_i + 10'b1;
		end

		DONE:
		begin
			//donefft <= 1'b1;
			clk_count_fft <= clk_count_fft + 32'b1;
		end
		
		FF1:
		begin
			addr_func_fft_real <= 10'd1;
			addr_func_fft_imag <= 10'd1;
			rden <= 1'b1;
			wren <= 1'b0;
		end
		
		FF2:
		begin
			
		end
		
		FF3:
		begin
			
		end
		
		FF4:
		begin
			donefft <= 1'b1;
			out_real <= out_func_fft_real;
			out_imag <= out_func_fft_imag;
		end

		endcase
	end

end


endmodule