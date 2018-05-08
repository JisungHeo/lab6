module IFID_Register(clk, reset_n, IF_PC4, IF_instruction, IF_flush, IFID_WriteEn, ID_PC4, ID_instruction, IFID_flush);
	input clk;
	input reset_n;
	input [15:0] IF_PC4;
	input [15:0] IF_instruction;
	input IF_flush;
	input IFID_WriteEn;
	output reg [15:0] ID_PC4;
	output reg [15:0] ID_instruction;
	output reg IFID_flush;

	always @(reset_n) begin
		ID_PC4 = 16'h0000;
		ID_instruction = 16'h0000;
		IFID_flush = 1'b1;
	end

	always @(posedge clk) begin
		/*if (IF_flush) begin
			ID_PC4 = 16'h0000;
			ID_instruction = 16'hb000;
			if (IFID_WriteEn) begin	
				IFID_flush = IF_flush;
			end
			
		end*/
		if (IFID_WriteEn) begin
			IFID_flush = IF_flush;
			ID_PC4 = IF_PC4;
			ID_instruction = IF_instruction;
			if (IF_flush) begin
				ID_instruction = 16'hb000;
			end
		end
	end 
endmodule