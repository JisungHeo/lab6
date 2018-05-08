//2 bit global predictor
module Predictor (clk, reset_n, EX_Branch, EX_Taken, prediction);
	input clk;
	input reset_n;
	input EX_Branch;
	input EX_Taken;
	output prediction;

	reg [1:0] predictor;
	
	always @(reset_n) begin
		predictor = 2'b10;
	end

	always @(negedge clk) begin
		if (EX_Branch == 1'b1) begin
			if (EX_Taken == 1'b1) begin
				if (predictor != 2'b11) begin
					predictor = predictor + 1;
				end
			end
			else if (EX_Taken == 1'b0) begin
				if (predictor != 2'b00) begin
					predictor = predictor - 1;
				end
			end
		end
	end

	assign prediction = predictor[1];
endmodule