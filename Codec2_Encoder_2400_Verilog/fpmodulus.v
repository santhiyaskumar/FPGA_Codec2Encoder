module fpmodulus (startfmod,clk,rst,num1,num2,mod,donefmod);

	parameter N = 32;
	parameter Q = 16;
	
	input clk, rst, startfmod;
	input [N-1:0] num1;
	input [N-1:0] num2;
	
	
	output reg [N-1:0] mod;
	output reg donefmod;
	
	 reg [4:0] c_here;

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------


//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          CHECK_IF = 3'd1,
          CALC_MOD = 3'd2,
          DONE = 3'd3,
		  ASSIGN_MOD = 3'd4,
		  SET_IF = 3'd5,
		  SET_MOD = 3'd6;

reg [2:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [N-1:0] a1_in1,a1_in2,gt1_in1,gt1_in2;
wire [N-1:0] a1_out;
wire gt1;

reg [N-1:0] c_num2 = 32'b00000000000001100100100001111110;

qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
fpgreaterthan	#(Q,N)    		fpgt1      (gt1_in1,gt1_in2,gt1);	

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
		if(startfmod)
		begin
			NEXT_STATE = SET_MOD;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end
	
	
	SET_MOD:
	begin
		NEXT_STATE = SET_IF;
	end
	
	SET_IF:
	begin
		NEXT_STATE = CHECK_IF;
	end

	CHECK_IF:
	begin
		if(gt1 || (mod == num2))
		begin
			NEXT_STATE = CALC_MOD;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
		
	end

	CALC_MOD:
	begin
		NEXT_STATE = ASSIGN_MOD;
	end
	
	ASSIGN_MOD:
	begin
		NEXT_STATE = SET_IF;
	end

	DONE:
	begin
		NEXT_STATE = START;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		

	end

	else
	begin
		case(STATE)

		START:
		begin
			donefmod <= 1'b0;
			
		end
		
		SET_MOD:
		begin
			mod <=  num1;//{8'b0,8'h15,16'hA5C2}; //num1;
		end
		
		
		SET_IF:
		begin
			gt1_in1 <= mod;
			gt1_in2 <= num2;
		end

		CHECK_IF:
		begin
			
		end

		CALC_MOD:
		begin
			a1_in1 <= mod;
			a1_in2 <= {(num2[N-1] == 0)?1'b1:1'b0,num2[N-2:0]};
			c_here <= 5'hf;
		end
		
		ASSIGN_MOD:
		begin
			mod <= a1_out;
		end

		DONE:
		begin
			donefmod <= 1'b1;
			//mod <= a1_out;
		end

		endcase
	end

end


endmodule