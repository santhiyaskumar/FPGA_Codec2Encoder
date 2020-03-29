  module analyse_one_frame (	startaof,clk,rst,
							//--- input------------------ 
							 mem_x_in,mem_y_in ,in_prev_f0, out_sn ,out_mem_fir,out_sq, 
							//--------------------------- 
							
							//--- output----------------------------------------------------------- 
						      mem_x_out,mem_y_out,out_prev_f0,out_best_f0,aof_w0_out,voiced_bit, addr_sn,addr_mem_fir,in_mem_fir, nlp_pitch, read_fir,write_fir ,
							 
							  addr_nlp_sq,in_sq ,read_sq,write_sq, 
							//--------------------------------------------------------------------- 
							 doneaof 
							 
							 );  
							 
							 

	parameter N = 32;
	parameter Q = 16;
	
	parameter N1 = 80;
	parameter Q1 = 16;
			
	input clk,rst,startaof;
	input   [N1-1:0] mem_x_in,mem_y_in;
	input   [N-1:0] out_sn;
	input 	[N-1:0] in_prev_f0;
	input   [N1-1:0] out_mem_fir,out_sq;
	
	output reg voiced_bit,doneaof,read_fir,write_fir,read_sq,write_sq;	
	output reg [N1-1:0] mem_x_out,mem_y_out;
	output reg [N-1:0] out_prev_f0,aof_w0_out,nlp_pitch;
	output reg [9:0] addr_sn,addr_mem_fir,addr_nlp_sq;
	output reg [N-1:0] aof_check_i; 
	 
	
	/***---------------------For Module Test--------------***/
	
	
 	   /* module analyse_one_frame (	startaof,clk,rst,
							//--- input------------------ /
							 mem_x_in,mem_y_in ,in_prev_f0, 
							//--------------------------- /
							
							//--- output----------------------------------------------------------- /
						      mem_x_out,mem_y_out,out_prev_f0,out_best_f0,aof_w0_out,voiced_bit, nlp_pitch ,
							 
							   
							//--------------------------------------------------------------------- /
							 doneaof ,c_cmax // , c_w0,c_w1, c_cmax,c_outreal,aof_check_in_real,aof_check_in_imag 
							 
							 ); 
							 
	parameter N = 32;
	parameter Q = 16;
	parameter N1 = 80;
	parameter Q1 = 16;

	input clk,rst,startaof;
	input   [N1-1:0] mem_x_in,mem_y_in;
	input 	[N-1:0] in_prev_f0;
	
	output reg voiced_bit,doneaof;	
	output reg [N1-1:0] mem_x_out,mem_y_out;
	reg [N1-1:0] c_outreal,aof_check_in_real,aof_check_in_imag;
	output reg [N-1:0] out_prev_f0,aof_w0_out,nlp_pitch;
	reg [N-1:0] c_w0,c_w1;
	output  reg [9:0] c_cmax;
	reg [9:0] aof_check_i;
	
	// RAM Sn
	reg [9:0] addr_sn;
	wire [N-1:0] out_sn;
	RAM_c2_sn_test_nlp c2_sn (addr_sn,clk,,1,0,out_sn); 

	// RAM_nlp_mem_fir - size 48 -------------------
	 reg [9:0] addr_mem_fir;
	 reg [N1-1:0] in_mem_fir;
	 reg read_fir, write_fir;
	 wire [N1-1:0] out_mem_fir;					 
	 RAM_nlp_mem_fir_80  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	

	// RAM_nlp_sq - size 320 --------------------
	 reg [9:0] addr_nlp_sq;
	 reg [N1-1:0] in_sq;
	 reg read_sq,write_sq;
	 wire [N1-1:0] out_sq;
	 RAM_nlp_sq_80    nlp_sq	   (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);	    
  */


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------


//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 8'd3,
          INIT_FOR_1 = 8'd11,
          CHECK_I_1 = 8'd21,
          SET_ADDR_SN_1 = 8'd0,
          SET_DELAY1 = 8'd4,
          SET_DELAY2 = 8'd5,
          SET_MULT_1 = 8'd6,
          SET_SW_REAL_1 = 8'd7,
          INCR_I_1 = 8'd8,
          INIT_FOR_2 = 8'd9,
          CHECK_I_2 = 8'd10,
          SET_ADDR_SN_2 = 8'd1,
          SET_DELAY3 = 8'd12,
          SET_DELAY4 = 8'd13,
          SET_MULT_2 = 8'd14,
          SET_SW_REAL_2 = 8'd15,
          INCR_I_2 = 8'd16,
          DONE = 8'd17,
		  START_DFT = 8'd18,
		  RUN_DFT = 8'd19,
		  START_NLP = 8'd20,
		  RUN_NLP = 8'd2,
		  GET_NLP = 8'd22,
		  START_TSPR = 8'd23,
		  RUN_TSPR = 8'd24,
		  GET_TSPR = 8'd25,
		  START_EA = 8'd26, 
		  RUN_EA = 8'd27,
		  GET_EA = 8'd28,
		  START_EVM = 8'd29,
		  RUN_EVM = 8'd30,
		  GET_EVM = 8'd31,
		  CALC_DIV_PITCH = 8'd32,
		  SET_DIV_PITCH = 8'd33,
		  CALC_WO = 8'd34,
		  CALC_DIV_WO = 8'd35,
		  SET_DIV_WO = 8'd36,
		  CALC_L = 8'd37;
		  
reg [7:0] STATE, NEXT_STATE;

parameter [9:0] mpitch = 10'd320,
				mpitch_by_2 = 10'd160,
				nw = 10'd279,
				nw_by_2 = 10'd139,
				fft_enc = 10'd512;
				
parameter [N-1:0] 	PI		 = 32'b00000000000000110010010000111111,
					TWO_PI	 = 32'b00000000000001100100100001111110;
				
