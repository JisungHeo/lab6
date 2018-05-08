//16bit-multiplexer 2 to 1
module sixteenBitMultiplexer2to1(zero, one, decider, result);
  input [15:0] zero;  
  input [15:0] one;
  output [15:0] result; 
  input decider;

  assign result = decider ? one : zero;
endmodule	