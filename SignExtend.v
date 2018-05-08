//immediateSignExtend
module SignExtend(immediate, im16_ext);
	input [7:0] immediate;
	output [15:0] im16_ext; 

	assign im16_ext = {{8{immediate[7]}},immediate[7:0]};	
endmodule		

