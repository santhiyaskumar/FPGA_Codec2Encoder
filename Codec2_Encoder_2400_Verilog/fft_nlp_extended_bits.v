/*
* Module         - fft_nlp
* Top module     - analyse_one_frame
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue May 14 13:49:31 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform62.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module fft_nlp_extended_bits (startfft,clk,rst,in_imag_data,in_real_data,
					addr_in_imag,addr_in_real,addr_out_real,addr_out_imag,
					write_fft_real,write_fft_imag,donefft,
					check_sin,check_cos,check_sig
					);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;
			
			parameter N1 = 80;
			parameter Q1 = 16;

			input clk,rst,startfft;

			
			//output reg [N-1:0] outreal,outimag;
			output reg donefft;
			output reg [N1-1:0] check_sin,check_cos;
			output reg [N1-1:0] check_sig;
		
     	output  reg [9:0] 		addr_in_imag,addr_in_real;
        input    	[N1-1:0]	in_imag_data,in_real_data;
		
		output reg 	[9:0] 		addr_out_real,addr_out_imag;
		output  reg [N1-1:0]	write_fft_real,write_fft_imag; 
		
		
		/*  reg [9:0] addr_in_real, addr_in_imag,addr_out_real, addr_out_imag;
wire [N1-1:0] in_real_data, in_imag_data;

reg [N1-1:0] write_fft_real, write_fft_imag;
wire [N1-1:0] out_fft_real, out_fft_imag;

RAM_in_fft_real_test            in_real	   (addr_in_real,clk,,1,0,in_real_data);
RAM_in_fft_imag_test      		  in_imag	   (addr_in_imag,clk,,1,0,in_imag_data);
//
RAM_out_fft_real           fft_out_real	   (addr_out_real,clk,write_fft_real,0,1,out_fft_real);
RAM_out_fft_imag      	   fft_out_imag    (addr_out_imag,clk,write_fft_imag,0,1,out_fft_imag); */
 


//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT_FOR = 5'd1,
          CHECK_K = 5'd2,
          INIT_LOOP = 5'd3,
          INIT_FOR_2 = 5'd4,
          CHECK_T = 5'd5,
          GET_1_BY_N_1 = 5'd6,
         // GET_1_BY_N_2 = 5'd7,
          GET_1_BY_N_3 = 5'd8,
          MULT_K_T = 5'd9,
          SET_ANGLE = 5'd10,
          SET_ADDR_IN_REAL_IMAG = 5'd11,
          SET_DELAY_1 = 5'd12,
          SET_DELAY_2 = 5'd13,
          START_COSSIN = 5'd14,
          GET_IN_REAL_IMAG = 5'd15,
          ADD_IMAG_REAL_1 = 5'd16,
		    ADD_IMAG_REAL_2 = 5'd23,
          SET_IMAG_REAL = 5'd17,
          INCR_T = 5'd18,
          SET_ADDR_OUT_REAL_IMAG = 5'd19,
          SET_OUT_REAL_IMAG = 5'd20,
          INCR_K = 5'd21,
          DONE = 5'd22;

reg [4:0] STATE, NEXT_STATE;


parameter [9:0] count = 10'd512;
/* parameter [N1-1:0] 	TWO_PI_96 		= 96'b000000000000000000000000000000000000000000000000000000000000011001001000011111101101100000000000;
 */
parameter [N1-1:0] 	TWO_PI_80 		= 80'b00000000000000000000000000000000000000000000000000000000000001100100100001111110;


parameter [N-1:0] 	TWO_PI 		 = 32'b00000000000001100100100001111110;
   	

parameter [N-1:0]   ONE_BY_COUNT = 32'b00000000000000000000000010000000;


/* parameter [N1-1:0]   ONE_BY_COUNT_96 = 
96'b000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000;
 */
 
parameter [N1-1:0]   ONE_BY_COUNT_80 = 
80'b00000000000000000000000000000000000000000000000000000000000000000000000010000000;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg 			[N-1:0] 		m1_in1,m1_in2,a1_in1,a1_in2,a2_in1,a2_in2,
								lt1_in1,lt1_in2,lt2_in1,lt2_in2,
								m2_in1,m2_in2,m3_in1,m3_in2,m4_in1,m4_in2;
								
wire 			[N-1:0] 		m1_out,a1_out,m2_out,a2_out,m3_out,m4_out;

