`timescale 1ns/1ns
`define PERIOD1 100
`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory
			//	requirements in the Active-HDL simulator 

module Memory(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, memory_ack1, memory_ack2);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;
	
	inout readM1;
	wire readM1;
	input [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	inout data1;
	wire [63:0] data1;
	reg [63:0] outputData1;
	
	assign data1 = readM1?outputData1:64'bz;
	
	input readM2;
	wire readM2;
	input writeM2;
	wire writeM2;
	input [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;
	inout data2;
	wire [63:0] data2;
	output memory_ack1;
	reg memory_ack1;
	output memory_ack2;
	reg memory_ack2;
	
	reg [`WORD_SIZE-1:0] memory [0:`MEMORY_SIZE-1];
	reg [63:0] outputData2;
	
	assign data2 = readM2?outputData2:64'bz;

	reg [15:0] count1;
	reg [15:0] count2;
	
	wire access1 = (readM1);
	wire access2 = (readM2 || writeM2);

	reg flag1;
	reg flag2;

	wire [63:0] memory_block1 = {memory[{address1[15:2],2'b11}], memory[{address1[15:2],2'b10}], memory[{address1[15:2],2'b01}], memory[{address1[15:2],2'b00}]};
	wire [63:0] memory_block2 = {memory[{address2[15:2],2'b11}], memory[{address2[15:2],2'b10}], memory[{address2[15:2],2'b01}], memory[{address2[15:2],2'b00}]};

	always@(posedge clk)
		if(!reset_n)
			begin
				memory[16'h0] <= 16'h9050;
				memory[16'h1] <= 16'h1;
				memory[16'h2] <= 16'h0;
				memory[16'h3] <= 16'h0;
				memory[16'h4] <= 16'h0;
				memory[16'h5] <= 16'h0;
				memory[16'h6] <= 16'h0;
				memory[16'h7] <= 16'h0;
				memory[16'h8] <= 16'h0;
				memory[16'h9] <= 16'h1;
				memory[16'ha] <= 16'h0;
				memory[16'hb] <= 16'h0;
				memory[16'hc] <= 16'h0;
				memory[16'hd] <= 16'h0;
				memory[16'he] <= 16'h0;
				memory[16'hf] <= 16'h0;
				memory[16'h10] <= 16'h0;
				memory[16'h11] <= 16'h0;
				memory[16'h12] <= 16'h0;
				memory[16'h13] <= 16'h0;
				memory[16'h14] <= 16'h0;
				memory[16'h15] <= 16'h0;
				memory[16'h16] <= 16'h0;
				memory[16'h17] <= 16'h0;
				memory[16'h18] <= 16'h0;
				memory[16'h19] <= 16'h0;
				memory[16'h1a] <= 16'h0;
				memory[16'h1b] <= 16'h0;
				memory[16'h1c] <= 16'h0;
				memory[16'h1d] <= 16'h0;
				memory[16'h1e] <= 16'h0;
				memory[16'h1f] <= 16'h0;
				memory[16'h20] <= 16'h0;
				memory[16'h21] <= 16'h0;
				memory[16'h22] <= 16'h0; // -----------------------------IGNORE-----------------------
				memory[16'h23] <= 16'h0; // LHI $0, 0
				memory[16'h24] <= 16'h0; // ADI $1, $0, 8
				memory[16'h25] <= 16'h0; // SHIFT: ADI $0, $0, 1
				memory[16'h26] <= 16'h0; // LHI $2, 0
				memory[16'h27] <= 16'h0; // ADI $2, $2, 1
				memory[16'h28] <= 16'h0; // MOVE: LWD $3, $2, 0 (base)
				memory[16'h29] <= 16'h0; // SWD $3, $2, 1
				memory[16'h2a] <= 16'h0; // ADI $2, $2, 1
				memory[16'h2b] <= 16'h0; // BEQ $1, $2, 1
				memory[16'h2c] <= 16'h0; // JMP MOVE
				memory[16'h2d] <= 16'h0; // LWD $3, $2, 0
				memory[16'h2e] <= 16'h0; // LHI $2, 0
				memory[16'h2f] <= 16'h0; // SWD $3, $2, 1
				memory[16'h30] <= 16'h0; // ADD $3, $3, 1
				memory[16'h31] <= 16'h0; // SWD $3, $2, 1
				memory[16'h32] <= 16'h0; // LHI $3, 0
				memory[16'h33] <= 16'h0; // ADI $3, $3, 10
				memory[16'h34] <= 16'h0; // BEQ $0, $3, 1
				memory[16'h35] <= 16'h0; // JMP SHIFT
				memory[16'h36] <= 16'h0; // LHI $0, 0
				memory[16'h37] <= 16'h0; // ADI $1, $0, 32
				memory[16'h38] <= 16'h0; // SHIFT2: ADI $0, $0, 1
				memory[16'h39] <= 16'h0; // LHI $2, 0
				memory[16'h3a] <= 16'h0; // ADI $2, $2, 1
				memory[16'h3b] <= 16'h0; // MOVE2: LWD $3, $2, 8 (base)
				memory[16'h3c] <= 16'h0; // SWD $3, $2, 1
				memory[16'h3d] <= 16'h0; // ADI $2, $2, 1
				memory[16'h3e] <= 16'h0; // BEQ $1, $2, 1
				memory[16'h3f] <= 16'h0; // JMP MOVE2
				memory[16'h40] <= 16'h0; // LWD $3, $2, 0
				memory[16'h41] <= 16'h0; // LHI $2, 0
				memory[16'h42] <= 16'h0; // SWD $3, $2, 1
				memory[16'h43] <= 16'h0; // ADD $3, $3, 1
				memory[16'h44] <= 16'h0; // SWD $3, $2, 1
				memory[16'h45] <= 16'h0; // LHI $3, 0
				memory[16'h46] <= 16'h0; // ADI $3, $3, 20
				memory[16'h47] <= 16'h0; // BEQ $0, $3, 1
				memory[16'h48] <= 16'h0; // JMP SHIFT2
				memory[16'h49] <= 16'h0; // --------------------------------IGNORE-----------------------
            memory[16'h4a] <= 16'h0;
            memory[16'h4b] <= 16'h0;
            memory[16'h4c] <= 16'h0;
            memory[16'h4d] <= 16'h0;
            memory[16'h4e] <= 16'h0;
            memory[16'h4f] <= 16'h0;
				memory[16'h50] <= 16'h6000; // LHI $0, 0
				memory[16'h51] <= 16'h4135; // ADI $1, $0, 48
				memory[16'h52] <= 16'h4001; // SHIFT: ADI $0, $0, 1
				memory[16'h53] <= 16'h6200; // LHI $2, 0
				memory[16'h54] <= 16'h4a01; // ADI $2, $2, 1
				memory[16'h55] <= 16'h7b00; // MOVE: LWD $3, $2, 0 (base)
				memory[16'h56] <= 16'h8b01; // SWD $3, $2, 1
				memory[16'h57] <= 16'h4a01; // ADI $2, $2, 1
				memory[16'h58] <= 16'h1901; // BEQ $1, $2, 1
				memory[16'h59] <= 16'h9055; // JMP MOVE
				memory[16'h5a] <= 16'h7b00; // LWD $3, $2, 0
				memory[16'h5b] <= 16'h6200; // LHI $2, 0
				memory[16'h5c] <= 16'h8b01; // SWD $3, $2, 1
				memory[16'h5d] <= 16'h4f01; // ADD $3, $3, 1
				memory[16'h5e] <= 16'h8b01; // SWD $3, $2, 1
				memory[16'h5f] <= 16'h6300; // LHI $3, 0
				memory[16'h60] <= 16'h4f0a; // ADI $3, $3, 16
				memory[16'h61] <= 16'h1c01; // BEQ $0, $3, 1
				memory[16'h62] <= 16'h9052; // JMP SHIFT
				memory[16'h63] <= 16'hf01c; // HLT
				memory[16'h64] <= 16'h4108; 
				memory[16'h65] <= 16'h4001; 
				memory[16'h66] <= 16'h6200;
				memory[16'h67] <= 16'h4a01; 
				memory[16'h68] <= 16'h7b08; 
				memory[16'h69] <= 16'h8b01; 
				memory[16'h6a] <= 16'h4a01; 
				memory[16'h6b] <= 16'h1901; 
				memory[16'h6c] <= 16'h9068; 
				memory[16'h6d] <= 16'h7b00; 
				memory[16'h6e] <= 16'h6200; 
				memory[16'h6f] <= 16'h8b01; 
				memory[16'h70] <= 16'h4f01; 
				memory[16'h71] <= 16'h8b01; 
				memory[16'h72] <= 16'h6200; 
				memory[16'h73] <= 16'h4f14; 
				memory[16'h74] <= 16'h1c01;
				memory[16'h75] <= 16'h9065;
				memory[16'h76] <= 16'hf01c;
            memory[16'h77] <= 16'h9079;
            memory[16'h78] <= 16'hf01d;
            memory[16'h79] <= 16'hf41c;
            memory[16'h7a] <= 16'hb01;
            memory[16'h7b] <= 16'h907d;
            memory[16'h7c] <= 16'hf01d;
            memory[16'h7d] <= 16'hf01c;
            memory[16'h7e] <= 16'h601;
            memory[16'h7f] <= 16'hf01d;
            memory[16'h80] <= 16'hf41c;
            memory[16'h81] <= 16'h1601;
            memory[16'h82] <= 16'h9084;
            memory[16'h83] <= 16'hf01d;
            memory[16'h84] <= 16'hf01c;
            memory[16'h85] <= 16'h1b01;
            memory[16'h86] <= 16'hf01d;
            memory[16'h87] <= 16'hf41c;
            memory[16'h88] <= 16'h2001;
            memory[16'h89] <= 16'h908b;
            memory[16'h8a] <= 16'hf01d;
            memory[16'h8b] <= 16'hf01c;
            memory[16'h8c] <= 16'h2401;
            memory[16'h8d] <= 16'hf01d;
            memory[16'h8e] <= 16'hf41c;
            memory[16'h8f] <= 16'h2801;
            memory[16'h90] <= 16'h9092;
            memory[16'h91] <= 16'hf01d;
            memory[16'h92] <= 16'hf01c;
            memory[16'h93] <= 16'h3001;
            memory[16'h94] <= 16'hf01d;
            memory[16'h95] <= 16'hf41c;
            memory[16'h96] <= 16'h3401;
            memory[16'h97] <= 16'h9099;
            memory[16'h98] <= 16'hf01d;
            memory[16'h99] <= 16'hf01c;
            memory[16'h9a] <= 16'h3801;
            memory[16'h9b] <= 16'h909d;
            memory[16'h9c] <= 16'hf01d;
            memory[16'h9d] <= 16'hf41c;
            memory[16'h9e] <= 16'ha0af;
            memory[16'h9f] <= 16'hf01c;
            memory[16'ha0] <= 16'ha0ae;
            memory[16'ha1] <= 16'hf01d;
            memory[16'ha2] <= 16'hf41c;
            memory[16'ha3] <= 16'h6300;
            memory[16'ha4] <= 16'h5f03;
            memory[16'ha5] <= 16'h6000;
            memory[16'ha6] <= 16'h4005;
            memory[16'ha7] <= 16'ha0b2;
            memory[16'ha8] <= 16'hf01c;
            memory[16'ha9] <= 16'h90b1;
            memory[16'haa] <= 16'h4900;
            memory[16'hab] <= 16'hf41a;
            memory[16'hac] <= 16'hf01c;
            memory[16'had] <= 16'hf01d;
            memory[16'hae] <= 16'h4a01;
            memory[16'haf] <= 16'hf819;
            memory[16'hb0] <= 16'hf01d;
            memory[16'hb1] <= 16'ha0aa;
            memory[16'hb2] <= 16'h41ff;
            memory[16'hb3] <= 16'h2404;
            memory[16'hb4] <= 16'h6000;
            memory[16'hb5] <= 16'h5001;
            memory[16'hb6] <= 16'hf819;
            memory[16'hb7] <= 16'hf01d;
            memory[16'hb8] <= 16'h8e00;
            memory[16'hb9] <= 16'h8c01;
            memory[16'hba] <= 16'h4f02;
            memory[16'hbb] <= 16'h40fe;
            memory[16'hbc] <= 16'ha0b2;
            memory[16'hbd] <= 16'h7dff;
            memory[16'hbe] <= 16'h8cff;
            memory[16'hbf] <= 16'h44ff;
            memory[16'hc0] <= 16'ha0b2;
            memory[16'hc1] <= 16'h7dff;
            memory[16'hc2] <= 16'h7efe;
            memory[16'hc3] <= 16'hf100;
            memory[16'hc4] <= 16'h4ffe;
            memory[16'hc5] <= 16'hf819;
            memory[16'hc6] <= 16'hf01d;
				count1 <= 0;
				count2 <= 0;
				memory_ack1 <= 0;
				memory_ack2 <= 0;
				flag1 <= 1;
				flag2 <= 1;
			end
		else
			begin
				
				if (access1 == 1 && flag1 == 1) begin
					flag1 = 0;
					count1 = 7;
				end
				if (access2 == 1 && flag2 == 1) begin
					flag2 = 0;
					count2 = 7;
				end
				if(count1 == 0) begin
					flag1 = 1;
					memory_ack1 <= 0;
				end
				if(count2 == 0) begin	
					flag2 = 1;
					memory_ack2 <= 0;
				end
				if(count1 == 1) begin				
					if(readM1)outputData1 <= memory_block1;//(writeM2 & address1==address2)?data2:memory_block1;
					memory_ack1 <= 1;
				end
				if(count2 == 1) begin
					if(readM2)outputData2 <= memory_block2;
					if(writeM2)memory[address2] <= data2[15:0];							
					memory_ack2 <= 1;								  
				end
				if (count1 > 0) begin
					count1 <= (count1 - 1);
				end
				if (count2 > 0) begin
					count2 <= (count2 - 1);
				end
			end
endmodule