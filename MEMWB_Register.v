module MEMWB_Register(clk, reset_n, WB_forwarded, MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult, MEM_WriteRegister, MEM_JLControl,// input
		      WB_RegWrite, WB_MemtoReg, // control output
		      WB_PC4, WB_ReadDataOfMem, WB_ALUResult, WB_WriteRegister, WB_JLControl); // data output
	input clk;
	input reset_n;
	input [1:0] WB_forwarded;
	input [15:0] MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult;
	input [1:0] MEM_WriteRegister;
	input MEM_JLControl;
	output reg WB_RegWrite;
	output reg WB_MemtoReg;
	output reg [15:0] WB_PC4, WB_ReadDataOfMem, WB_ALUResult;
	output reg [1:0] WB_WriteRegister;
	output reg WB_JLControl;

	always @(reset_n) begin
		WB_RegWrite = 1'b0;
		WB_MemtoReg = 1'b0;
		WB_PC4 = 16'h0000;
		WB_ReadDataOfMem = 16'h0000;
		WB_ALUResult = 16'h0000;
		WB_WriteRegister = 2'b00;
		WB_JLControl = 1'b0;
	end

	always @(posedge clk) begin
		WB_RegWrite = WB_forwarded[1];
		WB_MemtoReg = WB_forwarded[0];
		WB_PC4 = MEM_PC4;
		WB_ReadDataOfMem = MEM_ReadDataOfMem;
		WB_ALUResult = MEM_ALUResult;
		WB_WriteRegister = MEM_WriteRegister;
		WB_JLControl = MEM_JLControl;
	end
endmodule
		