parameter [N-1:0] 	w0  = 32'b00000000000000000000000000000000,
					w1  = 32'b00000000000000000000000000000000,
					w2  = 32'b00000000000000000000000000000000,
					w3  = 32'b00000000000000000000000000000000,
					w4  = 32'b00000000000000000000000000000000,
					w5  = 32'b00000000000000000000000000000000,
					w6  = 32'b00000000000000000000000000000000,
					w7  = 32'b00000000000000000000000000000000,
					w8  = 32'b00000000000000000000000000000000,
					w9  = 32'b00000000000000000000000000000000,
					w10  = 32'b00000000000000000000000000000000,
					w11  = 32'b00000000000000000000000000000000,
					w12  = 32'b00000000000000000000000000000000,
					w13  = 32'b00000000000000000000000000000000,
					w14  = 32'b00000000000000000000000000000000,
					w15  = 32'b00000000000000000000000000000000,
					w16  = 32'b00000000000000000000000000000000,
					w17  = 32'b00000000000000000000000000000000,
					w18  = 32'b00000000000000000000000000000000,
					w19  = 32'b00000000000000000000000000000000,
					w20  = 32'b00000000000000000000000000000000,
					w21  = 32'b00000000000000000000000000000000,
					w22  = 32'b00000000000000000000000000000000,
					w23  = 32'b00000000000000000000000000000000,
					w24  = 32'b00000000000000000000000000000000,
					w25  = 32'b00000000000000000000000000000000,
					w26  = 32'b00000000000000000000000000000000,
					w27  = 32'b00000000000000000000000000000001,
					w28  = 32'b00000000000000000000000000000001,
					w29  = 32'b00000000000000000000000000000010,
					w30  = 32'b00000000000000000000000000000010,
					w31  = 32'b00000000000000000000000000000011,
					w32  = 32'b00000000000000000000000000000100,
					w33  = 32'b00000000000000000000000000000101,
					w34  = 32'b00000000000000000000000000000110,
					w35  = 32'b00000000000000000000000000000111,
					w36  = 32'b00000000000000000000000000001000,
					w37  = 32'b00000000000000000000000000001001,
					w38  = 32'b00000000000000000000000000001010,
					w39  = 32'b00000000000000000000000000001011,
					w40  = 32'b00000000000000000000000000001100,
					w41  = 32'b00000000000000000000000000001110,
					w42  = 32'b00000000000000000000000000001111,
					w43  = 32'b00000000000000000000000000010001,
					w44  = 32'b00000000000000000000000000010010,
					w45  = 32'b00000000000000000000000000010100,
					w46  = 32'b00000000000000000000000000010110,
					w47  = 32'b00000000000000000000000000010111,
					w48  = 32'b00000000000000000000000000011001,
					w49  = 32'b00000000000000000000000000011011,
					w50  = 32'b00000000000000000000000000011101,
					w51  = 32'b00000000000000000000000000011111,
					w52  = 32'b00000000000000000000000000100001,
					w53  = 32'b00000000000000000000000000100011,
					w54  = 32'b00000000000000000000000000100101,
					w55  = 32'b00000000000000000000000000100111,
					w56  = 32'b00000000000000000000000000101010,
					w57  = 32'b00000000000000000000000000101100,
					w58  = 32'b00000000000000000000000000101110,
					w59  = 32'b00000000000000000000000000110001,
					w60  = 32'b00000000000000000000000000110011,
					w61  = 32'b00000000000000000000000000110110,
					w62  = 32'b00000000000000000000000000111000,
					w63  = 32'b00000000000000000000000000111011,
					w64  = 32'b00000000000000000000000000111101,
					w65  = 32'b00000000000000000000000001000000,
					w66  = 32'b00000000000000000000000001000011,
					w67  = 32'b00000000000000000000000001000101,
					w68  = 32'b00000000000000000000000001001000,
					w69  = 32'b00000000000000000000000001001011,
					w70  = 32'b00000000000000000000000001001110,
					w71  = 32'b00000000000000000000000001010001,
					w72  = 32'b00000000000000000000000001010100,
					w73  = 32'b00000000000000000000000001010111,
					w74  = 32'b00000000000000000000000001011010,
					w75  = 32'b00000000000000000000000001011101,
					w76  = 32'b00000000000000000000000001100000,
					w77  = 32'b00000000000000000000000001100011,
					w78  = 32'b00000000000000000000000001100110,
					w79  = 32'b00000000000000000000000001101001,
					w80  = 32'b00000000000000000000000001101100,
					w81  = 32'b00000000000000000000000001101111,
					w82  = 32'b00000000000000000000000001110010,
					w83  = 32'b00000000000000000000000001110101,
					w84  = 32'b00000000000000000000000001111001,
					w85  = 32'b00000000000000000000000001111100,
					w86  = 32'b00000000000000000000000001111111,
					w87  = 32'b00000000000000000000000010000010,
					w88  = 32'b00000000000000000000000010000101,
					w89  = 32'b00000000000000000000000010001001,
					w90  = 32'b00000000000000000000000010001100,
					w91  = 32'b00000000000000000000000010001111,
					w92  = 32'b00000000000000000000000010010010,
					w93  = 32'b00000000000000000000000010010101,
					w94  = 32'b00000000000000000000000010011001,
					w95  = 32'b00000000000000000000000010011100,
					w96  = 32'b00000000000000000000000010011111,
					w97  = 32'b00000000000000000000000010100010,
					w98  = 32'b00000000000000000000000010100101,
					w99  = 32'b00000000000000000000000010101000,
					w100  = 32'b00000000000000000000000010101100,
					w101  = 32'b00000000000000000000000010101111,
					w102  = 32'b00000000000000000000000010110010,
					w103  = 32'b00000000000000000000000010110101,
					w104  = 32'b00000000000000000000000010111000,
					w105  = 32'b00000000000000000000000010111011,
					w106  = 32'b00000000000000000000000010111110,
					w107  = 32'b00000000000000000000000011000001,
					w108  = 32'b00000000000000000000000011000100,
					w109  = 32'b00000000000000000000000011000111,
					w110  = 32'b00000000000000000000000011001010,
					w111  = 32'b00000000000000000000000011001101,
					w112  = 32'b00000000000000000000000011010000,
					w113  = 32'b00000000000000000000000011010010,
					w114  = 32'b00000000000000000000000011010101,
					w115  = 32'b00000000000000000000000011011000,
					w116  = 32'b00000000000000000000000011011011,
					w117  = 32'b00000000000000000000000011011101,
					w118  = 32'b00000000000000000000000011100000,
					w119  = 32'b00000000000000000000000011100011,
					w120  = 32'b00000000000000000000000011100101,
					w121  = 32'b00000000000000000000000011101000,
					w122  = 32'b00000000000000000000000011101010,
					w123  = 32'b00000000000000000000000011101100,
					w124  = 32'b00000000000000000000000011101111,
					w125  = 32'b00000000000000000000000011110001,
					w126  = 32'b00000000000000000000000011110011,
					w127  = 32'b00000000000000000000000011110110,
					w128  = 32'b00000000000000000000000011111000,
					w129  = 32'b00000000000000000000000011111010,
					w130  = 32'b00000000000000000000000011111100,
					w131  = 32'b00000000000000000000000011111110,
					w132  = 32'b00000000000000000000000100000000,
					w133  = 32'b00000000000000000000000100000010,
					w134  = 32'b00000000000000000000000100000011,
					w135  = 32'b00000000000000000000000100000101,
					w136  = 32'b00000000000000000000000100000111,
					w137  = 32'b00000000000000000000000100001000,
					w138  = 32'b00000000000000000000000100001010,
					w139  = 32'b00000000000000000000000100001011,
					w140  = 32'b00000000000000000000000100001101,
					w141  = 32'b00000000000000000000000100001110,
					w142  = 32'b00000000000000000000000100010000,
					w143  = 32'b00000000000000000000000100010001,
					w144  = 32'b00000000000000000000000100010010,
					w145  = 32'b00000000000000000000000100010011,
					w146  = 32'b00000000000000000000000100010100,
					w147  = 32'b00000000000000000000000100010101,
					w148  = 32'b00000000000000000000000100010110,
					w149  = 32'b00000000000000000000000100010111,
					w150  = 32'b00000000000000000000000100011000,
					w151  = 32'b00000000000000000000000100011000,
					w152  = 32'b00000000000000000000000100011001,
					w153  = 32'b00000000000000000000000100011001,
					w154  = 32'b00000000000000000000000100011010,
					w155  = 32'b00000000000000000000000100011010,
					w156  = 32'b00000000000000000000000100011011,
					w157  = 32'b00000000000000000000000100011011,
					w158  = 32'b00000000000000000000000100011011,
					w159  = 32'b00000000000000000000000100011011,
					w160  = 32'b00000000000000000000000100011011,
					w161  = 32'b00000000000000000000000100011011,
					w162  = 32'b00000000000000000000000100011011,
					w163  = 32'b00000000000000000000000100011011,
					w164  = 32'b00000000000000000000000100011011,
					w165  = 32'b00000000000000000000000100011010,
					w166  = 32'b00000000000000000000000100011010,
					w167  = 32'b00000000000000000000000100011001,
					w168  = 32'b00000000000000000000000100011001,
					w169  = 32'b00000000000000000000000100011000,
					w170  = 32'b00000000000000000000000100011000,
					w171  = 32'b00000000000000000000000100010111,
					w172  = 32'b00000000000000000000000100010110,
					w173  = 32'b00000000000000000000000100010101,
					w174  = 32'b00000000000000000000000100010100,
					w175  = 32'b00000000000000000000000100010011,
					w176  = 32'b00000000000000000000000100010010,
					w177  = 32'b00000000000000000000000100010001,
					w178  = 32'b00000000000000000000000100010000,
					w179  = 32'b00000000000000000000000100001110,
					w180  = 32'b00000000000000000000000100001101,
					w181  = 32'b00000000000000000000000100001011,
					w182  = 32'b00000000000000000000000100001010,
					w183  = 32'b00000000000000000000000100001000,
					w184  = 32'b00000000000000000000000100000111,
					w185  = 32'b00000000000000000000000100000101,
					w186  = 32'b00000000000000000000000100000011,
					w187  = 32'b00000000000000000000000100000010,
					w188  = 32'b00000000000000000000000100000000,
					w189  = 32'b00000000000000000000000011111110,
					w190  = 32'b00000000000000000000000011111100,
					w191  = 32'b00000000000000000000000011111010,
					w192  = 32'b00000000000000000000000011111000,
					w193  = 32'b00000000000000000000000011110110,
					w194  = 32'b00000000000000000000000011110011,
					w195  = 32'b00000000000000000000000011110001,
					w196  = 32'b00000000000000000000000011101111,
					w197  = 32'b00000000000000000000000011101100,
					w198  = 32'b00000000000000000000000011101010,
					w199  = 32'b00000000000000000000000011101000,
					w200  = 32'b00000000000000000000000011100101,
					w201  = 32'b00000000000000000000000011100011,
					w202  = 32'b00000000000000000000000011100000,
					w203  = 32'b00000000000000000000000011011101,
					w204  = 32'b00000000000000000000000011011011,
					w205  = 32'b00000000000000000000000011011000,
					w206  = 32'b00000000000000000000000011010101,
					w207  = 32'b00000000000000000000000011010010,
					w208  = 32'b00000000000000000000000011010000,
					w209  = 32'b00000000000000000000000011001101,
					w210  = 32'b00000000000000000000000011001010,
					w211  = 32'b00000000000000000000000011000111,
					w212  = 32'b00000000000000000000000011000100,
					w213  = 32'b00000000000000000000000011000001,
					w214  = 32'b00000000000000000000000010111110,
					w215  = 32'b00000000000000000000000010111011,
					w216  = 32'b00000000000000000000000010111000,
					w217  = 32'b00000000000000000000000010110101,
					w218  = 32'b00000000000000000000000010110010,
					w219  = 32'b00000000000000000000000010101111,
					w220  = 32'b00000000000000000000000010101100,
					w221  = 32'b00000000000000000000000010101000,
					w222  = 32'b00000000000000000000000010100101,
					w223  = 32'b00000000000000000000000010100010,
					w224  = 32'b00000000000000000000000010011111,
					w225  = 32'b00000000000000000000000010011100,
					w226  = 32'b00000000000000000000000010011001,
					w227  = 32'b00000000000000000000000010010101,
					w228  = 32'b00000000000000000000000010010010,
					w229  = 32'b00000000000000000000000010001111,
					w230  = 32'b00000000000000000000000010001100,
					w231  = 32'b00000000000000000000000010001001,
					w232  = 32'b00000000000000000000000010000101,
					w233  = 32'b00000000000000000000000010000010,
					w234  = 32'b00000000000000000000000001111111,
					w235  = 32'b00000000000000000000000001111100,
					w236  = 32'b00000000000000000000000001111001,
					w237  = 32'b00000000000000000000000001110101,
					w238  = 32'b00000000000000000000000001110010,
					w239  = 32'b00000000000000000000000001101111,
					w240  = 32'b00000000000000000000000001101100,
					w241  = 32'b00000000000000000000000001101001,
					w242  = 32'b00000000000000000000000001100110,
					w243  = 32'b00000000000000000000000001100011,
					w244  = 32'b00000000000000000000000001100000,
					w245  = 32'b00000000000000000000000001011101,
					w246  = 32'b00000000000000000000000001011010,
					w247  = 32'b00000000000000000000000001010111,
					w248  = 32'b00000000000000000000000001010100,
					w249  = 32'b00000000000000000000000001010001,
					w250  = 32'b00000000000000000000000001001110,
					w251  = 32'b00000000000000000000000001001011,
					w252  = 32'b00000000000000000000000001001000,
					w253  = 32'b00000000000000000000000001000101,
					w254  = 32'b00000000000000000000000001000011,
					w255  = 32'b00000000000000000000000001000000,
					w256  = 32'b00000000000000000000000000111101,
					w257  = 32'b00000000000000000000000000111011,
					w258  = 32'b00000000000000000000000000111000,
					w259  = 32'b00000000000000000000000000110110,
					w260  = 32'b00000000000000000000000000110011,
					w261  = 32'b00000000000000000000000000110001,
					w262  = 32'b00000000000000000000000000101110,
					w263  = 32'b00000000000000000000000000101100,
					w264  = 32'b00000000000000000000000000101010,
					w265  = 32'b00000000000000000000000000100111,
					w266  = 32'b00000000000000000000000000100101,
					w267  = 32'b00000000000000000000000000100011,
					w268  = 32'b00000000000000000000000000100001,
					w269  = 32'b00000000000000000000000000011111,
					w270  = 32'b00000000000000000000000000011101,
					w271  = 32'b00000000000000000000000000011011,
					w272  = 32'b00000000000000000000000000011001,
					w273  = 32'b00000000000000000000000000010111,
					w274  = 32'b00000000000000000000000000010110,
					w275  = 32'b00000000000000000000000000010100,
					w276  = 32'b00000000000000000000000000010010,
					w277  = 32'b00000000000000000000000000010001,
					w278  = 32'b00000000000000000000000000001111,
					w279  = 32'b00000000000000000000000000001110,
					w280  = 32'b00000000000000000000000000001100,
					w281  = 32'b00000000000000000000000000001011,
					w282  = 32'b00000000000000000000000000001010,
					w283  = 32'b00000000000000000000000000001001,
					w284  = 32'b00000000000000000000000000001000,
					w285  = 32'b00000000000000000000000000000111,
					w286  = 32'b00000000000000000000000000000110,
					w287  = 32'b00000000000000000000000000000101,
					w288  = 32'b00000000000000000000000000000100,
					w289  = 32'b00000000000000000000000000000011,
					w290  = 32'b00000000000000000000000000000010,
					w291  = 32'b00000000000000000000000000000010,
					w292  = 32'b00000000000000000000000000000001,
					w293  = 32'b00000000000000000000000000000001,
					w294  = 32'b00000000000000000000000000000000,
					w295  = 32'b00000000000000000000000000000000,
					w296  = 32'b00000000000000000000000000000000,
					w297  = 32'b00000000000000000000000000000000,
					w298  = 32'b00000000000000000000000000000000,
					w299  = 32'b00000000000000000000000000000000,
					w300  = 32'b00000000000000000000000000000000,
					w301  = 32'b00000000000000000000000000000000,
					w302  = 32'b00000000000000000000000000000000,
					w303  = 32'b00000000000000000000000000000000,
					w304  = 32'b00000000000000000000000000000000,
					w305  = 32'b00000000000000000000000000000000,
					w306  = 32'b00000000000000000000000000000000,
					w307  = 32'b00000000000000000000000000000000,
					w308  = 32'b00000000000000000000000000000000,
					w309  = 32'b00000000000000000000000000000000,
					w310  = 32'b00000000000000000000000000000000,
					w311  = 32'b00000000000000000000000000000000,
					w312  = 32'b00000000000000000000000000000000,
					w313  = 32'b00000000000000000000000000000000,
					w314  = 32'b00000000000000000000000000000000,
					w315  = 32'b00000000000000000000000000000000,
					w316  = 32'b00000000000000000000000000000000,
					w317  = 32'b00000000000000000000000000000000,
					w318  = 32'b00000000000000000000000000000000,
					w319  = 32'b00000000000000000000000000000000;


