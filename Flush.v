module Flush (IFID_flush, ID_flush, Stall_flush, flush);
	input IFID_flush;
	input ID_flush;
	input Stall_flush;
	output flush;
	
	assign flush = IFID_flush || ID_flush || Stall_flush;
endmodule