module IDEX_Register(clk, reset_n, ID_PC4, ControlInput, ReadData1, ReadData2, im16_ext, rs, rt, rd, JRControl, JLControl, //control and data input
		     WB, MEM, //bunch output
		     EX_Branch, EX_ALUSrc, EX_RegDst, EX_opcode, EX_funct, EX_JRControl, EX_JLControl, //control output
		     EX_PC4, EX_im16_ext, EX_ReadData1, EX_ReadData2, EX_rs, EX_rt, EX_rd); //data output
	input clk;
	input reset_n;
	input [15:0] ID_PC4;
	input [16:0]ControlInput;
	input [15:0] ReadData1, ReadData2, im16_ext;
	input [1:0] rs, rt, rd;
	input JRControl;
	input JLControl;
	output reg [1:0] WB;
	output reg [1:0] MEM;
	output reg EX_Branch, EX_ALUSrc, EX_RegDst;
	output reg [3:0] EX_opcode;
	output reg [5:0] EX_funct;
	output reg EX_JRControl;
	output reg EX_JLControl;
	output reg [15:0] EX_PC4, EX_im16_ext, EX_ReadData1, EX_ReadData2;
	output reg [1:0] EX_rs, EX_rt, EX_rd;

	always @(reset_n) begin
		WB = 2'b00;
		MEM = 2'b00;
		EX_Branch = 1'b0;
		EX_ALUSrc = 1'b0;
		EX_RegDst = 1'b0;
		EX_opcode = 4'b0000;
		EX_funct = 6'b000000;
		EX_JRControl = 1'b0;
		EX_JLControl = 1'b0;
		EX_PC4 = 16'h0000;
		EX_im16_ext = 16'h0000;
		EX_ReadData1 = 16'h0000;
		EX_ReadData2 = 16'h0000;
		EX_rs = 2'b00;
		EX_rt = 2'b00;
		EX_rd = 2'b00;
	end

	always @(posedge clk) begin
		WB = ControlInput[16:15];
		MEM = ControlInput[14:13];
		EX_Branch = ControlInput[12];
		EX_ALUSrc = ControlInput[11];
		EX_RegDst = ControlInput[10];
		EX_opcode = ControlInput[9:6];
		EX_funct = ControlInput[5:0];
		EX_JRControl = JRControl;
		EX_JLControl = JLControl;
		EX_PC4 = ID_PC4;
		EX_im16_ext = im16_ext;
		EX_ReadData1 = ReadData1;
		EX_ReadData2 = ReadData2;
		EX_rs = rs;
		EX_rt = rt;
		EX_rd = rd;
	end
endmodule

//Control Input WB, MEM, EX
//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct

//Forwarded Data: WriteRegister, PC4, JLControl