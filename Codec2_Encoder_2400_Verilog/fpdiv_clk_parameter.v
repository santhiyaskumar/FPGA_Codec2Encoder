/*
* Module         - fpdiv_clk
* Top module     - codec2_encode_2400
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Fri Mar 15 21:26:48 2019
*
* Description    - Divison by Newton-Raphson Method - Calculates (1/den)
* Inputs         -
* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

/* C++ Code:

double fpdiv(double num){
    double mul = 1.0; // power of 2
    double d0 = num;
   
    while (d0 > 1) {
        // divide by 2, will
        // later divide by 2 again
       
        d0 = d0/2.0;
        mul = mul*2.0;
    }
    while (d0 < 0.5) {
        
        d0 = d0*2.0;
        mul = mul/2.0;
    }

    double x0 = 1;// 2.82353 - 1.88235 * d0;
    double x1;
    for (int i=0 ;i < 5  ;i++  ) {
        
        x1 = x0*(2 - d0*x0);
        x0 = x1;
    }

    double ans = x1/mul;
   
    return ans;
}


*/


module fpdiv_clk_parameter #(
	//Parameterized values
	parameter Q = 32,
	parameter N = 48
	) (startdiv,clk,rst,in,ans,donediv);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
		
	
		input clk, rst, startdiv;
		input [N-1:0] in;
		output reg donediv;
		output reg [N-1:0] ans;



//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 5'd1,
          SET_WHILE = 5'd2,
          WHILE_1 = 5'd3,
          WHILE_2 = 5'd4,
          INIT_LOOP = 5'd5,
          CALC1_X1 = 5'd6,
          CALC2_X1 = 5'd7,
          CALC3_X1 = 5'd8,
          SET_X1 = 5'd9,
          SET_X0 = 5'd10,
          INCR_I = 5'd11,
          CHECK_I = 5'd12,
          SET_ANS = 5'd13,
          DONE = 5'd14,
			 NEXT_WHILE = 5'd15,
			 SET_ANS_SIGN = 5'd16;

reg [4:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [N-1:0] NUMBER_TWO = {14'b0,2'b10,32'b0},
						NUMBER_ONE = {14'b0,2'b01,32'b0},
						NUMBER_POINT_FIVE = {16'b0,1'b1,31'b0};

						
reg [N-1:0] a1_in1,a1_in2,m1_in1,m1_in2,
			lt1_in1,lt1_in2,gt1_in1,gt1_in2,
			x0;
reg [N-1:0] x1,den;
reg [3:0] i;
reg [4:0] count;

wire [N-1:0] a1_out,m1_out;
wire lt1,gt1;

reg neg,ltflag,gtflag;


qadd 			#(Q,N) adder		(a1_in1, a1_in2, a1_out);
qmult 			#(Q,N) multiplier	(m1_in1, m1_in2, m1_out);
fplessthan	 	#(Q,N) lt			(lt1_in1,lt1_in2,lt1);
fpgreaterthan 	#(Q,N) gt    		(gt1_in1,gt1_in2,gt1);
	

				  
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
		if(startdiv)
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
		NEXT_STATE = SET_WHILE;
	end
	
	SET_WHILE:
	begin
		NEXT_STATE = NEXT_WHILE;
	end

	NEXT_WHILE:
	begin
		if(gt1)
		begin
			NEXT_STATE = WHILE_1;
		end
		else if(!gt1 && lt1)
		begin
			NEXT_STATE = WHILE_2;
		end
		else
		begin
			NEXT_STATE = INIT_LOOP;
		end
	end

	WHILE_1:
	begin
		NEXT_STATE = SET_WHILE;
	end

	WHILE_2:
	begin
		NEXT_STATE = SET_WHILE;
	end

	INIT_LOOP:
	begin
		NEXT_STATE = CALC1_X1;
	end

	CALC1_X1:
	begin
		NEXT_STATE = CALC2_X1;
	end

	CALC2_X1:
	begin
		NEXT_STATE = CALC3_X1;
	end

	CALC3_X1:
	begin
		NEXT_STATE = SET_X1;
	end

	SET_X1:
	begin
		NEXT_STATE = SET_X0;
	end

	SET_X0:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i <= 4'd10)
		begin
			NEXT_STATE = CALC1_X1;
		end
		else
		begin
			NEXT_STATE = SET_ANS;
		end
	end

	SET_ANS:
	begin
		NEXT_STATE = SET_ANS_SIGN;
	end
	
	SET_ANS_SIGN:
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

		donediv <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			donediv <= 1'b0;
		end

		INIT:
		begin
			count <= 5'd0;
			x0 	<= NUMBER_ONE;
			ltflag <= 1'b0;
			gtflag <= 1'b0;
			
			if(in[N-1] == 1'b1)
			begin
				neg <= 1'b1;
			end
			else
			begin
				neg <= 1'b0;
			end
			
			den 	<= {1'b0,in[N-2:0]};
			
		end

		SET_WHILE:
		begin
			gt1_in1 <= den;
			gt1_in2 <= NUMBER_ONE;
			lt1_in1 <= den;
			lt1_in2 <= NUMBER_POINT_FIVE;
		end
		
		NEXT_WHILE:
		begin
		
		end

		WHILE_1:
		begin
			den <= den >> 1;
			count <= count + 5'd1;
			gtflag <= 1'b1;
			
		end

		WHILE_2:
		begin
			den <= den << 1;
			ltflag <= 1'b1;
			count <= count + 5'd1;
		end

		INIT_LOOP:
		begin
			i <= 4'd0;
		end

		CALC1_X1:
		begin
			m1_in1 <= den;
			m1_in2 <= x0;
		end

		CALC2_X1:
		begin
			a1_in1 <= NUMBER_TWO;
			a1_in2 <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
		end

		CALC3_X1:
		begin
			m1_in1 <= x0;
			m1_in2 <= a1_out;
		end

		SET_X1:
		begin
			x1 <= m1_out;
		end

		SET_X0:
		begin
			x0 <= x1;
		end

		INCR_I:
		begin
			i <= i + 4'd1;
		end

		CHECK_I:
		begin
			
		end

		SET_ANS:
		begin
			if(gtflag)
			begin
				ans <= x1 >> count;
			end
			else if (!gtflag && ltflag)
			begin
				ans <= x1 << count;
			end
			else
			begin
				ans <= x1;
			end 
		end
		
		SET_ANS_SIGN:
		begin
			if(neg)
			begin
				ans[N-1] <= 1'b1;
			end
			else
			begin
				ans[N-1] <= 1'b0;
			end
		end

		DONE:
		begin
			donediv <= 1'b1;
		end

		endcase
	end

end


endmodule

