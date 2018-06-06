/*module LRU_Register(address,read,write,reset_n, valid_wire, selection,LRU_vector);
	input [15:0]address;
	input read;
	input write;
	input reset_n;
	input [7:0] valid_wire;
	input selection;

	output reg [127:0] LRU_vector;
	wire [15:0] LRU [0:7];


	always @(reset_n) begin
	  {LRU[0], LRU[1], LRU[2], LRU[3], LRU[4], LRU[5], LRU[6], LRU[7]} = {{8{16'b0}}};
	end
	
	always @(*)begin
		LRU[0] = LRU_vector[15:0];
		LRU[1] = LRU_vector[31:16];
		LRU[2] = LRU_vector[47:32];
		LRU[3] = LRU_vector[63:48];
		LRU[4] = LRU_vector[79:64];
		LRU[5] = LRU_vector[95:80];
		LRU[6] = LRU_vector[111:96];
		LRU[7] = LRU_vector[127:112];
	end

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
    		LRU[selection] = 0;
	  end
	end
endmodule
*/