reg [9:0] i;

				
//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------
	  reg  [N-1:0] 		m1_in1, m1_in2;// m2_in1, m2_in2;
wire [N-1:0] 		m1_out, m2_out;

reg [9:0] addr_sw_fft_imag,addr_sw_fft_real,addr_sw_imag,addr_sw_real;
reg re_sw,we_sw,re_sw_fft,we_sw_fft;

reg [N-1:0] write_sw_fft_imag,write_sw_fft_real,write_sw_imag,write_sw_real;
wire [N-1:0] out_sw_imag,out_sw_real,out_sw_fft_imag,out_sw_fft_real;

qmult			 	 #(Q,N) 			    qmult1	   (m1_in1,m1_in2,m1_out);
//qmult  				 #(Q,N) 			    qmult2	   (m2_in1,m2_in2,m2_out);

// ------------------------------- Speech samples -------------------------------------------------------------------//

// ------------------------------- Speech samples FFT input-------------------------------------------------------------------//
RAM_Sw_in_real          in_real	   (addr_sw_real,clk,write_sw_real,re_sw,we_sw,out_sw_real);
RAM_Sw_in_imag          in_imag	   (addr_sw_imag,clk,write_sw_imag,re_sw,we_sw,out_sw_imag);

// ------------------------------- Speech samples FFT output-------------------------------------------------------------------//
RAM_Sw_fft_real      fft_out_real	(addr_sw_fft_real,clk,write_sw_fft_real,re_sw_fft,we_sw_fft,out_sw_fft_real);
RAM_Sw_fft_imag      fft_out_imag	(addr_sw_fft_imag,clk,write_sw_fft_imag,re_sw_fft,we_sw_fft,out_sw_fft_imag);


