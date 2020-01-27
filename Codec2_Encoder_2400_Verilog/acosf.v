/*
* Module         - acosf
* Top module     - lpc_to_lsp
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Tue Mar 05 19:36:27 2019
*
* Description    - 
* Inputs         -
* Simulation     -
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


/*
double arccos_cordic ( double t, int n )

//
//
//  Purpose:
//
//    ARCCOS_CORDIC returns the arccosine of an angle using the CORDIC method.
//
//  Licensing:
//
//    This code is distributed under the GNU LGPL license.
//
//  Modified:
//
//    16 June 2007
//
//  Author:
//
//    John Burkardt
//
//  Reference:
//
//    Jean-Michel Muller,
//    Elementary Functions: Algorithms and Implementation,
//    Second Edition,
//    Birkhaeuser, 2006,
//    ISBN13: 978-0-8176-4372-0,
//    LC: QA331.M866.
//
//  Parameters:
//
//    Input, double T, the cosine of an angle.  -1 <= T <= 1.
//
//    Input, int N, the number of iterations to take.
//    A value of 10 is low.  Good accuracy is achieved with 20 or more
//    iterations.
//
//    Output, double ARCCOS_CORDIC, an angle whose cosine is T.
//
//  Local Parameters:
//
//    Local, double ANGLES(60) = arctan ( (1/2)^(0:59) );
//
{
# define ANGLES_LENGTH 17

    double angle;
    double angles[ANGLES_LENGTH] = {
            7.8539816339744830962E-01,
            4.6364760900080611621E-01,
            2.4497866312686415417E-01,
            1.2435499454676143503E-01,
            6.2418809995957348474E-02,
            3.1239833430268276254E-02,
            1.5623728620476830803E-02,
            7.8123410601011112965E-03,
            3.9062301319669718276E-03,
            1.9531225164788186851E-03,
            9.7656218955931943040E-04,
            4.8828121119489827547E-04,
            2.4414062014936176402E-04,
            1.2207031189367020424E-04,
            6.1035156174208775022E-05,
            3.0517578115526096862E-05,
            1.5258789061315762107E-05,


     };
    int i;
    int j;
    double poweroftwo;
    double sigma;
    double sign_z2;
    double theta;
    double x1;
    double x2;
    double y1;
    double y2;

    if ( 1.0 < fabs ( t ) )
    {
        cerr << "\n";
        cerr << "ARCCOS_CORDIC - Fatal error!\n";
        cerr << "  1.0 < |T|.\n";
        exit ( 1 );
    }

    theta = 0.0;
    x1 = 1.0;
    y1 = 0.0;
    poweroftwo = 1.0;

    for ( j = 1; j <= n; j++ )
    {
        if ( y1 < 0.0 )
        {
            sign_z2 = -1.0;
        }
        else
        {
            sign_z2 = +1.0;
        }

        if ( t <= x1 )
        {
            sigma = + sign_z2;
        }
        else
        {
            sigma = - sign_z2;
        }

        if ( j <= 10 )
        {
            angle = angles[j-1];
        }
        else
        {
            angle = angle / 2.0;
        }

        for ( i = 1; i <= 2; i++ )
        {
            x2 = x1 - sigma * poweroftwo * y1;
            y2 = sigma * poweroftwo * x1 + y1;

            x1 = x2;
            y1 = y2;
        }

        theta  = theta + 2.0 * sigma * angle;

        t = t + t * poweroftwo * poweroftwo;

        poweroftwo = poweroftwo / 2.0;
    }

    return theta;
# undef ANGLES_LENGTH
}


*/

