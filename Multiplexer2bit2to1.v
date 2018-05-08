//2bit-multiplexer 2 to 1
module twoBitMultiplexer2to1(zero, one, decider, result);
  input [1:0] zero;  
  input [1:0] one;
  output [1:0] result; 
  input decider;

  assign result = decider ? one : zero;
endmodule	
