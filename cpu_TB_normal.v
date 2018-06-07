
`timescale 1ns/1ns
`define PERIOD1 100
`define WORD_SIZE 16

`define NUM_TEST 56
`define TESTID_SIZE 5

module cpu_TB();
   reg reset_n;    // active-low RESET signal
   reg clk;        // clock signal   
   
   wire readM1;
   wire [`WORD_SIZE-1:0] address1;
   wire [63:0] data1;
   wire readM2;
   wire writeM2;
   wire [`WORD_SIZE-1:0] address2;
   wire [63:0] data2;

   // for debuging purpose
   wire [`WORD_SIZE-1:0] num_inst;      // number of instruction during execution
   wire [`WORD_SIZE-1:0] output_port;   // this will be used for a "WWD" instruction
   wire is_halted;            // set if the cpu is halted

	wire memory_ack1;
	wire memory_ack2;
   // instantiate the unit under test
   cpu UUT (clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted, memory_ack1, memory_ack2);
   Memory NUUT(!clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, memory_ack1, memory_ack2);

   // initialize inputs
   initial begin
      clk = 0;           // set initial clock value   
      
      reset_n = 1;       // generate a LOW pulse for reset_n
      #(`PERIOD1/4) reset_n = 0;
      #(`PERIOD1 + `PERIOD1/2) reset_n = 1;
   end

   // generate the clock
   always #(`PERIOD1/2)clk = ~clk;  // generates a clock (period = `PERIOD1)
      
   event testbench_finish;   // This event will finish the testbench.
   initial #(`PERIOD1*10000) -> testbench_finish; // Only 10,000 cycles are allowed.
      
   reg [`TESTID_SIZE*8-1:0] TestID[`NUM_TEST-1:0];
   reg [`WORD_SIZE-1:0] TestNumInst [`NUM_TEST-1:0];
   reg [`WORD_SIZE-1:0] TestAns[`NUM_TEST-1:0];
   reg TestPassed[`NUM_TEST-1:0];   
   
   reg [`WORD_SIZE-1:0] i;   
   reg [`WORD_SIZE-1:0] num_clock;
      
   always @ (posedge clk) begin 
      if (is_halted == 1) begin
         -> testbench_finish;
      end
      else begin
         num_clock = 0;
      end
   end   
   always @(testbench_finish) begin
      $display("cache test finished. provide cache hit ratio on cache module.");
      $finish;
   end

endmodule