reg startcossin;
wire donecossin;
reg 	[N-1:0] beta;
wire 	[N-1:0] cos,sin;

reg startdiv;
wire donediv;
reg [N-1:0] div_in;
wire [N-1:0] div_ans;

reg [9:0] k,t;

reg [N1-1:0] sumreal,sumimag;
//reg [N-1:0] twopi_t;

reg [N-1:0] angle;

//output reg 	[N-1:0] c_cos,c_sin;

qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2     (a2_in1,a2_in2,a2_out);
qmult  			#(Q,N) 			qmult3	   (m3_in1,m3_in2,m3_out);
qmult  			#(Q,N) 			qmult4	   (m4_in1,m4_in2,m4_out);


 /* cossin_cordic */     cossine_accurate 	 cossin	   (startcossin,clk,rst,beta,cos,sin,donecossin);


fpdiv_clk  	  	 				divider	   (startdiv,clk,rst,div_in,div_ans,donediv);




reg startfmod;
reg [N-1:0] num1,num2;
wire [N-1:0] mod;
wire donefmod;

fpmodulus (startfmod,clk,rst,num1,num2,mod,donefmod);


/*-------------------96 bits modules------------------*/
reg [N1-1:0] ms1_in1,ms1_in2,
			 ms2_in1,ms2_in2,
			 ms3_in1,ms3_in2,
			 ms4_in1,ms4_in2,
			 as1_in1,as1_in2,
			 as2_in1,as2_in2;
			 
wire [N1-1:0] ms1_out,ms2_out,ms3_out,ms4_out,as1_out,as2_out;

qmult  			#(Q1,N1) 			qmult96_1	   (ms1_in1,ms1_in2,ms1_out);
qmult  			#(Q1,N1) 			qmult96_2	   (ms2_in1,ms2_in2,ms2_out);
qmult  			#(Q1,N1) 			qmult96_3	   (ms3_in1,ms3_in2,ms3_out);
qmult  			#(Q1,N1) 			qmult96_4	   (ms4_in1,ms4_in2,ms4_out);

