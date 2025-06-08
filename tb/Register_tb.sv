module register_clock_load_tb();  
  
  reg clk;  
  reg [15:0] in;  
  reg load;  
  wire [15:0] out;
  reg  [15:0] out_exp;
  reg [32:0] testvectors[0:147]; // array of testvectors
  reg [31:0] vectornum, errors, testnum;
  
  // Instantiate the module under test (DUT)  
  Register dut (  
    .clk(clk),  
    .in(in),  
    .load(load),  
    .out(out)  
  );  
  
  initial begin  
    clk = 1;
    in = 16'b0;load = 0; out_exp=16'b0; 
    $dumpfile("Register.vcd");  
    $readmemb("../tb/Register.tv", testvectors, 0, 147);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #4; // Do not have inputs changing right on clock edge
    load = testvectors[vectornum][16];
    in = testvectors[vectornum][32:17]; 
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    out_exp = testvectors[vectornum][15:0];
    if (testvectors[vectornum] === 33'bx) begin
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