module acosf (startacosf,clk,rst,value,theta,doneacosf);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
	parameter N = 32;
	parameter Q = 16;
	
	input clk, rst, startacosf;
	input [N-1:0] value;
	output reg [N-1:0] theta;

	output reg doneacosf;
	
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 5'd0,
          INIT = 5'd1,
          CHECK_J = 5'd2,
          IF_1 = 5'd3,
          IF_2_3 = 5'd4,
          SET_SIGMA = 5'd5,
          CHECK_I = 5'd6,
          PRE_CALC1_X2 = 5'd7,
          PRE_CALC2_X2 = 5'd8,
          PRE_CALC3_X2 = 5'd9,
          CALC_X2_Y2 = 5'd10,
          SET_X1_Y1 = 5'd11,
          INCR_I = 5'd12,
          CALC_THETA = 5'd13,
          CALC_T = 5'd14,
          SET_THETA = 5'd15,
          SET_POWER2 = 5'd16,
          INCR_J = 5'd17,
          DONE = 5'd18;

reg [4:0] STATE, NEXT_STATE;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

parameter [4:0]   count = 5'd15;
parameter [N-1:0] NUMBER_ONE = 32'b0_000000000000001_0000000000000000,
						NUMBER_NEG_ONE = 32'b10000000000000010000000000000000;

						
parameter [N-1:0] 	angles0  =  32'b00000000000000001100100100001111,
							angles1  =  32'b00000000000000000111011010110001,
							angles2  =  32'b00000000000000000011111010110110,
							angles3  =  32'b00000000000000000001111111010101,
							angles4  =  32'b00000000000000000000111111111010,
							angles5  =  32'b00000000000000000000011111111111,
							angles6  =  32'b00000000000000000000001111111111,
							angles7  =  32'b00000000000000000000000111111111,
							angles8  =  32'b00000000000000000000000011111111,
							angles9  =  32'b00000000000000000000000001111111,
							angles10  =  32'b00000000000000000000000000111111,
							angles11  =  32'b00000000000000000000000000011111,
							angles12  =  32'b00000000000000000000000000010000,
							angles13  =  32'b00000000000000000000000000001000,
							angles14  =  32'b00000000000000000000000000000100,
							angles15  =  32'b00000000000000000000000000000010,
							angles16  =  32'b00000000000000000000000000000001;	
		
reg [3:0] i;
reg [4:0] j;

reg [N-1:0] a1_in1,a1_in2,x1,y1,power2,angle,sign_z2,lt1_in1, lt1_in2,sigma,
			m1_in1,m1_in2,m2_in1,m3_in1,m2_in2,m3_in2,t,a2_in1,a2_in2,x2,y2;

wire [N-1:0] a1_out,a2_out, m1_out,m2_out, m3_out;
wire lt1;

