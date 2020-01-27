/*
* Module         - autocorrelate
* Top module     - speech_to_uq_lsps
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Sat Feb 09 21:16:58 2019
*
* Description    -
* Inputs         -
* Simulation     - Waveform28.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module autocorrelate_rn_ram (	startac,clk,rst,sn_read_data1,
										rn0,rn1,rn2,rn3,rn4,rn5,
										rn6,rn7,rn8,rn9,rn10,sn_addr1,doneac);
	

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	input clk, rst, startac;
	input [N-1:0] sn_read_data1;
	output reg doneac;
	output reg [N-1:0] rn0,rn1,rn2,rn3,rn4,rn5,rn6,rn7,rn8,rn9,rn10;
	output reg [8:0] sn_addr1; 
	

	reg [N-1:0] out_rn_final;
	

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------


parameter START = 5'd0,
          INIT_VALUES = 5'd1,
          INIT_LOOP = 5'd2,
          INIT_I = 5'd3,
          SET_ADDR = 5'd4,
          SET_SN = 5'd5,
			 CALC_SN = 5'd6,
          SET_RN = 5'd7,
          INCR_I = 5'd8,
          CHECK_I = 5'd9,
			 SET_OUT_RN = 5'd10,
          INCR_J = 5'd11,
          CHECK_J = 5'd12,
			 CHECK_RN = 5'd13,
          DONE = 5'd14,
		  SET_ADDR1 = 5'd15,
		  SET_SN1 = 5'd16,
		  SET_DELAY1 = 5'd17,
		  SET_DELAY2 = 5'd18,
		  SET_DELAY3 = 5'd19,
		  SET_DELAY4 = 5'd20;

reg [4:0] STATE, NEXT_STATE;

reg [8:0] i,j;


parameter [8:0] nsam  = 9'b101000000; 
parameter [8:0] order = 9'b000001010; 

reg [N-1:0] in_rn,in_sn,in_sn1,in_sn2;

wire [N-1:0] out_sn,out_rn;

reg rn_read, rn_write, rn_read1,rn_write1 ;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

qmult #(Q,N) mult1  (in_sn1,in_sn2,out_sn);
qadd  #(Q,N) adder1 (in_rn,in_sn,out_rn);


//RAM_autocorrelate_Sn ram1_sn(sn_addr1,clk,,1,0,sn_read_data1);
//RAM_autocorrelate_Sn ram2_sn(sn_addr2,clk,,1,0,sn_read_data2);



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
		if(startac)
		begin
			NEXT_STATE = INIT_VALUES;
		end
		else
		begin
			NEXT_STATE = START;
		end
	end

	INIT_VALUES:
	begin
		NEXT_STATE = INIT_LOOP;
	end

	INIT_LOOP:
	begin
		NEXT_STATE = INIT_I;
	end

	INIT_I:
	begin
		NEXT_STATE = SET_ADDR;
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
		NEXT_STATE = SET_SN;
	end
			
	SET_SN:
	begin
		NEXT_STATE = SET_ADDR1;
	end
	
	SET_ADDR1:
	begin
		NEXT_STATE = SET_DELAY3;
	end
	
	SET_DELAY3:
	begin
		NEXT_STATE = SET_DELAY4;
	end
	
	SET_DELAY4:
	begin
		NEXT_STATE = SET_SN1;
	end

	SET_SN1:
	begin
		NEXT_STATE = CALC_SN;
	end
	
	CALC_SN:
	begin
		NEXT_STATE = SET_RN;
	end

	SET_RN:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i < (nsam - j))
		begin
			NEXT_STATE = SET_ADDR;
		end
		else
		begin
			NEXT_STATE = SET_OUT_RN;
		end
	end
	
	SET_OUT_RN:
	begin
		NEXT_STATE = INCR_J;
	end

	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end

	CHECK_J:
	begin
		if( j < (order + 1))
		begin
			NEXT_STATE = INIT_LOOP;
		end
		else
		begin
			NEXT_STATE = CHECK_RN;
		end
	end

	CHECK_RN:
	begin
		NEXT_STATE = DONE;
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
	   doneac <= 1'b0;
		i <= 9'b0;
		j <= 9'b0;
	end

	else
	begin
		case(STATE)

		START:
		begin
		
		end

		INIT_VALUES:
		begin
			i <= 9'b0;
			j <= 9'b0;
		end

		INIT_LOOP:
		begin
			in_rn <= 32'b0;
		end

		INIT_I:
		begin
			i <= 9'b0;
		end

		SET_ADDR:
		begin
			sn_addr1 <= i;
			//sn_addr2 <= i + j;
			
		end
		
		SET_DELAY1:
		begin
		
		
		end
		
		SET_DELAY2:
		begin
		
		
		end
		

		SET_SN:
		begin
			in_sn1 <= sn_read_data1;
			//in_sn2 <= sn_read_data2;
		end
		
		SET_ADDR1:
		begin
			sn_addr1 <= i + j;
			//sn_addr2 <= i + j;
			
		end
		
		SET_DELAY3:
		begin
		
		
		end
		
		SET_DELAY4:
		begin
		
		
		end
		

		SET_SN1:
		begin
			//in_sn1 <= sn_read_data1;
			in_sn2 <= sn_read_data1;
		end
		
		CALC_SN:
		begin
			in_sn <= out_sn;
		end

		SET_RN:
		begin
			in_rn <= out_rn;
			
			out_rn_final <= out_rn;
		end

		INCR_I:
		begin
			i <= i + 9'b1;
		end

		CHECK_I:
		begin
			
		end

		SET_OUT_RN:
		begin
			case (j)
			4'd0: rn0 <= out_rn_final;
			4'd1: rn1 <= out_rn_final;
			4'd2: rn2 <= out_rn_final;
			4'd3: rn3 <= out_rn_final;
			4'd4: rn4 <= out_rn_final;
			4'd5: rn5 <= out_rn_final;
			4'd6: rn6 <= out_rn_final;
			4'd7: rn7 <= out_rn_final;
			4'd8: rn8 <= out_rn_final;
			4'd9: rn9 <= out_rn_final;
			4'd10: rn10 <= out_rn_final;
			endcase
		end
		
		INCR_J:
		begin
			j <= j + 9'b1;


		end

		CHECK_J:
		begin
		
		end
		
		CHECK_RN:
		begin

		end

		DONE:
		begin	
			doneac <= 1'b1;
		end

		endcase
	end

end


endmodule