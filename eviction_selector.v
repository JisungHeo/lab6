/*module eviction_selector(clk, reset_n, eviction_set, LRU_wire, valid_wire);
  input clk;
  input reset_n;
  input [15:0] LRU_wire [7:0];
  input valid_wire [7:0];
  output [2:0] eviction_set;

  //valid to vector
  assign {valid_wire[7], valid_wire[6], valid_wire[5],
  valid_wire[4], valid_wire[3], valid_wire[2], valid_wire[1], valid_wire[0]}
  = {valid_vector[0], valid_vector[0], valid_vector[0], valid_vector[0], 
valid_vector[0], valid_vector[0], valid_vector[0], valid_vector[7]};

  //calculate index of value '0' nearast to index'0'
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
    max = LRU_wire[0];
    selection = 0;
    if(valid_vector == 8'b11111111)begin
      if(LRU_wire[1] > max )begin
        max = LRU_wire[1];
	selection = 3'b1;
      end
      if(LRU_wire[2] > max)begin
        max = LRU_wire[2];
	selection = 3'b10;
      end
      if(LRU_wire[3] > max)begin
        max = LRU_wire[3];
	selection = 3'b11;
      end
      if(LRU_wire[4] > max)begin
        max = LRU_wire[4];
	selection = 3'b100;
      end
      if(LRU_wire[5] > max)begin
	max = LRU_wire[5];
        selection = 3'b101;
      end
      if(LRU_wire[6] > max)begin
	max = LRU_wire[6];
        selection = 3'b110;
      end
      if(LRU_wire[7] > max)begin
	max = LRU_wire[7];
        selection = 3'b111;
      end
    end
    else begin
      selection = idx;
    end
  end
endmodule
*/
