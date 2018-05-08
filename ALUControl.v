`define WORD_SIZE 16
//R-type instructions
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
`define	OP_AND	4'b0010
`define	OP_ORR	4'b0011
`define	OP_NOT  4'b0100
`define	OP_TCP	4'b0101
`define	OP_SHL	4'b0110
`define	OP_SHR	4'b0111
//I-type instructions
`define	OP_ADI	4'b1000
`define	OP_ORI	4'b1001
`define	OP_LHI	4'b1010
//Memory instructions. i.e. LWD and SWD
`define OP_MEM  4'b1011
//Branch instructions
`define	OP_BNE	4'b1100
`define	OP_BEQ	4'b1101
`define OP_BGZ  4'b1110
`define OP_BLZ  4'b1111

//ALU Control Input Module 
module aluControl (funct, opcode, aluControlInput);//should be dependent on state register
	//input [3:0] aluOp;
	input [5:0] funct;
	input [3:0] opcode;
	output reg [3:0] aluControlInput;
	
	always @(*) begin
		//if (aluOp == 4'b0000) begin
		//	aluControlInput = 4'b0000;
		//end
		//else 
		if ((opcode == 4'b1111)&&(funct <= 4'b0111)) begin //R-Type instructions
			aluControlInput = funct[3:0];
		end
		else begin
			case(opcode)
				4'b0100: aluControlInput = `OP_ADI;
				4'b0101: aluControlInput = `OP_ORI;
				4'b0110: aluControlInput = `OP_LHI;				
				4'b0111: aluControlInput = `OP_MEM;
				4'b1000: aluControlInput = `OP_MEM;
				4'b0000: aluControlInput = `OP_BNE;
				4'b0001: aluControlInput = `OP_BEQ;
				4'b0010: aluControlInput = `OP_BGZ;
				4'b0011: aluControlInput = `OP_BLZ;
				default: aluControlInput = `OP_ADD;//alu for PC+4
			endcase
		end
	end
endmodule