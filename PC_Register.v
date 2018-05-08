module PC_Register(clk, reset_n, PCin, PC_WriteEn, PC);
	input clk;
	input reset_n;
	input [15:0] PCin;
	input PC_WriteEn;
	output reg [15:0] PC;

	always @(reset_n) begin
		PC = 0;
	end
	always @(posedge clk) begin
		if (PC_WriteEn) begin
			PC = PCin;
		end
	end
endmodule
