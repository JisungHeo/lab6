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

//jump instructions do not require alu 
//HLT and WWD do not require alu
module ALU(A,B,aluControlInput,bcond,aluResult);

	input [15:0]A;
	input [15:0]B;
	input [3:0]aluControlInput;
	output [15:0]aluResult;					   
	output bcond;
	//TODO: Code your ALU

reg [15:0]aluResult;
reg bcond;
always @(A,B,aluControlInput) begin
bcond = 0;
case(aluControlInput)
	`OP_ADD: aluResult <= A+B;	
	`OP_SUB: aluResult <= A-B;
	`OP_AND: aluResult <= A&B;
	`OP_ORR: aluResult <= A|B;
	`OP_NOT: aluResult <= ~A;
	`OP_TCP: aluResult <= ~A+1;
	`OP_SHL: aluResult <= {A[14:0],1'b0};
	`OP_SHR: aluResult <= {A[15],A[15:1]};
	`OP_ADI: aluResult <= A+B;
	`OP_ORI: aluResult <= A|{8'h00,B[7:0]};
	`OP_LHI: aluResult <= {B[7:0],8'h00};
	`OP_MEM: aluResult <= A+B;
	`OP_BNE: bcond <= (A!=B);
	`OP_BEQ: bcond <= (A==B);
	`OP_BGZ: bcond <= ((A[`WORD_SIZE-1]==1'b0)&&(A>0));
	`OP_BLZ: bcond <= (A[`WORD_SIZE-1]==1'b1);
 	default: ;
endcase
end
endmodule

module addALU(A,B,C);
	input [15:0]A;
	input [15:0]B;
	output [15:0]C;		
	assign C = A+B;
endmodule

module addStateALU(A,B,C);
	input [3:0]A;
	input [3:0]B;
	output [3:0]C;		
	assign C = A+B;
endmodule