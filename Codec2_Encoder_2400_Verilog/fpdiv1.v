// Simulaltion : Waveform32.vwf

module fpdiv1 #(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );

reg [N-1:0] res;

assign c = res ;

always @(*) 
	begin
		// both negative or both positive
		if(a[N-1] == b[N-1]) 
		begin						
			//res[N-2:0] = (a[N-2:0] << 8 / b[N-2:0]) << 8;	
			res = (({1'b0,a[N-2:0]} << 8) /{1'b0,b[N-2:0]}) << 8;
			//					
		end	
		
		//	one of them is negative...
		else
		begin		
			//res[N-2:0] = (a[N-2:0] << 8 / b[N-2:0]) << 8;		
			res = (({1'b0,a[N-2:0]} << 8) /{1'b0,b[N-2:0]}) << 8;
				
		end	
		if(a[N-1] == b[N-1]) 
		begin						
				res[N-1] = 1'b0;		
		end	
		
		//	one of them is negative...
		else
		begin		
				res[N-1] = 1'b1;
		end	
		
	end
	
endmodule
