module JLControlBlock(opcode, funct, JLControl);
	input [3:0] opcode;
	input [5:0] funct;
	output JLControl;

	//J or JRL => JLControl is asserted.	
	assign JLControl = (opcode == 4'b1010) || ((opcode == 4'b1111) && (funct == 6'b011010));
endmodule