/*
* Module         - ROM_cb9
* Top module     - cbselect
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Mon Feb 04 15:19:31 2019
*
* Description    -
* Inputs         -
*static const float codes9[] = {
  2900,
  3100,
  3300,
  3500
*};
*32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/
module ROM_cb9(addr,dataout);

	parameter N = 32;
	input [3:0] addr;
	output reg [N-1:0] dataout;

	reg [N-1:0] cb9[3:0];
	
	always@(*)
	begin
		cb9[0] = 32'b00001011010101000000000000000000;
		cb9[1] = 32'b00001100000111000000000000000000;
		cb9[2] = 32'b00001100111001000000000000000000;
		cb9[3] = 32'b00001101101011000000000000000000;
				
		dataout = cb9[addr];
	end
endmodule
