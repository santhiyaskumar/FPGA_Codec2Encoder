/*
* Module         - ROM_cb8
* Top module     - cbselect
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Mon Feb 04 15:19:31 2019
*
* Description    -
* Inputs         -
*static const float codes8[] = {

*};
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/
module ROM_cb8(addr,dataout);

	parameter N = 32;
	input [3:0] addr;
	output reg [N-1:0] dataout;

	reg [N-1:0] cb8[7:0];
	
	always@(*)
	begin
		cb8[0] = 32'b00001001110001000000000000000000;
		cb8[1] = 32'b00001010001010000000000000000000;
		cb8[2] = 32'b00001010100011000000000000000000;
		cb8[3] = 32'b00001010111100000000000000000000;
		cb8[4] = 32'b00001011010101000000000000000000;
		cb8[5] = 32'b00001011101110000000000000000000;
		cb8[6] = 32'b00001100000111000000000000000000;
		cb8[7] = 32'b00001100100000000000000000000000;
		
		dataout = cb8[addr];
	end
endmodule
