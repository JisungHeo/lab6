module BTB (clk, reset_n, PCindex, bneControl, EX_PC, branch_addr, valid, tag, nextPC);
	input clk;
	input reset_n;
	input [5:0] PCindex;
	input bneControl;
	input [15:0] EX_PC;
	input [15:0] branch_addr;
	output valid;
	output [9:0] tag;
	output [15:0] nextPC;

	reg ValidCache [0:63];
	reg [9:0] TagCache [0:63];
	reg [15:0] NextPCCache [0:63];
	
	reg [15:0] i;
	
	always @(reset_n) begin
		for (i = 0; i < 64; i=i+1) begin
			ValidCache[i] = 0;
		end
	end
	
	always @(negedge clk) begin
		if (bneControl) begin
			ValidCache[EX_PC[5:0]] = 1'b1;
			TagCache[EX_PC[5:0]] = EX_PC[15:6];
			NextPCCache[EX_PC[5:0]] = branch_addr;
		end
	end
			
	assign valid = ValidCache[PCindex];
	assign tag = TagCache[PCindex];
	assign nextPC = NextPCCache[PCindex];
endmodule