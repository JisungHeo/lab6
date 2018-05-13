module Cache (clk, reset_n, address, data);
	input clk;
	input reset_n;

	input [15:0] address;
	output [15:0] data;

	reg [76:0] cache [0:3][0:1];	
	wire tag[9:0];
	wire index[1:0];
	wire block[1:0];
	wire data[15:0];

	assign tag = address[15:6];
	assign index = address[5:4];
	assign block = address[3:2];

	getDataFromCache(tag,index,block,cache,data);	
endmodule

module getDataFromCache(tag, index, block, cache, data);
	input [76:0] cache [0:3][0:1];	//valid(1),LRU(1), dirty(1),tag(10),data(64)
	input tag[9:0];
	input index[1:0];
	input block[1:0];
	output data[15:0]; 
	
	wire valid;
	wire line[76:0];
	wire valid;
	wire tmp_data[15:0];

	findLineFromCache(tag,index,cache,line,valid);
	getDataFromLine(line, block,tmp_data);

	if(valid) begin
		assign data = tmp_data;	
	end
	else begin
		assign data = 16'h
zzzz;
	end
endmodule

//find line from cache
module findLineFromCache(tag,index,cache,line,valid);
	input [76:0] cache [0:3][0:1];	//valid(1),LRU(1), dirty(1),tag(10),data(64)
	input tag[9:0];
	input index[1:0];

	output line[76:0];
	output reg valid; //*****

	wire [76:0]line1;
	wire [76:0]line2;

	assign line1 = cache[index][0];
	assign line2 = cache[index][1];
	
	//line1 test
	if (line1[76])begin // if line1 valid
		if (line1[73:64] == tag) begin //tag match
			assign line = line1;
			assign valid = line1[76];
		end
	end

	//line2 test
	if (line2[76])begin // if line2 valid
		if (line2[73:64] == tag) begin //tag match
			assign line = line2;
			assign valid = line2[76];
		end
	end
	
endmodule

//Get Data from Line
module getDataFromLine(line, block, data);
	input line[76:0];
	input block[1:0];
	output data[15:0];

	wire index;
	assign index = 63 - (4'h0010*block_index); //find bit in line 
	assign data = line[index:index-4'b1111]; 
endmodule
