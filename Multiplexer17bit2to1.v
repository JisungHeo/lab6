//16bit-multiplexer 2 to 1
module seventeenBitMultiplexer2to1(zero, one, decider, result);
  input [16:0] zero;  
  input [16:0] one;
  output [16:0] result; 
  input decider;

  assign result = decider ? one : zero;
endmodule	