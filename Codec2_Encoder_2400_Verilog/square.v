module square(sq);

output  [31:0] sq;

parameter [31:0] in = 32'b10000001010000101110101010111100;

assign sq = in << 1;

endmodule