qadd   			#(Q1,N1)			adder96_1      (as1_in1,as1_in2,as1_out);
qadd   			#(Q1,N1)			adder96_2      (as2_in1,as2_in2,as2_out);



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
		if(startfft == 1'b1)
		begin
			NEXT_STATE = INIT_FOR;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_K;
	end

	CHECK_K:
	begin
		if(k < 10'd513)
		begin
			NEXT_STATE = INIT_LOOP;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end

	INIT_LOOP:
	begin
		NEXT_STATE = INIT_FOR_2;
	end

	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_T;
	end

	CHECK_T:
	begin
		if(t <= count)
		begin
			NEXT_STATE = GET_1_BY_N_1;
		end
		else
		begin
			NEXT_STATE = SET_ADDR_OUT_REAL_IMAG;
		end
	end

	GET_1_BY_N_1:
	begin
		NEXT_STATE = GET_1_BY_N_3;
	end

	/* GET_1_BY_N_2:
	begin
		if(donediv)
		begin
			NEXT_STATE = GET_1_BY_N_3;
		end
		else
		begin
			NEXT_STATE = GET_1_BY_N_2;
		end
	end */

	GET_1_BY_N_3:
	begin
		NEXT_STATE = MULT_K_T;
	end

	MULT_K_T:
	begin
		NEXT_STATE = SET_ANGLE;
	end

	SET_ANGLE:
	begin
		NEXT_STATE = SET_ADDR_IN_REAL_IMAG;
	end

	SET_ADDR_IN_REAL_IMAG:
	begin
		NEXT_STATE = SET_DELAY_1;
	end

	SET_DELAY_1:
	begin
		NEXT_STATE = SET_DELAY_2;
	end

	SET_DELAY_2:
	begin
		NEXT_STATE = START_COSSIN;
	end

	START_COSSIN:
	begin
		if(donecossin)
		begin
			NEXT_STATE = GET_IN_REAL_IMAG;
		end
		else
		begin
			NEXT_STATE = START_COSSIN;
		end
	end

	GET_IN_REAL_IMAG:
	begin
		NEXT_STATE = ADD_IMAG_REAL_1;
	end

	ADD_IMAG_REAL_1:
	begin
		NEXT_STATE = ADD_IMAG_REAL_2;
	end
	
	ADD_IMAG_REAL_2:
	begin
		NEXT_STATE = SET_IMAG_REAL;
	end

	SET_IMAG_REAL:
	begin
		NEXT_STATE = INCR_T;
	end

	INCR_T:
	begin
		NEXT_STATE = CHECK_T;
	end

	SET_ADDR_OUT_REAL_IMAG:
	begin
		NEXT_STATE = SET_OUT_REAL_IMAG;
	end

	SET_OUT_REAL_IMAG:
	begin
		NEXT_STATE = INCR_K;
	end

	INCR_K:
	begin
		NEXT_STATE = CHECK_K;
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

		donefft <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donefft <= 1'b0;
		end

		INIT_FOR:
		begin
			k <= 10'd0;
		//	outreal <= 32'b0;
		//	outimag <= 32'b0;
		end

		CHECK_K:
		begin
			
		end

		INIT_LOOP:
		begin
			sumreal <= 80'b0;
			sumimag <= 80'b0;
		//	sign <= 4'd4;
		end

		INIT_FOR_2:
		begin
			t <= 10'd0;
			//sign <= 4'd3;
		end

		CHECK_T:
		begin
		//	sign <= 4'd2;
		end

		GET_1_BY_N_1:
		begin
			ms1_in1 <= TWO_PI_80;
			ms1_in2 <= {54'b0,t,16'b0};

		end

		GET_1_BY_N_3:
		begin
			//twopi_t <= m1_out;
			ms1_in1 <= {54'b0,k,16'b0};
			ms1_in2 <= ms1_out;
			
			
			
		end

		MULT_K_T:
		begin
			ms1_in1 <= ms1_out;
			ms1_in2 <= ONE_BY_COUNT_80;
			
			/*  if(k == 10'd1 && t== 10'd1)
			begin
				check_sig <= m1_out;
			end  */
			
		end

		SET_ANGLE:
		begin
			angle <= ms1_out[31:0];
			 if(k == 10'd511 && t == 10'd511)
			begin
				check_sig <= ms1_out;
			end  
		end

		SET_ADDR_IN_REAL_IMAG:
		begin
			addr_in_real <= t;
			addr_in_imag <= t;
		end

		SET_DELAY_1:
		begin
			
		end

		SET_DELAY_2:
		begin
			beta <= angle;
			startcossin <= 1'b1;
		end

		START_COSSIN:
		begin
			startcossin <= 1'b0;
		end

		GET_IN_REAL_IMAG:
		begin
			
			ms1_in1 <=	in_real_data;
			ms1_in2 <=	{cos[N-1],48'd0,cos[N-2:0]};
			ms2_in1 <=	{(in_real_data[N1-1] == 0)?1'b1:1'b0,in_real_data[N1-2:0]};
			ms2_in2 <=	{sin[N-1],48'd0,sin[N-2:0]};
			
			ms3_in1 <=	in_imag_data;
			ms3_in2 <=	{sin[N-1],48'd0,sin[N-2:0]};;
			ms4_in1 <=	in_imag_data;
			ms4_in2 <=	{cos[N-1],48'd0,cos[N-2:0]};;
			
	
		end

		ADD_IMAG_REAL_1:
		begin
			as1_in1 <=	ms1_out;
			as1_in2 <=	ms3_out;
			
			as2_in1 <=	ms2_out;
			as2_in2 <=	ms4_out;
			
			/* if(k == 10'd511 && t == 10'd511)
			begin
				check_cos <= cos;
				check_sin <= sin;
			end */
			
		end
		
		ADD_IMAG_REAL_2:
		begin
			as1_in1 <=	as1_out;
			as1_in2 <=	sumreal;
			 
			as2_in1 <=	as2_out;
			as2_in2 <=	sumimag;
		end

		SET_IMAG_REAL:
		begin
			sumreal <= as1_out;
			sumimag <= as2_out;
		end

		INCR_T:
		begin
			t <= t + 10'd1;
			  
		end

		SET_ADDR_OUT_REAL_IMAG:
		begin
			addr_out_real <= k;
			addr_out_imag <= k;
		end

		SET_OUT_REAL_IMAG:
		begin
			write_fft_real <= sumreal;
			write_fft_imag <= sumimag;
		end

		INCR_K:
		begin
			k <= k + 10'd1;
			/* if(k == 10'd511)
			begin
				check_sig <= sumreal;
			end  */
		end

		DONE:
		begin
			donefft <= 1'b1;
		end

		endcase
	end

end


endmodule