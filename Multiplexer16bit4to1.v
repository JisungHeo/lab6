//16bit-multiplexer 4 to 1
module sixteenBitMultiplexer4to1(zero, one, two, three, decider, result);
  input [15:0] zero;
  input [15:0] one;
  input [15:0] two;
  input [15:0] three;
  output reg [15:0] result; 
  input [1:0] decider;

  always @(*) begin
    case (decider)
      2'b00: result = zero;
      2'b01: result = one;
      2'b10: result = two;
      2'b11: result = three;
      default: ;
    endcase
  end
endmodule
