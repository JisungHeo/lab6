module EXMEM_Register(clk, reset_n, WB, MEM, EX_PC4, EX_ALUResult, BusB_forwarded, EX_WriteRegister, EX_JLControl, // input
		      WB_forwarded, MEM_MemWrite, MEM_MemRead, MEM_RegWrite,// control output
		      MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded, MEM_WriteRegister, MEM_JLControl); // data output
	input clk;
	input reset_n;
	input [1:0] WB;
	input [1:0] MEM;
	input [15:0] EX_PC4, EX_ALUResult, BusB_forwarded;
	input [1:0] EX_WriteRegister;
	input EX_JLControl;
	output reg [1:0] WB_forwarded;
	output reg MEM_MemWrite, MEM_MemRead;
	output reg MEM_RegWrite;
	output reg [15:0] MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded;
	output reg [1:0] MEM_WriteRegister;
	output reg MEM_JLControl;

	always @(reset_n) begin
		WB_forwarded = 2'b00;
		MEM_MemWrite = 1'b0;
		MEM_MemRead = 1'b0;
		MEM_RegWrite = 1'b0;
		MEM_PC4 = 16'h0000;
		MEM_ALUResult = 16'h0000;
		MEM_BusB_forwarded = 16'h0000;
		MEM_WriteRegister = 2'b00;
		MEM_JLControl = 1'b0;
	end

	always @(posedge clk) begin
		WB_forwarded = WB;
		MEM_MemWrite = MEM[1];
		MEM_MemRead = MEM[0];
		MEM_RegWrite = WB_forwarded[1];
		MEM_PC4 = EX_PC4;
		MEM_ALUResult = EX_ALUResult;
		MEM_BusB_forwarded = BusB_forwarded;
		MEM_WriteRegister = EX_WriteRegister;
		MEM_JLControl = EX_JLControl;
	end
endmodule

//Control Input WB, MEM, EX
//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct

//Forwarded Data: WriteRegister, PC4, JLControl