module bit_clock_load_tb();  
  
  reg clk;  
  reg in;  
  reg load;  
  wire out;
  reg out_exp;
  reg [2:0] testvectors[0:213]; // array of testvectors
  reg [2:0] temprow;
  reg [31:0] vectornum, errors, testnum;
  
  // Instantiate the module under test (DUT)  
  Bit dut (  
    .clk(clk),  
    .in(in),  
    .load(load),  
    .out(out)  
  );  
  
  initial begin  
    clk = 0;
    in = 0;load = 0; out_exp=0; 
    $dumpfile("Bit.vcd");  
    $dumpvars;
    $readmemb("../tb/Bit.tv", testvectors, 0, 213);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #4;
    in = testvectors[vectornum][2];
    load = testvectors[vectornum][1];
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    out_exp = testvectors[vectornum][0];
    if (testvectors[vectornum] === 3'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    #1; // Artificial Delay to let the DUT run.
    if (out !== out_exp) begin
      $display ("Test: %d", {testnum});
      $display ("CLK: %b", {clk});
      
      $display("Error: inputs = %b", {in, load} );
      $display("  ouputs = %b (%b expected)", out, out_exp);
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    testnum = testnum + 1;
  end

endmodule  