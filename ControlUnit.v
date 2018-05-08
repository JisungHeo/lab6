//module Control unit
module ControlUnit(opcode, funct, ControlInput,Jump);
	input [3:0]opcode;
	input [5:0]funct;
	output [16:0] ControlInput;
	output Jump;

	reg RegWrite;
	reg MemtoReg;
	reg MemWrite;
	reg MemRead;
	reg Branch;
	reg ALUSrc;
	reg RegDst;

	assign Jump = (opcode == 4'b1001)||(opcode == 4'b1010)? 1:0;// Jmp, JAl

	always @(*) begin
		RegWrite = 1'b0;
		MemtoReg = 1'b0;
		MemWrite = 1'b0;
		MemRead = 1'b0;
		Branch = 1'b0;
		ALUSrc = 1'b0;
		RegDst = 1'b0;
		case (opcode)
			4'b1111: begin
				if (funct <= 4'b0111) begin// R type
					RegWrite = 1'b1;
					RegDst = 1'b1;
				end
				else if (funct == 6'b011010) begin
					RegWrite = 1'b1;
				end
			end
			4'b0000: begin// BNE
				Branch = 1'b1;
			end
			4'b0001: begin// BEQ
				Branch = 1'b1;
			end
			4'b0010: begin// BGZ
				Branch = 1'b1;
			end
			4'b0011: begin// BLZ
				Branch = 1'b1;
			end
			4'b0100: begin// ADI
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
			end
			4'b0101: begin// ORI
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
			end
			4'b0110: begin// LHI
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
			end
			4'b0111: begin// LWD
				RegWrite = 1'b1;
				MemtoReg = 1'b1;
				MemRead = 1'b1;
				ALUSrc = 1'b1;
			end
			4'b1000: begin// SWD
				MemWrite = 1'b1;
				ALUSrc = 1'b1;
			end
			4'b1001: ;// JMP
			4'b1010: begin// JAL
				RegWrite = 1'b1;
			end
			default: ;
		endcase
	end

	assign ControlInput = {RegWrite,MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDst, opcode, funct};
endmodule
//Control Input WB, MEM, EX
//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct