module JRControlBlock(opcode, funct, JRControl);
	input [3:0] opcode;
	input [5:0] funct;
	output JRControl;

	//JPR or JRL => JRControl is asserted.	
	assign JRControl = (opcode == 4'b1111) && (funct == 6'b011001 || funct == 6'b011010);
endmodule