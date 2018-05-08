module ForwardingUnit (MEM_WriteRegister, MEM_RegWrite, WB_WriteRegister, WB_RegWrite, EX_rs, EX_rt, ForwardA, ForwardB);
	input [1:0] MEM_WriteRegister;
	input MEM_RegWrite;
	input [1:0] WB_WriteRegister;
	input WB_RegWrite;
	input [1:0] EX_rs;
	input [1:0] EX_rt;
	output reg [1:0] ForwardA;
	output reg [1:0] ForwardB;

	always @(*) begin
		ForwardA = 2'b00;
		ForwardB = 2'b00;
		if (MEM_RegWrite == 1'b1) begin
			if (MEM_WriteRegister == EX_rs) begin
				ForwardA = 2'b10;
			end
			else if (MEM_WriteRegister == EX_rt) begin
				ForwardB = 2'b10;
			end
		end
		if (WB_RegWrite == 1'b1) begin
			if (~((MEM_RegWrite == 1'b1) && (MEM_WriteRegister == EX_rs)) && (WB_WriteRegister == EX_rs)) begin
				ForwardA = 2'b01;
			end
			else if (~((MEM_RegWrite == 1'b1) && (MEM_WriteRegister == EX_rt)) && WB_WriteRegister == EX_rt) begin
				ForwardB = 2'b01;
			end
		end
	end
endmodule
				