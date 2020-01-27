/*
* Module         - quantise_ROM
* Top module     - encode_lsps_scalar
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue Feb 05 13:00:43 2019
*
* Description    -
* Inputs         -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
	
	Simulation file : Waveform17.vwf
*/

module quantise_ROM (clk,rst,m,orderi,vec,besti,doneq);

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	input clk,rst;
	input [4:0] m;
	input [3:0] orderi;
	input [N-1:0] vec;
	
	output reg [4:0] besti;
	output reg doneq;
	reg [N-1:0] e;
	
	reg [N-1:0] beste = 32'b0_111111111111111_1111111111111111;
	reg [N-1:0] cb;
	reg [N-1:0] in_e,in_beste;
	reg [4:0] j;
	
	reg [N-1:0] in_e1,in_e2;
	reg [N-1:0] abs_e;
	wire [N-1:0] power_e;
	
	wire [N-1:0] out_e;
	wire lt1;
	
					 
	
// Cb values
	reg [3:0] cb_select,cb_addr;
	wire [N-1:0] cb_dataout;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 4'd0,
          INITVALUES = 4'd1,
          INITLOOP = 4'd2,
			 SETCB = 4'd3,
          CALCERROR = 4'd4,
			 POWERE = 4'd5,
          BESTECHECK = 4'd6,
          INCRJ = 4'd7,
          CHECKJ = 4'd8,
          CALCSE = 4'd9,
          DONE = 4'd10;

reg [3:0] STATE, NEXT_STATE;

//------------------------------------------------------------------
//                  -- Module Instantiations  --                   
//------------------------------------------------------------------

cbselect cbselect_module(cb_select,cb_addr,cb_dataout);  // select cb0 to cb9, addr 0 to 15, dataout is cb.

// 15 adder modules reduced to 1.

qadd #(Q,N) qadd0(cb,{(vec[N-1] == 0)?1'b1:1'b0,vec[N-2:0]},out_e); 		
	

fplessthan #(Q,N) fplt1(in_e,in_beste,lt1);

qmult #(Q,N) mult1(in_e1,in_e2,power_e);

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
		NEXT_STATE = INITVALUES;
	end

	INITVALUES:
	begin
		NEXT_STATE = INITLOOP;
	end

	INITLOOP:
	begin
		NEXT_STATE = SETCB;
	end
	
	SETCB:
	begin
		NEXT_STATE = CALCERROR;
	end

	CALCERROR:
	begin
		NEXT_STATE = POWERE;
	end
	
	POWERE:
	begin
		NEXT_STATE = BESTECHECK;
	end

	BESTECHECK:
	begin
		NEXT_STATE = INCRJ;
	end

	INCRJ:
	begin
		NEXT_STATE = CHECKJ;
	end

	CHECKJ:
	begin
		if(j < m) 
		begin
			NEXT_STATE = INITLOOP;
		end
		else 
		begin
			NEXT_STATE = CALCSE;
		end
	end

	CALCSE:
	begin
		NEXT_STATE = DONE;
	end

	DONE:
	begin
		NEXT_STATE = DONE;
	end


	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin
		besti <= 5'b0;
		e <= 32'b0;
		beste <= 32'b0_111111111111111_1111111111111111;
		j <= 5'd0;
	end

	else
	begin
		case(STATE)

		START:
		begin
			doneq <= 1'b0;
		end

		INITVALUES:
		begin
			besti <= 5'b0;
			beste <= 32'b0_111111111111111_1111111111111111;
			j <= 5'd0;
			cb_select <= orderi;
		end

		INITLOOP:
		begin
			e <= 32'b0;
			cb_addr <= j;
			
		end
		
		SETCB:
		begin
			cb <= cb_dataout;
		end

		CALCERROR:
		begin
			e <= out_e;		
		end
		
		POWERE:
		begin
				//in_e1 <= e;
				//in_e2 <= e;
				abs_e <= {(e[N-1] == 1)?1'b0:1'b0,e[N-2:0]};
		end

		BESTECHECK:
		begin
				in_e <= abs_e;
				in_beste <= beste;
		end

		INCRJ:
		begin
				j <= j + 5'd1;
				if(lt1)
				begin
					beste <= abs_e;
					besti <= j;
				end
		end

		CHECKJ:
		begin
				
		end

		CALCSE:
		begin
			
		end

		DONE:
		begin
			doneq <= 1'b1;
		end

		endcase
	end

end


endmodule