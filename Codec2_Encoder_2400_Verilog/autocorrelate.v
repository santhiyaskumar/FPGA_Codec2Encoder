/*
* Module         - autocorrelate
* Top module     - speech_to_uq_lsps
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Sat Feb 09 21:16:58 2019
*
* Description    - Writes to RAM_autocorrelate_Rn
* Inputs         -
* Simulation     - Waveform25.vwf
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module autocorrelate (startac,clk,rst,doneac);
	

//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------

	parameter N = 32;
	parameter Q = 16;
	
	input clk, rst, startac;
	output reg doneac;
	//output reg [N-1:0] in_sn1_check,out_rn_check,rn_write_data_check,ram_out_check;
	//output reg [8:0] rn_addr_check;
	

//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------


parameter START = 4'd0,
          INIT_VALUES = 4'd1,
          INIT_LOOP = 4'd2,
          INIT_I = 4'd3,
          SET_ADDR = 4'd4,
          SET_SN = 4'd5,
			 CALC_SN = 4'd6,
          SET_RN = 4'd7,
          INCR_I = 4'd8,
          CHECK_I = 4'd9,
			 SET_ADDR_RN = 4'd10,
          INCR_J = 4'd11,
          CHECK_J = 4'd12,
			 CHECK_RN = 4'd13,
          DONE = 4'd14;

reg [3:0] STATE, NEXT_STATE;

reg [8:0] i,j;

reg rn_clk,rn_clk1;

parameter [8:0] nsam = 9'b101000000;			//9'b101000000; 
parameter [8:0] order = 9'b000001010; 

reg [N-1:0] in_rn,in_sn,rn_write_data,in_sn1,in_sn2;
reg [8:0] sn_addr1,sn_addr2,rn_addr,rn_addr1;
wire [N-1:0] sn_read_data1,sn_read_data2,out_sn,out_rn,ram_out,ram_out1;

reg rn_read, rn_write, rn_read1,rn_write1 ;


//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

qmult #(Q,N) mult1  (in_sn1,in_sn2,out_sn);
qadd  #(Q,N) adder1 (in_rn,in_sn,out_rn);


RAM_autocorrelate_Sn ram1_sn(sn_addr1,clk,,1,0,sn_read_data1);
RAM_autocorrelate_Sn ram2_sn(sn_addr2,clk,,1,0,sn_read_data2);

RAM_autocorrelate_Rn ram1_rn(rn_addr,clk,rn_write_data,rn_read,rn_write,ram_out);
//RAM_autocorrelate_Rn ram2_rn(rn_addr1,rn_clk1,,rn_read1,rn_write1,ram_out1);


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
		NEXT_STATE = SET_SN;
	end

	SET_SN:
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
			NEXT_STATE = SET_ADDR_RN;
		end
	end
	
	SET_ADDR_RN:
	begin
		NEXT_STATE = INCR_J;
	end

	INCR_J:
	begin
		NEXT_STATE = CHECK_J;
	end

	CHECK_J:
	begin
		if( j < (order + 2))
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
		NEXT_STATE = DONE;
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
			sn_addr2 <= i + j;
			
		end

		SET_SN:
		begin
			in_sn1 <= sn_read_data1;
			in_sn2 <= sn_read_data2;
		end
		
		CALC_SN:
		begin
		 //  in_sn1_check <= in_sn1;
			in_sn <= out_sn;
		end

		SET_RN:
		begin
			in_rn <= out_rn;
		//	out_rn_check <= out_rn; 
		end

		INCR_I:
		begin
			i <= i + 9'b1;
		end

		CHECK_I:
		begin
			
		end
		
		SET_ADDR_RN:
		begin
			rn_addr <= j;
		end

		INCR_J:
		begin
			j <= j + 9'b1;
			rn_write <= 1;
			rn_read <= 0;
			rn_write_data <= out_rn;

		end

		CHECK_J:
		begin

			rn_write <= 0;
			rn_read <= 1;
				
			//rn_addr_check <= rn_addr ;
			//rn_write_data_check <= rn_write_data;
			
		end
		
		CHECK_RN:
		begin
			rn_addr <= 9'd2;
//			for (i = 0; i < 10; i = i +1) begin
//				
//   		end

		end

		DONE:
		begin
			doneac <= 1'b1;
			//ram_out_check <= ram_out;
		end

		endcase
	end

end


endmodule