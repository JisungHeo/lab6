module DiscardInstruction(Jump, bneControl, EX_JRControl, IF_flush, ID_flush);
	input Jump; //  Jump includes J, JAL.
	input bneControl;
	input EX_JRControl;
	output IF_flush;
	output ID_flush;

	assign IF_flush = Jump || bneControl || EX_JRControl;
	assign ID_flush = bneControl || EX_JRControl;
endmodule