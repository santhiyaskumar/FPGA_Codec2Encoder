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

module encode_lsp_scalar_index (start_elsp,clk,rst,index,
									in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9,
									out_index,
									done_elsp
	
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
	//input [N-1:0] lsp_out;
	input [3:0] index;
	output reg done_elsp;
	output reg [3:0] out_index;
	//addr_lsp;//,besti_check0;
	
	//output reg [N-1:0] c_lsp;
	
	input [N-1:0] in_lsp0,in_lsp1,in_lsp2,in_lsp3,in_lsp4,in_lsp5,in_lsp6,in_lsp7,in_lsp8,in_lsp9;
	
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
	wire [3:0] 	 besti;
	reg [3:0] besti0,besti1,besti2,besti3,besti4,
					 besti5,besti6,besti7,besti8,besti9;	
	
	reg [N-1:0] in_lsp_hz,in_lsp_hz0,in_lsp_hz1,in_lsp_hz2,in_lsp_hz3,in_lsp_hz4,
					in_lsp_hz5,in_lsp_hz6,in_lsp_hz7,in_lsp_hz8,in_lsp_hz9;
	
	
	
	
	reg startq;
	reg [4:0] m,quanti;
	reg [3:0] orderi;
	
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
						 
	wire doneq,doneq0,doneq1,doneq2,doneq3,doneq4,doneq5,doneq6,doneq7,doneq8,doneq9;


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
				 SET_DELAY2 = 6'd13,
				 INIT_QUANT_FOR = 6'd14,
				 CHECK_QUANT_I = 6'd15,
				 INCR_QUANT_I = 6'd16,
				 RECORD_BEST_I = 6'd17;
				 

	reg [5:0] STATE, NEXT_STATE;



//------------------------------------------------------------------
//                  -- Module Instantiations  --                   
//------------------------------------------------------------------

quantise quantise0(clk,1,startq,m,orderi,in_lsp_hz,besti,doneq);



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
			NEXT_STATE = INIT_QUANT_FOR;//INIT_QUANTISE;
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
	
	INIT_QUANT_FOR:
	begin
		NEXT_STATE = CHECK_QUANT_I;
	end
	
	CHECK_QUANT_I:
	begin
		if(quanti >= 4'd10)
		begin
			NEXT_STATE = RECORD_INDEX;
		end
		else
		begin
			NEXT_STATE = INIT_QUANTISE;
		end
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
		if(doneq)
		begin
			NEXT_STATE = RECORD_BEST_I;
		end
		else
		begin
			NEXT_STATE = CALC_INDEX;
		end
	end
	
	RECORD_BEST_I:
	begin
		NEXT_STATE = INCR_QUANT_I;
	end
	
	RECORD_INDEX:
	begin
		NEXT_STATE = DONE;
	end
	
	
	INCR_QUANT_I:
	begin
		NEXT_STATE = CHECK_QUANT_I;
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
			
			
			/* in_lsp0 <= 16'h11E6;
			in_lsp1 <= 16'h5C1E;
			in_lsp2 <= 16'hBC5E;
			in_lsp3 <= 16'hF156;
			in_lsp4 <= 32'h13E6A;
			in_lsp5 <= 32'h1894E;
			in_lsp6 <= 32'h1DE4A;
			in_lsp7 <= 32'h2309A;
			in_lsp8 <= 32'h281EE;
			in_lsp9 <= 32'h2DB06;    // Actual
			 */
			 
		 /* in_lsp0 <= 16'h12A9;
			in_lsp1 <= 16'h5779;
			in_lsp2 <= 16'hB990;
			in_lsp3 <= 16'hEEE2;
			in_lsp4 <= 32'h13D57;
			in_lsp5 <= 32'h186D6;
			in_lsp6 <= 32'h1DD7C;
			in_lsp7 <= 32'h22E76;
			in_lsp8 <= 32'h2810C;
			in_lsp9 <= 32'h2D02D;  */   // Expected  c code base
			
			
			/* in_lsp0 <= 16'h12E2;
			in_lsp1 <= 16'h577E;
			in_lsp2 <= 16'hB996;
			in_lsp3 <= 16'hEEDE;
			in_lsp4 <= 32'h13D82;
			in_lsp5 <= 32'h186F2;
			in_lsp6 <= 32'h1DD76;
			in_lsp7 <= 32'h22E72;
			in_lsp8 <= 32'h28126;
			in_lsp9 <= 32'h2CFE2;    // Actual Dec 2
			 
			
			index <= 4'd9;  */
		end

		INITVALUES:
		begin	
			startq <= 1'b0;
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
			//addr_lsp <= i;
		end
		
		SET_DELAY1:
		begin
		
		end
		
		SET_DELAY2:
		begin
		
		end

		CALC_LSPHZ:
		begin
			/* case(i)
			
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
			
			c_lsp <= lsp_out; */
		end
		
		INCR_FOR_I:
		begin
			i <= i + 4'd1;
		end
		
		INIT_QUANT_FOR:
		begin
			quanti <= 4'd0;
		end
		
		CHECK_QUANT_I:
		begin
			
		end
		
		INIT_QUANTISE:
		begin
			
			case(quanti)
			4'd0:
			begin
				in_lsp_hz <= lsp_hz0;
				m <= m0;
				orderi <= orderi0;
			end
			4'd1:
			begin
				in_lsp_hz <= lsp_hz1;
				m <= m1;
				orderi <= orderi1;
			end
			4'd2:
			begin
				in_lsp_hz <= lsp_hz2;
				m <= m2;
				orderi <= orderi2;
			end
			4'd3:
			begin
				in_lsp_hz <= lsp_hz3;
				m <= m3;
				orderi <= orderi3;
			end
			4'd4:
			begin
				in_lsp_hz <= lsp_hz4;
				m <= m4;
				orderi <= orderi4;
			end
			4'd5:
			begin
				in_lsp_hz <= lsp_hz5;
				m <= m5;
				orderi <= orderi5;
			end
			4'd6:
			begin
				in_lsp_hz <= lsp_hz6;
				m <= m6;
				orderi <= orderi6;
			end
			4'd7:
			begin
				in_lsp_hz <= lsp_hz7;
				m <= m7;
				orderi <= orderi7;
			end
			4'd8:
			begin
				in_lsp_hz <= lsp_hz8;
				m <= m8;
				orderi <= orderi8;
			end
			4'd9:
			begin
				in_lsp_hz <= lsp_hz9;
				m <= m9;
				orderi <= orderi9;
			end

			endcase
			
		end
		
		START_QUANTISE:
		begin
			startq <= 1'b1;
		end

		CALC_INDEX:
		begin
			//startq <= 1'b0;
		end
		
		RECORD_BEST_I:
		begin
			case(quanti)
			
			4'd0:	besti0 <= besti;
			4'd1:	besti1 <= besti;
			4'd2:	besti2 <= besti;
			4'd3:	besti3 <= besti;
			4'd4:	besti4 <= besti;
			4'd5:	besti5 <= besti;
			4'd6:	besti6 <= besti;
			4'd7:	besti7 <= besti;
			4'd8:	besti8 <= besti;
			4'd9:	besti9 <= besti;
			
			endcase
		end
      
		RECORD_INDEX:
		begin 
		
		 /*    indexes0 <= besti0;
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
			//in_lsp_hz_check0 <= lsp_hz0; */
			
			
			 case(index)
			
			4'd0:	out_index <= besti0;
			4'd1:	out_index <= besti1;
			4'd2:	out_index <= besti2;
			4'd3:	out_index <= besti3;
			4'd4:	out_index <= besti4;
			4'd5:	out_index <= besti5;
			4'd6:	out_index <= besti6;
			4'd7:	out_index <= besti7;
			4'd8:	out_index <= besti8;
			4'd9:	out_index <= besti9;
			
			endcase
		end
		
		INCR_QUANT_I:
		begin
			quanti <= quanti + 1'b1;
		end
		
		DONE:
		begin
			done_elsp <= 1'b1;
		end

		endcase
	end

end




endmodule