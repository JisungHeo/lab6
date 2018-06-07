module Cache (clk, reset_n, address, inputData, addressM, readM, writeM, dataM, read, write, readData, WriteEn, memory_ack);
	input clk;
	input reset_n;
	input [15:0] address;
	input [15:0] inputData;
	output reg [15:0] addressM;
	output readM;
	output writeM;
	inout [63:0] dataM;
	input read;
	input write;
	output [15:0] readData;
	output WriteEn;
	input memory_ack; // 1: memory access has been completed

	reg [15:0] outputData;
	reg readM;
	reg writeM;

	reg valid [0:7];
	reg [13:0] tag [0:7];
	reg [63:0] block [0:7];
	reg [15:0] LRU [0:7];
	reg dirty [0:7];

	reg [15:0] i;
	reg [15:0] j;

	always @(reset_n) begin
		{valid[0], valid[1], valid[2], valid[3], valid[4], valid[5], valid[6], valid[7]} = {{8{1'b0}}};
		{tag[0], tag[1], tag[2], tag[3], tag[4], tag[5], tag[6], tag[7]} = {{8{14'b0}}};
		{block[0], block[1], block[2], block[3], block[4], block[5], block[6], block[7]} = {{8{64'b0}}};
		{dirty[0], dirty[1], dirty[2], dirty[3], dirty[4], dirty[5], dirty[6], dirty[7]} = {{8{1'b0}}};
		outputData = 64'bz;
	end

	assign dataM = writeM ? outputData : {64{1'bz}}; // dataM

	wire [13:0] addr_tag;
	wire [1:0] addr_bo;

	assign addr_tag = address[15:2];
	assign addr_bo = address[1:0];

	wire valid_wire [0:7];
	wire [13:0] tag_wire [0:7];
	wire [63:0] block_wire [0:7];
	wire hit_wire [0:7];
	wire [15:0] LRU_wire [0:7];
	wire [63:0] block_bus;
	wire hit;

	assign valid_wire[0] = valid[0];
	assign valid_wire[1] = valid[1];
	assign valid_wire[2] = valid[2];
	assign valid_wire[3] = valid[3];
	assign valid_wire[4] = valid[4];
	assign valid_wire[5] = valid[5];
	assign valid_wire[6] = valid[6];
	assign valid_wire[7] = valid[7];

	assign block_wire[0] = block[0];
	assign block_wire[1] = block[1];
	assign block_wire[2] = block[2];
	assign block_wire[3] = block[3];
	assign block_wire[4] = block[4];
	assign block_wire[5] = block[5];
	assign block_wire[6] = block[6];
	assign block_wire[7] = block[7];

	assign tag_wire[0] = tag[0];
	assign tag_wire[1] = tag[1];
	assign tag_wire[2] = tag[2];
	assign tag_wire[3] = tag[3];
	assign tag_wire[4] = tag[4];
	assign tag_wire[5] = tag[5];
	assign tag_wire[6] = tag[6];
	assign tag_wire[7] = tag[7];

	assign hit_wire[0] = ((tag_wire[0] == addr_tag) && (valid_wire[0] == 1'b1));
	assign hit_wire[1] = ((tag_wire[1] == addr_tag) && (valid_wire[1] == 1'b1));
	assign hit_wire[2] = ((tag_wire[2] == addr_tag) && (valid_wire[2] == 1'b1));
	assign hit_wire[3] = ((tag_wire[3] == addr_tag) && (valid_wire[3] == 1'b1));
	assign hit_wire[4] = ((tag_wire[4] == addr_tag) && (valid_wire[4] == 1'b1));
	assign hit_wire[5] = ((tag_wire[5] == addr_tag) && (valid_wire[5] == 1'b1));
	assign hit_wire[6] = ((tag_wire[6] == addr_tag) && (valid_wire[6] == 1'b1));
	assign hit_wire[7] = ((tag_wire[7] == addr_tag) && (valid_wire[7] == 1'b1));

	assign block_bus = hit_wire[0] ? block_wire[0] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[1] ? block_wire[1] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[2] ? block_wire[2] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[3] ? block_wire[3] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[4] ? block_wire[4] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[5] ? block_wire[5] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[6] ? block_wire[6] : 64'hzzzzzzzzzzzzzzzz;
	assign block_bus = hit_wire[7] ? block_wire[7] : 64'hzzzzzzzzzzzzzzzz;


	wire [7:0] valid_vector = {valid_wire[7], valid_wire[6], valid_wire[5],valid_wire[4], 
				   valid_wire[3], valid_wire[2], valid_wire[1], valid_wire[0]};

	assign hit = (hit_wire[0] || hit_wire[1] || hit_wire[2] || hit_wire[3] ||
	 	      hit_wire[4] || hit_wire[5] || hit_wire[6] || hit_wire[7]);

	reg [2:0] hit_set;
	always @(*) begin
		if (hit_wire[0] == 1) begin
			hit_set = 0;
		end
		else if (hit_wire[1] == 1) begin
			hit_set = 1;
		end
		else if (hit_wire[2] == 1) begin
			hit_set = 2;
		end
		else if (hit_wire[3] == 1) begin
			hit_set = 3;
		end
		else if (hit_wire[4] == 1) begin
			hit_set = 4;
		end
		else if (hit_wire[5] == 1) begin
			hit_set = 5;
		end
		else if (hit_wire[6] == 1) begin
			hit_set = 6;
		end
		else if (hit_wire[7] == 1) begin
			hit_set = 7;
		end
	end

	sixteenBitMultiplexer4to1 mul4to1(block_bus[15:0], block_bus[31:16], block_bus[47:32], block_bus[63:48], addr_bo, readData);

//------------------------------------------eviction, stalling, memory read/write--------

	// write hit: no memory access
	// write miss with dirty eviction: 2 memory access

	// read hit: no memory access
	// read miss with dirty eviction: 2 memory access
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

	//if miss, always access memory
	wire memory_access;
	assign memory_access = ~hit;

	//What line to evict
	wire [2:0] eviction_set; //index of evicted line
	//eviction_selector Eviction(clk, reset_n, eviction_set, LRU_wire, valid_wire);
	wire dirty_eviction = ~hit && dirty[eviction_set];  //Whether evicted line should be wirte back?

	reg [3:0] condition; // 0: no cache access
			     // 1: read hit
			     // 2: read miss without dirty eviction
			     // 3: read miss with dirty eviction
			     // 4: write hit
			     // 5: write miss without dirty eviction
			     // 6: write miss with dirty eviction
	
	//Write back to Memory(drity) or Data read from Memory
	
	//LRU_Register LRU_update(address,read,write,reset_n, valid_vector, selection,LRU_vector);
	
	always @(address or inputData or read or write) begin
		if(write_hit == 1'b1) begin
			valid[hit_set] = 1;
			tag[hit_set] = addr_tag;
			//readM = 0;
			if(addr_bo == 2'b00)begin
				block[hit_set][15:0] = inputData;
			end
			else if(addr_bo == 2'b01) begin
				block[hit_set][31:16] = inputData;
			end
			else if(addr_bo == 2'b10) begin
				block[hit_set][47:32] = inputData;
			end
			else if(addr_bo == 2'b11) begin
				block[hit_set][63:48] = inputData;
			end
			condition = 0;
		end
	end
	
	always @(*) begin

		if(read_miss == 1'b1)begin
			//Read miss without dirty eviction
			WriteEn = 0;
			if (~dirty_eviction) begin
				condition = 2;
				addressM = address;
				readM = 1;
			end
			//Read miss with dirty
			else begin
				condition = 3;
				//write_back
				addressM = {tag[eviction_set], 2'b00};
				outputData = block[eviction_set];
				writeM = 1;
			end
		end
		else if(write_miss == 1'b1) begin
			//Write miss withoug dirty eviction
			WriteEn = 0;
			if (~dirty_eviction) begin
				condition = 5;
				addressM = address;
				readM = 1;
			end
			//Write miss with dirty
			else begin
				condition = 6;
				addressM = {tag[eviction_set], 2'b00};
				outputData = block[eviction_set];
				writeM = 1;
			end
		end
		
	end

	// 2: read miss without dirty eviction
	// 3: read miss with dirty eviction
	// 5: write miss without dirty eviction
	// 6: write miss with dirty eviction

	always @(posedge memory_ack) begin
		//read without eviction
		if (condition == 2) begin 
			valid[eviction_set] = 1;
			tag[eviction_set] = addr_tag;
			block[eviction_set] = dataM;
			//readM = 0;
			condition = 0;
			WriteEn = 1;
		end
		//eviciton read
		else if (condition == 3) begin 
			condition = 2;
			addressM = address;
			writeM = 0;
			readM = 1;
		end
		//write without eviction
		else if (condition == 5) begin 
			valid[eviction_set] = 1;
			tag[eviction_set] = addr_tag;
			block[eviction_set] = dataM;
			//readM = 0;
			if(addr_bo == 2'b00)begin
				block[eviction_set][15:0] = inputData;
			end
			else if(addr_bo == 2'b01) begin
				block[eviction_set][31:16] = inputData;
			end
			else if(addr_bo == 2'b10) begin
				block[eviction_set][47:32] = inputData;
			end
			else if(addr_bo == 2'b11) begin
				block[eviction_set][63:48] = inputData;
			end
			condition = 0;
			WriteEn = 1;
		end
		//write with eviction
		else if (condition == 6)begin //write
			condition = 5;
			addressM = address;
			writeM = 0;
			readM = 1;
		end
	end


	//LRU update
	always @(address) begin
	  if(read || write)begin
 	  	if(valid_wire[0] == 1)begin
      			LRU[0] = LRU[0] + 1;
    		end
    		if(valid_wire[1] == 1)begin
    		 	LRU[1] = LRU[1] + 1;
   		end
    		if(valid_wire[2] == 1)begin
    		 	LRU[2] = LRU[2] + 1;
   		end
    		if(valid_wire[3] == 1)begin
    		 	LRU[3] = LRU[3] + 1;
   		end
    		if(valid_wire[4] == 1)begin
    		 	LRU[4] = LRU[4] + 1;
   		end
    		if(valid_wire[5] == 1)begin
    		 	LRU[5] = LRU[5] + 1;
   		end
    		if(valid_wire[6] == 1)begin
    		 	LRU[6] = LRU[6] + 1;
   		end
    		if(valid_wire[7] == 1)begin
    		 	LRU[7] = LRU[7] + 1;
   		end
    		LRU[eviction_set] = 0;
	  end
	end

	//Select Eviciton set
	wire [7:0] valid_vector_tmp;
 	assign valid_vector_tmp = valid_vector + 1;
 	wire [7:0] vector_xor;
 	assign vector_xor =  valid_vector ^ valid_vector_tmp;
  	wire [2:0] idx;
  	assign idx = vector_xor[0]+vector_xor[1]+vector_xor[2] + vector_xor[3]+
                    vector_xor[4] + vector_xor[5] + vector_xor[6] + vector_xor[7] -1;

  	reg [2:0] selection;
 	reg [15:0] max;
  	assign eviction_set = selection;
	
 	always @(*)begin
  		  //eviction start
    		max = LRU[0];
  	  	selection = 0;
    		if(valid_vector == 8'b11111111)begin
      			if(LRU[1] > max )begin
      				max = LRU[1];
				selection = 3'b1;
      			end
      			if(LRU[2] > max)begin
      				max = LRU[2];
				selection = 3'b10;
      			end
      			if(LRU[3] > max)begin
        			max = LRU[3];
				selection = 3'b11;
      			end
      			if(LRU[4] > max)begin
        			max = LRU[4];
				selection = 3'b100;
      			end
      			if(LRU[5] > max)begin
				max = LRU[5];
      				selection = 3'b101;
      			end
      			if(LRU[6] > max)begin
				max = LRU[6];
        			selection = 3'b110;
      			end
      			if(LRU[7] > max)begin
				max = LRU[7];
        			selection = 3'b111;
      			end
    		end
    		else begin
    			selection = idx;
    		end
  	end

endmodule
