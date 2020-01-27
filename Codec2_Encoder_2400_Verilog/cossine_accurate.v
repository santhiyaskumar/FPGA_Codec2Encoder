module cossine_accurate (startcs,clk,rst,angle,cos,sin,donecs);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
			parameter N = 32;
			parameter Q = 16;

			input clk,rst,startcs;

			input [N-1:0] angle;
			output reg [N-1:0] cos,sin;
			output reg donecs;

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 4'd0,
          INIT_MOD = 4'd1,
          CALC_MOD = 4'd2,
          INIT_FOR = 4'd3,
          CHECK_I = 4'd4,
          SET_REC = 4'd5,
          MULT_1 = 4'd6,
          MULT_2 = 4'd7,
          ADD = 4'd8,
          SET_SUM = 4'd9,
          INCR_I = 4'd10,
          SET_SIN_COS = 4'd11,
          DONE = 4'd12,
		  MULT_3 = 4'd13,
		  SET_T = 4'd14;

reg [3:0] STATE, NEXT_STATE;

parameter [N-1:0] TWO_PI 		= 32'b00000000000001100100100001111110,
					ONE 		= 32'b00000000000000010000000000000000;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg [3:0] i;
reg [N-1:0] t,t1,sum,sum1,rec1,rec2;


reg startfmod;
reg [N-1:0] num1,num2;
wire [N-1:0] mod;
wire donefmod;

reg 			[N-1:0] 		m1_in1,m1_in2,a1_in1,a1_in2,a2_in1,a2_in2,
								lt1_in1,lt1_in2,lt2_in1,lt2_in2,
								m2_in1,m2_in2;
								
wire 			[N-1:0] 		m1_out,a1_out,m2_out,a2_out;


fpmodulus (startfmod,clk,rst,num1,num2,mod,donefmod);
qmult  			#(Q,N) 			qmult1	   (m1_in1,m1_in2,m1_out);
qadd   			#(Q,N)			adder1     (a1_in1,a1_in2,a1_out);
qmult  			#(Q,N) 			qmult2	   (m2_in1,m2_in2,m2_out);
qadd   			#(Q,N)			adder2     (a2_in1,a2_in2,a2_out);

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
		if(startcs)
		begin
			NEXT_STATE = INIT_MOD;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_MOD:
	begin
		NEXT_STATE = CALC_MOD;
	end

	CALC_MOD:
	begin
		if(donefmod)
		begin
			NEXT_STATE = INIT_FOR;
		end
		else
		begin
			NEXT_STATE = CALC_MOD;
		end
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i > 4'd10)
		begin
			NEXT_STATE = SET_SIN_COS;
		end
		else
		begin
			NEXT_STATE = SET_REC;
		end
	end

	SET_REC:
	begin
		NEXT_STATE = MULT_1;
	end

	MULT_1:
	begin
		NEXT_STATE = MULT_2;
	end

	MULT_2:
	begin
		NEXT_STATE = MULT_3;
	end
	
	MULT_3:
	begin
		NEXT_STATE = SET_T;
	end
	
	SET_T:
	begin
		NEXT_STATE = ADD;
	end

	ADD:
	begin
		NEXT_STATE = SET_SUM;
	end

	SET_SUM:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	SET_SIN_COS:
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

		

	end

	else
	begin
		case(STATE)

		START:
		begin
			donecs <= 1'b0;
			
		end

		INIT_MOD:
		begin
			startfmod <= 1'b1;
			num1 <= angle;//{8'b0,8'h15,16'hA5C2}; //angle; //// // //1.22717
			num2 <= TWO_PI;
		end

		CALC_MOD:
		begin
			startfmod <= 1'b0;
		end

		INIT_FOR:
		begin
			t <= mod;
			sum <= mod;
			
			t1 <= ONE;
			sum1 <= ONE;
			
			i <= 4'd1;
		
			
			
		end

		CHECK_I:
		begin
			
		end

		SET_REC:
		begin
			case(i)
			4'd1:
			begin
			   rec1 <= {16'b0,16'h2AAB};   	// 0.166666667;
			   rec2 <= {16'b0,16'h8000};  	// 0.500000000;
			end
			4'd2:
			begin
			   rec1 <= {16'b0,16'h0CCD};	//0.050000000;
			   rec2 <= {16'b0,16'h1555};	//0.083333333;
			end
			4'd3:
			begin
			   rec1 <= {16'b0,16'h0618}; //0.023809524;
			   rec2 <= {16'b0,16'h0888}; //0.033333333;
			end
			4'd4:
			begin
			   rec1 <= {16'b0,16'h038E}; //0.013888889;
			   rec2 <= {16'b0,16'h0492}; //0.017857143;
			end
			4'd5:
			begin
			   rec1 <= {16'b0,16'h0254}; //0.009090909;
			   rec2 <= {16'b0,16'h02D8}; //0.011111111;
			end
			4'd6:
			begin
			   rec1 <= {16'b0,16'h01A4}; //0.006410256;
			   rec2 <= {16'b0,16'h01F0};//0.007575758;
			end
			4'd7:
			begin
			   rec1 <= {16'b0,16'h0138}; //0.004761905;
			   rec2 <= {16'b0,16'h0168}; //0.005494505;
			end
			4'd8:
			begin
			   rec1 <= {16'b0,16'h00F1}; //0.003676471;
			   rec2 <= {16'b0,16'h0111}; //0.004166667;
			end
			4'd9:
			begin
			   rec1 <= {16'b0,16'h00F0}; //0.002923977;
			   rec2 <= {16'b0,16'h00D6}; //0.003267974;
			end
			4'd10:
			begin
			   rec1 <= {16'b0,16'h009C}; //0.002380952;
			   rec2 <= {16'b0,16'h00AC}; //0.002631579;
			end
			
			
			endcase
		end

		MULT_1:
		begin
			m1_in1 <= mod;
			m1_in2 <= mod;
			
			m2_in1 <= mod;
			m2_in2 <= mod;
		end

		MULT_2:
		begin
			m1_in1 <= m1_out;
			m1_in2 <= t;
			
			m2_in1 <= m2_out;
			m2_in2 <= t1;
			
		end
		
		MULT_3:
		begin
			m1_in1 <= m1_out;
			m1_in2 <= rec1;
			
			m2_in1 <= m2_out;
			m2_in2 <= rec2;
			
		end
		
		SET_T:
		begin
			t <= {(m1_out[N-1] == 0)?1'b1:1'b0,m1_out[N-2:0]};
			t1 <= {(m2_out[N-1] == 0)?1'b1:1'b0,m2_out[N-2:0]};
		end

		ADD:
		begin
			a1_in1 <= t;
			a1_in2 <= sum;
			
			a2_in1 <= t1;
			a2_in2 <= sum1;
		end

		SET_SUM:
		begin
			sum <= a1_out;
			sum1 <= a2_out;
			
			
			
		end

		INCR_I:
		begin
			i <= i + 4'd1;
		end

		SET_SIN_COS:
		begin
			sin <= sum;
			cos <= sum1;
		end

		DONE:
		begin
			donecs <= 1'b1;
		end

		endcase
	end

end


endmodule