/*
* Module         - encode_lsps_scalar
* Top module     - codec2_encode_2400
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Feb 06 16:25:02 2019
*
* Description    - 
* Input(s)       - lsp[10] (from RAM_lsp)
* Output(s)      - indexes
* Simulation 	  - Waveform18.vwf 
* 32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module encode_lsps_scalar (start_elsp,clk,rst,lsp_out,
									indexes0,indexes1,indexes2,indexes3,indexes4,indexes5,
									indexes6,indexes7,indexes8,indexes9,
									addr_lsp,
									done_elsp,
									c_lsp
									
									);
									//in_lsp_hz_check0,besti_check0);



//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
	parameter N = 32;
	parameter Q = 16;
	parameter [N-1:0] RADTOHZ = 32'b00000100111110010011110101010010;   // 4000 * PI = 1273.239545
	 
	input 	  clk,rst;
	input  start_elsp;
	input [N-1:0] lsp_out;
	output reg done_elsp;
	output reg [3:0] indexes0,indexes1,indexes2,indexes3,indexes4,indexes5,
				indexes6,indexes7,indexes8,indexes9,addr_lsp;//,besti_check0;
	
	output reg [N-1:0] c_lsp;
	
	// reg [3:0] addr_lsp;
//
// wire [N-1:0] lsp_out;
//
//RAM_encode_lsp ram_lsps0(addr_lsp,clk,,1,0,lsp_out); 

//------------------------------------------------------------------
//                  -- Reg Declarations  --                   
//------------------------------------------------------------------
	wire [N-1:0] lsp_hz0,lsp_hz1,lsp_hz2,lsp_hz3,lsp_hz4,
					 lsp_hz5,lsp_hz6,lsp_hz7,lsp_hz8,lsp_hz9;
	wire [N-1:0] lsp0,lsp1,lsp2,lsp3,lsp4,
					 lsp5,lsp6,lsp7,lsp8,lsp9;
	wire [3:0] 	 besti0,besti1,besti2,besti3,besti4,
					 besti5,besti6,besti7,besti8,besti9;	
	
	reg [N-1:0] in_lsp_hz0,in_lsp_hz1,in_lsp_hz2,in_lsp_hz3,in_lsp_hz4,
					in_lsp_hz5,in_lsp_hz6,in_lsp_hz7,in_lsp_hz8,in_lsp_hz9;
	
	
	reg [N-1:0] in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9;
	
	reg startq;
	
	parameter [4:0] m0 = 5'd16,
						 m1 = 5'd16,
						 m2 = 5'd16,
						 m3 = 5'd16,
						 m4 = 5'd16,
						 m5 = 5'd16,
						 m6 = 5'd16,
						 m7 = 5'd8,
						 m8 = 5'd8,
						 m9 = 5'd4;
						 
	parameter [3:0] orderi0 = 4'd0,
						 orderi1 = 4'd1,
						 orderi2 = 4'd2,
						 orderi3 = 4'd3,
						 orderi4 = 4'd4,
						 orderi5 = 4'd5,
						 orderi6 = 4'd6,
						 orderi7 = 4'd7,
						 orderi8 = 4'd8,
						 orderi9 = 4'd9;
						 
	wire doneq0,doneq1,doneq2,doneq3,doneq4,doneq5,doneq6,doneq7,doneq8,doneq9;


//------------------------------------------------------------------
//                  -- State Declarations  --                   
//------------------------------------------------------------------

	parameter START = 6'd0,
				 INITVALUES = 6'd1,
				 CALC_LSPHZ = 6'd2,
				 INIT_QUANTISE = 6'd3,
				 START_QUANTISE = 6'd4,
				 CALC_INDEX = 6'd5,
				 RECORD_INDEX = 6'd6,
				 DONE = 6'd7,
				 INCR_FOR_I = 6'd8,
				 INIT_FOR = 6'd9,
				 CHECK_FOR_I = 6'd10,
				 SET_ADDR = 6'd11,
				 SET_DELAY1 = 6'd12,
				 SET_DELAY2 = 6'd13;
				 

	reg [5:0] STATE, NEXT_STATE;



//------------------------------------------------------------------
//                  -- Module Instantiations  --                   
//------------------------------------------------------------------

quantise quantise0(clk,1,startq,m0,orderi0,in_lsp_hz0,besti0,doneq0);
quantise quantise1(clk,1,startq,m1,orderi1,in_lsp_hz1,besti1,doneq1);
quantise quantise2(clk,1,startq,m2,orderi2,in_lsp_hz2,besti2,doneq2);
quantise quantise3(clk,1,startq,m3,orderi3,in_lsp_hz3,besti3,doneq3);
quantise quantise4(clk,1,startq,m4,orderi4,in_lsp_hz4,besti4,doneq4);
quantise quantise5(clk,1,startq,m5,orderi5,in_lsp_hz5,besti5,doneq5);
quantise quantise6(clk,1,startq,m6,orderi6,in_lsp_hz6,besti6,doneq6);
quantise quantise7(clk,1,startq,m7,orderi7,in_lsp_hz7,besti7,doneq7);
quantise quantise8(clk,1,startq,m8,orderi8,in_lsp_hz8,besti8,doneq8);
quantise quantise9(clk,1,startq,m9,orderi9,in_lsp_hz9,besti9,doneq9);


qmult #(Q,N) mult0(RADTOHZ, in_lsp0, lsp_hz0);
qmult #(Q,N) mult1(RADTOHZ, in_lsp1, lsp_hz1);
qmult #(Q,N) mult2(RADTOHZ, in_lsp2, lsp_hz2);
qmult #(Q,N) mult3(RADTOHZ, in_lsp3, lsp_hz3);
qmult #(Q,N) mult4(RADTOHZ, in_lsp4, lsp_hz4);
qmult #(Q,N) mult5(RADTOHZ, in_lsp5, lsp_hz5);
qmult #(Q,N) mult6(RADTOHZ, in_lsp6, lsp_hz6);
qmult #(Q,N) mult7(RADTOHZ, in_lsp7, lsp_hz7);
qmult #(Q,N) mult8(RADTOHZ, in_lsp8, lsp_hz8);
qmult #(Q,N) mult9(RADTOHZ, in_lsp9, lsp_hz9);


 reg [3:0] i; 
 



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
		if(start_elsp == 1'b1)
		begin
			NEXT_STATE = INITVALUES;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INITVALUES:
	begin
		NEXT_STATE = INIT_FOR;
	end
	
	INIT_FOR:
	begin
		NEXT_STATE = CHECK_FOR_I;
	end
	
	CHECK_FOR_I:
	begin
		if(i < 4'd10)
		begin
			NEXT_STATE = SET_ADDR;
		end
		else
		begin
			NEXT_STATE = INIT_QUANTISE;
		end
	end
	
	SET_ADDR:
	begin
		NEXT_STATE = SET_DELAY1;
	end
	
	SET_DELAY1:
	begin
	NEXT_STATE = SET_DELAY2;
	end
	
	SET_DELAY2:
	begin
	NEXT_STATE = CALC_LSPHZ;
	end

	CALC_LSPHZ:
	begin
		NEXT_STATE = INCR_FOR_I;
	end
	
	INCR_FOR_I:
	begin
		NEXT_STATE = CHECK_FOR_I;
	end
	
	INIT_QUANTISE:
	begin
		NEXT_STATE = START_QUANTISE;
	end
	
	START_QUANTISE:
	begin
		NEXT_STATE = CALC_INDEX;
	end
	
	CALC_INDEX:
	begin
		if(doneq0 && doneq1 && doneq2 && doneq3 && doneq4 && doneq5 && doneq6 && doneq7 && doneq8 && doneq9)
		begin
			NEXT_STATE = RECORD_INDEX;
		end
		else
		begin
			NEXT_STATE = CALC_INDEX;
		end
	end
	
	RECORD_INDEX:
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
		done_elsp <= 1'b0;	
	end

	else
	begin
		case(STATE)
		START:
		begin
			done_elsp <= 1'b0;
			startq <= 1'b0;
		end

		INITVALUES:
		begin	
			
		end
		
		INIT_FOR:
		begin
			i <= 4'd0;
		end
		
		CHECK_FOR_I:
		begin
		
		end
		
		SET_ADDR:
		begin
			addr_lsp <= i;
		end
		
		SET_DELAY1:
		begin
		
		end
		
		SET_DELAY2:
		begin
		
		end

		CALC_LSPHZ:
		begin
			case(i)
			
			4'd0:	in_lsp0 <= lsp_out;
			4'd1:	in_lsp1 <= lsp_out;
			4'd2:	in_lsp2 <= lsp_out;
			4'd3:	in_lsp3 <= lsp_out;
			4'd4:	in_lsp4 <= lsp_out;
			4'd5:	in_lsp5 <= lsp_out;
			4'd6:	in_lsp6 <= lsp_out;
			4'd7:	in_lsp7 <= lsp_out;
			4'd8:	in_lsp8 <= lsp_out;
			4'd9:	in_lsp9 <= lsp_out;
			
			endcase
			
			c_lsp <= lsp_out;
		end
		
		INCR_FOR_I:
		begin
			i <= i + 4'd1;
		end
		
		INIT_QUANTISE:
		begin
			
			in_lsp_hz0 <= lsp_hz0;
			in_lsp_hz1 <= lsp_hz1;
			in_lsp_hz2 <= lsp_hz2;
			in_lsp_hz3 <= lsp_hz3;
			in_lsp_hz4 <= lsp_hz4;
			in_lsp_hz5 <= lsp_hz5;
			in_lsp_hz6 <= lsp_hz6;
			in_lsp_hz7 <= lsp_hz7;
			in_lsp_hz8 <= lsp_hz8;
			in_lsp_hz9 <= lsp_hz9;	
			
		end
		
		START_QUANTISE:
		begin
			startq <= 1'b1;
		end

		CALC_INDEX:
		begin
		end
      
		RECORD_INDEX:
		begin 
		   indexes0 <= besti0;
			indexes1 <= besti1;
			indexes2 <= besti2;
			indexes3 <= besti3;
			indexes4 <= besti4;
			indexes5 <= besti5;
			indexes6 <= besti6;
			indexes7 <= besti7;
			indexes8 <= besti8;
			indexes9 <= besti9;
			//besti_check0 <= besti0;
			//in_lsp_hz_check0 <= lsp_hz0;
		end
		
		DONE:
		begin
			done_elsp <= 1'b1;
		end

		endcase
	end

end




endmodule