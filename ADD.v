module ADD (a,b,add_out);
	input [15:0] a;
	input [15:0] b;
	output [15:0] add_out;
	
	assign add_out = a+b;
endmodule