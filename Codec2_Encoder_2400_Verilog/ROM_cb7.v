/*
* Module         - ROM_cb7
* Top module     - cbselect
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Mon Feb 04 15:19:31 2019
*
* Description    -
* Inputs         -
*static const float codes7[] = {
	  2300,
	  2400,
	  2500,
	  2600,
	  2700,
	  2800,
	  2900,
	  3000
*};
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/
module ROM_cb7(addr,dataout);

	parameter N = 32;
	input [3:0] addr;
	output reg [N-1:0] dataout;

	reg [N-1:0] cb7[7:0];
	
	always@(*)
	begin
		cb7[0] = 32'b00001000111111000000000000000000;
		cb7[1] = 32'b00001001011000000000000000000000;
		cb7[2] = 32'b00001001110001000000000000000000;
		cb7[3] = 32'b00001010001010000000000000000000;
		cb7[4] = 32'b00001010100011000000000000000000;
		cb7[5] = 32'b00001010111100000000000000000000;
		cb7[6] = 32'b00001011010101000000000000000000;
		cb7[7] = 32'b00001011101110000000000000000000;
		
		dataout = cb7[addr];
	end
endmodule