// ------------------------------- FFT for nlp -------------------------------------------------------------------//
reg startfft;
wire   [N-1:0]		in_imag_data,in_real_data,fft_write_fft_real,fft_write_fft_imag;
wire [9:0] fft_addr_in_imag,fft_addr_in_real,fft_addr_out_real,fft_addr_out_imag;
wire donefft;

fft_32_bits_aof fft_32_bits (startfft,clk,rst,out_sw_imag,out_sw_real,
						fft_addr_in_imag,fft_addr_in_real,fft_addr_out_real,fft_addr_out_imag,
						fft_write_fft_real,fft_write_fft_imag,
						
						donefft
						
						);


// ------------------------------- NLP module -------------------------------------------------------------------//					
reg startnlp;
wire [9:0] nlp_addr_sn,nlp_addr_mem_fir,nlp_addr_nlp_sq;
reg [N1-1:0] nlp_mem_x,nlp_mem_y,nlp_out_mem_fir,nlp_out_sq;
reg [N-1:0] prev_f0,nlp_out_sn,one_by_pitch,one_by_wo;
wire [N-1:0] pitch,best_f0,o_prev_f0;
wire [N1-1:0] nlp_mem_x_out,nlp_mem_y_out,nlp_in_mem_fir,nlp_in_sq;//nlp_pitch;
wire nlp_read_fir,nlp_write_fir,donenlp,nlp_read_sq,nlp_write_sq;
output reg [N-1:0] out_best_f0;

reg [N-1:0] nlp_m1_out;
//wire [N-1:0] nlp_m1_in1,nlp_m1_in2;
wire [9:0] check_cmax_bin;
wire [N-1:0] check_i;
wire [N1-1:0] check_in_sq,check_in_real,check_in_imag;
 

			
nlp_extended_bits   nlp_module	(startnlp,clk,rst,nlp_out_sn,nlp_out_sq,nlp_out_mem_fir,nlp_mem_x,nlp_mem_y,prev_f0,
					best_f0,o_prev_f0,pitch,nlp_mem_x_out,nlp_mem_y_out,nlp_addr_sn,nlp_addr_mem_fir,nlp_in_mem_fir,
					nlp_read_fir,nlp_write_fir,
					nlp_addr_nlp_sq,nlp_read_sq,nlp_write_sq,nlp_in_sq,
					donenlp
					);

// ---------------------------------Division module --------------------------------------------------------------//
reg startdiv;
reg [N-1:0] div_in;
wire [N-1:0] div_ans;
wire donediv;

fpdiv_clk  	  	 divider	    (startdiv,clk,rst,div_in,div_ans,donediv);


// ------------------------------- two_stage_pitch_refinement module ---------------------------------------------//
reg starttspr;
reg [N-1:0] Wo_in,L_in;
wire [N-1:0] Wo_out,L_out;//c_w0;
wire donetspr;

reg [N-1:0] out_real, out_imag;
wire [9:0] addr_real,addr_imag;

two_stage_pitch_refinement tspr_module (starttspr,clk,rst,Wo_in,L_in,out_real,out_imag,
								           Wo_out,L_out,addr_real,addr_imag,
										   donetspr,ts_c_w0,ts_c_w1);
										   
wire [N-1:0] ts_c_w0,ts_c_w1;
// ------------------------------- estimate_amplitudes module --------------------------------------------------------//					
										   
reg startea;
reg [N-1:0] ea_Wo;
reg [9:0] ea_L;
wire doneea;
wire [9:0] ea_addr_real,ea_addr_imag,ea_addr_a;
reg [N-1:0] ea_out_real,ea_out_imag;
wire [N-1:0] ea_write_data_a;
					   
estimate_amplitudes ea_module(startea,clk,rst,ea_Wo,ea_L,ea_out_real,ea_out_imag,
								ea_addr_real,ea_addr_imag,ea_addr_a,ea_write_data_a,
								doneea);

// ------------------------------- estimate_voicing_mbe module --------------------------------------------------------//
reg startevmbe;
reg [9:0] evm_L_in;
reg [N-1:0] evm_Wo_in,evm_out_am,evm_out_sw_real,evm_out_sw_imag;
wire [N-1:0] evm_snr;
wire [9:0] evm_addr_am,evm_addr_sw_real,evm_addr_sw_imag;
wire evm_voiced,doneevmbe;


estimate_voicing_mbe evm_module(startevmbe, clk, rst, evm_L_in, evm_Wo_in, evm_out_am,evm_out_sw_real,evm_out_sw_imag, 
								evm_snr, evm_voiced , evm_addr_am,evm_addr_sw_real,evm_addr_sw_imag,
								doneevmbe);

// ------------------------------- model->A RAM module ----------------------------------------------------------------//					
reg [9:0] addr_a;
wire [N-1:0] out_a;
reg [N-1:0] write_data_a;
reg re_am,we_am;

RAM_model_A modelram (addr_a,clk,write_data_a,re_am,we_am,out_a);
										   
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

always@(*)
begin
	case(STATE)
	
	SET_ADDR_SN_1:
	begin
		addr_sn = i + mpitch_by_2;
		nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end
	
	SET_DELAY1:
	begin
		addr_sn = i + mpitch_by_2;	
		nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end

	SET_DELAY2:
	begin
		addr_sn = i + mpitch_by_2;	
		nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end
	
	SET_ADDR_SN_2:
	begin
		addr_sn = i + 10'd21;
		nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end
	
	SET_DELAY3:
	begin
		addr_sn = i + 10'd21;	
		nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end

	SET_DELAY4:
	begin
		addr_sn = i + 10'd21;

			nlp_out_sn <= out_sn;
				
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end
		
		
	RUN_NLP:
	begin
			nlp_out_sn = out_sn;
			addr_sn = nlp_addr_sn;
			
			addr_mem_fir = nlp_addr_mem_fir;
			in_mem_fir = nlp_in_mem_fir;
			read_fir = nlp_read_fir;
			write_fir = nlp_write_fir;
			nlp_out_mem_fir = out_mem_fir;
			
			addr_nlp_sq = nlp_addr_nlp_sq;
			in_sq = nlp_in_sq;
			read_sq = nlp_read_sq;
			write_sq = nlp_write_sq;
			nlp_out_sq = out_sq;
	end
	
	START_NLP:
	begin
			nlp_out_sn = out_sn;
			addr_sn = nlp_addr_sn;
			
			addr_mem_fir = nlp_addr_mem_fir;
			in_mem_fir = nlp_in_mem_fir;
			read_fir = nlp_read_fir;
			write_fir = nlp_write_fir;
			nlp_out_mem_fir = out_mem_fir;
			
			addr_nlp_sq = nlp_addr_nlp_sq;
			in_sq = nlp_in_sq;
			read_sq = nlp_read_sq;
			write_sq = nlp_write_sq;
			nlp_out_sq = out_sq;
	end
	
	default:
	begin
			/* addr_sn = 10'd0;
			nlp_out_sn = 32'b0;
			
			addr_mem_fir = 10'b0;
			in_mem_fir = 80'b0;
			read_fir = 1'b0;
			write_fir = 1'b0;
			nlp_out_mem_fir = 80'b0;
			
			addr_nlp_sq = 10'b0;
			in_sq = 80'b0;
			read_sq = 1'b0;
			write_sq = 1'b0;
			nlp_out_sq = 80'b0; */
			
			nlp_out_sn <= out_sn;
			addr_sn <= nlp_addr_sn;
			
			addr_mem_fir <= nlp_addr_mem_fir;
			in_mem_fir <= nlp_in_mem_fir;
			read_fir <= nlp_read_fir;
			write_fir <= nlp_write_fir;
			nlp_out_mem_fir <= out_mem_fir;
			
			addr_nlp_sq <= nlp_addr_nlp_sq;
			in_sq <= nlp_in_sq;
			read_sq <= nlp_read_sq;
			write_sq <= nlp_write_sq;
			nlp_out_sq <= out_sq;
	end
	
	endcase