qadd 			#(Q,N) 		adder1 	(a1_in1,a1_in2,a1_out);
qadd 			#(Q,N) 		adder2 	(a2_in1,a2_in2,a2_out);
qmult 		#(Q,N) 		mult1 	(m1_in1,m1_in2,m1_out);			
qmult 		#(Q,N) 		mult2 	(m2_in1,m2_in2,m2_out);						
qmult 		#(Q,N) 		mult3 	(m3_in1,m3_in2,m3_out);	
fplessthan 	#(Q,N) 		lt			(lt1_in1,lt1_in2,lt1);	



						
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
		if(startacosf)
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
		NEXT_STATE = CHECK_J;
	end

	CHECK_J:
	begin
		if(j <= count)
		begin
			NEXT_STATE = IF_1;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end

	IF_1:
	begin
		NEXT_STATE = IF_2_3;
	end

	IF_2_3:
	begin
		NEXT_STATE = SET_SIGMA;
	end

	SET_SIGMA:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i <= 4'd2)
		begin
			NEXT_STATE = PRE_CALC1_X2;
		end
		else
		begin
			NEXT_STATE = CALC_THETA;
		end
	end

	PRE_CALC1_X2:
	begin
		NEXT_STATE = PRE_CALC2_X2;
	end

	PRE_CALC2_X2:
	begin
		NEXT_STATE = PRE_CALC3_X2;
	end

	PRE_CALC3_X2:
	begin
		NEXT_STATE = CALC_X2_Y2;
	end

	CALC_X2_Y2:
	begin
		NEXT_STATE = SET_X1_Y1;
	end

	SET_X1_Y1:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	CALC_THETA:
	begin
		NEXT_STATE = CALC_T;
	end

	CALC_T:
	begin
		NEXT_STATE = SET_THETA;
	end

	SET_THETA:
	begin
		NEXT_STATE = SET_POWER2;
	end

	SET_POWER2:
	begin
		NEXT_STATE = INCR_J;
	end

	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
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

		theta <= 32'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			doneacosf <= 1'b0;
		end

		INIT:
		begin
			theta <= 32'b0;
			x1 <= NUMBER_ONE;
			y1 <= 32'b0;
			power2 <= NUMBER_ONE;
			j <= 5'd1;
			angle <= 32'b0;
			sign_z2 <= 32'b0;
			doneacosf <= 1'b0;
			sigma <= 32'b0;
			t <= value;
			
		end

		CHECK_J:
		begin
			lt1_in1 <= t;
			lt1_in2 <= x1;
		end

		IF_1:
		begin
			if(y1[N-1] == 1'b1)
			begin
				sign_z2 <= NUMBER_NEG_ONE;
			end
			else
			begin
				sign_z2 <= NUMBER_ONE;
			end
			
			a1_in1 <= sigma;
			
		end

		IF_2_3:
		begin
			if(lt1 || (t == x1))
			begin
				sigma <= sign_z2;
			end
			else
			begin
				sigma <= {(sign_z2[N-1] == 0)?1'b1:1'b0,sign_z2[N-2:0]};
			end
			
			if(j <= 5'd10)
			begin
				case (j)
				5'd1: angle <= angles0;
				5'd2: angle <= angles1;
				5'd3: angle <= angles2;
				5'd4: angle <= angles3;
				5'd5: angle <= angles4;
				5'd6: angle <= angles5;
				5'd7: angle <= angles6;
				5'd8: angle <= angles7;
				5'd9: angle <= angles8;
				5'd10: angle <= angles9;
				5'd11: angle <= angles10;
				5'd12: angle <= angles11;
				5'd13: angle <= angles12;
				5'd14: angle <= angles13;
				5'd15: angle <= angles14;
				5'd16: angle <= angles15;
				5'd17: angle <= angles16;
				default : angle <= angles16;
				endcase
			end
			else
			begin
				angle <= {angle[N-1],angle[N-2:0] >> 1};
			end
		end

		SET_SIGMA:
		begin
			
			i <= 4'd1;
		end

		CHECK_I:
		begin
			
		end

		PRE_CALC1_X2:
		begin
			m1_in1 <= sigma;
			m1_in2 <= power2;
			m2_in1 <= y1;
			m3_in1 <= x1;
		end

		PRE_CALC2_X2:
		begin
			m2_in2 <= m1_out;
			m3_in2 <= m1_out;
		end

		PRE_CALC3_X2:
		begin
			a1_in1 <= x1;
			a1_in2 <= {(m2_out[N-1] == 0)?1'b1:1'b0,m2_out[N-2:0]};
			a2_in1 <= y1;
			a2_in2 <= m3_out;
		end

		CALC_X2_Y2:
		begin
			x2 <= a1_out;
			y2 <= a2_out;
		end

		SET_X1_Y1:
		begin
			x1 <= x2;
			y1 <= y2;
		end

		INCR_I:
		begin
			i <= i + 4'd1;
			
			
		end

		CALC_THETA:
		begin
			a1_in1 <= theta;
			a2_in1 <= t;
			m1_in1 <= {sigma[N-1],sigma[N-2:0] << 1};
			m1_in2 <= angle;
			m2_in1 <= power2;
			m2_in2 <= power2;
			
		end

		CALC_T:
		begin
			a1_in2 <= m1_out;
			m1_in1 <= m2_out;
			m1_in2 <= t;
		end

		SET_THETA:
		begin
			a2_in2 <= m1_out;
			theta <= a1_out;
		end

		SET_POWER2:
		begin
			t <= a2_out;
			power2 <= {power2[N-1],power2[N-2:0] >> 1};
		end

		INCR_J:
		begin
			j <= j + 5'd1;
		end

		DONE:
		begin
			doneacosf <= 1'b1;
		end

		endcase
	end

end


endmodule




