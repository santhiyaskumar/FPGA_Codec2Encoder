module neg_check (gt1,psumr, psum1);

 parameter N= 32;

 input [N-1:0] psumr, psum1;

	output reg gt1;
	
	
//	reg [31:0] in1_gt,in2_gt;
//	wire out_gt;
	
	//fpgreaterthan gt(in1_gt,in2_gt,out_gt);
	
	
	always@(*)
	begin
	
	if((psumr[N-1] ==  1 && psum1[N-1] == 0) || 
			(psumr[N-1] ==  0 && psum1[N-1] == 1) )
	begin
				gt1 <= 1;
	end
	else
	begin
				gt1 <= 0;
	end
	end
	
	
	
	endmodule