end


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		if(startaof == 1'b1)
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
		NEXT_STATE = CHECK_I_1;
	end

	CHECK_I_1:
	begin
		if(i < nw_by_2)
		begin
			NEXT_STATE = SET_ADDR_SN_1;
		end
		else
		begin
			NEXT_STATE = INIT_FOR_2;
		end
	end

	SET_ADDR_SN_1:
	begin
		NEXT_STATE = SET_DELAY1;
	end

	SET_DELAY1:
	begin
		NEXT_STATE = SET_DELAY2;
	end

	SET_DELAY2:
	begin
		NEXT_STATE = SET_MULT_1;
	end

	SET_MULT_1:
	begin
		NEXT_STATE = SET_SW_REAL_1;
	end

	SET_SW_REAL_1:
	begin
		NEXT_STATE = INCR_I_1;
	end

	INCR_I_1:
	begin
		NEXT_STATE = CHECK_I_1;
	end

	INIT_FOR_2:
	begin
		NEXT_STATE = CHECK_I_2;
	end

	CHECK_I_2:
	begin
		if(i < nw_by_2)
		begin
			NEXT_STATE = SET_ADDR_SN_2;
		end
		else
		begin
			NEXT_STATE = START_DFT;
		end
	end

	SET_ADDR_SN_2:
	begin
		NEXT_STATE = SET_DELAY3;
		//addr_sn = i + 10'd21;
	end

	SET_DELAY3:
	begin
		NEXT_STATE = SET_DELAY4;
	end

	SET_DELAY4:
	begin
		NEXT_STATE = SET_MULT_2;
	end

	SET_MULT_2:
	begin
		NEXT_STATE = SET_SW_REAL_2;
	end

	SET_SW_REAL_2:
	begin
		NEXT_STATE = INCR_I_2;
	end

	INCR_I_2:
	begin
		NEXT_STATE = CHECK_I_2;
	end
	
	START_DFT:
	begin
		NEXT_STATE = RUN_DFT;
	end
	
	RUN_DFT:
	begin
		if(donefft)
		begin
			NEXT_STATE = START_NLP;
		end
		else
		begin
			NEXT_STATE = RUN_DFT;
		end
	end
	
	START_NLP:
	begin
		NEXT_STATE = RUN_NLP;
	end
	
	RUN_NLP:
	begin
		if(donenlp)
		begin
			NEXT_STATE = GET_NLP;
		end
		else
		begin
			NEXT_STATE = RUN_NLP;
		end

	end

	GET_NLP:
	begin
		NEXT_STATE = CALC_DIV_PITCH;
	end
	
	CALC_DIV_PITCH:
	begin
		NEXT_STATE = SET_DIV_PITCH;
	end
	
	SET_DIV_PITCH:
	begin
		if(donediv)
		begin
			NEXT_STATE = CALC_WO;
		end
		else
		begin
			NEXT_STATE = SET_DIV_PITCH;
		end
	end
	
	CALC_WO:
	begin
		NEXT_STATE = CALC_DIV_WO;
	end
			
	CALC_DIV_WO:
	begin
		if(donediv)
		begin
			NEXT_STATE = SET_DIV_WO;
		end
		else
		begin
			NEXT_STATE = CALC_DIV_WO;
		end
	end
	
	SET_DIV_WO:
	begin
		NEXT_STATE = CALC_L;
	end
	
	CALC_L:
	begin
		NEXT_STATE = START_TSPR;
	end
	
	START_TSPR:
	begin
		NEXT_STATE = RUN_TSPR;	
	end
	
	RUN_TSPR:
	begin
		if(donetspr)
		begin
			NEXT_STATE = GET_TSPR;
		end
		else
		begin
			NEXT_STATE = RUN_TSPR;
		end
	end
	
	GET_TSPR:
	begin
		NEXT_STATE = START_EA;
	end
	
	START_EA:
	begin
		NEXT_STATE = RUN_EA;	
	end
	
	RUN_EA:
	begin
		if(doneea)
		begin
			NEXT_STATE = GET_EA;
		end
		else
		begin
			NEXT_STATE = RUN_EA;
		end
	end
	
	GET_EA:
	begin
		NEXT_STATE = START_EVM;
	end
	
	START_EVM:
	begin
		NEXT_STATE = RUN_EVM;	
	end
	
	RUN_EVM:
	begin
		if(doneevmbe)
		begin
			NEXT_STATE = GET_EVM;
		end
		else
		begin
			NEXT_STATE = RUN_EVM;
		end
	end
	
	GET_EVM:
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

		doneaof <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneaof <= 1'b0;
			
		end

		INIT_FOR_1:
		begin
			i <= 10'd0;
		end

		CHECK_I_1:
		begin
			
		end

		SET_ADDR_SN_1:
		begin
			//addr_sn <= i + mpitch_by_2;	
		end

		SET_DELAY1:
		begin
			
		end

		SET_DELAY2:
		begin
			
		end

		SET_MULT_1:
		begin
			m1_in1 <= out_sn;
			case (i + mpitch_by_2)
			10'd0  :
			   begin
				   m1_in2 <= w160;
			   end
			10'd1  :
			   begin
				   m1_in2 <= w161;
			   end
			10'd2  :
			   begin
				   m1_in2 <= w162;
			   end
			10'd3  :
			   begin
				   m1_in2 <= w163;
			   end
			10'd4  :
			   begin
				   m1_in2 <= w164;
			   end
			10'd5  :
			   begin
				   m1_in2 <= w165;
			   end
			10'd6  :
			   begin
				   m1_in2 <= w166;
			   end
			10'd7  :
			   begin
				   m1_in2 <= w167;
			   end
			10'd8  :
			   begin
				   m1_in2 <= w168;
			   end
			10'd9  :
			   begin
				   m1_in2 <= w169;
			   end
			10'd10  :
			   begin
				   m1_in2 <= w170;
			   end
			10'd11  :
			   begin
				   m1_in2 <= w171;
			   end
			10'd12  :
			   begin
				   m1_in2 <= w172;
			   end
			10'd13  :
			   begin
				   m1_in2 <= w173;
			   end
			10'd14  :
			   begin
				   m1_in2 <= w174;
			   end
			10'd15  :
			   begin
				   m1_in2 <= w175;
			   end
			10'd16  :
			   begin
				   m1_in2 <= w176;
			   end
			10'd17  :
			   begin
				   m1_in2 <= w177;
			   end
			10'd18  :
			   begin
				   m1_in2 <= w178;
			   end
			10'd19  :
			   begin
				   m1_in2 <= w179;
			   end
			10'd20  :
			   begin
				   m1_in2 <= w180;
			   end
			10'd21  :
			   begin
				   m1_in2 <= w181;
			   end
			10'd22  :
			   begin
				   m1_in2 <= w182;
			   end
			10'd23  :
			   begin
				   m1_in2 <= w183;
			   end
			10'd24  :
			   begin
				   m1_in2 <= w184;
			   end
			10'd25  :
			   begin
				   m1_in2 <= w185;
			   end
			10'd26  :
			   begin
				   m1_in2 <= w186;
			   end
			10'd27  :
			   begin
				   m1_in2 <= w187;
			   end
			10'd28  :
			   begin
				   m1_in2 <= w188;
			   end
			10'd29  :
			   begin
				   m1_in2 <= w189;
			   end
			10'd30  :
			   begin
				   m1_in2 <= w190;
			   end
			10'd31  :
			   begin
				   m1_in2 <= w191;
			   end
			10'd32  :
			   begin
				   m1_in2 <= w192;
			   end
			10'd33  :
			   begin
				   m1_in2 <= w193;
			   end
			10'd34  :
			   begin
				   m1_in2 <= w194;
			   end
			10'd35  :
			   begin
				   m1_in2 <= w195;
			   end
			10'd36  :
			   begin
				   m1_in2 <= w196;
			   end
			10'd37  :
			   begin
				   m1_in2 <= w197;
			   end
			10'd38  :
			   begin
				   m1_in2 <= w198;
			   end
			10'd39  :
			   begin
				   m1_in2 <= w199;
			   end
			10'd40  :
			   begin
				   m1_in2 <= w200;
			   end
			10'd41  :
			   begin
				   m1_in2 <= w201;
			   end
			10'd42  :
			   begin
				   m1_in2 <= w202;
			   end
			10'd43  :
			   begin
				   m1_in2 <= w203;
			   end
			10'd44  :
			   begin
				   m1_in2 <= w204;
			   end
			10'd45  :
			   begin
				   m1_in2 <= w205;
			   end
			10'd46  :
			   begin
				   m1_in2 <= w206;
			   end
			10'd47  :
			   begin
				   m1_in2 <= w207;
			   end
			10'd48  :
			   begin
				   m1_in2 <= w208;
			   end
			10'd49  :
			   begin
				   m1_in2 <= w209;
			   end
			10'd50  :
			   begin
				   m1_in2 <= w210;
			   end
			10'd51  :
			   begin
				   m1_in2 <= w211;
			   end
			10'd52  :
			   begin
				   m1_in2 <= w212;
			   end
			10'd53  :
			   begin
				   m1_in2 <= w213;
			   end
			10'd54  :
			   begin
				   m1_in2 <= w214;
			   end
			10'd55  :
			   begin
				   m1_in2 <= w215;
			   end
			10'd56  :
			   begin
				   m1_in2 <= w216;
			   end
			10'd57  :
			   begin
				   m1_in2 <= w217;
			   end
			10'd58  :
			   begin
				   m1_in2 <= w218;
			   end
			10'd59  :
			   begin
				   m1_in2 <= w219;
			   end
			10'd60  :
			   begin
				   m1_in2 <= w220;
			   end
			10'd61  :
			   begin
				   m1_in2 <= w221;
			   end
			10'd62  :
			   begin
				   m1_in2 <= w222;
			   end
			10'd63  :
			   begin
				   m1_in2 <= w223;
			   end
			10'd64  :
			   begin
				   m1_in2 <= w224;
			   end
			10'd65  :
			   begin
				   m1_in2 <= w225;
			   end
			10'd66  :
			   begin
				   m1_in2 <= w226;
			   end
			10'd67  :
			   begin
				   m1_in2 <= w227;
			   end
			10'd68  :
			   begin
				   m1_in2 <= w228;
			   end
			10'd69  :
			   begin
				   m1_in2 <= w229;
			   end
			10'd70  :
			   begin
				   m1_in2 <= w230;
			   end
			10'd71  :
			   begin
				   m1_in2 <= w231;
			   end
			10'd72  :
			   begin
				   m1_in2 <= w232;
			   end
			10'd73  :
			   begin
				   m1_in2 <= w233;
			   end
			10'd74  :
			   begin
				   m1_in2 <= w234;
			   end
			10'd75  :
			   begin
				   m1_in2 <= w235;
			   end
			10'd76  :
			   begin
				   m1_in2 <= w236;
			   end
			10'd77  :
			   begin
				   m1_in2 <= w237;
			   end
			10'd78  :
			   begin
				   m1_in2 <= w238;
			   end
			10'd79  :
			   begin
				   m1_in2 <= w239;
			   end
			10'd80  :
			   begin
				   m1_in2 <= w240;
			   end
			10'd81  :
			   begin
				   m1_in2 <= w241;
			   end
			10'd82  :
			   begin
				   m1_in2 <= w242;
			   end
			10'd83  :
			   begin
				   m1_in2 <= w243;
			   end
			10'd84  :
			   begin
				   m1_in2 <= w244;
			   end
			10'd85  :
			   begin
				   m1_in2 <= w245;
			   end
			10'd86  :
			   begin
				   m1_in2 <= w246;
			   end
			10'd87  :
			   begin
				   m1_in2 <= w247;
			   end
			10'd88  :
			   begin
				   m1_in2 <= w248;
			   end
			10'd89  :
			   begin
				   m1_in2 <= w249;
			   end
			10'd90  :
			   begin
				   m1_in2 <= w250;
			   end
			10'd91  :
			   begin
				   m1_in2 <= w251;
			   end
			10'd92  :
			   begin
				   m1_in2 <= w252;
			   end
			10'd93  :
			   begin
				   m1_in2 <= w253;
			   end
			10'd94  :
			   begin
				   m1_in2 <= w254;
			   end
			10'd95  :
			   begin
				   m1_in2 <= w255;
			   end
			10'd96  :
			   begin
				   m1_in2 <= w256;
			   end
			10'd97  :
			   begin
				   m1_in2 <= w257;
			   end
			10'd98  :
			   begin
				   m1_in2 <= w258;
			   end
			10'd99  :
			   begin
				   m1_in2 <= w259;
			   end
			10'd100  :
			   begin
				   m1_in2 <= w260;
			   end
			10'd101  :
			   begin
				   m1_in2 <= w261;
			   end
			10'd102  :
			   begin
				   m1_in2 <= w262;
			   end
			10'd103  :
			   begin
				   m1_in2 <= w263;
			   end
			10'd104  :
			   begin
				   m1_in2 <= w264;
			   end
			10'd105  :
			   begin
				   m1_in2 <= w265;
			   end
			10'd106  :
			   begin
				   m1_in2 <= w266;
			   end
			10'd107  :
			   begin
				   m1_in2 <= w267;
			   end
			10'd108  :
			   begin
				   m1_in2 <= w268;
			   end
			10'd109  :
			   begin
				   m1_in2 <= w269;
			   end
			10'd110  :
			   begin
				   m1_in2 <= w270;
			   end
			10'd111  :
			   begin
				   m1_in2 <= w271;
			   end
			10'd112  :
			   begin
				   m1_in2 <= w272;
			   end
			10'd113  :
			   begin
				   m1_in2 <= w273;
			   end
			10'd114  :
			   begin
				   m1_in2 <= w274;
			   end
			10'd115  :
			   begin
				   m1_in2 <= w275;
			   end
			10'd116  :
			   begin
				   m1_in2 <= w276;
			   end
			10'd117  :
			   begin
				   m1_in2 <= w277;
			   end
			10'd118  :
			   begin
				   m1_in2 <= w278;
			   end
			10'd119  :
			   begin
				   m1_in2 <= w279;
			   end
			10'd120  :
			   begin
				   m1_in2 <= w280;
			   end
			10'd121  :
			   begin
				   m1_in2 <= w281;
			   end
			10'd122  :
			   begin
				   m1_in2 <= w282;
			   end
			10'd123  :
			   begin
				   m1_in2 <= w283;
			   end
			10'd124  :
			   begin
				   m1_in2 <= w284;
			   end
			10'd125  :
			   begin
				   m1_in2 <= w285;
			   end
			10'd126  :
			   begin
				   m1_in2 <= w286;
			   end
			10'd127  :
			   begin
				   m1_in2 <= w287;
			   end
			10'd128  :
			   begin
				   m1_in2 <= w288;
			   end
			10'd129  :
			   begin
				   m1_in2 <= w289;
			   end
			10'd130  :
			   begin
				   m1_in2 <= w290;
			   end
			10'd131  :
			   begin
				   m1_in2 <= w291;
			   end
			10'd132  :
			   begin
				   m1_in2 <= w292;
			   end
			10'd133  :
			   begin
				   m1_in2 <= w293;
			   end
			10'd134  :
			   begin
				   m1_in2 <= w294;
			   end
			10'd135  :
			   begin
				   m1_in2 <= w295;
			   end
			10'd136  :
			   begin
				   m1_in2 <= w296;
			   end
			10'd137  :
			   begin
				   m1_in2 <= w297;
			   end
			10'd138  :
			   begin
				   m1_in2 <= w298;
			   end	
			endcase
			
			addr_sw_real <= i;
			we_sw <= 1'b1;
			re_sw <= 1'b0;
		end

		SET_SW_REAL_1:
		begin
			write_sw_real <= m1_out;
		end

		INCR_I_1:
		begin
			i <= i + 10'd1;
		end

		INIT_FOR_2:
		begin
			i <= 10'd0;
		end

		CHECK_I_2:
		begin
			
		end

		SET_ADDR_SN_2:
		begin
			//addr_sn <= i + 10'd21;	
		end

		SET_DELAY3:
		begin
			
		end

		SET_DELAY4:
		begin
			
		end

		SET_MULT_2:
		begin
			m1_in1 <= out_sn;
			case (i + 10'd21)
			10'd0  :
			   begin
				   m1_in2 <= w21;
			   end
			10'd1  :
			   begin
				   m1_in2 <= w22;
			   end
			10'd2  :
			   begin
				   m1_in2 <= w23;
			   end
			10'd3  :
			   begin
				   m1_in2 <= w24;
			   end
			10'd4  :
			   begin
				   m1_in2 <= w25;
			   end
			10'd5  :
			   begin
				   m1_in2 <= w26;
			   end
			10'd6  :
			   begin
				   m1_in2 <= w27;
			   end
			10'd7  :
			   begin
				   m1_in2 <= w28;
			   end
			10'd8  :
			   begin
				   m1_in2 <= w29;
			   end
			10'd9  :
			   begin
				   m1_in2 <= w30;
			   end
			10'd10  :
			   begin
				   m1_in2 <= w31;
			   end
			10'd11  :
			   begin
				   m1_in2 <= w32;
			   end
			10'd12  :
			   begin
				   m1_in2 <= w33;
			   end
			10'd13  :
			   begin
				   m1_in2 <= w34;
			   end
			10'd14  :
			   begin
				   m1_in2 <= w35;
			   end
			10'd15  :
			   begin
				   m1_in2 <= w36;
			   end
			10'd16  :
			   begin
				   m1_in2 <= w37;
			   end
			10'd17  :
			   begin
				   m1_in2 <= w38;
			   end
			10'd18  :
			   begin
				   m1_in2 <= w39;
			   end
			10'd19  :
			   begin
				   m1_in2 <= w40;
			   end
			10'd20  :
			   begin
				   m1_in2 <= w41;
			   end
			10'd21  :
			   begin
				   m1_in2 <= w42;
			   end
			10'd22  :
			   begin
				   m1_in2 <= w43;
			   end
			10'd23  :
			   begin
				   m1_in2 <= w44;
			   end
			10'd24  :
			   begin
				   m1_in2 <= w45;
			   end
			10'd25  :
			   begin
				   m1_in2 <= w46;
			   end
			10'd26  :
			   begin
				   m1_in2 <= w47;
			   end
			10'd27  :
			   begin
				   m1_in2 <= w48;
			   end
			10'd28  :
			   begin
				   m1_in2 <= w49;
			   end
			10'd29  :
			   begin
				   m1_in2 <= w50;
			   end
			10'd30  :
			   begin
				   m1_in2 <= w51;
			   end
			10'd31  :
			   begin
				   m1_in2 <= w52;
			   end
			10'd32  :
			   begin
				   m1_in2 <= w53;
			   end
			10'd33  :
			   begin
				   m1_in2 <= w54;
			   end
			10'd34  :
			   begin
				   m1_in2 <= w55;
			   end
			10'd35  :
			   begin
				   m1_in2 <= w56;
			   end
			10'd36  :
			   begin
				   m1_in2 <= w57;
			   end
			10'd37  :
			   begin
				   m1_in2 <= w58;
			   end
			10'd38  :
			   begin
				   m1_in2 <= w59;
			   end
			10'd39  :
			   begin
				   m1_in2 <= w60;
			   end
			10'd40  :
			   begin
				   m1_in2 <= w61;
			   end
			10'd41  :
			   begin
				   m1_in2 <= w62;
			   end
			10'd42  :
			   begin
				   m1_in2 <= w63;
			   end
			10'd43  :
			   begin
				   m1_in2 <= w64;
			   end
			10'd44  :
			   begin
				   m1_in2 <= w65;
			   end
			10'd45  :
			   begin
				   m1_in2 <= w66;
			   end
			10'd46  :
			   begin
				   m1_in2 <= w67;
			   end
			10'd47  :
			   begin
				   m1_in2 <= w68;
			   end
			10'd48  :
			   begin
				   m1_in2 <= w69;
			   end
			10'd49  :
			   begin
				   m1_in2 <= w70;
			   end
			10'd50  :
			   begin
				   m1_in2 <= w71;
			   end
			10'd51  :
			   begin
				   m1_in2 <= w72;
			   end
			10'd52  :
			   begin
				   m1_in2 <= w73;
			   end
			10'd53  :
			   begin
				   m1_in2 <= w74;
			   end
			10'd54  :
			   begin
				   m1_in2 <= w75;
			   end
			10'd55  :
			   begin
				   m1_in2 <= w76;
			   end
			10'd56  :
			   begin
				   m1_in2 <= w77;
			   end
			10'd57  :
			   begin
				   m1_in2 <= w78;
			   end
			10'd58  :
			   begin
				   m1_in2 <= w79;
			   end
			10'd59  :
			   begin
				   m1_in2 <= w80;
			   end
			10'd60  :
			   begin
				   m1_in2 <= w81;
			   end
			10'd61  :
			   begin
				   m1_in2 <= w82;
			   end
			10'd62  :
			   begin
				   m1_in2 <= w83;
			   end
			10'd63  :
			   begin
				   m1_in2 <= w84;
			   end
			10'd64  :
			   begin
				   m1_in2 <= w85;
			   end
			10'd65  :
			   begin
				   m1_in2 <= w86;
			   end
			10'd66  :
			   begin
				   m1_in2 <= w87;
			   end
			10'd67  :
			   begin
				   m1_in2 <= w88;
			   end
			10'd68  :
			   begin
				   m1_in2 <= w89;
			   end
			10'd69  :
			   begin
				   m1_in2 <= w90;
			   end
			10'd70  :
			   begin
				   m1_in2 <= w91;
			   end
			10'd71  :
			   begin
				   m1_in2 <= w92;
			   end
			10'd72  :
			   begin
				   m1_in2 <= w93;
			   end
			10'd73  :
			   begin
				   m1_in2 <= w94;
			   end
			10'd74  :
			   begin
				   m1_in2 <= w95;
			   end
			10'd75  :
			   begin
				   m1_in2 <= w96;
			   end
			10'd76  :
			   begin
				   m1_in2 <= w97;
			   end
			10'd77  :
			   begin
				   m1_in2 <= w98;
			   end
			10'd78  :
			   begin
				   m1_in2 <= w99;
			   end
			10'd79  :
			   begin
				   m1_in2 <= w100;
			   end
			10'd80  :
			   begin
				   m1_in2 <= w101;
			   end
			10'd81  :
			   begin
				   m1_in2 <= w102;
			   end
			10'd82  :
			   begin
				   m1_in2 <= w103;
			   end
			10'd83  :
			   begin
				   m1_in2 <= w104;
			   end
			10'd84  :
			   begin
				   m1_in2 <= w105;
			   end
			10'd85  :
			   begin
				   m1_in2 <= w106;
			   end
			10'd86  :
			   begin
				   m1_in2 <= w107;
			   end
			10'd87  :
			   begin
				   m1_in2 <= w108;
			   end
			10'd88  :
			   begin
				   m1_in2 <= w109;
			   end
			10'd89  :
			   begin
				   m1_in2 <= w110;
			   end
			10'd90  :
			   begin
				   m1_in2 <= w111;
			   end
			10'd91  :
			   begin
				   m1_in2 <= w112;
			   end
			10'd92  :
			   begin
				   m1_in2 <= w113;
			   end
			10'd93  :
			   begin
				   m1_in2 <= w114;
			   end
			10'd94  :
			   begin
				   m1_in2 <= w115;
			   end
			10'd95  :
			   begin
				   m1_in2 <= w116;
			   end
			10'd96  :
			   begin
				   m1_in2 <= w117;
			   end
			10'd97  :
			   begin
				   m1_in2 <= w118;
			   end
			10'd98  :
			   begin
				   m1_in2 <= w119;
			   end
			10'd99  :
			   begin
				   m1_in2 <= w120;
			   end
			10'd100  :
			   begin
				   m1_in2 <= w121;
			   end
			10'd101  :
			   begin
				   m1_in2 <= w122;
			   end
			10'd102  :
			   begin
				   m1_in2 <= w123;
			   end
			10'd103  :
			   begin
				   m1_in2 <= w124;
			   end
			10'd104  :
			   begin
				   m1_in2 <= w125;
			   end
			10'd105  :
			   begin
				   m1_in2 <= w126;
			   end
			10'd106  :
			   begin
				   m1_in2 <= w127;
			   end
			10'd107  :
			   begin
				   m1_in2 <= w128;
			   end
			10'd108  :
			   begin
				   m1_in2 <= w129;
			   end
			10'd109  :
			   begin
				   m1_in2 <= w130;
			   end
			10'd110  :
			   begin
				   m1_in2 <= w131;
			   end
			10'd111  :
			   begin
				   m1_in2 <= w132;
			   end
			10'd112  :
			   begin
				   m1_in2 <= w133;
			   end
			10'd113  :
			   begin
				   m1_in2 <= w134;
			   end
			10'd114  :
			   begin
				   m1_in2 <= w135;
			   end
			10'd115  :
			   begin
				   m1_in2 <= w136;
			   end
			10'd116  :
			   begin
				   m1_in2 <= w137;
			   end
			10'd117  :
			   begin
				   m1_in2 <= w138;
			   end
			10'd118  :
			   begin
				   m1_in2 <= w139;
			   end
			10'd119  :
			   begin
				   m1_in2 <= w140;
			   end
			10'd120  :
			   begin
				   m1_in2 <= w141;
			   end
			10'd121  :
			   begin
				   m1_in2 <= w142;
			   end
			10'd122  :
			   begin
				   m1_in2 <= w143;
			   end
			10'd123  :
			   begin
				   m1_in2 <= w144;
			   end
			10'd124  :
			   begin
				   m1_in2 <= w145;
			   end
			10'd125  :
			   begin
				   m1_in2 <= w146;
			   end
			10'd126  :
			   begin
				   m1_in2 <= w147;
			   end
			10'd127  :
			   begin
				   m1_in2 <= w148;
			   end
			10'd128  :
			   begin
				   m1_in2 <= w149;
			   end
			10'd129  :
			   begin
				   m1_in2 <= w150;
			   end
			10'd130  :
			   begin
				   m1_in2 <= w151;
			   end
			10'd131  :
			   begin
				   m1_in2 <= w152;
			   end
			10'd132  :
			   begin
				   m1_in2 <= w153;
			   end
			10'd133  :
			   begin
				   m1_in2 <= w154;
			   end
			10'd134  :
			   begin
				   m1_in2 <= w155;
			   end
			10'd135  :
			   begin
				   m1_in2 <= w156;
			   end
			10'd136  :
			   begin
				   m1_in2 <= w157;
			   end
			10'd137  :
			   begin
				   m1_in2 <= w158;
			   end
			10'd138  :
			   begin
				   m1_in2 <= w159;
			   end
			endcase
			addr_sw_real <= fft_enc - nw_by_2 + i;
			we_sw <= 1'b1;
			re_sw <= 1'b0;
		end

		SET_SW_REAL_2:
		begin
			write_sw_real <= m1_out;
		end

		INCR_I_2:
		begin
			i <= i + 10'd1;
		end
		
		START_DFT:
		begin
			startfft <= 1'b1;
	
			re_sw <= 1'b1;
			we_sw <= 1'b0;
			
			re_sw_fft <= 1'b0;
			we_sw_fft <= 1'b1;
			
		end
		
		RUN_DFT:
		begin
			startfft <= 1'b0;
			addr_sw_real <= fft_addr_in_real;
			addr_sw_imag <= fft_addr_in_imag;
			
			addr_sw_fft_real <= fft_addr_out_real;
			addr_sw_fft_imag <= fft_addr_out_imag;

			write_sw_fft_real <= fft_write_fft_real;
			write_sw_fft_imag <= fft_write_fft_imag;
	
		end
		
		START_NLP:
		begin
			startnlp <= 1'b1;
			
			/* nlp_mem_x <= 80'h2A40000;
			nlp_mem_y <= 80'hCBDE96; 
			prev_f0 <= {16'd50,16'd0};   */   // to test aof2
			
			/* 
			nlp_mem_x <= 80'd0;
			nlp_mem_y <= 80'd0;
			prev_f0 <= {16'd50,16'd0};  */    // to test aof1
			
		  	nlp_mem_x <= mem_x_in; 
			nlp_mem_y <= mem_y_in; 
			prev_f0 <= in_prev_f0;  
	
			
		end
		
		RUN_NLP:
		begin
			startnlp <= 1'b0;
		end
		
		GET_NLP:
		begin
			mem_x_out <= nlp_mem_x_out;
			mem_y_out <= nlp_mem_y_out;
			out_best_f0 <= best_f0;
			out_prev_f0 <= o_prev_f0;
			startdiv <= 1'b1;	
		end
		
		CALC_DIV_PITCH:
		begin
			div_in <= pitch;
			startdiv <= 1'b0;
		end
		
		SET_DIV_PITCH:
		begin
			one_by_pitch <= div_ans;
		end
		
		CALC_WO:
		begin
			m1_in1 <= TWO_PI;
			m1_in2 <= one_by_pitch;
			startdiv <= 1'b1;
		end
		
		CALC_DIV_WO:
		begin
			Wo_in <= m1_out;
			aof_w0_out <= m1_out;    
			div_in <= m1_out;
			startdiv <= 1'b0;
		end
		
		SET_DIV_WO:
		begin
			one_by_wo <= div_ans;
		end
		
		CALC_L:
		begin
			m1_in1 <= PI;
			m1_in2 <= one_by_wo;
		end
		
		
		START_TSPR:
		begin
			starttspr <= 1'b1;
			re_sw_fft <= 1'b1;
			we_sw_fft <= 1'b0;
		
			L_in <= m1_out;//10'd79;
			
		end
		
		RUN_TSPR:
		begin
			starttspr <= 1'b0;
			out_real <= out_sw_fft_real;
			out_imag <= out_sw_fft_imag;
			addr_sw_fft_real <= addr_real;
			addr_sw_fft_imag <= addr_imag;

		end
		
		GET_TSPR:
		begin
			ea_L <= L_out[25:16];
			ea_Wo <= Wo_out;
		end
		
		START_EA:
		begin
			startea <= 1'b1;
			we_am <= 1'b1;
			re_am <= 1'b0;

		end
		
		RUN_EA:
		begin
			startea <= 1'b0;
			ea_out_real <= out_sw_fft_real;
			ea_out_imag <= out_sw_fft_imag;
			addr_sw_fft_real <= ea_addr_real;
			addr_sw_fft_imag <= ea_addr_imag;
			addr_a <= ea_addr_a;
			write_data_a <= ea_write_data_a;

		end
		
		GET_EA:
		begin
			evm_L_in <= L_out[25:16];
			evm_Wo_in <= Wo_out;

		end
		
		START_EVM:
		begin
			startevmbe <= 1'b1;
			we_am <= 1'b0;
			re_am <= 1'b1;
		end
		
		RUN_EVM:
		begin
			startevmbe <= 1'b0;
			evm_out_sw_real <= out_sw_fft_real;
			evm_out_sw_imag <= out_sw_fft_imag;
			addr_sw_fft_real <= evm_addr_sw_real;
			addr_sw_fft_imag <= evm_addr_sw_imag;
			addr_a <= evm_addr_am;
			evm_out_am <= out_a;

		end
		
		GET_EVM:
		begin
			voiced_bit <= evm_voiced;
			nlp_pitch <= pitch;
		end
		
		DONE:
		begin
			doneaof <= 1'b1;
		end

		endcase
	end

end


endmodule
