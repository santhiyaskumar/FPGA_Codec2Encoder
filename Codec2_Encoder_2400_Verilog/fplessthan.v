/* Module - fplessthan
* Descritption : fixed point less than
* input : [N:0] a,b
* output 1 if a<b else 0;
* Santhiya S.
* 01-18-2019
*/

module fplessthan #(
	//Parameterized values
	parameter Q = 15,
	parameter N = 32
	)
	(
    input [N-1:0] a,
    input [N-1:0] b,
    output c
    );

reg res;

assign c = res;

always @(*) begin
	
	if(a == b) 
	begin
		res = 1'b0;
	end
	// both negative or both positive
	else if(a[N-1] == b[N-1]) begin			   
		if(a[N-1] == 0) begin         // positive			
			if( a[N-2:0] < b[N-2:0] ) begin
				res = 1'b1;
			end
			else  
			begin
			   res = 1'b0;
			end		
		end
		else begin         				// negative			             
		   if( a[N-2:0] < b[N-2:0] ) 
			begin
				res = 1'b0;
			end
			else  begin
			   res = 1'b1;
			end
		
		end
	end												
	//	one of them is negative
	else if ( (b[N-1] == 1) && (a[N-1] == 0)) 
	begin
				res = 1'b0;
	end
	else if ((b[N-1] == 0) && (a[N-1] == 1)) begin
			res = 1'b1;
	end
	else 
		res = 1'b0;
	
end
	
endmodule
