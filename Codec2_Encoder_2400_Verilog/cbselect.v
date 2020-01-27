/*
* Module         - cbselect
* Top module     - quantise
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Mon Feb 04 16:14:44 2019
*
* Description    - select data from the ROMs cb0 to cb9 based on the select input and address.
* Inputs         - select : 0 to 9 , corresponds to cb0 to cb9.
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/

module cbselect(select,addr,dataout);

	parameter N = 32;
	
	input [3:0] 	select, addr;
	output reg [N-1:0] dataout;
	
	reg [3:0] 		cb_addr_0,cb_addr_1,cb_addr_2,cb_addr_3,cb_addr_4,cb_addr_5,cb_addr_6,cb_addr_7,cb_addr_8,cb_addr_9;
	wire [N-1:0] 	cb_data_out_0,cb_data_out_1,cb_data_out_2,cb_data_out_3,cb_data_out_4,cb_data_out_5,
						cb_data_out_6,cb_data_out_7,cb_data_out_8,cb_data_out_9;
	
	ROM_cb0 cb0(cb_addr_0,cb_data_out_0);
	ROM_cb1 cb1(cb_addr_1,cb_data_out_1);
	ROM_cb2 cb2(cb_addr_2,cb_data_out_2);
	ROM_cb3 cb3(cb_addr_3,cb_data_out_3);
	ROM_cb4 cb4(cb_addr_4,cb_data_out_4);
	ROM_cb5 cb5(cb_addr_5,cb_data_out_5);
	ROM_cb6 cb6(cb_addr_6,cb_data_out_6);
	ROM_cb7 cb7(cb_addr_7,cb_data_out_7);
	ROM_cb8 cb8(cb_addr_8,cb_data_out_8);
	ROM_cb9 cb9(cb_addr_9,cb_data_out_9);
	
	always@(*)
	begin
		case(select)
		4'd0: 
		begin
			cb_addr_0 = addr;
			dataout = cb_data_out_0;
		end	
		4'd1: 
		begin
			cb_addr_1 = addr;
			dataout = cb_data_out_1;
		end
		4'd2: 
		begin
			cb_addr_2 = addr; 
			dataout = cb_data_out_2;
		end
		4'd3: 
		begin
			cb_addr_3 = addr; 
			dataout = cb_data_out_3;
		end
		4'd4: 
		begin
			cb_addr_4 = addr; 
			dataout = cb_data_out_4;
		end
		4'd5: 
		begin
			cb_addr_5 = addr; 
			dataout = cb_data_out_5;
		end
		4'd6: 
		begin
			cb_addr_6 = addr; 
			dataout = cb_data_out_6;
		end
		4'd7:
		begin
			cb_addr_7 = addr; 
			dataout = cb_data_out_7;
		end
		4'd8: 
		begin
			cb_addr_8 = addr; 
			dataout = cb_data_out_8;
		end
		4'd9: 
		begin
			cb_addr_9 = addr; 
			dataout = cb_data_out_9;
		end
		default:
		begin
			cb_addr_9 = addr; 
			dataout = cb_data_out_9;
		end
		endcase
		
		
		
	end

endmodule
