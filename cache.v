module Cache (clk, reset_n, address, inputData, readM, writeM, dataM, read, write, readData, WriteEn);
	input clk;
	input reset_n;
	input [15:0] address;
	input [15:0] inputData;
	output readM;
	output writeM;
	inout [63:0] dataM;
	input read;
	input write;
	output [15:0] readData;
	output WriteEn;

	reg readM;
	reg writeM;

	reg valid [0:1][0:3];
	reg FIFO [0:1][0:3];
	reg [11:0] tag [0:1][0:3];
	reg [63:0] data [0:1][0:3];
	
	reg [15:0] i;
	reg [15:0] j;

	always @(reset_n) begin
		for (i=0; i<=1; i=i+1) begin
			for (j=0; j<=3; j=j+1) begin
				valid[i][j] = 0;
			 	FIFO[i][j] = 0;
				tag[i][j] = 0;
				data[i][j] = 0;
			end
		end
	end

	assign dataM = (writeM ? {{48{1'bz}}, inputData} : {64{1'bz}});

	wire [11:0] addr_tag;
	wire [1:0] addr_idx;
	wire [1:0] addr_bo;

	assign addr_tag = address[15:4];
	assign addr_idx = address[3:2];
	assign addr_bo = address[1:0];

	wire valid1, valid2;
	wire FIFO1, FIFO2;	
	wire [11:0] tag1;
	wire [11:0] tag2;
	wire hit1, hit2;
	wire [63:0] data1;
	wire [63:0] data2;

	assign valid1 = valid[0][addr_idx];
	assign valid2 = valid[1][addr_idx];
	assign FIFO1 = FIFO[0][addr_idx];
	assign FIFO2 = FIFO[1][addr_idx];
	assign tag1 = tag[0][addr_idx];
	assign tag2 = tag[1][addr_idx];

	assign hit1 = ((tag1 == addr_tag) && (valid1 == 1'b1));
	assign hit2 = ((tag2 == addr_tag) && (valid2 == 1'b1));

	assign data1 = hit1 ? data[0][addr_idx] : {64{1'bz}};
	assign data2 = hit2 ? data[1][addr_idx] : {64{1'bz}};

	wire hit;
	assign hit = (hit1 || hit2);

	wire [63:0] readBlock;
	assign readBlock = hit1 ? data1 : data2;
	sixteenBitMultiplexer4to1 mul4to1(readBlock[15:0], readBlock[31:16], readBlock[47:32], readBlock[63:48], addr_bo, readData);

//------------------------------------------eviction, stalling, memory read/write--------

	// write hit 
	// write miss
	// read miss
	

	reg [15:0] count;
	reg WriteEn;
	always @(reset_n) begin
		count = 0;
		WriteEn = 1'b1;
		readM = 0;
		writeM = 0;
	end

	wire write_hit, write_miss, read_hit, read_miss;
	assign write_hit = ((write == 1'b1) && (hit == 1'b1));
	assign write_miss = ((write == 1'b1) && (hit == 1'b0));
	assign read_hit = ((read == 1'b1) && (hit == 1'b1));
	assign read_miss = ((read == 1'b1) && (hit == 1'b0));

	wire memory_access;
	assign memory_access = ((write == 1'b1) || (read == 1'b1 && hit == 1'b0));

	

	always @(*) begin
		if (memory_access == 1'b1) begin
			WriteEn = 1'b0;
			if (write_hit || write_miss) begin // write hit, write miss
				writeM = 1'b1;
			end
			else if (read_miss) begin // read miss
				readM = 1'b1;
			end
			count = 7;
		end
	end
	
	always @(posedge (count == 0)) begin
		WriteEn = 1'b1;
	end

	reg selection;
	always @(*) begin
		if (hit1 == 1'b1) begin
			selection = 0;
		end	
		else if (hit2 == 1'b1) begin
			selection = 1;
		end
		else if (valid1 == 1'b0) begin
			selection = 0;
		end
		else if (valid2 == 1'b0) begin
			selection = 1;
		end
		else if (FIFO1 == 1'b0) begin
			selection = 0;
		end
		else begin
			selection = 1;
		end
	end

	always @(posedge clk) begin
		
		if (count > 0) begin
			count = (count - 1);
		end else begin
			readM = 0;
			writeM = 0;
		end
		
		if (count == 6) begin
			if (write_hit) begin
				valid [selection][addr_idx] = 1'b1;
				FIFO [selection][addr_idx] = 1'b1; // if fresh, 1
				FIFO [~selection][addr_idx] = 1'b0;
				tag [selection][addr_idx] = addr_tag;
				data [selection][addr_idx] = inputData;
			end
		end
		
		else if (count == 0) begin
			if (read_miss) begin
				valid [selection][addr_idx] = 1'b1;
				FIFO [selection][addr_idx] = 1'b1; // if fresh, 1
				FIFO [~selection][addr_idx] = 1'b0;
				tag [selection][addr_idx] = addr_tag;
				data [selection][addr_idx] = dataM;
			end
		end	

		
	end
endmodule

